log "Installing custom purge Maven repositories Powershell script version #{node['target_node']['script_version']}" do
  level :info
end

debug = node['target_node']['debug']
if debug.nil?
  debug = false
end

account_username = node['target_node']['account_username']
basedir = node['target_node']['basedir']
powershell_noop = node['target_node']['powershell_noop']
if powershell_noop.nil? || powershell_noop == '' # TODO: type check
  powershell_noop = '$true'
end
high_percent = node['target_node']['high_percent'].to_i
drive_id = node['target_node']['drive_id']
if drive_id.nil?
  drive_id = 'C:'
end
scriptdir = node['target_node']['scriptdir']
do_purge = node['target_node']['do_purge']
if do_purge.nil? || do_purge == '' # TODO: type check
  do_purge = '$true'
end
account_home = "/home/#{account_username}"
purge_script = 'purge.ps1'

batch 'Enable execution of PowerShell scripts for 32 bit' do
  code <<-EOF
    REM TODO: branch for 64/32 Windows versions, for 32-bit Chef DK
    if /I "%PROCESSOR_ARCHITECTURE%" EQU "AMD64" %windir%/syswow64/WindowsPowerShell/v1.0/powershell -command "&{Set-ExecutionPolicy -ExecutionPolicy remotesigned -force -scope LocalMachine}"
    if /I not "%PROCESSOR_ARCHITECTURE%" EQU "AMD64"  %windir%/system32/WindowsPowerShell/v1.0/powershell -command "&{Set-ExecutionPolicy -ExecutionPolicy remotesigned -force -scope LocalMachine}"
  EOF
end

begin

  # # chef-shell
  # attributes_mode
  # chef:attributes > attributes[:filesystem]['C:']['percent_used'].to_i

  if node.attribute?('filesystem')
    fs           = node['filesystem']
    percent_used = fs[drive_id]['percent_used'].to_i
    scratch_obj  = fs.to_s
    if debug
      log "Filesystem object dump: #{scratch_obj}" do
        level :info
      end
    end
    log "Disk percent_used: #{percent_used}" do
      level :info
    end
  else
    log 'Warning: chef attribute filesysem is not available' do
      level :info
    end
    # set dummy valuee 
    percent_used = 1
  end
end

if percent_used > high_percent
  directory scriptdir do
    action :create
    rights :read, 'Everyone'
    rights :full_control, 'Administrators', :applies_to_children => true
  end
  
  # https://sweetcode.io/introduction-chef-windows-how-write-simple-cookbook/
  
  file 'c:\users\vagrant\desktop\script1.ps1' do
    content <<-EOF
      write-host "This is a test file"
    EOF
    action :create
  end
  
  template 'C:/users/vagrant/Desktop/show_percentage_used.ps1' do
    source 'show_percentage_used_ps1.erb'
    variables(
      :high_percent => high_percent,
      :basedir      => basedir,
      :drive_id     => drive_id,
    )
  end
  
  template "#{scriptdir}/purge.ps1" do
    source 'purge_ps1.erb'
    variables(
      :do_purge           => do_purge,
      :basedir            => basedir,
      :powershell_noop    => powershell_noop,
    )
    notifies :create, "directory[#{scriptdir}]", :before
    notifies :run, 'powershell_script[Run purge script]', :delayed
  end
  
  # TODO: test powershell_out
  powershell_script 'Run purge script' do
    code <<-EOF
      & 'C:/users/vagrant/Desktop/show_percentage_used.ps1'
      & #{scriptdir}/purge.ps1
    EOF
  end
  
  # TODO: test powershell_out
  powershell_script 'Show message box' do
    code <<-EOF
    @('System.Drawing','System.Windows.Forms') | foreach-object {
      [void] [System.Reflection.Assembly]::LoadWithPartialName($_)
    }
    try {
      [System.Windows.Forms.MessageBox]::Show('this is a test' )
    } catch [Exception] {
      # simply ignore for now
    }
    exit 0
    EOF
  end
else
  log "The disk usage #{percent_used}% is below threshold of #{high_percent}%." do
    level :info
  end
end

log 'Complete Powershell script' do
  level :info
end
