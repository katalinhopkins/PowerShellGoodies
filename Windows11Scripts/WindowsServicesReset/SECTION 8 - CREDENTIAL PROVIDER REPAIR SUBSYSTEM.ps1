# ============================================================
# SECTION 8 — CREDENTIAL PROVIDER REPAIR SUBSYSTEM
# ============================================================

function Repair-CredentialProviders
{
    Log `
        -Level "INFO" `
        -Category "CredentialProviderRepair" `
        -Operation "InitCredRepair" `
        -Message "Starting Credential Provider repair operations."

    # Core Credential Provider DLLs
    $credDlls = @(
        "C:\Windows\System32\credprovhost.dll",
        "C:\Windows\System32\credprovs.dll",
        "C:\Windows\System32\authui.dll",
        "C:\Windows\System32\SmartcardCredentialProvider.dll",
        "C:\Windows\System32\PinEnrollmentProvider.dll",
        "C:\Windows\System32\FaceCredentialProvider.dll",
        "C:\Windows\System32\FingerprintCredentialProvider.dll",
        "C:\Windows\System32\NgcCtnr.dll",
        "C:\Windows\System32\NgcCtnrSvc.dll"
    )

    try
    {
        foreach ($dll in $credDlls)
        {
            Log `
                -Level "INFO" `
                -Category "CredentialProviderRepair" `
                -Operation "RegisterDLL" `
                -Message "Attempting to re-register Credential Provider DLL: $dll" `
                -Path $dll

            try
            {
                regsvr32.exe /s $dll

                Log `
                    -Level "SUCCESS" `
                    -Category "CredentialProviderRepair" `
                    -Operation "RegisterDLL" `
                    -Message "Credential Provider DLL registered successfully." `
                    -Path $dll
            }#end try block
            catch
            {
                Log `
                    -Level "ERROR" `
                    -Category "CredentialProviderRepair" `
                    -Operation "RegisterDLL" `
                    -Message "Failed to register Credential Provider DLL." `
                    -Path $dll `
                    -ExceptionType $_.Exception.GetType().FullName

                Write-Host $_ -ForegroundColor DarkRed
            }#end catch block

        }#end foreach block
    }#end try block
    catch
    {
        Log `
            -Level "ERROR" `
            -Category "CredentialProviderRepair" `
            -Operation "InitCredRepair" `
            -Message "Critical failure during Credential Provider repair." `
            -ExceptionType $_.Exception.GetType().FullName

        Write-Host $_ -ForegroundColor DarkRed
    }#end catch block

    Log `
        -Level "SUCCESS" `
        -Category "CredentialProviderRepair" `
        -Operation "InitCredRepair" `
        -Message "Credential Provider repair subsystem completed."
}#end function Repair-CredentialProviders

# ------------------------------------------------------------
# Section header
# ------------------------------------------------------------
Log "INFO" "Init" "CredentialProviderSubsystem" "Credential Provider repair subsystem initialized."
# end SECTION 8
