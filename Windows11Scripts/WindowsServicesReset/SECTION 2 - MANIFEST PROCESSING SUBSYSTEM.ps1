# ============================================================
# SECTION 2 — MANIFEST PROCESSING SUBSYSTEM
# ============================================================

Start-DISMHeartbeat -IntervalSeconds 30 -IdleThresholdSeconds 300

function Apply-Manifest
{
    param(
        [string]$ManifestPath
    )

    Log `
        -Level "INFO" `
        -Category "ManifestProcessing" `
        -Operation "ApplyManifest" `
        -Message "Processing manifest: $ManifestPath" `
        -Path $ManifestPath

    try
    {
        $exitCode = Invoke-DISMWithDeadlockDetection `
            -Arguments "/online /add-package /packagepath:`"$ManifestPath`" /quiet" `
            -IdleThresholdSeconds 600

        if ($exitCode -eq 0)
        {
            Log `
                -Level "SUCCESS" `
                -Category "ManifestProcessing" `
                -Operation "ApplyManifest" `
                -Message "Manifest applied successfully." `
                -Path $ManifestPath
        }#end if block
        else
        {
            Log `
                -Level "ERROR" `
                -Category "ManifestProcessing" `
                -Operation "ApplyManifest" `
                -Message "DISM failed or deadlocked for manifest." `
                -Path $ManifestPath `
                -Code $exitCode
        }#end else block
    }#end try block
    catch
    {
        Log `
            -Level "EXCEPTION" `
            -Category "ManifestProcessing" `
            -Operation "ApplyManifest" `
            -Message "Exception thrown while applying manifest." `
            -Path $ManifestPath `
            -ExceptionType $_.Exception.GetType().FullName
    }#end catch block

    <#
    try
    {
        Start-Process `
            -FilePath "dism.exe" `
            -ArgumentList "/online","/add-package","/packagepath:$ManifestPath","/quiet" `
            -Wait `
            -NoNewWindow

        Log `
            -Level "SUCCESS" `
            -Category "ManifestProcessing" `
            -Operation "ApplyManifest" `
            -Message "Manifest applied successfully." `
            -Path $ManifestPath
    }#end try block
    catch
    {
        Log `
            -Level "ERROR" `
            -Category "ManifestProcessing" `
            -Operation "ApplyManifest" `
            -Message "Failed to apply manifest." `
            -Path $ManifestPath `
            -Code "0x80070002" `
            -ExceptionType $_.Exception.GetType().FullName

        Write-Host $_ -ForegroundColor DarkRed
    }#end catch block
    #>
}#end function Apply-Manifest

# ------------------------------------------------------------
# Enumerate and process all manifests
# ------------------------------------------------------------
function Process-AllManifests
{
    $manifestDirectory = "C:\Windows\servicing\Packages"

    Log `
        -Level "INFO" `
        -Category "ManifestProcessing" `
        -Operation "EnumerateManifests" `
        -Message "Scanning manifest directory: $manifestDirectory" `
        -Path $manifestDirectory

    try
    {
        $manifests = Get-ChildItem `
            -Path $manifestDirectory `
            -Filter *.mum `
            -ErrorAction Stop

        Log `
            -Level "INFO" `
            -Category "ManifestProcessing" `
            -Operation "EnumerateManifests" `
            -Message "Found $($manifests.Count) manifests." `
            -Path $manifestDirectory

        foreach ($m in $manifests)
        {
            $manifestPath = $m.FullName

            Log `
                -Level "INFO" `
                -Category "ManifestProcessing" `
                -Operation "QueueManifest" `
                -Message "Queuing manifest for processing: $manifestPath" `
                -Path $manifestPath

            Apply-Manifest -ManifestPath $manifestPath
        }#end foreach block
    }#end try block
    catch
    {
        Log `
            -Level "ERROR" `
            -Category "ManifestProcessing" `
            -Operation "EnumerateManifests" `
            -Message "Failed to enumerate manifests." `
            -Path $manifestDirectory `
            -ExceptionType $_.Exception.GetType().FullName

        Write-Host $_ -ForegroundColor DarkRed
    }#end catch block

}#end function Process-AllManifests

# ------------------------------------------------------------
# Section header
# ------------------------------------------------------------
Log "INFO" "Init" "ManifestSubsystem" "Manifest processing subsystem initialized."
# end SECTION 2