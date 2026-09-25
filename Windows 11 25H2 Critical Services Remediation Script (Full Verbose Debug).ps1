# Windows 11 25H2 Critical Services Remediation Script (Full Verbose Debug)
# Personal Laptop Version (LG Gram 16")
# Run as Administrator.

$CriticalServices25H2 = @(
    @{ Name = "WinDefend"; Startup = "Automatic"; StartService = $true }
    @{ Name = "SecurityHealthService"; Startup = "Automatic"; StartService = $true }
    @{ Name = "WaaSMedicSvc"; Startup = "Automatic"; StartService = $true }
    @{ Name = "TrustedInstaller"; Startup = "Manual"; StartService = $false }
    @{ Name = "AppXSvc"; Startup = "Manual"; StartService = $false }
    @{ Name = "ClipSVC"; Startup = "Manual"; StartService = $false }
    @{ Name = "TokenBroker"; Startup = "Manual"; StartService = $false }
    @{ Name = "LSASS"; Startup = "Automatic"; StartService = $false }
    @{ Name = "UserManager"; Startup = "Automatic"; StartService = $true }
    @{ Name = "Dnscache"; Startup = "Automatic"; StartService = $true }
    @{ Name = "Dhcp"; Startup = "Automatic"; StartService = $true }
    @{ Name = "NlaSvc"; Startup = "Automatic"; StartService = $true }
    @{ Name = "LanmanWorkstation"; Startup = "Automatic"; StartService = $true }
    @{ Name = "LanmanServer"; Startup = "Automatic"; StartService = $true }
    @{ Name = "WinHttpAutoProxySvc"; Startup = "Manual"; StartService = $false }
    @{ Name = "IKEEXT"; Startup = "Automatic"; StartService = $true }
    @{ Name = "WlanSvc"; Startup = "Automatic"; StartService = $true }
    @{ Name = "wuauserv"; Startup = "Manual"; StartService = $false }
    @{ Name = "BITS"; Startup = "Automatic"; StartService = $true }
    @{ Name = "DoSvc"; Startup = "Automatic"; StartService = $true }
    @{ Name = "UsoSvc"; Startup = "Automatic"; StartService = $true }
    @{ Name = "ShellHWDetection"; Startup = "Automatic"; StartService = $true }
    @{ Name = "Themes"; Startup = "Automatic"; StartService = $true }
    @{ Name = "StateRepository"; Startup = "Automatic"; StartService = $true }
    @{ Name = "WSearch"; Startup = "Automatic"; StartService = $true }
    @{ Name = "SysMain"; Startup = "Automatic"; StartService = $true }
    @{ Name = "DsmSvc"; Startup = "Manual"; StartService = $false }
    @{ Name = "PlugPlay"; Startup = "Automatic"; StartService = $true }
    @{ Name = "bthserv"; Startup = "Manual"; StartService = $false }
    @{ Name = "Spooler"; Startup = "Automatic"; StartService = $true }
    @{ Name = "TimeBrokerSvc"; Startup = "Automatic"; StartService = $true }
    @{ Name = "CryptSvc"; Startup = "Automatic"; StartService = $true }
    @{ Name = "KeyIso"; Startup = "Manual"; StartService = $false }
    @{ Name = "MpsSvc"; Startup = "Automatic"; StartService = $true }
    @{ Name = "VaultSvc"; Startup = "Manual"; StartService = $false }
    @{ Name = "TPM"; Startup = "Manual"; StartService = $false }
    @{ Name = "Schedule"; Startup = "Automatic"; StartService = $true }
    @{ Name = "EventLog"; Startup = "Automatic"; StartService = $true }
    @{ Name = "W32Time"; Startup = "Manual"; StartService = $false }
    @{ Name = "EventSystem"; Startup = "Automatic"; StartService = $true }
    @{ Name = "RpcSs"; Startup = "Automatic"; StartService = $false }
)

# Windows 11 25H2 protected services (startup type cannot be modified)
$ProtectedServices = @(
    "RpcSs",
    "LSASS",
    "WinDefend",
    "TrustedInstaller",
    "SecurityHealthService",
    "StateRepository",
    "SysMain",
    "WSearch",
    "AppXSvc",
    "WaaSMedicSvc"
)

