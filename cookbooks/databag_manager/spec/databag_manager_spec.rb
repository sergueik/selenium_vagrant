require 'chefspec'
require 'chef-vault'

# https://github.com/sethvargo/chefspec

describe 'databag_manager::default' do

  before(:each) do
    @environment = 'spec'
    @vault_databag = 'spec-vault'
    @seedvalue = 12345
    @dbweb = {
        'dbweb_username' => 'xxx_user' ,
        'dbweb_password' => 'password'
    }
    @dbdwh = {
        'dbdwh_username' => nil ,
        'dbdwh_password' => nil 
    }
    @polar = {
        'hal_username' => nil ,
        'hal_password' => nil ,
        'sbn_username'=>nil,
        'sbn_password'=>nil
    }
    @rpm_version = '42'
    @package_name = @application_server = 'hal-giftsf-server'
    @server_config_databag = 'spec_tomcat_app_config'
    @service_conf_name =  "/etc/#{@application_server}/chip.conf"
    @user_account = nil
    @group_account = nil
    @http_port = nil
    @https_port = nil
    @jmx_port = nil
    @ajp_port = nil
    @shutdown_port = nil
    @Xmx = nil
    @Xms = nil
    @PermSize = nil
    @MaxPermSize = nil
    @setenv_file = "/etc/#{@application_server}/setenv.sh"
    @logging_base_dir = nil
    @keystore_location  = nil
    @keystore_password = nil
    @application_site =  'hollandamerica'
    @nginx_server_block = "/etc/nginx/sites-available/#{@application_site}"
    stub_data_bag(@vault_databag).and_return(
        {
            'seedvalue' => nil,
            'dbweb-enc' => nil
        }
    )
    stub_data_bag_item(@server_config_databag, @application_server).and_return(
        {
            'spec' => {
                'application' => {
                    'user' => @user_account,
                    'group' => @group_account,
                    'rpm_version' => @rpm_version,
                    'ports' => {
                        'http' => @http_port,
                        'http' => @http_port,
                        'https' => @https_port,
                        'jmx' => @http_port,
                        'ajp' => @ajp_port,
                        'shutdown' => @shutdown_port
                    },
                    'spring_profiles_active' => true,
                    'memory' => {
                        'Xms' => @Xms,
                        'Xmx' => @Xmx,
                        'PermSize' => @PermSize,
                        'MaxPermSize' => @MaxPermSize
                    },
                    'host_config' => nil,
			'cms' => {'url'=>nil },
			'dbweb' => {'url'=>nil},
			'dbdwh' => {'url'=>nil, 'driverClassName'=>nil},

			'polar' => {
                                  'sbn' => {
                                              'url'=>nil
                                             }, 
                                    'hal'=>{'url'=>nil}, 
                                    'load_cabin_metadata'=>nil , 
                                    'cabin_metadata_location' =>nil
                                   }

                }
            }
        }
    )
  end


  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|

      # Stub any calls to Environment
      env = Chef::Environment.new
      env.name @environment
      allow(node).to receive(:chef_environment).and_return(env.name)
      allow(Chef::Environment).to receive(:load).and_return(env)

      # Stub any calls to ChefVault
      # NOTE: expect does not get work
      allow(ChefVault::Item).to receive(:load).with(@vault_databag, 'seedvalue').and_return(
                                    {
                                        'seedvalue' => @seedvalue
                                    })
      allow(ChefVault::Item).to receive(:load).with(@vault_databag, 'dbweb-enc').and_return( @dbweb ) 
                                #    {
                                #       'dbdweb' => @dbweb
                                #    })
      allow(ChefVault::Item).to receive(:load).with(@vault_databag, 'dbdwh').and_return(
                                    {
                                        'dbdwh' => @dbdwh
                                    })
      allow(ChefVault::Item).to receive(:load).with(@vault_databag, 'polar').and_return(
                                    {
                                        'polar' => @polar
                                    })

      # Stub node parameters hidden in erb template
      node.set[:keystore][:location]  = @keystore_location 
      node.set[:keystore][:password]  = @keystore_password
      node.set[:logging_base_dir]  = @logging_base_dir   

    end.converge(described_recipe)
  end

  # TODO code expectation to not receive the exception Chef::Exceptions::InvalidDataBagPath
  it 'reads configuration data in the vault databag' do
    expect(chef_run).to write_log(/#{@seedvalue}/)
    expect(chef_run).to write_log(/#{@dbdwh}/)
    expect(chef_run).to write_log(/#{@dbweb}/)
  end

  it 'reads application data in the tomcat_app_config databag' do
    expect(chef_run).to write_log(/#{@user_account}/)
    expect(chef_run).to write_log(/#{@group_account}/)
    expect(chef_run).to write_log(/#{@rpm_version}/)
  end

  it 'installs service package' do
    expect(chef_run).to install_yum_package(@package_name)
  end

  xit 'writes setenv configuration file' do
    expect(chef_run).to create_file(@setenv_file).with(
                            user: @user_account,
                            group: @group_account,
                            mode: 00644
                        )
  end

  it 'generates a valid setenv content' do
    expect(chef_run).to render_file(@setenv_file).with_content(/^JAVA_OPTS=.*/)
  end

  it 'notifies service' do
    resource = chef_run.file(@setenv_file)
    expect(resource).to_not notify("service['#{@application_server}']").to(:restart).delayed
  end

  it 'notifies nginx' do
    resource = chef_run.file(@nginx_server_block )
    expect(resource).to_not notify('service[nginx]').to(:restart).delayed
  end
  # https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/satisfy-matcher

  it 'generates a valid init script configuration' do
    expect(chef_run).to render_file(@service_conf_name).with_content(/.*/)
  end

  it 'generates a valid json configuration' do
    expect(chef_run).to render_file(@service_conf_name).with_content(satisfy { |content|
 pat =/
  ^      # match start of line
  \s*    # match zero or more spaces
  $      # match end-of-line
/x

pieces = content.split(pat)

config = pieces[3]
config.gsub!('polar','')
Chef::Log.info(config)
STDERR.puts config
# content.scan( /^[\s#]*$(\{[^}]*\})^[\s#]*$/).last.first
    JSON.parse(config) rescue nil })
  end 

end

# http://stackoverflow.com/questions/21808145/mocking-out-file-contents-in-chefspec
