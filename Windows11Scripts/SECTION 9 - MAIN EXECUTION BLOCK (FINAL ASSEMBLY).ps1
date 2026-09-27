# ============================================================
# SECTION 9 — MAIN EXECUTION BLOCK (FINAL ASSEMBLY)
# ============================================================

function Run-FullSystemRepair
{
    Log `
        -Level "INFO" `
        -Category "SystemRepair" `
        -Operation "InitFullRepair" `
        -Message "Starting full Windows 11 Enterprise 25H2 repair sequence."

    try
    {
        # ------------------------------------------------------------
        # 1. Manifest Processing
        # ------------------------------------------------------------
        Log `
            -Level "INFO" `
            -Category "SystemRepair" `
            -Operation "ManifestProcessing" `
            -Message "Executing manifest processing subsystem."

        Process-AllManifests

        # ------------------------------------------------------------
        # 2. Core Windows Service Reset
        # ------------------------------------------------------------
        Log `
            -Level "INFO" `
            -Category "SystemRepair" `
            -Operation "CoreServiceReset" `
            -Message "Executing core Windows service reset subsystem."

        Reset-CoreWindowsServices

        # ------------------------------------------------------------
        # 3. Duplicate Per-User Service Cleanup
        # ------------------------------------------------------------
        Log `
            -Level "INFO" `
            -Category "SystemRepair" `
            -Operation "DuplicateCleanup" `
            -Message "Executing duplicate per-user service cleanup subsystem."

        Remove-DuplicateUserServices

        # ------------------------------------------------------------
        # 4. Third-Party Service Removal
        # ------------------------------------------------------------
        Log `
            -Level "INFO" `
            -Category "SystemRepair" `
            -Operation "ThirdPartyCleanup" `
            -Message "Executing third-party service cleanup subsystem."

        Remove-ThirdPartyServices

        # ------------------------------------------------------------
        # 5. WMI Repository Repair
        # ------------------------------------------------------------
        Log `
            -Level "INFO" `
            -Category "SystemRepair" `
            -Operation "WMIRepair" `
            -Message "Executing WMI repository repair subsystem."

        Repair-WMIRepository

        # ------------------------------------------------------------
        # 6. Windows Update Repair
        # ------------------------------------------------------------
        Log `
            -Level "INFO" `
            -Category "SystemRepair" `
            -Operation "WindowsUpdateRepair" `
            -Message "Executing Windows Update repair subsystem."

        Repair-WindowsUpdate

        # ------------------------------------------------------------
        # 7. Credential Provider Repair
        # ------------------------------------------------------------
        Log `
            -Level "INFO" `
            -Category "SystemRepair" `
            -Operation "CredentialProviderRepair" `
            -Message "Executing Credential Provider repair subsystem."

        Repair-CredentialProviders

        # ------------------------------------------------------------
        # Final success
        # ------------------------------------------------------------
        Log `
            -Level "SUCCESS" `
            -Category "SystemRepair" `
            -Operation "InitFullRepair" `
            -Message "Full Windows 11 Enterprise 25H2 repair sequence completed successfully."
    }#end try block
    catch
    {
        Log `
            -Level "ERROR" `
            -Category "SystemRepair" `
            -Operation "InitFullRepair" `
            -Message "Critical failure during full repair sequence." `
            -ExceptionType $_.Exception.GetType().FullName

        Write-Host $_ -ForegroundColor DarkRed
    }#end catch block

}#end function Run-FullSystemRepair

# ------------------------------------------------------------
# Section header
# ------------------------------------------------------------
Log "INFO" "Init" "MainExecutionBlock" "Main execution block initialized."
# end SECTION 9

