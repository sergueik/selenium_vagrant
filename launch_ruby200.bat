@echo OFF 
REM NOTE to double the special characters.
set HTTP_PROXY=http://carnival%%5Csergueik:Rfrds6H%%40nm@proxy.carnival.com:8080
REM ERROR:  While executing gem ... (Net::HTTPServerException)
REM     407 "Proxy Authentication Required ( Forefront TMG requires authorization to fulfill the request. Access to the Web Proxy filter is denied.  )"
pushd %~dp0
PATH=%CD%\bin;%PATH%;
REM TODO check if it is there
call DevKit\devkitvars.bat
REM TODO check if the gems are already installed
for %%. in (rspec chefspec fauxhai test-kitchen chef-vault) do call gem install %%. --no-rdoc --no-ri
REM to workaround for SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B
REM http://stackoverflow.com/questions/19150017/ssl-error-when-installing-rubygems-unable-to-pull-data-from-https-rubygems-o
REM gem sources -a http://rubygems.org
REM call gem.bat sources -q -a http://rubygems.org
REM NOTE The quiet flag still does not make gem.bat pass-through 
goto :EOF 
