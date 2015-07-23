require 'chefspec'

describe 'wrapper_vnc::default' do
  before(:each) do
    @user = 'vncuser'; # not used
  end
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }
 
  it 'installs vnc' do
    expect(chef_run).to install_package("vnc")
  end

end


