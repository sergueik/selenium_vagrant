# Change the Network Category to Private for Powershell remoting into Windows vagrant box
# http://blogs.msdn.com/b/powershell/archive/2009/04/03/setting-network-location-to-private.aspx
# https://social.technet.microsoft.com/Forums/windowsserver/en-US/e1acf5d3-2bd0-4393-928f-561bfbe9fa96/api-inetworklistmanager-in-powershell?forum=winserverpowershell


# Skip network location setting for pre-Vista operating systems 
if([environment]::OSVersion.version.Major -lt 6) { return } 

$networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}'))
$connections = $networkListManager.GetNetworkConnections()

# Set network location to Private for all networks 
$connections |foreach-object {
  if ($_.GetNetwork().GetCategory() -eq 0)
  {
      {$_.GetNetwork().SetCategory(1)}
  }
}

