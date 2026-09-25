# Windows 11 25H2 Critical Services Remediation Script (Verbose Debug Edition)
# Author: Copilot for Katalin
# Purpose: Restore correct startup types and safely start critical services
# NOTE: Run as Administrator.

$CriticalServices25H2 = @(
    @{ Name = "WinDefend"; Startup = "Automatic"; StartService = $true }
    @{ Name = "SecurityHealthService"; Startup = "Automatic"; StartService = $true }
    @{ Name = "WaaSMedicSvc"; Startup = "Automatic"; StartService = $true }
    @{ Name = "TrustedInstaller"; Startup = "Manual"; StartService = $false }
    @{ Name = "AppXSvc"; Startup = "Manual"; StartService = $false }
    @{ Name = "ClipSVC"; Startup = "Manual"; StartService = $false }
    @{ Name = "TokenBroker"; Startup = "Manual"; StartService = $false }
    @{ Name = "LSASS"; Startup = "Automatic"; StartService = $false }      # NEVER touch LSASS
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
    @{ Name = "Spooler"; Startup = "Automatic"; StartService = $true }     # 25H2: WPP identity enforced
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
    @{ Name = "RpcSs"; Startup = "Automatic"; StartService = $false }      # NEVER touch RPC
)

<#
function Debug-Error {
    param(
        [string]$Context,
        [System.Exception]$Error
    )

    Write-Host "`n[ERROR] Context: $Context" -ForegroundColor Red
    Write-Host "Message: $($Error.Message)" -ForegroundColor Red
    Write-Host "Exception Type: $($Error.GetType().FullName)" -ForegroundColor Red
    Write-Host "Source: $($Error.Source)" -ForegroundColor Red
    Write-Host "TargetSite: $($Error.TargetSite)" -ForegroundColor Red
    Write-Host "StackTrace:" -ForegroundColor Red
    Write-Host $Error.StackTrace -ForegroundColor DarkRed
    Write-Host "Suggested Cause: Permission issue, corrupted registry entry, or service protection." -ForegroundColor Yellow
    Write-Host ""
}
#>
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

    switch ($StartupType) {
        "Automatic" { $startValue = 2 }
        "Manual"    { $startValue = 3 }
        "Disabled"  { $startValue = 4 }
        default     { $startValue = $null }
    }

    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName"

    Write-Host "`n[DEBUG] Setting startup type for $ServiceName" -ForegroundColor Cyan
    Write-Host "Expected Startup Type: $StartupType" -ForegroundColor Cyan
    Write-Host "Registry Path: $regPath" -ForegroundColor Cyan

    try {
        if (Test-Path $regPath) {
            Set-ItemProperty -Path $regPath -Name Start -Value $startValue -ErrorAction Stop
            Write-Host "[FIXED] Startup type set: $ServiceName → $StartupType (Value: $startValue)" -ForegroundColor Green
        } else {
            Write-Host "[MISSING] Registry path not found: $regPath" -ForegroundColor Red
        }
    }
    catch {
        Debug-Error -Context "Setting startup type for $ServiceName" -Error $_
    }
}

Write-Host "`n=== Windows 11 25H2 Critical Services Remediation (Verbose Debug Mode) ===`n"

foreach ($svc in $CriticalServices25H2) {

    Write-Host "`n------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "[DEBUG] Processing service: $($svc.Name)" -ForegroundColor White

    $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue

    if (-not $service) {
        Write-Host "[MISSING] $($svc.Name) - Service not found" -ForegroundColor Red
        continue
    }

    # 1. Fix startup type
    Set-ServiceStartupType -ServiceName $svc.Name -StartupType $svc.Startup

    # 2. Start service if allowed
    if ($svc.StartService -and $service.Status -ne "Running") {

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
        Write-Host "[OK] $($svc.Name) already running" -ForegroundColor Green
    }
}

Write-Host "`nRemediation complete. A reboot is recommended.`n"
