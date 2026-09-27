# ============================================================
# SECTION 5 — THIRD-PARTY SERVICE REMOVAL SUBSYSTEM
# ============================================================

function Remove-ThirdPartyServices
{
    Log `
        -Level "INFO" `
        -Category "ThirdPartyCleanup" `
        -Operation "InitThirdPartyScan" `
        -Message "Scanning for third-party and OEM services."

    # Known non-Windows services (expandable)
    $thirdPartyServices = @(
        "ExpressVPNService",
        "ExpressVPNUpdate",
        "Fing.Agent",
        "TechSmithUploaderService",
        "AdobeUpdateService",
        "AdobeARMservice",
        "GoogleUpdaterService",
        "GoogleUpdaterInternalService",
        "Everything",
        "LGUWPService",
        "MaximAudioService",
        "RealtekAudioUniversalService",
        "DolbyDAXAPI",
        "InputDirector",
        "IntuitUpdateService",
        "CanonUpdate",
        "CanonService",
        "BrotherService",
        "GamingServices",
        "GamingServicesNet",
        "WebThreatDefense",
        "WebThreatDefenseUserService",
        "IntelAnalyticsService",
        "IntelTelemetryService"
    )

    try
    {
        foreach ($svcName in $thirdPartyServices)
        {
            Log `
                -Level "INFO" `
                -Category "ThirdPartyCleanup" `
                -Operation "CheckService" `
                -Message "Checking for service: $svcName" `
                -Path $svcName

            $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue

            if ($null -ne $svc)
            {
                Log `
                    -Level "WARN" `
                    -Category "ThirdPartyCleanup" `
                    -Operation "QueueDelete" `
                    -Message "Third-party service detected and queued for deletion: $svcName" `
                    -Path $svcName

                try
                {
                    sc.exe delete $svcName | Out-Null

                    Log `
                        -Level "SUCCESS" `
                        -Category "ThirdPartyCleanup" `
                        -Operation "DeleteService" `
                        -Message "Deleted third-party service." `
                        -Path $svcName
                }#end try block
                catch
                {
                    Log `
                        -Level "ERROR" `
                        -Category "ThirdPartyCleanup" `
                        -Operation "DeleteService" `
                        -Message "Failed to delete third-party service." `
                        -Path $svcName `
                        -ExceptionType $_.Exception.GetType().FullName

                    Write-Host $_ -ForegroundColor DarkRed
                }#end catch block
            }#end if block
            else
            {
                Log `
                    -Level "INFO" `
                    -Category "ThirdPartyCleanup" `
                    -Operation "CheckService" `
                    -Message "Service not present: $svcName" `
                    -Path $svcName
            }#end else block

        }#end foreach block
    }#end try block
    catch
    {
        Log `
            -Level "ERROR" `
            -Category "ThirdPartyCleanup" `
            -Operation "InitThirdPartyScan" `
            -Message "Critical failure during third-party service scan." `
            -ExceptionType $_.Exception.GetType().FullName

        Write-Host $_ -ForegroundColor DarkRed
    }#end catch block

    Log `
        -Level "SUCCESS" `
        -Category "ThirdPartyCleanup" `
        -Operation "InitThirdPartyScan" `
        -Message "Third-party service cleanup completed."
}#end function Remove-ThirdPartyServices

# ------------------------------------------------------------
# Section header
# ------------------------------------------------------------
Log "INFO" "Init" "ThirdPartyCleanupSubsystem" "Third-party service cleanup subsystem initialized."
# end SECTION 5
