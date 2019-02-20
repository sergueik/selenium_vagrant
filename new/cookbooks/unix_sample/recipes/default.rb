log "Platform: #{node['platform']} platform family: #{node['platform_family']}" do
  level :info
end
# home-brewed 'platform_kind' hierarchy key - a better way probably exists
if node['platform'] == 'debian' || node['platform'] == 'ubuntu' || node['platform'] == 'centos' || node['platform'] == 'rhel'
  platform_kind = 'unix'
else
  platform_kind = 'windows'
end
debug = node['target_node']['debug']
if debug.nil?
  debug = false
end
log "Installing custom purge Maven repositories script version #{node['target_node'][platform_kind]['script_version']}" do
  level :info
end
if platform_kind == 'unix'
  include_recipe 'jenkins::master'

  # NOTE: do not include recipe 'java' due to its dependencies
  # Install jdk 8 on trusty through Vagrantfile shell script provisioner
  # include_recipe 'java'


  node.default['jenkins']['master']['version'] = '2.51'

  account_username = node['target_node'][platform_kind]['account_username']
  basedir = node['target_node'][platform_kind]['basedir']
  high_percent = node['target_node'][platform_kind]['high_percent'].to_i
  disk = node['target_node'][platform_kind]['disk']
  if disk.nil?
    disk = '/dev/sda1'
  end
  do_purge = node['target_node'][platform_kind]['do_purge']
  account_home = "/home/#{account_username}"
  scriptdir = "#{account_home}/scripts"
  purge_script = 'purge.sh'
  purge_script_template = purge_script.gsub(/.([^.]+)$/, '_\1.erb')
  begin
    # https://www.linuxnix.com/chef-get-node-attributes-or-values/
    # https://www.jvt.me/posts/2018/08/29/debugging-chef-shell/
    # # ohai filesystem/by_mount_dirpoint
    # # chef-shell
    # attributes_mode
    # chef:attributes > attributes[:filesystem]['by_device']['/dev/sda1']['percent_used'].to_i

    if node.attribute?('filesystem')
      fs           = node['filesystem']
      percent_used = fs['by_device'][disk]['percent_used'].to_i
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
    end
  rescue => e
    percent_used = 0
    log "failed to read filesystem object #{e.to_s}" do
      level :info
    end
  end
  if percent_used > high_percent
    directory "#{account_home}/scripts" do
      owner     account_username
      group     account_username
      mode      00755
      recursive true
      action    :create
    end

    # Create purge script
    directory scriptdir do
      action   :create
      owner    account_username
      group    account_username
      # wrong direction
      # notifies :create, "template[#{scriptdir}/#{purge_script}]", :before
    end

    template ("#{scriptdir}/#{purge_script}") do
      source  purge_script_template
      variables(
        :high_percent => high_percent,
        :do_purge     => do_purge,
        :basedir      => basedir,
        :ipaddress    => node['ipaddress'],
        )
      owner    account_username
      group    account_username
      notifies :run, 'bash[run purge script]', :delayed
      notifies :create, "directory[#{scriptdir}]", :before
      mode     00755
    end

    bash 'run purge script' do
      code <<-EOF
    pushd "#{account_home}/scripts"
    # assume it may need to be run from a specific directory
    ./#{purge_script}
      EOF
      ignore_failure true
      only_if { ::File.exists?("#{scriptdir}/#{purge_script}") }
    end
    # CAN duplicate?
    service 'stop jenkins' do
      action       :stop
      service_name 'jenkins'
      subscribes   :stop, 'bash[run purge script]', :before
    end	
    service 'start jenkins' do
      action       :start
      service_name 'jenkins'
      subscribes   :start, 'bash[run purge script]', :delayed
    end	
  else
    log "The disk usage #{percent_used}% is below threshold of #{high_percent}%." do
      level :info
    end
  end
else
  log "Installing custom purge Maven repositories Powershell script version #{node['target_node'][platform_kind]['script_version']}" do
    level :info
  end
  
  account_username = node['target_node'][platform_kind]['account_username']
  basedir = node['target_node'][platform_kind]['basedir']
  powershell_noop = node['target_node'][platform_kind]['powershell_noop']
  if powershell_noop.nil? || powershell_noop == '' # TODO: type check
    powershell_noop = '$true'
  else
    if [true, false].include? powershell_noop
      powershell_noop = ('$' + powershell_noop.to_s )
    else
      powershell_noop = '$true'
    end
  end
  high_percent = node['target_node'][platform_kind]['high_percent'].to_i
  drive_id = node['target_node']['drive_id']
  if drive_id.nil?
    drive_id = 'C:'
  end
  scriptdir = node['target_node'][platform_kind]['scriptdir']
  do_purge = node['target_node'][platform_kind]['do_purge']
  if do_purge.nil? || do_purge == '' # TODO: type check
    do_purge = '$false'
  else
    if [true, false].include? do_purge
      do_purge = ('$' + do_purge.to_s )
    else
      do_purge = '$false'
    end
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
  
    # chef-shell
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
  
    file 'c:\users\vagrant\Desktop\script1.ps1' do
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
  
    powershell_script 'Run purge script' do
      code <<-EOF
        write-host 'Explicitly measure disk space percentage used'
        & 'C:/users/vagrant/Desktop/show_percentage_used.ps1'
        $repository_dir = "#{basedir}\\.m2\\repository";
     
        $subdirs = @( get-childitem -path $repository_dir)
        write-host ('{0} subdirectories Currently in "{1}"' -f $subdirs.length, $repository_dir )
        write-host "Purge the repository in #{basedir}"
        
        ## purge ##
        & #{scriptdir}/purge.ps1
        ## purge done ## 
        # will show 0 subdirectories, if the purge was successful
        $subdirs = @( get-childitem -path $repository_dir)
        # use write-host to communicate the status to Chef 
        write-host ('{0} subdirectories remaining in "{1}"' -f $subdirs.length, $repository_dir )
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
  
end	
log 'Finished configuring Node.' do
  level :info
end


