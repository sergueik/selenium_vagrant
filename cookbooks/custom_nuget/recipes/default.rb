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

cookbook_file "#{scripts_dir}/wget.ps1" do
  source 'wget.ps1'
  path "#{scripts_dir}/wget.ps1"
  action :create_if_missing
end

powershell "Download #{package_title}" do
  code <<-EOH

  pushd '#{temp_dir}'
 . .\\wget.ps1 -download_url '#{download_url}' -local_file_path '#{temp_dir}' -filename '#{filename}'

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
  action :create_if_missing
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

