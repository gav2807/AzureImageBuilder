@allowed([
  'np01'
  'pr01'
])
param environment string
// param location string = 'uksouth'
param name string = 'win-2019'
param version string

targetScope = 'resourceGroup'

var computeGalleryName = 'azuks${environment}cmnsvcimagegal'

var suffix = environment == 'np01' ? 'hardened-beta' : 'hardened'  

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' existing = {
  name: 'sbs-uks-${environment}-cmnsvc-gallery-rg'
  scope: subscription()
}

// resource imageBuilderRg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
//   name: 'sbs-uks-${environment}-cmnsvc-aib-${name}-rg'
//   location: location
// }

module imageDefinition '../modules/imageDefinition.bicep' = {
  name: '${uniqueString(deployment().name)}-imageDefinition'
  scope: resourceGroup
  params: {
    computeGalleryName: computeGalleryName
    imageDefinition: {
      name: 'az-uks-win-2019-${suffix}'
      sku: 'az-windows-standard-2019'
      publisher: 'lab'
      offer: 'windows-server-2019'
    }
    location: resourceGroup.location
  }
}

module imageTemplate '../modules/imageTemplate.bicep' = {
  name: '${uniqueString(deployment().name)}-imageTemplate'
  scope: resourceGroup
  params: {
    osName: name
    computeGalleryName: computeGalleryName
    customizers: [
      {
        type: 'PowerShell'
        name: 'EnableTLS1.2'
        inline: [
          'New-Item \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\TLS 1.2\\Server\' -Force | Out-Null'

          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\TLS 1.2\\Server\' -name \'Enabled\' -value \'1\' -PropertyType \'DWord\' -Force | Out-Null'

          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\TLS 1.2\\Server\' -name \'DisabledByDefault\' -value \'0\' -PropertyType \'DWord\' -Force | Out-Null'

          'New-Item \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\TLS 1.2\\Client\' -Force | Out-Null'

          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\TLS 1.2\\Client\' -name \'Enabled\' -value \'1\' -PropertyType \'DWord\' -Force | Out-Null'

          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\TLS 1.2\\Client\' -name \'DisabledByDefault\' -value \'0\' -PropertyType \'DWord\' -Force | Out-Null'

          'Write-Host "TLS 1.2 has been enabled."'
        ]
        runAsSystem: true
        runElevated: true
      }
      {
        type: 'PowerShell'
        name: 'Enable Cipher Suites'
        inline: [
          '(Get-Item \'HKLM:\\\').OpenSubKey(\'SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Ciphers\', $true).CreateSubKey(\'AES 128/128\')'
          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Ciphers\\AES 128/128\' -name \'Enabled\' -value \'1\' -PropertyType \'DWord\' -Force | Out-Null'

          '(Get-Item \'HKLM:\\\').OpenSubKey(\'SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Ciphers\', $true).CreateSubKey(\'AES 256/256\')'
          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Ciphers\\AES 256/256\' -name \'Enabled\' -value \'1\' -PropertyType \'DWord\' -Force | Out-Null'
        ]
        runElevated: true
        runAsSystem: true
      }
      {
        type: 'PowerShell'
        name: 'Disable Cipher Suites'
        inline: [
          '(Get-Item \'HKLM:\\\').OpenSubKey(\'SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Ciphers\', $true).CreateSubKey(\'DES 56/56\')'
          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Ciphers\\DES 56/56\' -name \'Enabled\' -value \'0\' -PropertyType \'DWord\' -Force | Out-Null'

          '(Get-Item \'HKLM:\\\').OpenSubKey(\'SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Ciphers\', $true).CreateSubKey(\'RC2 40/128\')'
          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Ciphers\\RC2 40/128\' -name \'Enabled\' -value \'0\' -PropertyType \'DWord\' -Force | Out-Null'

          '(Get-Item \'HKLM:\\\').OpenSubKey(\'SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Ciphers\', $true).CreateSubKey(\'RC2 56/128\')'
          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Ciphers\\RC2 56/128\' -name \'Enabled\' -value \'0\' -PropertyType \'DWord\' -Force | Out-Null'

          '(Get-Item \'HKLM:\\\').OpenSubKey(\'SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Ciphers\', $true).CreateSubKey(\'RC2 128/128\')'
          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Ciphers\\RC2 128/128\' -name \'Enabled\' -value \'0\' -PropertyType \'DWord\' -Force | Out-Null'

          '(Get-Item \'HKLM:\\\').OpenSubKey(\'SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Ciphers\', $true).CreateSubKey(\'RC4 40/128\')'
          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Ciphers\\RC4 40/128\' -name \'Enabled\' -value \'0\' -PropertyType \'DWord\' -Force | Out-Null'

          '(Get-Item \'HKLM:\\\').OpenSubKey(\'SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Ciphers\', $true).CreateSubKey(\'RC4 56/128\')'
          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Ciphers\\RC4 56/128\' -name \'Enabled\' -value \'0\' -PropertyType \'DWord\' -Force | Out-Null'

          '(Get-Item \'HKLM:\\\').OpenSubKey(\'SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Ciphers\', $true).CreateSubKey(\'RC4 64/128\')'
          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Ciphers\\RC4 64/128\' -name \'Enabled\' -value \'0\' -PropertyType \'DWord\' -Force | Out-Null'

          '(Get-Item \'HKLM:\\\').OpenSubKey(\'SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Ciphers\', $true).CreateSubKey(\'RC4 128/128\')'
          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Ciphers\\RC4 128/128\' -name \'Enabled\' -value \'0\' -PropertyType \'DWord\' -Force | Out-Null'

          '(Get-Item \'HKLM:\\\').OpenSubKey(\'SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Ciphers\', $true).CreateSubKey(\'Triple DES 168\')'
          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Ciphers\\Triple DES 168\' -name \'Enabled\' -value \'0\' -PropertyType \'DWord\' -Force | Out-Null'
        ]
        runElevated: true
        runAsSystem: true
      }
      {
        type: 'PowerShell'
        name: 'DisableTLS1.0'
        inline: [
          'New-Item \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\TLS 1.0\\Server\' -Force | Out-Null'

          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\TLS 1.0\\Server\' -name \'Enabled\' -value \'0\' -PropertyType \'DWord\' -Force | Out-Null'

          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\TLS 1.0\\Server\' -name \'DisabledByDefault\' -value \'1\' -PropertyType \'DWord\' -Force | Out-Null'

          'New-Item \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\TLS 1.0\\Client\' -Force | Out-Null'

          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\TLS 1.0\\Client\' -name \'Enabled\' -value \'0\' -PropertyType \'DWord\' -Force | Out-Null'

          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\TLS 1.0\\Client\' -name \'DisabledByDefault\' -value \'1\' -PropertyType \'DWord\' -Force | Out-Null'

          'Write-Host "TLS 1.0 has been disabled."'
        ]
        runAsSystem: true
        runElevated: true
      }
      {
        type: 'PowerShell'
        name: 'DisableTLS1.1'
        inline: [
          'New-Item \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\TLS 1.1\\Server\' -Force | Out-Null'

          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\TLS 1.1\\Server\' -name \'Enabled\' -value \'0\' -PropertyType \'DWord\' -Force | Out-Null'

          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\TLS 1.1\\Server\' -name \'DisabledByDefault\' -value \'1\' -PropertyType \'DWord\' -Force | Out-Null'

          'New-Item \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\TLS 1.1\\Client\' -Force | Out-Null'

          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\TLS 1.1\\Client\' -name \'Enabled\' -value \'0\' -PropertyType \'DWord\' -Force | Out-Null'

          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\TLS 1.1\\Client\' -name \'DisabledByDefault\' -value \'1\' -PropertyType \'DWord\' -Force | Out-Null'

          'Write-Host "TLS 1.1 has been disabled."'
        ]
        runAsSystem: true
        runElevated: true
      }
      {
        type: 'PowerShell'
        name: 'DisableSSL2.0'
        inline: [
          'New-Item \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\SSL 2.0\\Server\' -Force | Out-Null'

          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\SSL 2.0\\Server\' -name \'Enabled\' -value \'0\' -PropertyType \'DWord\' -Force | Out-Null'

          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\SSL 2.0\\Server\' -name \'DisabledByDefault\' -value \'1\' -PropertyType \'DWord\' -Force | Out-Null'

          'New-Item \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\SSL 2.0\\Client\' -Force | Out-Null'

          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\SSL 2.0\\Client\' -name \'Enabled\' -value \'0\' -PropertyType \'DWord\' -Force | Out-Null'

          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\SSL 2.0\\Client\' -name \'DisabledByDefault\' -value \'1\' -PropertyType \'DWord\' -Force | Out-Null'

          'Write-Host "SSL 2.0 has been disabled."'
        ]
        runAsSystem: true
        runElevated: true
      }
      {
        type: 'PowerShell'
        name: 'DisableSSL3.0'
        inline: [
          'New-Item \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\SSL 3.0\\Server\' -Force | Out-Null'

          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\SSL 3.0\\Server\' -name \'Enabled\' -value \'0\' -PropertyType \'DWord\' -Force | Out-Null'

          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\SSL 3.0\\Server\' -name \'DisabledByDefault\' -value \'1\' -PropertyType \'DWord\' -Force | Out-Null'

          'New-Item \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\SSL 3.0\\Client\' -Force | Out-Null'

          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\SSL 3.0\\Client\' -name \'Enabled\' -value \'0\' -PropertyType \'DWord\' -Force | Out-Null'

          'New-ItemProperty -path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\SSL 3.0\\Client\' -name \'DisabledByDefault\' -value \'1\' -PropertyType \'DWord\' -Force | Out-Null'

          'Write-Host "SSL 3.0 has been disabled."'
        ]
        runAsSystem: true
        runElevated: true
      }
      {
        type: 'PowerShell'
        name: 'Disable Hashing Functions'
        inline: [
          'New-Item -Path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Hashes\\MD5\' -Force'
          'New-ItemProperty -Path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Hashes\\MD5\' -name \'Enabled\' -value \'0\' -PropertyType \'DWord\' -Force'

          'New-Item -Path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Hashes\\SHA\' -Force'
          'New-ItemProperty -Path \'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Hashes\\SHA\' -name \'Enabled\' -value \'0\' -PropertyType \'DWord\' -Force'
        ]
        runElevated: true
        runAsSystem: true
      }
      {
        type: 'PowerShell'
        name: 'Install Storage Services Feature'
        inline: [
          'Install-WindowsFeature Storage-Services'
        ]
        runAsSystem: true
        runElevated: true
      }
      {
        type: 'PowerShell'
        name: 'Install .NET 4.7 Feature'
        inline: [
          'Install-WindowsFeature NET-Framework-45-Core'
          'Install-WindowsFeature NET-WCF-Services45'
          'Install-WindowsFeature -Name NET-WCF-TCP-PortSharing45'
        ]
        runAsSystem: true
        runElevated: true
      }
      {
        type: 'PowerShell'
        name: 'Install Remote Differential Compression Feature'
        inline: [
          'Install-WindowsFeature RDC'
        ]
        runAsSystem: true
        runElevated: true
      }
      {
        type: 'PowerShell'
        name: 'Install WoW64 Feature'
        inline: [
          'Install-WindowsFeature -Name WoW64-Support'
        ]
        runAsSystem: true
        runElevated: true
      }
      {
        type: 'PowerShell'
        name: 'Remove XPS Viewer'
        inline: [
          'Remove-WindowsFeature XPS-Viewer'
        ]
        runElevated: true
        runAsSystem: true
      }
      {
        type: 'PowerShell'
        name: 'Remove Web Server (IIS) Feature'
        inline: [
          'Remove-WindowsFeature Web-Server'
        ]
        runElevated: true
        runAsSystem: true
      }
      {
        type: 'PowerShell'
        name: 'Remove WAS Feature'
        inline: [
          'Remove-WindowsFeature WAS'
        ]
        runElevated: true
        runAsSystem: true
      }
      {
        type: 'PowerShell'
        name: 'Remove Windows-Defender Feature'
        inline: [
          'Remove-WindowsFeature Windows-Defender'
        ]
        runElevated: true
        runAsSystem: true
      }
      {
        type: 'PowerShell'
        name: 'Remove IIS'
        inline: [
          'Remove-WindowsFeature Web-Default-Doc'
          'Remove-WindowsFeature Web-Dir-Browsing'
          'Remove-WindowsFeature Web-Http-Errors'
          'Remove-WindowsFeature Web-Static-Content'
          'Remove-WindowsFeature Web-Http-Logging'
          'Remove-WindowsFeature Web-Request-Monitor'
          'Remove-WindowsFeature Web-Stat-Compression'
          'Remove-WindowsFeature Web-Filtering'
          'Remove-WindowsFeature Web-Windows-Auth'
          'Remove-WindowsFeature Web-Net-Ext45'
          'Remove-WindowsFeature Web-Asp-Net45'
          'Remove-WindowsFeature Web-ISAPI-Ext'
          'Remove-WindowsFeature Web-ISAPI-Filter'
          'Remove-WindowsFeature Web-Mgmt-Console'
          'Remove-WindowsFeature Web-Metabase'
        ]
        runElevated: true
        runAsSystem: true
      }
      {
        type: 'PowerShell'
        name: 'Remove Web Security Feature'
        inline: [
          'Remove-WindowsFeature Web-Security'
        ]
        runElevated: true
        runAsSystem: true
      }
      {
        type: 'PowerShell'
        name: 'Disable Services'
        inline: [
          'Stop-Service -Name WMPNetworkSvc -Force'
          'Set-Service -StartupType Disabled WMPNetworkSvc'

          'Stop-Service -Name WpnService -Force'
          'Set-Service -StartupType Disabled WpnService'

          'Stop-Service -Name stisvc -Force'
          'Set-Service -StartupType Disabled stisvc'

          'Stop-Service -Name FrameServer -Force'
          'Set-Service -StartupType Disabled FrameServer'

          'Stop-Service -Name BTAGService -Force'
          'Set-Service -StartupType Disabled BTAGService'

          'Stop-Service -Name Bthserv -Force'
          'Set-Service -StartupType Disabled Bthserv'

          'Stop-Service -Name AJRouter -Force'
          'Set-Service -StartupType Disabled AJRouter'

          'Stop-Service -Name WbioSrvc -Force'
          'Set-Service -StartupType Disabled WbioSrvc'

          'Stop-Service -Name AudioEndpointBuilder -Force'
          'Set-Service -StartupType Disabled AudioEndpointBuilder'

          'Stop-Service -Name Audiosrv -Force'
          'Set-Service -StartupType Disabled Audiosrv'

          'Stop-Service -Name WarpJITSvc -Force'
          'Set-Service -StartupType Disabled WarpJITSvc'

          'Stop-Service -Name TabletInputService -Force'
          'Set-Service -StartupType Disabled TabletInputService'

          'Stop-Service -Name WiaRpc -Force'
          'Set-Service -StartupType Disabled WiaRpc'

          'Stop-Service -Name SCPolicySvc -Force'
          'Set-Service -StartupType Disabled SCPolicySvc'

          'Stop-Service -Name SCardSvr -Force'
          'Set-Service -StartupType Disabled SCardSvr'

          'Stop-Service -Name SensorService -Force'
          'Set-Service -StartupType Disabled SensorService'

          'Stop-Service -Name SensrSvc -Force'
          'Set-Service -StartupType Disabled SensrSvc'

          'Stop-Service -Name RasMan -Force'
          'Set-Service -StartupType Disabled RasMan'

          'Stop-Service -Name RasAuto -Force'
          'Set-Service -StartupType Disabled RasAuto'

          'Stop-Service -Name QWAVE -Force'
          'Set-Service -StartupType Disabled QWAVE'

          'Stop-Service -Name InstallService -Force'
          'Set-Service -StartupType Disabled InstallService'

          'Stop-Service -Name Spooler -Force'
          'Set-Service -StartupType Disabled Spooler'

          'Stop-Service -Name NcbService -Force'
          'Set-Service -StartupType Disabled NcbService'

          'Stop-Service -Name wlidsvc -Force'
          'Set-Service -StartupType Disabled wlidsvc'

          'Stop-Service -Name CDPSvc -Force'
          'Set-Service -StartupType Disabled CDPSvc'
        ]
        runAsSystem: true
        runElevated: true
      }
      {
        type: 'PowerShell'
        name: 'Add Custom Administrator Account'
        inline: [
          'New-LocalUser -Name "Garibaldi" -NoPassword -FullName "Michael Garibaldi"'
          'Add-LocalGroupMember -Group "Administrators" -Member "Garibaldi"'
        ]
        runAsSystem: true
        runElevated: true
      }
      {
        type: 'PowerShell'
        name: 'Download Powershell 7'
        inline: [
          'Invoke-Webrequest -Uri "https://github.com/PowerShell/PowerShell/releases/download/v7.4.2/PowerShell-7.4.2-win-x64.msi" -OutFile "C:\\PowerShell-7.4.2-win-x64.msi"'
        ]
        runAsSystem: true
        runElevated: true
      }
      {
        type: 'PowerShell'
        name: 'Download Powershell 7'
        inline: [
          'msiexec.exe /package C:\\PowerShell-7.4.2-win-x64.msi /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 USE_MU=1 ENABLE_MU=1 ADD_PATH=1'
        ]
        runAsSystem: true
        runElevated: true
      }
      {
        type: 'PowerShell'
        name: 'Install NuGet Package Manager'
        inline: [
          'Install-PackageProvider NuGet -Force'
        ]
        runAsSystem: true
        runElevated: true
      }
      {
        type: 'WindowsRestart'
        restartCommand: 'shutdown /r /f /t 0'
        restartTimeout: '5m'
      }
      {
        type: 'PowerShell'
        name: 'SleeptoAllowExtensionInstall'
        inline: [
          'Get-Date'
          'Start-Sleep -Seconds 120;'
          'Get-Date'
        ]
        runElevated: true
        runAsSystem: true
      }
    ]
    environment: environment
    imageDefinitionName: imageDefinition.outputs.properties.name
    imageTemplateName: 'sbs-uks-${environment}-${name}-it'
    image:{
      sku: '2019-Datacenter'
      offer: 'WindowsServer'
      publisher: 'MicrosoftWindowsServer'
      version: 'latest'
    }
    location: resourceGroup.location
    version: version
  }
}
