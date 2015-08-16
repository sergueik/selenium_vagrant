log 'Started execution custom nuget.exe downloader' do
  level :info
end

temp_dir ='C:\\Users\\vagrant\\AppData\\Local\\Temp'
scripts_dir = temp_dir.gsub('\\','/')
system = node['kernel']['machine'] == 'x86_64' ? 'win64' : 'win32'
download_url = node['custom_nuget']['download_url']
filename = node['custom_nuget']['filename']
package_title = 'console nuget client'
assemblies = %w/
CsQuery
Newtonsoft.Json
/

powershell "Download #{package_title}" do
  code <<-EOH

[string]$download_url = '#{download_url}'
[string]$local_file_path = '#{temp_dir}'
[string]$filename = '#{filename}'

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
# NOTE:
# Exception calling "DownloadFile" with "2" argument(s): "An exception occurred during a WebClient request."
# TODO: throw custom exception if unable to download the file.

Write-Host ("Moving {0} to {1}" -f $destination_file, $local_file_path)
$local_file = [System.IO.Path]::Combine($local_file_path, $filename)
copy-item -Destination $local_file -literalPath $destination_file
if ( -not (test-path -path $local_file )) { 
  Throw 'Failed to download file.'
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
  not_if {::File.exists?("#{temp_dir}/#{assembly}.dll".gsub('\\', '/'))}

  end
end

cookbook_file "#{scripts_dir}/get_task_scheduler_events.ps1" do
  source 'get_task_scheduler_events.ps1'
  path "#{scripts_dir}/get_task_scheduler_events.ps1"
end

powershell 'Execute uploaded script' do
  code <<-EOH
pushd '#{temp_dir}'
 . .\\get_task_scheduler_events.ps1
   EOH
end

log 'Completed execution uploaded script with Nuget-provided dependency.' do
  level :info
end

powershell 'Execute inline script version with no json dependency' do
  code <<-EOH

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

log 'Completed execution embedded powershell script without extra assembly dependency.' do
  level :info
end

powershell 'Execute test script version with downloaded assembly dependnecy' do
  code <<-EOH
$DebugPreference = 'Continue'
pushd '#{temp_dir}'
add-type -path "#{temp_dir}\\Newtonsoft.Json.dll"

Add-Type -IgnoreWarnings @"

using System;
using System.Diagnostics.Eventing.Reader;
using System.Security;
using System.Collections;
using Newtonsoft.Json;

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
                  "<Query Id='0' Path='Microsoft-Windows-TaskScheduler/Operational'>" +
                  "<Select Path='Microsoft-Windows-TaskScheduler/Operational'>" +
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

        public object[] QueryActiveLog()
        {
            // TODO: Extend structured query to two different event logs.
            EventLogQuery eventsQuery = new EventLogQuery("Application", PathType.LogName, Query);
            EventLogReader logReader = new EventLogReader(eventsQuery);
            return DisplayEventAndLogInformation(logReader);
        }

        private object[] DisplayEventAndLogInformation(EventLogReader logReader)
        {
            ArrayList eventlog_json_arraylist = new ArrayList();
            for (EventRecord eventInstance = logReader.ReadEvent();
                null != eventInstance; eventInstance = logReader.ReadEvent())
            {
                string eventlog_json = null;
                try { eventlog_json =  JsonConvert.SerializeObject(eventInstance);
		} catch (Exception e){
			// Assert
		}
                eventlog_json_arraylist.Add(eventlog_json);

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
            object[] result = eventlog_json_arraylist.ToArray();
            return result;
        }
    }
}

"@ -ReferencedAssemblies 'System.dll', 'System.Security.dll', 'System.Core.dll', "#{temp_dir}\\Newtonsoft.Json.dll"

write-Debug 'Running embedded assembly:' | out-file 'report.log' -append -encoding 'ASCII'
$o = new-object 'EventQuery.EventQueryExampleEmbedded' -erroraction 'SilentlyContinue'

$o.Query = @"
<QueryList>
<Query Id="0" Path="Microsoft-Windows-TaskScheduler/Operational">
<Select Path="Microsoft-Windows-TaskScheduler/Operational">*[System[Level=4 and TimeCreated[timediff(@SystemTime) &lt;= 3600000]]]</Select>
</Query>
</QueryList>
"@
$o.Verbose = $false
Write-Debug ("Query:`r`n{0}" -f $o.Query)
try{
$r = $o.QueryActiveLog() 
} catch [Exception] { 

}
write-Debug ('Result: {0} rows' -f $r.count) | out-file 'report.log' -append -encoding 'ASCII'
write-Debug ('Saving sample entry to {0}'  -f 'report.log')
write-output '' | out-file 'report.log' -append -encoding 'ASCII'
$r  | select-object -first 1  | convertfrom-json | out-file 'report.log' -append -encoding 'ASCII'

  EOH
end

log 'Completed execution custom powershell scripts with Nuget-provided dependency.' do
  level :info
end


