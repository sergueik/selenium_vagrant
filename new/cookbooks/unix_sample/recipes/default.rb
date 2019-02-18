log "Installing custom purge Maven repositories script version #{node['target_node']['script_version']}" do
  level :info
end
include_recipe 'jenkins::master'

# NOTE: do not include recipe 'java' due to its dependencies
# Install jdk 8 on trusty through Vagrantfile shell script provisioner
# include_recipe 'java'

debug = node['target_node']['debug']
if debug.nil?
  debug = false
end

node.default['jenkins']['master']['version'] = '2.51'

account_username = node['target_node']['account_username']
basedir = node['target_node']['basedir']
high_percent = node['target_node']['high_percent'].to_i
disk = node['target_node']['disk']
if disk.nil?
  disk = '/dev/sda1'
end
do_purge = node['target_node']['do_purge']
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
log 'Finished configuring Node.' do
  level :info
end


