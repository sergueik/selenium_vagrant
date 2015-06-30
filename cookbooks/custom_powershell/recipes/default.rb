log 'Started execution various custom powershell scripts.' do
  level :info
end
system = node['kernel']['machine'] == 'x86_64' ? 'win64' : 'win32'
filename = node['custom_powershell']['filename']

# this happens to be cwd of the Powershell script
temp_dir='C:\\Users\\vagrant\\AppData\\Local\\Temp'
file_fillpath = "#{temp_dir}\\#{filename}"


powershell  'Process JSON' do
  code <<-EOH



# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory {
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  if ($Invocation.PSScriptRoot) {
    $Invocation.PSScriptRoot
  }
  elseif ($Invocation.MyCommand.Path) {
    Split-Path $Invocation.MyCommand.Path
  } else {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf(""))
  }
}

$filename = "#{filename}"

$default_result = @"
[{
	"serverName": "ccltsteco1n2",
	"iisStatus": "started",
	"sites": [{
		"siteName": "Carnival",
		"siteStatus": "started",
		"applications": [{
			"applicationName": "\\\\",
			"applicationPool": "Carnival",
			"dotNet": 4,
			"mode": "classic",
			"status": "started"
		}, {
			"applicationName": "OnlineCheckIn",
			"applicationPool": "OnlineCheckIn",
			"dotNet": 4,
			"mode": "classic",
			"status": "stopped"
		}]
	}, {
		"siteName": "CarnivalUK",
		"siteStatus": "stopped",
		"applications": [{
			"applicationName": "\\\\",
			"applicationPool": "CarnivalUK",
			"dotNet": 4,
			"mode": "classic",
			"status": "started"
		}]
	}]
}]
"@


$json_object = ConvertFrom-Json -InputObject $default_result
 
# NOTE: A parameter cannot be found that matches  parameter name 'Depth'
# this conflicts with documentation.
# https://technet.microsoft.com/en-us/library/hh849922(v=wps.620).aspx
Write-Host $json_object.'serverName'
Write-Host $json_object.'iisStatus'
[System.Object[]]$sites = $json_object.'sites'

[System.Object]$site = $sites[0]
Write-Host $site.'siteName'
Write-Host $site.'siteStatus'
[System.Object[]]$applications = $site.'applications'
[System.Object]$application = $applications[0]

Write-Host $application.'applicationName'
Write-Host $application.'applicationPool'
Write-Host $application.'dotNet'
Write-Host $application.'mode'
Write-Host $application.'status'


# http://stackoverflow.com/questions/28077854/powershell-2-0-convertfrom-json-and-convertto-json-implementation
function ConvertTo-Json20 {
  param([object]$InputObject)
  Add-Type -Assembly system.web.extensions
  $ps_js = New-Object system.web.script.serialization.javascriptSerializer
  return $ps_js.Serialize($InputObject)
}


function generate_result_mockup () {
  param([string]$json_result = 'out.json'
  ) # this function will  emit the  json in specific schema

  $mockup_result =
  @(
    @{
      "serverName" = "ccltsteco1n2";
      "iisStatus" = "started";
      "sites" = @(
        @{
          "siteName" = "Carnival";
          "siteStatus" = "started";
          "applications" = @(
            @{
              "applicationName" = "\\";
              "applicationPool" = "Carnival";
              "dotNet" = 4;
              "mode" = "classic";
              "status" = "started";
            },@{
              "applicationName" = "OnlineCheckIn";
              "applicationPool" = "OnlineCheckIn";
              "dotNet" = 4;
              "mode" = "classic";
              "status" = "stopped";
            });
        },@{
          "siteName" = "CarnivalUK";
          "siteStatus" = "stopped";
          "applications" = @(
            @{
              "applicationName" = "\\";
              "applicationPool" = "CarnivalUK";
              "dotNet" = 4;
              "mode" = "classic";
              "status" = "started";
            });
        });
    });

  $json_object = $mockup_result
  ConvertTo-Json -InputObject $json_object
  #  the structure is  corrupt 
  ConvertTo-Json20 -InputObject $json_object
  #  truncate the file 

  '' | Out-File -FilePath $json_result -Encoding ascii -Force
  Write-Output ('Saving new contents to the file "{0}"' -f $json_result)
  #   ConvertTo-Json -InputObject $json_object | Out-File -FilePath ([System.IO.Path]::Combine((Get-ScriptDirectory),$json_result)) -Encoding ascii -Force -Append
  ConvertTo-Json20 -InputObject $json_object | Out-File -FilePath ([System.IO.Path]::Combine((Get-ScriptDirectory),$json_result)) -Encoding ascii -Force -Append

}

generate_result_mockup -json_result $filename


  EOH
  action  :run
end


# http://stackoverflow.com/questions/15695909/how-to-read-a-file-content-at-execution-time-chef-reads-at-compile-time
ruby_block "Check the Powershell step log file" do
Chef::Log.info("Test if log file exists: \"#{file_fillpath}\"")
  block do
    version = ""
    if File.exists?("#{file_fillpath}")
      Chef::Log.info("Read the info from file  #{file_fillpath}")
      f = File.open("#{file_fillpath}")
      f.each {|line|
        Chef::Log.info(line)
      }
      f.close
    end
  end
end


log 'Completed execution various custom powershell scripts.' do
  level :info
end
