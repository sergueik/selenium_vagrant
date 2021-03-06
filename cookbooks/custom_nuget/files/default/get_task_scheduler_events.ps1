$report = 'report.log'
$DebugPreference = 'Continue'
$assembly_name = 'Newtonsoft.Json.dll'


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

Write-Debug "Loading external assembly ${assembly_name}"
add-type -path ([System.IO.Path]::Combine( (Get-ScriptDirectory), $assembly_name))

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

"@ -ReferencedAssemblies 'System.dll', 'System.Security.dll', 'System.Core.dll', ([System.IO.Path]::Combine( (Get-ScriptDirectory), $assembly_name))

write-Debug 'Running embedded assembly:'

$helper = new-object 'EventQuery.EventQueryExampleEmbedded' -erroraction 'SilentlyContinue'

$helper.Query = @"
<QueryList>
<Query Id='0' Path='Microsoft-Windows-TaskScheduler/Operational'>
<Select Path='Microsoft-Windows-TaskScheduler/Operational'>*[System[Level=4 and TimeCreated[timediff(@SystemTime) &lt;= 1800000]]]</Select>
</Query>
</QueryList>
"@
$helper.Verbose = $false
Write-Debug ("Query:`r`n{0}" -f $helper.Query)
try{
  $result = $helper.QueryActiveLog() 
} catch [Exception] { 

}

Write-Debug ('Result: {0} rows' -f $result.count) 
Write-Debug ('Saving sample entry to {0}'  -f $report)
Write-Output $result | select-object -first 1  | convertfrom-json 

write-output '' | out-file $report -encoding 'ASCII'
$result | select-object -first 1 | out-file $report -append -encoding 'ASCII'

