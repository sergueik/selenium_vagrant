log 'Starting Powershell script' do
  level :info
end

# This will fail when the user is unauthorized  to registry access:
# STDERR: Set-ExecutionPolicy : Access to the registry key 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell' is denied.
# At C:\Users\sergueik\AppData\Local\Temp\chef-script20150225-10904-tugust.ps1:2 char:2

powershell "Enable execution of PowerShell scripts" do
  code <<-EOH
 write-output 'This is a test'
 EOH
end

powershell "Enable execution of PowerShell scripts for x86" do
  code <<-EOH
 Set-ExecutionPolicy -ExecutionPolicy remotesigned -force -scope LocalMachine
 EOH
end

powershell "This will a failing script" do
  code <<-EOH
 Set-Executiowzsaewfd43w5r
 EOH
end

#
#windows_batch "Enable execution of PowerShell scripts for x86" do
#  code <<-EOH
# %windir%/syswow64/WindowsPowerShell/v1.0/powershell -command "&{Set-ExecutionPolicy -ExecutionPolicy remotesigned -force -scope LocalMachine}"
# EOH
#end


log 'Complete Powershell script' do
  level :info
end
