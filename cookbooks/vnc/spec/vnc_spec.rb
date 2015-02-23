require 'chefspec'

# https://github.com/sethvargo/chefspec

describe 'vnc::default' do
  before(:each) do
    @package_name = 'tightvncserver'
    @service_name = 'vncserver'
    @account_usergroup  = 'vncuser'
    @account_username = 'vncuser'
    @account_home     = "/home/#{@account_username}";
    @server_initscript = '/etc/init.d/vncserver' 
    @server_config_directory = "/home/#{@account_username}/.vnc" 
    @server_password  = "#{@account_home}/.vnc/passwd";
    stub_data_bag(kind_of(String)).and_return([])
    stub_data_bag_item(kind_of(String), kind_of(Object)).and_return($nil)
    # how to stub ChefVault::Item.load ? 

  end
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }
 
  it 'creates the user' do
    expect(chef_run).to create_user( @account_username )
  end

  it 'adds the user to sudoers' do
    expect(chef_run).to modify_group( 'sudo' )
  end

  it 'installs service package' do
    expect(chef_run).to install_package( @package_name )
  end

  it 'creates service directory' do
    expect(chef_run).to create_directory( @server_config_directory ).with(
      user:   @account_username ,
      group:  @account_usergroup
    )
  end

  it 'writes service password file' do
    expect(chef_run).to create_file( @server_password ) .with(
      user:   @account_username ,
      group:  @account_usergroup,
      mode: 00600
    )
  end

  it 'does not notifiy service' do
  resource = chef_run.cookbook_file(@server_initscript)
  expect(resource).to_not notify("service[#{@service_name}]").to(:restart).delayed
 end 
  it 'generates a valid init script configuration' do
    expect(chef_run).to render_file(@server_initscript).with_content(/#!\s*\/bin\/(ba)?sh.*/)
  end 
end


