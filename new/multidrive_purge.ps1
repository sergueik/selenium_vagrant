# Cookbook for multi drive free space examination / maven repository cleanup
$drive_ids = (@'
["C:","E:"]
'@ -join '') | convertfrom-json;
$basedirs =  ('{"C:":"C:\\Programdata\\jenkins","E:":"E:\\Jenkins","D:":"D:\\Jenkins"}' -join '') | convertfrom-json;
$high_percents = ('{"C:":90,"D:":10,"E:":25}' -join '') | convertfrom-json;

write-host ('drive_ids: {0}' -f  $drive_ids)
write-host ('basedirs: {0}' -f  $basedirs)
write-host ('high_percents: {0}' -f  $high_percents)
$drive_ids | foreach-object { 
  $drive_id = $_
  if ($drive_id -eq ''){
    $drive_id = 'C:'
  }
  $disk_info = get-wmiobject Win32_LogicalDisk -computerName '.' -filter "DeviceID='${drive_id}'" | select-object Size,FreeSpace
  $percenage_used = [Math]::Round(100 * (1 - $disk_info.FreeSpace / $disk_info.Size))
  write-host ('Used disk percentage on drive "{0}" is {1} %' -f $drive_id, $percenage_used)
  $percentage_threshold = $high_percents.$drive_id
  write-host ('Threshold used disk percentage on drive "{0}" is {1} %' -f $drive_id,$percentage_threshold)
    if ($percenage_used  -gt $percentage_threshold ){
    $basedir = $basedirs.$drive_id

    write-host ('A purge is required for {0}' -f $basedir )
    if (test-path -path "${basedir}\.m2\repository") {
      get-childitem -path "${basedir}\.m2\repository" | where-object {
        $_.PSIsContainer } | foreach-object {
        $maven_directory = $_
        [String]$full_maven_directory_name = $maven_directory.FullName
        write-host ('Removing "{0}"' -f $full_maven_directory_name)
        if ($powershell_noop) {
          remove-item -path $full_maven_directory_name -recurse -force -whatif
        } else {
          remove-item -path $full_maven_directory_name -recurse -force
        }
      }
    } else {
      write-host ('The directory "{0}" does not exist' -f "${basedir}\.m2\repository")
    } 
  } else {
    write-host ('Drive usage is low on "${0}"' -f $drive_id)
  }
}
