<# =====================================================================
   REGISTRY SCRUB — REMOTE DESKTOP / WINDOWS APP ONLY
   Removes keys/values containing:
      "katalin.hopkins.ctr@mail.mil"
   ONLY if the key path is related to:
      MSRDC, RemoteDesktop, WindowsAppRuntime, MSTSC, TERMSRV
   Full logging + ACL fixes included.
===================================================================== #>

$TargetString = "katalin.hopkins.ctr@mail.mil"
$LogFile = "C:\RegScrub_RDP_Log.txt"

Function Log($msg) {
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Add-Content -Path $LogFile -Value "$timestamp  $msg"
}

Log "=== RDP/MSRDC REGISTRY SCRUB STARTED ==="
Log "Target string: $TargetString"

# ---------------------------------------------------------------------
# Relevant registry path filters
# ---------------------------------------------------------------------
$RdpPatterns = @(
    "*MSRDC*",
    "*RemoteDesktop*",
    "*RemoteDesktopPreview*",
    "*WindowsAppRuntime*",
    "*Terminal Services*",
    "*TERMSRV*",
    "*mstsc*",
    "*Workspaces*",
    "*Feeds*",
    "*Subscriptions*",
    "*AADBrokerPlugin*"
)

Function Is-RdpKey {
    param([string]$KeyPath)

    foreach ($pattern in $RdpPatterns) {
        if ($KeyPath -like $pattern) { return $true }
    }
    return $false
}

# ---------------------------------------------------------------------
# ACL FIX + DELETE FUNCTION
# ---------------------------------------------------------------------
Function Remove-RegistryKeySafe {
    param([string]$KeyPath)

    Log "[ACTION] Attempting deletion: $KeyPath"

    try {
        $acl = Get-Acl $KeyPath
        $owner = New-Object System.Security.Principal.NTAccount("Administrators")
        $acl.SetOwner($owner)
        Set-Acl -Path $KeyPath -AclObject $acl
        Log "[SUCCESS] Ownership changed"

        $rule = New-Object System.Security.AccessControl.RegistryAccessRule(
            "Administrators","FullControl",
            "ContainerInherit,ObjectInherit","None","Allow"
        )
        $acl = Get-Acl $KeyPath
        $acl.SetAccessRule($rule)
        Set-Acl -Path $KeyPath -AclObject $acl
        Log "[SUCCESS] ACL updated"

        Remove-Item -Path $KeyPath -Recurse -Force -ErrorAction Stop
        Log "[SUCCESS] Deleted key: $KeyPath"
    }
    catch {
        Log "[ERROR] PowerShell deletion failed: $($_.Exception.Message)"
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

        # Only process RDP/MSRDC-related keys
        if (-not (Is-RdpKey -KeyPath $key.Name)) { continue }

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
        catch {}
    }
}

# ---------------------------------------------------------------------
# EXECUTE SCRUB
# ---------------------------------------------------------------------
$Hives = @(
    "HKLM:\SOFTWARE",
    "HKLM:\SYSTEM",
    "HKCU:\",
    "HKU:\"
)

foreach ($h in $Hives) {
    Search-And-Scrub -Hive $h
}

Log "=== RDP/MSRDC REGISTRY SCRUB COMPLETED ==="
Write-Host "RDP/MSRDC registry scrub completed. Log saved to $LogFile" -ForegroundColor Green