function Debug-Error {
    param(
        [string]$Context,
        [System.Management.Automation.ErrorRecord]$Error
    )

    $ex = $Error.Exception

    Write-Host "`n[ERROR] Context: $Context" -ForegroundColor Red
    Write-Host "Message: $($ex.Message)" -ForegroundColor Red
    Write-Host "Exception Type: $($ex.GetType().FullName)" -ForegroundColor Red
    Write-Host "Source: $($ex.Source)" -ForegroundColor Red
    Write-Host "TargetSite: $($ex.TargetSite)" -ForegroundColor Red
    Write-Host "StackTrace:" -ForegroundColor DarkRed
    Write-Host $ex.StackTrace -ForegroundColor DarkRed
    Write-Host "Suggested Cause: Protected service, registry ACL, or service security hardening." -ForegroundColor Yellow
    Write-Host ""
}

function Set-ServiceStartupType {
    param(
        [string]$ServiceName,
        [string]$StartupType
    )

    Write-Host "`n[DEBUG] Setting startup type for $ServiceName" -ForegroundColor Cyan
    Write-Host "Expected Startup Type: $StartupType" -ForegroundColor Cyan

    if ($ProtectedServices -contains $ServiceName) {
        Write-Host "[PROTECTED] $ServiceName is a Windows 11 25H2 protected service." -ForegroundColor Yellow
        Write-Host "[PROTECTED] Startup type cannot be modified." -ForegroundColor Yellow
        return
    }

    switch ($StartupType) {
        "Automatic" { $startValue = 2 }
        "Manual"    { $startValue = 3 }
        "Disabled"  { $startValue = 4 }
        default     { $startValue = $null }
    }

    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName"
    Write-Host "Registry Path: $regPath" -ForegroundColor Cyan

    try {
        $acl = Get-Acl -Path $regPath -ErrorAction Stop

        if ($acl.AccessToString -match "DENY" -or
            ($acl.AccessToString -match "ReadKey" -and -not ($acl.AccessToString -match "WriteKey"))) {

            Write-Host "[PROTECTED] ACL prevents modifying $ServiceName startup type." -ForegroundColor Yellow
            return
        }
    }
    catch {
        Debug-Error -Context "Checking ACL for $ServiceName" -Error $_
        return
    }

    try {
        Set-ItemProperty -Path $regPath -Name Start -Value $startValue -ErrorAction Stop
        Write-Host "[FIXED] Startup type set: $ServiceName → $StartupType (Value: $startValue)" -ForegroundColor Green
    }
    catch {
        Debug-Error -Context "Setting startup type for $ServiceName" -Error $_
    }
}

Write-Host "`n=== Windows 11 25H2 Critical Services Remediation (Full Verbose Debug Mode) ===`n"

foreach ($svc in $CriticalServices25H2) {

    Write-Host "`n------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "[DEBUG] Processing service: $($svc.Name)" -ForegroundColor White

    $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue

    if (-not $service) {
        Write-Host "[MISSING] $($svc.Name) - Service not found" -ForegroundColor Red
        continue
    }

    Set-ServiceStartupType -ServiceName $svc.Name -StartupType $svc.Startup

    if ($svc.StartService -and $service.Status -ne "Running" -and -not ($ProtectedServices -contains $svc.Name)) {

        Write-Host "[DEBUG] Attempting to start service: $($svc.Name)" -ForegroundColor Cyan
        Write-Host "StartService Policy: $($svc.StartService)" -ForegroundColor Cyan
        Write-Host "Expected Startup Type: $($svc.Startup)" -ForegroundColor Cyan

        try {
            Start-Service -Name $svc.Name -ErrorAction Stop
            Start-Sleep -Milliseconds 500

            $updated = Get-Service -Name $svc.Name

            Write-Host "[STARTED] $($svc.Name)" -ForegroundColor Green
            Write-Host "Post-Start Status: $($updated.Status)" -ForegroundColor Green
            Write-Host "Startup Type (Expected): $($svc.Startup)" -ForegroundColor Green
            Write-Host "StartService Policy: $($svc.StartService)" -ForegroundColor Green
        }
        catch {
            Debug-Error -Context "Starting service $($svc.Name)" -Error $_
        }
    }
    elseif (-not $svc.StartService) {
        Write-Host "[INFO] Start skipped by policy for $($svc.Name)" -ForegroundColor Yellow
    }
    else {
        Write-Host "[OK] $($svc.Name) already running or protected from start/stop." -ForegroundColor Green
    }
}

Write-Host "`nRemediation complete. A reboot is recommended.`n"
