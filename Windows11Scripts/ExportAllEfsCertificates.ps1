<# 
    ExportAllEfsCertificates

    Export All EFS Certificates (with private keys)
    Author: Katalin
    Date: 2026-09-28
#>

# --- Output Root ---
$OutputRoot = "\\DS224\LGGram16\2026-10-04\Certificate Backups"


# --- Today's Date Folder ---
$Today = (Get-Date).ToString("yyyy-MM-dd")
$BackupFolder = Join-Path $OutputRoot ("{0}_CertBackup" -f $Today)

# --- PFX Password ---
$Password = ConvertTo-SecureString -String "ChangeThisPassword" -Force -AsPlainText

Write-Host "=== Starting EFS Certificate Backup ===" -ForegroundColor Cyan

# Create root output folder if missing
if (-not (Test-Path $OutputRoot))
{
    New-Item -ItemType Directory -Path $OutputRoot | Out-Null
}

# Create dated backup folder
if (-not (Test-Path $BackupFolder))
{
    New-Item -ItemType Directory -Path $BackupFolder | Out-Null
}

# Enumerate all user profiles
$UserProfiles = Get-CimInstance Win32_UserProfile | Where-Object { $_.LocalPath -like "C:\Users\*" }

foreach ($Profile in $UserProfiles)
{
    $UserPath = $Profile.LocalPath
    $UserName = Split-Path $UserPath -Leaf

    Write-Host "`n--- Processing user: $UserName ---" -ForegroundColor Yellow

    # Load user certificate store
    $Store = New-Object System.Security.Cryptography.X509Certificates.X509Store "My", "CurrentUser"
    $Store.Open("ReadOnly")

    # Filter EFS certificates
    $EfsCerts = $Store.Certificates | Where-Object {
        $_.EnhancedKeyUsageList | Where-Object { $_.FriendlyName -eq "File Encryption" }
    }

    if ($EfsCerts.Count -eq 0)
    {
        Write-Host "No EFS certificates found for $UserName" -ForegroundColor DarkGray
        $Store.Close()
        continue
    }

    # Create user output folder inside today's backup folder
    $UserOutput = Join-Path $BackupFolder $UserName
    if (-not (Test-Path $UserOutput))
    {
        New-Item -ItemType Directory -Path $UserOutput | Out-Null
    }

    foreach ($Cert in $EfsCerts)
    {
        Write-Host "Exporting EFS certificate: $($Cert.Subject)" -ForegroundColor Green

        $Thumbprint = $Cert.Thumbprint
        $OutputFile = Join-Path $UserOutput ("EFS-" + $Thumbprint + ".pfx")

        try
        {
            $Bytes = $Cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx, $Password)
            [IO.File]::WriteAllBytes($OutputFile, $Bytes)

            Write-Host "Exported to: $OutputFile" -ForegroundColor Cyan
        }
        catch
        {
            Write-Host "Failed to export certificate $Thumbprint" -ForegroundColor Red
        }
    }

    $Store.Close()
}

Write-Host "`n=== Backup Complete ===" -ForegroundColor Cyan
