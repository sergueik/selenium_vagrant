require 'chefspec'
require 'chef-vault'

# https://github.com/sethvargo/chefspec

describe 'databag_manager::default' do

  before(:each) do
    @databag_manager_name = 'spec-vault'
    @seedvalue = 12345
    @dbweb = 'xxxx'
    @dbdwh = 'yyy'
    @rpm_version = 42
    stub_data_bag(@databag_manager_name).and_return({'seedvalue' => nil, 'dbweb-enc' =>nil })

    stub_data_bag_item("spec_tomcat_app_config",'hal-giftsf-server').and_return({'spec' => { 'application' => { 'user'=> nil, 'group'=> nil, 'rpm_version'=> @rpm_version } } })
  end


  let(:chef_run) do
    # Stub any calls to Environment
    ChefSpec::SoloRunner.new do |node|
      env = Chef::Environment.new
      env.name 'spec'
      allow(node).to receive(:chef_environment).and_return(env.name)
      allow(Chef::Environment).to receive(:load).and_return(env)

      # Stub any calls to ChefVault
      #   chefvault_item_double = double("ChefVault::Item")
      # expect does not get fired
      # expect(chefvault_item_double).to receive(:load).with(@databag_manager_name,'seedvalue').and_return({"seedvalue"=>nil})
      allow(ChefVault::Item).to receive(:load).with(@databag_manager_name,'seedvalue').and_return({"seedvalue"=>@seedvalue})
      allow(ChefVault::Item).to receive(:load).with(@databag_manager_name,'dbweb-enc').and_return({"dbweb"=>@dbweb})
      allow(ChefVault::Item).to receive(:load).with(@databag_manager_name,'dbdwh').and_return({"dbdwh"=>@dbdwh})
    end.converge(described_recipe)
  end

  # TODO expectation to not receive the exception Chef::Exceptions::InvalidDataBagPath:
  it 'finds seedvalue data in the vault databag' do
    expect(chef_run).to write_log( /#{@seedvalue}/ )
  end

  it 'finds dbdwh data in the vault databag' do
    expect(chef_run).to write_log( /#{@dbdwh}/ )
  end

  it 'finds dbweb data in the vault databag' do
    expect(chef_run).to write_log( /#{@dbweb}/ )
  end

  it 'finds rpm_version data in the tomcat_app_config databag' do
    expect(chef_run).to write_log( /#{@rpm_version}/ )
  end


end

