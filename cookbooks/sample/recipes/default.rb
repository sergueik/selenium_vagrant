log 'Starting Powershell script' do
  level :info
end


powershell 'Hello World from PowerShell scripts' do
  code <<-EOH
  write-output 'This is a test'
   EOH
end

# This may fail when the user is unauthorized  to registry access therefore needs to be somehow excluded from lone chef-solo runs:
# STDERR: Set-ExecutionPolicy : Access to the registry key 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell' is denied.
# At C:\Users\sergueik\AppData\Local\Temp\chef-script20150225-10904-tugust.ps1:2 char:2
powershell "Enable execution of PowerShell scripts." do
  code <<-EOH
 Set-ExecutionPolicy -ExecutionPolicy remotesigned -force -scope LocalMachine
 EOH
end

powershell "This will be a failing script" do
  code <<-EOH
 try {
  Set-Executiowzsaewfd43w5r
 } catch [Exception] { 
 Write-Output (($_.Exception.Message) -split "`n")[0]
}
 EOH
end

powershell 'This will attempt to show  message box and probably fail' do
  code <<-EOH
@('System.Drawing','System.Windows.Forms') |  foreach-object {   [void] [System.Reflection.Assembly]::LoadWithPartialName($_) } 
 [System.Windows.Forms.MessageBox]::Show('this is a test' )
 EOH
end

Begin output of 
C:\Windows\system32\WindowsPowershell\v1.\powershell.exe -NoLogo -NonInteractive -NoProfile -ExecutionPolicy RemoteSigned -InputFormat None -Command "C:\Users\vagrant\AppData\Local\Temp\chef-script20150225-3912-23ife0.ps1" 
# ----
# STDOUT: 
# STDERR: Exception calling "Show" with "1" argument(s): 
# Showing a modal dialog box or form when 
# the application is not running in UserInteractive mode is not a valid operation. 
# Specify the ServiceNotification or DefaultDesktopOnly style 
# to display a notification from a service application.
# 


#
#windows_batch "Enable execution of PowerShell scripts for x86" do
#  code <<-EOH
# %windir%/syswow64/WindowsPowerShell/v1.0/powershell -command "&{Set-ExecutionPolicy -ExecutionPolicy remotesigned -force -scope LocalMachine}"
# EOH
#end


log 'Complete Powershell script' do
  level :info
end
