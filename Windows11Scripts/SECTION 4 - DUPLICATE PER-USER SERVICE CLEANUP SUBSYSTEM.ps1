# ============================================================
# SECTION 4 — DUPLICATE PER-USER SERVICE CLEANUP SUBSYSTEM
# ============================================================

function Remove-DuplicateUserServices
{
    Log `
        -Level "INFO" `
        -Category "DuplicateCleanup" `
        -Operation "InitDuplicateScan" `
        -Message "Scanning for duplicated per-user services."

    try
    {
        # Services ending with _xxxxxxx (hex suffix)
        $duplicatePattern = "_[0-9a-f]{6}$"

        $duplicateServices = Get-Service `
            | Where-Object { $_.Name -match $duplicatePattern }

        Log `
            -Level "INFO" `
            -Category "DuplicateCleanup" `
            -Operation "InitDuplicateScan" `
            -Message "Found $($duplicateServices.Count) duplicated per-user services."

        foreach ($svc in $duplicateServices)
        {
            $svcName = $svc.Name

            Log `
                -Level "WARN" `
                -Category "DuplicateCleanup" `
                -Operation "QueueDelete" `
                -Message "Queuing duplicated service for deletion: $svcName" `
                -Path $svcName

            try
            {
                sc.exe delete $svcName | Out-Null

                Log `
                    -Level "SUCCESS" `
                    -Category "DuplicateCleanup" `
                    -Operation "DeleteService" `
                    -Message "Deleted duplicated per-user service." `
                    -Path $svcName
            }#end try block
            catch
            {
                Log `
                    -Level "ERROR" `
                    -Category "DuplicateCleanup" `
                    -Operation "DeleteService" `
                    -Message "Failed to delete duplicated per-user service." `
                    -Path $svcName `
                    -ExceptionType $_.Exception.GetType().FullName

                Write-Host $_ -ForegroundColor DarkRed
            }#end catch block

        }#end foreach block
    }#end try block
    catch
    {
        Log `
            -Level "ERROR" `
            -Category "DuplicateCleanup" `
            -Operation "InitDuplicateScan" `
            -Message "Critical failure during duplicate service scan." `
            -ExceptionType $_.Exception.GetType().FullName

        Write-Host $_ -ForegroundColor DarkRed
    }#end catch block

    Log `
        -Level "SUCCESS" `
        -Category "DuplicateCleanup" `
        -Operation "InitDuplicateScan" `
        -Message "Duplicate per-user service cleanup completed."
}#end function Remove-DuplicateUserServices

# ------------------------------------------------------------
# Section header
# ------------------------------------------------------------
Log "INFO" "Init" "DuplicateCleanupSubsystem" "Duplicate per-user service cleanup subsystem initialized."
# end SECTION 4
