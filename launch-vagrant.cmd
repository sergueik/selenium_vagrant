@echo OFF 
cd %~dp0
set VAGRANT_HOME=%CD%
set VAGRANT_USE_PROXY=1
set PATH=%VAGRANT_HOME%\bin;%VAGRANT_HOME%\embedded\bin;%PATH%
set HTTP_PROXY=http://sergueik:password@proxy.carnival.com:8080

goto :EOF
