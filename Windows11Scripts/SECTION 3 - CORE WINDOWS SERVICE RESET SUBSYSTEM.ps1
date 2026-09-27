# ============================================================
# SECTION 3 — CORE WINDOWS SERVICE RESET SUBSYSTEM
# ============================================================

function Reset-CoreWindowsServices
{
    Log `
        -Level "INFO" `
        -Category "ServiceReset" `
        -Operation "InitCoreReset" `
        -Message "Initializing core Windows service reset subsystem."

    # Windows 11 Enterprise 25H2 default startup types
    $defaults = @{
        "wuauserv" = "manual"
        "bits" = "delayed-auto"
        "cryptsvc" = "auto"
        "eventlog" = "auto"
        "themes" = "auto"
        "profsvc" = "auto"
        "gpsvc" = "auto"
        "winmgmt" = "auto"
        "lanmanworkstation" = "auto"
        "lanmanserver" = "auto"
        "dhcp" = "auto"
        "dnscache" = "auto"
        "bfe" = "auto"
        "mpssvc" = "auto"
        "tokenbroker" = "manual"
        "clipsvc" = "manual"
        "appxsvc" = "manual"
        "sppsvc" = "delayed-auto"
        "wsearch" = "delayed-auto"
        "wlansvc" = "auto"
        "dot3svc" = "manual"
        "scardsvr" = "manual"
        "camsvc" = "manual"
        "diagnosticshub.standardcollector.service" = "manual"
    }

    try
    {
        foreach ($svc in $defaults.Keys)
        {
            $desiredType = $defaults[$svc]

            Log `
                -Level "INFO" `
                -Category "ServiceReset" `
                -Operation "SetStartupType" `
                -Message "Attempting to reset service: $svc → $desiredType" `
                -Path $svc

            try
            {
                Set-Service `
                    -Name $svc `
                    -StartupType $desiredType

                Log `
                    -Level "SUCCESS" `
                    -Category "ServiceReset" `
                    -Operation "SetStartupType" `
                    -Message "Startup type set successfully." `
                    -Path $svc
            }#end try block
            catch
            {
                Log `
                    -Level "ERROR" `
                    -Category "ServiceReset" `
                    -Operation "SetStartupType" `
                    -Message "Failed to update service startup type." `
                    -Path $svc `
                    -ExceptionType $_.Exception.GetType().FullName

                Write-Host $_ -ForegroundColor DarkRed
            }#end catch block

        }#end foreach block
    }#end try block
    catch
    {
        Log `
            -Level "ERROR" `
            -Category "ServiceReset" `
            -Operation "InitCoreReset" `
            -Message "Critical failure during core service reset initialization." `
            -ExceptionType $_.Exception.GetType().FullName

        Write-Host $_ -ForegroundColor DarkRed
    }#end catch block

    Log `
        -Level "SUCCESS" `
        -Category "ServiceReset" `
        -Operation "InitCoreReset" `
        -Message "Core Windows service reset subsystem completed."
}#end function Reset-CoreWindowsServices

# ------------------------------------------------------------
# Section header
# ------------------------------------------------------------
Log "INFO" "Init" "CoreServiceSubsystem" "Core Windows service reset subsystem initialized."
# end SECTION 3
