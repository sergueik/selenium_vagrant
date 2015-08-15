log 'Started execution custom nuget.exe downloader' do
  level :info
end

temp_dir  ='C:\\Users\\vagrant\\AppData\\Local\\Temp'
system = node['kernel']['machine'] == 'x86_64' ? 'win64' : 'win32'
download_url = node['custom_nuget']['download_url']
filename =  node['custom_nuget']['filename']
package_title = 'console nuget client'
assemblies = %w/
CsQuery
Newtonsoft.Json
/

powershell "Download #{package_title}" do
  code <<-EOH

# http://poshcode.org/4332
# http://poshcode.org/4331

[string]$download_url = '#{download_url}'
[string]$local_file_path = '#{temp_dir}'
[string]$filename = '#{filename}'

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory {
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  if ($Invocation.PSScriptRoot) {
    $Invocation.PSScriptRoot
  }
  elseif ($Invocation.MyCommand.Path) {
    Split-Path $Invocation.MyCommand.Path
  } else {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf(''))
  }
}

# support relative paths
if (!(Split-Path -Parent $local_file_path) -or !(Test-Path -PathType Container (Split-Path -Parent $local_file_path))) {
  $local_file_path = Join-Path (Get-ScriptDirectory) (Split-Path -Leaf $local_file_path)
}

if (-not (Test-Path $local_file_path))
{
  throw "Folder ${local_path} does not Exist, file cannot be saved to"
}

$destination_file =  ('downloaded_file_{0}.exe' -f (Get-Random -Maximum 5000) )
Write-Host ("Downloading {0}`nSaving as {1}" -f $download_url,$destination_file)

$web_client = New-Object System.Net.WebClient
# TODO: proxy authentication

$web_client.DownloadFile($download_url,$destination_file)
# TODO: better handle 
# Exception calling "DownloadFile" with "2" argument(s): "An exception occurred during a WebClient request."
# TODO: throw custom exception if unable to download the file.

Write-Host ("Moving {0} to {1}" -f $destination_file, $local_file_path)
$local_file = [System.IO.Path]::Combine($local_file_path, $filename)
copy-item -Destination $local_file -literalPath $destination_file
if ( -not (test-path -path $local_file )) { 
throw 'Failed to download file.'
}

  EOH
  not_if {::File.exists?("#{temp_dir}/#{filename}".gsub('\\', '/'))}
end

log "Completed download #{package_title}" do
  level :info
end

assemblies.each  do |assembly|
  powershell "Install #{assembly}" do
    code <<-EOH
      $framework = 'net40'
      pushd '#{temp_dir}'
      $env:PATH = "${env:PATH};#{temp_dir}"
      & nuget.exe install '#{assembly}' | out-file "#{temp_dir}\\nuget.log" -encoding ASCII -append
      pushd '#{temp_dir}'
      get-childitem -filter '#{assembly}.dll' -recurse | where-object { $_.PSPath -match '\\\\net40\\\\'} | copy-item -destination '.'
  EOH
  end
end

powershell 'Execute test script version with no json dependnecy' do
  code <<-EOH

# version with no json dependnecy
Add-Type -IgnoreWarnings @"

using System;
using System.Diagnostics.Eventing.Reader;
using System.Security;
using System.Collections;

namespace EventQuery
{
    public class EventQueryExampleEmbedded
    {
        // log the entries to console
        private bool _verbose;
        public bool Verbose
        {
            get
            {
                return _verbose;
            }
            set
            {
                _verbose = value;
            }

        }

        private String _query = @"<QueryList>" +
                  "<Query Id=\\"0\\" Path=\\"Microsoft-Windows-TaskScheduler/Operational\\">" +
                  "<Select Path=\\"Microsoft-Windows-TaskScheduler/Operational\\">" +
                  "*[System[(Level=1  or Level=2 or Level=3 or Level=4) and " +
                  "TimeCreated[timediff(@SystemTime) &lt;= 14400000]]]" + "</Select>" +
                  "</Query>" +
                  "</QueryList>";
        public String Query
        {
            get
            {
                return _query;
            }
            set
            {
                _query = value;
            }

        }


        public void QueryActiveLog()
        {
            // TODO: Extend structured query to two different event logs.
            EventLogQuery eventsQuery = new EventLogQuery("Application", PathType.LogName, Query);
            EventLogReader logReader = new EventLogReader(eventsQuery);
            DisplayEventAndLogInformation(logReader);
        }

        private void DisplayEventAndLogInformation(EventLogReader logReader)
        {
            for (EventRecord eventInstance = logReader.ReadEvent();
                null != eventInstance; eventInstance = logReader.ReadEvent())
            {
                if (Verbose)
                {
                    Console.WriteLine("-----------------------------------------------------");
                    Console.WriteLine("Event ID: {0}", eventInstance.Id);
                    Console.WriteLine("Level: {0}", eventInstance.Level);
                    Console.WriteLine("LevelDisplayName: {0}", eventInstance.LevelDisplayName);
                    Console.WriteLine("Opcode: {0}", eventInstance.Opcode);
                    Console.WriteLine("OpcodeDisplayName: {0}", eventInstance.OpcodeDisplayName);
                    Console.WriteLine("TimeCreated: {0}", eventInstance.TimeCreated);
                    Console.WriteLine("Publisher: {0}", eventInstance.ProviderName);
                }
                try
                {
                    if (Verbose)
                    {
                        Console.WriteLine("Description: {0}", eventInstance.FormatDescription());
                    }
                }
                catch (EventLogException)
                {

                    // The event description contains parameters, and no parameters were 
                    // passed to the FormatDescription method, so an exception is thrown.

                }

                // Cast the EventRecord object as an EventLogRecord object to 
                // access the EventLogRecord class properties
                EventLogRecord logRecord = (EventLogRecord)eventInstance;
                if (Verbose)
                {
                    Console.WriteLine("Container Event Log: {0}", logRecord.ContainerLog);
                }
            }
        }
    }
}

"@ -ReferencedAssemblies 'System.dll', 'System.Security.dll', 'System.Core.dll' 
# NOTE: Newtonsoft.Json is extemently brittle
# http://stackoverflow.com/questions/22685530/could-not-load-file-or-assembly-newtonsoft-json-or-one-of-its-dependencies-ma

Write-Output 'Running embedded assembly:'

$o = new-object 'EventQuery.EventQueryExampleEmbedded' -erroraction 'SilentlyContinue'

$o.Query = @"
<QueryList>
<Query Id="0" Path="Microsoft-Windows-TaskScheduler/Operational">
<Select Path="Microsoft-Windows-TaskScheduler/Operational">*[System[Level=4 and TimeCreated[timediff(@SystemTime) &lt;= 3600000]]]</Select>
</Query>
</QueryList>
"@
$o.Verbose = $true
write-output ("Query:`r`n{0}" -f $o.Query)
try{
  # NOTE: the output will not get captured
  $o.QueryActiveLog()
} catch [Exception] { 

}

  EOH
end

log 'Completed execution custom powershell scripts with Nuget-provided dependency.' do
  level :info
end


