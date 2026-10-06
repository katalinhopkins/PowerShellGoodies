#$Backup = "$env:USERPROFILE\Desktop\LicenseBackup"
$Backup = "\\DS224\LGGram16\2026-10-04\LicenseBackup"

New-Item -ItemType Directory -Path $Backup -Force | Out-Null

# Windows activation and licensing details
Get-CimInstance SoftwareLicensingProduct |
    Where-Object { $_.PartialProductKey } |
    Select-Object Name, Description, LicenseStatus,
                  PartialProductKey, ProductKeyChannel,
                  ApplicationID, ID |
    Export-Csv "$Backup\Windows-Licensing.csv" -NoTypeInformation

# Windows licensing service information
Get-CimInstance SoftwareLicensingService |
    Select-Object Version, RemainingWindowsReArmCount,
                  RemainingSkuReArmCount,
                  OA3xOriginalProductKey |
    Export-Csv "$Backup\Windows-Licensing-Service.csv" -NoTypeInformation

# Installed desktop programs: 64-bit and 32-bit
$RegistryPaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

Get-ItemProperty $RegistryPaths -ErrorAction SilentlyContinue |
    Where-Object DisplayName |
    Select-Object DisplayName, DisplayVersion, Publisher,
                  InstallDate, InstallLocation |
    Sort-Object DisplayName -Unique |
    Export-Csv "$Backup\Installed-Software.csv" -NoTypeInformation

# Microsoft Store/AppX packages
Get-AppxPackage -AllUsers |
    Select-Object Name, PackageFullName, Publisher, Version |
    Export-Csv "$Backup\Store-Apps.csv" -NoTypeInformation

# Activation diagnostics
cscript.exe //nologo "$env:windir\system32\slmgr.vbs" /dlv |
    Out-File "$Backup\Windows-Activation-Details.txt"

Write-Host "Export completed: $Backup"