log 'installing CPAN modules' do
  level :info
end

# http://www.perlmonks.org/?node_id=1025272
required_modules = %w/HTML::Parser CGI Time::HiRes URI::Escape Data::Dumper MIME:Base64/
required_modules = %w/
CGI 
Time::HiRes 
Date::Parse 
IO::File POSIX 
Storable 
Module::Install 
Compress::Zlib 
Time::ParseDate 
List::Util 
JSON 
HTML::Entities 
Carp 
File::Temp 
Encode
SOAP::Lite
XML::Simple
MIME::Lite
Encode 
LWP::UserAgent Date::Calc /

obsolete_modules = %w/HTML::LinkExt/
# Finding HTML::LinkExt () on mirror http://www.cpan.org failed.
# XML::Parser XML::Simple
# need to addsome packages
required_modules.each do |cpan_module_name|
cpan_module cpan_module_name
end

# Errno::ENOENT
# -------------
# No such file or directory - /usr/local/bin/cpanm
log 'Finished installing CPAN modules.' do
  level :info
end





