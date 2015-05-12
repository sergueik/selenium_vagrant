log 'installing CPAN modules' do
  level :info
end

node['custom_cpan_modules']['packages'].each do |perl_pkg|
    package perl_pkg
end

node['custom_cpan_modules']['modules'].each do |cpan_module_name|
 cpan_module cpan_module_name
end

log 'Finished installing CPAN modules.' do
  level :info
end





