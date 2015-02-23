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
    expect(chef_run).to render_file(@json_file).with_content(satisfy do |content| 
begin
parsed_content = JSON.parse(content) 
rescue 
nil
end

end
 )
  end 
# https://github.com/opscode-cookbooks/chef-vault
# http://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&ved=0CCAQFjAA&url=http%3A%2F%2Fapidock.com%2Fruby%2FString%2Fstart_with%253F&ei=cqDrVNGSIcLvoATK-IKIDw&usg=AFQjCNFyA3--YZzUgNZmbQsSnIIAgXoY0g&sig2=hYh25nwPSO-umllt4V6hlA&bvm=bv.86475890,d.cGU
end


