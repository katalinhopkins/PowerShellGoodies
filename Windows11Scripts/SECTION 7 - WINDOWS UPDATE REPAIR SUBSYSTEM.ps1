# ============================================================
# SECTION 7 — WINDOWS UPDATE REPAIR SUBSYSTEM
# ============================================================

function Repair-WindowsUpdate
{
    Log `
        -Level "INFO" `
        -Category "WindowsUpdateRepair" `
        -Operation "InitWURepair" `
        -Message "Starting Windows Update repair operations."

    try
    {
        # ------------------------------------------------------------
        # Stop Windows Update services
        # ------------------------------------------------------------
        Log `
            -Level "INFO" `
            -Category "WindowsUpdateRepair" `
            -Operation "StopServices" `
            -Message "Stopping Windows Update services (wuauserv, bits)."

        try
        {
            Stop-Service -Name wuauserv -Force -ErrorAction Stop
            Stop-Service -Name bits -Force -ErrorAction Stop

            Log `
                -Level "SUCCESS" `
                -Category "WindowsUpdateRepair" `
                -Operation "StopServices" `
                -Message "Successfully stopped Windows Update services."
        }#end try block
        catch
        {
            Log `
                -Level "ERROR" `
                -Category "WindowsUpdateRepair" `
                -Operation "StopServices" `
                -Message "Failed to stop Windows Update services." `
                -ExceptionType $_.Exception.GetType().FullName

            Write-Host $_ -ForegroundColor DarkRed
        }#end catch block

        # ------------------------------------------------------------
        # Clear SoftwareDistribution
        # ------------------------------------------------------------
        $sdPath = "C:\Windows\SoftwareDistribution"

        Log `
            -Level "INFO" `
            -Category "WindowsUpdateRepair" `
            -Operation "ClearSoftwareDistribution" `
            -Message "Clearing SoftwareDistribution folder." `
            -Path $sdPath

        try
        {
            Remove-Item -Path $sdPath -Recurse -Force -ErrorAction Stop

            Log `
                -Level "SUCCESS" `
                -Category "WindowsUpdateRepair" `
                -Operation "ClearSoftwareDistribution" `
                -Message "SoftwareDistribution folder cleared." `
                -Path $sdPath
        }#end try block
        catch
        {
            Log `
                -Level "ERROR" `
                -Category "WindowsUpdateRepair" `
                -Operation "ClearSoftwareDistribution" `
                -Message "Failed to clear SoftwareDistribution folder." `
                -Path $sdPath `
                -ExceptionType $_.Exception.GetType().FullName

            Write-Host $_ -ForegroundColor DarkRed
        }#end catch block

        # ------------------------------------------------------------
        # Clear catroot2
        # ------------------------------------------------------------
        $catrootPath = "C:\Windows\System32\catroot2"

        Log `
            -Level "INFO" `
            -Category "WindowsUpdateRepair" `
            -Operation "ClearCatroot2" `
            -Message "Clearing catroot2 folder." `
            -Path $catrootPath

        try
        {
            Remove-Item -Path $catrootPath -Recurse -Force -ErrorAction Stop

            Log `
                -Level "SUCCESS" `
                -Category "WindowsUpdateRepair" `
                -Operation "ClearCatroot2" `
                -Message "catroot2 folder cleared." `
                -Path $catrootPath
        }#end try block
        catch
        {
            Log `
                -Level "ERROR" `
                -Category "WindowsUpdateRepair" `
                -Operation "ClearCatroot2" `
                -Message "Failed to clear catroot2 folder." `
                -Path $catrootPath `
                -ExceptionType $_.Exception.GetType().FullName

            Write-Host $_ -ForegroundColor DarkRed
        }#end catch block

        # ------------------------------------------------------------
        # Restart Windows Update services
        # ------------------------------------------------------------
        Log `
            -Level "INFO" `
            -Category "WindowsUpdateRepair" `
            -Operation "StartServices" `
            -Message "Restarting Windows Update services."

        try
        {
            Start-Service -Name wuauserv -ErrorAction Stop
            Start-Service -Name bits -ErrorAction Stop

            Log `
                -Level "SUCCESS" `
                -Category "WindowsUpdateRepair" `
                -Operation "StartServices" `
                -Message "Windows Update services restarted successfully."
        }#end try block
        catch
        {
            Log `
                -Level "ERROR" `
                -Category "WindowsUpdateRepair" `
                -Operation "StartServices" `
                -Message "Failed to restart Windows Update services." `
                -ExceptionType $_.Exception.GetType().FullName

            Write-Host $_ -ForegroundColor DarkRed
        }#end catch block

    }#end try block
    catch
    {
        Log `
            -Level "ERROR" `
            -Category "WindowsUpdateRepair" `
            -Operation "InitWURepair" `
            -Message "Critical failure during Windows Update repair." `
            -ExceptionType $_.Exception.GetType().FullName

        Write-Host $_ -ForegroundColor DarkRed
    }#end catch block

    Log `
        -Level "SUCCESS" `
        -Category "WindowsUpdateRepair" `
        -Operation "InitWURepair" `
        -Message "Windows Update repair subsystem completed."
}#end function Repair-WindowsUpdate

# ------------------------------------------------------------
# Section header
# ------------------------------------------------------------
Log "INFO" "Init" "WindowsUpdateRepairSubsystem" "Windows Update repair subsystem initialized."
# end SECTION 7
