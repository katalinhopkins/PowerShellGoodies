# ============================================================
# SECTION 6 — WMI REPOSITORY REPAIR SUBSYSTEM
# ============================================================

function Repair-WMIRepository
{
    Log `
        -Level "INFO" `
        -Category "WMIRepair" `
        -Operation "InitWMIRepair" `
        -Message "Starting WMI repository verification and repair."

    try
    {
        Log `
            -Level "INFO" `
            -Category "WMIRepair" `
            -Operation "VerifyRepository" `
            -Message "Verifying WMI repository integrity."

        $verifyResult = winmgmt /verifyrepository

        Log `
            -Level "INFO" `
            -Category "WMIRepair" `
            -Operation "VerifyRepository" `
            -Message "WMI verification result: $verifyResult"

        Log `
            -Level "WARN" `
            -Category "WMIRepair" `
            -Operation "SalvageRepository" `
            -Message "Attempting WMI repository salvage."

        $salvageResult = winmgmt /salvagerepository

        Log `
            -Level "SUCCESS" `
            -Category "WMIRepair" `
            -Operation "SalvageRepository" `
            -Message "WMI repository salvage completed successfully." `
            -Details $salvageResult
    }#end try block
    catch
    {
        Log `
            -Level "ERROR" `
            -Category "WMIRepair" `
            -Operation "InitWMIRepair" `
            -Message "Critical failure during WMI repository repair." `
            -ExceptionType $_.Exception.GetType().FullName

        Write-Host $_ -ForegroundColor DarkRed
    }#end catch block

    Log `
        -Level "SUCCESS" `
        -Category "WMIRepair" `
        -Operation "InitWMIRepair" `
        -Message "WMI repository repair subsystem completed."
}#end function Repair-WMIRepository

# ------------------------------------------------------------
# Section header
# ------------------------------------------------------------
Log "INFO" "Init" "WMIRepairSubsystem" "WMI repository repair subsystem initialized."
# end SECTION 6
