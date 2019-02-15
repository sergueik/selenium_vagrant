log "Installing custom purge scripts version #{node['target_node']['script_version']}" do
  level :info
end

account_username = node['target_node']['account_username']
basedir = node['target_node']['basedir']
high_percent = node['target_node']['high_percent'].to_i
mount_dir = node['target_node']['mount_dir']
disk = node['target_node']['disk']
if disk.nil?
  disk = '/dev/sda1'
end
do_purge = node['target_node']['do_purge']
account_home = "/home/#{account_username}"
purge_script = 'purge.sh'
debug = false

begin
  # https://www.linuxnix.com/chef-get-node-attributes-or-values/
  # https://www.jvt.me/posts/2018/08/29/debugging-chef-shell/
  # # ohai filesystem/by_mount_dirpoint
  # # chef-shell
  # attributes_mode
  # chef:attributes > attributes[:filesystem]['by_device']['/dev/sda1']['percent_used'].to_i

  if node.attribute?('filesystem')
    log "Attribute filesysem is available" do
      level :info
    end
    fs = node['filesystem']
    percent_used = fs['by_device'][disk]['percent_used'].to_i
    scratch_obj = fs.to_s
  else
    log "Attribute filesysem is not available" do
      level :info
    end
  end
  if debug
    log "Filesystem object dump: #{scratch_obj}" do
      level :info
    end
  end
  log "Disk percent_used: #{percent_used}" do
    level :info
  end
rescue => e
  percent_used = 0
  log "failed to read filesystem object #{e.to_s}" do
    level :info
  end
end
if percent_used > high_percent
  directory "#{account_home}/scripts" do
    owner account_username
    group account_username
    mode  00755
    recursive true
    action :create
  end
  # Create purge script
  template ("#{account_home}/scripts/#{purge_script}") do
    source 'purge.erb'
    variables(
      :high_percent => high_percent,
      :mount_dir    => mount_dir,
      :do_purge     => do_purge,
      :basedir      => basedir,
      :ipaddress    => node['ipaddress'],
      )
    owner account_username
    group account_username
    notifies :run, 'bash[run purge script]', :delayed
    mode 00755
  end

  bash 'run purge script' do
      code <<-EOF
  pushd "#{account_home}/scripts"
  # assume it may need to be run from a specific directory
  ./#{purge_script}
      EOF
      ignore_failure true
      only_if { ::File.exists?("#{account_home}/scripts/#{purge_script}") }
  end
else
log "The disk usage #{percent_used} is < {high_percent}." do
  level :info
end
end
log 'Finished configuring Node.' do
  level :info
end


