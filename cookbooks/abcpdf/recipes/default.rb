log 'installing abcpdf license' do
  level :info
end

# Define variables for attributes
temp_dir='C:\\Users\\vagrant\\AppData\\Local\\Temp'


cookbook_file "#{temp_dir}\\abcpdf_license.txt" do
  source 'abcpdf_license.txt'
  path "#{temp_dir}\\abcpdf_license.txt"
  action :create_if_missing
end

# TODO: smoke test 

log 'Finished installing abcpdf license.' do
  level :info
end





