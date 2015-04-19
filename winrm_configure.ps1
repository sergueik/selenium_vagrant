# enable winrm in windows box
# origin: https://gist.github.com/uchagani/48d25871e7f306f1f8af
get-service winrm
Enable-PSRemoting -force
winrm qc -q  
winrm set winrm/config/client '@{TrustedHosts="*"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}'
winrm set winrm/config/winrs '@{MaxConcurrentUsers="100"}'
winrm set winrm/config/winrs '@{AllowRemoteShellAccess="True"}'
winrm set winrm/config '@{MaxTimeoutms="604800000"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'

