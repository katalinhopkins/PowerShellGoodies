<# =====================================================================
   REGISTRY SCRUB — TARGETED EMAIL ARTIFACT REMOVAL
   Removes any registry key/value containing:
      "katalin.hopkins.ctr@mail.mil"
   Includes ACL fixes, SID/profile cleanup, and full logging.
   Author: Copilot for Katalin
===================================================================== #>

$TargetString = "katalin.hopkins.ctr@mail.mil"
$LogFile = "C:\RegScrub_Log.txt"

Function Log($msg) {
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Add-Content -Path $LogFile -Value "$timestamp  $msg"
}

Log "=== REGISTRY SCRUB STARTED ==="
Log "Target string: $TargetString"

# ---------------------------------------------------------------------
# ACL FIX + DELETE FUNCTION
# ---------------------------------------------------------------------
Function Remove-RegistryKeySafe {
    param([string]$KeyPath)

    Log "[ACTION] Attempting deletion: $KeyPath"

    try {
        # Take ownership
        $acl = Get-Acl $KeyPath
        $owner = New-Object System.Security.Principal.NTAccount("Administrators")
        $acl.SetOwner($owner)
        Set-Acl -Path $KeyPath -AclObject $acl
        Log "[SUCCESS] Ownership changed"

        # Grant full control
        $rule = New-Object System.Security.AccessControl.RegistryAccessRule(
            "Administrators","FullControl",
            "ContainerInherit,ObjectInherit","None","Allow"
        )
        $acl = Get-Acl $KeyPath
        $acl.SetAccessRule($rule)
        Set-Acl -Path $KeyPath -AclObject $acl
        Log "[SUCCESS] ACL updated"

        # Delete
        Remove-Item -Path $KeyPath -Recurse -Force -ErrorAction Stop
        Log "[SUCCESS] Deleted key: $KeyPath"
    }
    catch {
        Log "[ERROR] PowerShell deletion failed: $($_.Exception.Message)"
        Log "[ACTION] Trying .NET fallback"

        try {
            $hive, $subkey = $KeyPath.Split(":\", 2)
            $root = switch ($hive) {
                "HKLM" { [Microsoft.Win32.Registry]::LocalMachine }
                "HKCU" { [Microsoft.Win32.Registry]::CurrentUser }
                "HKU"  { [Microsoft.Win32.Registry]::Users }
                "HKCR" { [Microsoft.Win32.Registry]::ClassesRoot }
                "HKCC" { [Microsoft.Win32.Registry]::CurrentConfig }
            }
            $root.DeleteSubKeyTree($subkey)
            Log "[SUCCESS] Deleted via .NET fallback: $KeyPath"
        }
        catch {
            Log "[ERROR] .NET fallback failed: $($_.Exception.Message)"
        }
    }
}

# ---------------------------------------------------------------------
# SEARCH FUNCTION
# ---------------------------------------------------------------------
Function Search-And-Scrub {
    param([string]$Hive)

    Log "Scanning hive: $Hive"

    try {
        $root = Get-ChildItem -Path $Hive -Recurse -ErrorAction SilentlyContinue
    }
    catch {
        Log "[ERROR] Failed to enumerate hive $Hive : $($_.Exception.Message)"
        return
    }

    foreach ($key in $root) {
        # Check key name
        if ($key.Name -like "*$TargetString*") {
            Log "[MATCH] Key name contains target: $($key.Name)"
            Remove-RegistryKeySafe -KeyPath $key.PSPath
        }

        # Check values
        try {
            $values = Get-ItemProperty -Path $key.PSPath -ErrorAction SilentlyContinue
            foreach ($property in $values.PSObject.Properties) {
                if ($property.Value -is [string] -and $property.Value -like "*$TargetString*") {
                    Log "[MATCH] Value found in $($key.PSPath) : $($property.Name)"
                    Set-ItemProperty -Path $key.PSPath -Name $property.Name -Value "" -Force
                    Log "[SUCCESS] Value cleared: $($property.Name)"
                }
            }
        }
        catch {
            # Ignore unreadable keys
        }
    }
}

# ---------------------------------------------------------------------
# EXECUTE SCRUB
# ---------------------------------------------------------------------
$Hives = @(
    "HKLM:\SOFTWARE",
    "HKLM:\SYSTEM",
    "HKLM:\SAM",
    "HKLM:\SECURITY",
    "HKCU:\",
    "HKU:\"
)

foreach ($h in $Hives) {
    Search-And-Scrub -Hive $h
}

# ---------------------------------------------------------------------
# PROFILELIST CLEANUP (based on your screenshots)
# ---------------------------------------------------------------------
$ProfileList = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
Log "Scanning ProfileList for stale profiles"

foreach ($sid in Get-ChildItem $ProfileList) {
    try {
        $path = (Get-ItemProperty $sid.PSPath -Name ProfileImagePath -ErrorAction SilentlyContinue).ProfileImagePath
        if ($path -like "*katal*" -or $path -like "*katlocal*") {
            Log "[STALE PROFILE] $($sid.PSChildName) → $path"
            Remove-RegistryKeySafe -KeyPath $sid.PSPath
        }
    }
    catch {}
}

Log "=== REGISTRY SCRUB COMPLETED ==="
Write-Host "Registry scrub completed. Log saved to $LogFile" -ForegroundColor Green
