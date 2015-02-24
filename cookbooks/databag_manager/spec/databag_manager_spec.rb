require 'chefspec'
require 'chef-vault'

# https://github.com/sethvargo/chefspec

describe 'databag_manager::default' do

  before(:each) do
    @environment = 'spec'
    @vault_databag = 'spec-vault'
    @seedvalue = 12345
    @dbweb = 'xxxx'
    @dbdwh = 'yyy'
    @rpm_version = '42'
    @application_server = 'hal-giftsf-server'
    @server_config_databag = 'spec_tomcat_app_config'
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
      allow(ChefVault::Item).to receive(:load).with(@vault_databag, 'dbweb-enc').and_return(
                                    {
                                        'dbweb' => @dbweb
                                    })
      allow(ChefVault::Item).to receive(:load).with(@vault_databag, 'dbdwh').and_return(
                                    {
                                        'dbdwh' => @dbdwh
                                    })

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

end
