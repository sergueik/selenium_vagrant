log 'Starting Powershell script' do
  level :info
end

batch "Enable execution of PowerShell scripts for x86" do
  code <<-EOF
   REM TODO: branch for 64/32 Windows versions
   REM %windir%/syswow64/WindowsPowerShell/v1.0/powershell -command "&{Set-ExecutionPolicy -ExecutionPolicy remotesigned -force -scope LocalMachine}"
   %windir%/system32/WindowsPowerShell/v1.0/powershell -command "&{Set-ExecutionPolicy -ExecutionPolicy remotesigned -force -scope LocalMachine}"
  EOF
end
powershell_out 'Hello World' do
  code <<-EOF
    write-host 'This is a test'
  EOF
end
# https://sweetcode.io/introduction-chef-windows-how-write-simple-cookbook/
file 'c:\users\vagrant\desktop\script1.ps1' do
 content <<-EOF 
    write-host "This is a test file"
 EOF
 action :create
end 

template 'C:/users/vagrant/Desktop/script2.ps1' do 
  source 'script2_ps1.erb'
end 

# TODO:  test powershell_out
powershell_script 'Show message box' do
  code <<-EOF
  @('System.Drawing','System.Windows.Forms') | foreach-object { 
    [void] [System.Reflection.Assembly]::LoadWithPartialName($_) 
  }
  try {
    [System.Windows.Forms.MessageBox]::Show('this is a test' )
  } catch [Exception] {
    # simply ignore for now
  }
  exit 0
  EOF
end

log 'Complete Powershell script' do
  level :info
end
