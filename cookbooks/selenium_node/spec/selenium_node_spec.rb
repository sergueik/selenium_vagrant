require 'chefspec'
require 'json'

# https://github.com/sethvargo/chefspec

describe 'selenium_node::default' do
  before(:each) do
    @account_username = 'vncuser';
    @account_home     = "/home/#{@account_username}";
    @json_file =  "#{@account_home}/selenium/node.json";
  end
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }
 
# https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/satisfy-matcher

  it 'generates a valid init script configuration' do
    expect(chef_run).to render_file(@json_file).with_content(/.*/)
  end

  it 'generates a valid json configuration' do
    expect(chef_run).to render_file(@json_file).with_content(satisfy { |content|
    JSON.parse(content) rescue nil })
  end 
end


