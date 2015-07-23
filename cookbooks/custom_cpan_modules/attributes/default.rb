default['custom_cpan_modules']['packages'] = %w/
build-essential
libssl-dev
libxml2-dev
libxslt1-dev
libexpat1-dev
/
# TODO : clean modules cpanm would be able to figure out on its own
default['custom_cpan_modules']['modules'] = %w/
Carp::Assert
Archive::Zip
Test::Deep
Test::Fatal
Test::NoWarnings
Test::Warn
Time::Mock
Try::Tiny
Socket
IO::Socket
namespace::clean
Sub::Install
Test::LongString
Test::LWP::UserAgent
List::MoreUtils
File::Which
Moo
Moo::Role
Selenium::Remote::Driver
CGI 
Time::HiRes 
Date::Parse 
Date::Calc
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

LWP::Simple
LWP::UserAgent 
Net::SSLeay
IO::Socket::SSL
SOAP::Lite

MIME::Lite

XML::Parser
XML::Simple

HTML::LinkExtor

Protocol::WebSocket::URL
/



