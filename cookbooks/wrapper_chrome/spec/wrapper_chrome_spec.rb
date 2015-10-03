require 'chefspec'
require 'json'

# https://github.com/sethvargo/chefspec

describe 'wrapper_chrome::default' do
  before(:each) do
    @track = 'stable';
  end
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }
 
  it 'generates a valid init script configuration' do
    expect(chef_run).to install_package("google-chrome-#{@track}")
  end

end


