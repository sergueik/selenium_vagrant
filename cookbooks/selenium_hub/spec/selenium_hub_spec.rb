require 'chefspec'
require 'json'

# https://github.com/sethvargo/chefspec
# https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/satisfy-matcher

describe 'selenium_hub::default' do
  before(:each) do
    @account_username = 'vncuser'
    @account_home     = "/home/#{@account_username}"
    @selenium_home    = "#{@account_home}/selenium"
    @json_file        = "#{@selenium_home}/node.json"
    @service_name     = 'selenium_hub'
    @init_script      = "/etc/init.d/#{@service_name}"
  end

  let(:chef_run) do |node|
    ChefSpec::SoloRunner.converge(described_recipe)
  end

  it 'creates selenium directory' do
    expect(chef_run).to create_directory(@selenium_home) 
  end

  it 'starts selenium hub service' do
    expect(chef_run).to start_service(@service_name)
  end

  it 'generates init script configuration' do
    expect(chef_run).to render_file(@init_script)
  end

  xit 'generates a valid json configuration' do
    expect(chef_run).to render_file(@json_file).with_content(satisfy { |content|
    JSON.parse(content) rescue nil })
  end 
end
