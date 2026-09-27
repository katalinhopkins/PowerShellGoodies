# ============================================================
# UnifiedWindows11RemoteDesktopResetScript
# UNIFIED WINDOWS 11 REMOTE DESKTOP RESET SCRIPT
# Server-side + Client-side + MSRDC + MSTSC + Firewall
# Safe for Windows 10/11 (all builds)
# ============================================================

Write-Host "Stopping Remote Desktop Services..." -ForegroundColor Yellow
Stop-Service TermService -Force -ErrorAction SilentlyContinue

# ============================================================
# TERMINAL SERVER / RDP LISTENER RESET (SAFE)
# ============================================================

Write-Host "Resetting Terminal Server keys..." -ForegroundColor Yellow

$tsPaths = @(
    "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp",
    "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\RDP",
    "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\DefaultUserConfiguration",
    "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\AddIns",
    "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\ClusterSettings",
    "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\Licensing Core",
    "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\Utilities"
)

foreach ($path in $tsPaths)
{
    if (Test-Path $path)
    {
        Write-Host "Removing: $path" -ForegroundColor Cyan
        Remove-Item -Path $path -Recurse -Force
    }
    else
    {
        Write-Host "Skipping missing key: $path" -ForegroundColor DarkGray
    }
}

Write-Host "Recreating RDP-Tcp listener container..." -ForegroundColor Yellow
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /f

# ============================================================
# GROUP POLICY RDP SETTINGS RESET
# ============================================================

Write-Host "Removing GP-applied RDP policies..." -ForegroundColor Yellow

$gpPaths = @(
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services",
    "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\RemoteDesktop"
)

foreach ($path in $gpPaths)
{
    if (Test-Path $path)
    {
        Write-Host "Removing: $path" -ForegroundColor Cyan
        Remove-Item -Path $path -Recurse -Force
    }
    else
    {
        Write-Host "Skipping missing GP key: $path" -ForegroundColor DarkGray
    }
}

# ============================================================
# NLA / CREDSSP / SECURITY RESET
# ============================================================

Write-Host "Resetting NLA and security layers..." -ForegroundColor Yellow

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v SecurityLayer /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 1 /f

# ============================================================
# REMOTEFX + REDIRECTION RESET (WINDOWS 11 SAFE)
# ============================================================

Write-Host "Resetting RemoteFX and redirection..." -ForegroundColor Yellow

$remoteFxPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Terminal Server\TSAppCompat",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\DeviceRedirection",
    "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\AddIns\RDPDR",
    "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\AddIns\RDPENH"
)

foreach ($path in $remoteFxPaths)
{
    if (Test-Path $path)
    {
        Write-Host "Removing: $path" -ForegroundColor Cyan
        Remove-Item -Path $path -Recurse -Force
    }
    else
    {
        Write-Host "Skipping missing RemoteFX key: $path" -ForegroundColor DarkGray
    }
}

# ============================================================
# FIREWALL RESET (WINDOWS 11 SAFE)
# ============================================================

Write-Host "Resetting RDP firewall rules..." -ForegroundColor Yellow

Get-NetFirewallRule |
    Where-Object {
        $_.DisplayName -like "*Remote Desktop*" -or
        $_.DisplayName -like "*RDP*" -or
        $_.Group -like "*Remote Desktop*" -or
        $_.Group -like "*RemoteDesktop*"
    } |
    Remove-NetFirewallRule -ErrorAction SilentlyContinue

$rdpBuiltinRules = @(
    "RemoteDesktop-UserMode-In-TCP",
    "RemoteDesktop-UserMode-In-UDP",
    "RemoteDesktop-Shadow-In-TCP",
    "RemoteDesktop-Services-In-TCP",
    "RemoteDesktop-Services-In-UDP"
)

foreach ($rule in $rdpBuiltinRules)
{
    Write-Host "Enabling built-in rule: $rule" -ForegroundColor Cyan
    Enable-NetFirewallRule -Name $rule -ErrorAction SilentlyContinue
}

Get-NetFirewallRule |
    Where-Object { $_.Group -like "*Remote Desktop Services*" } |
    Enable-NetFirewallRule -ErrorAction SilentlyContinue

# ============================================================
# CLIENT RESET: MSTSC + MSRDC (WINDOWS APP)
# ============================================================

Write-Host "Stopping client processes..." -ForegroundColor Yellow
Get-Process mstsc -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process msrdc -ErrorAction SilentlyContinue | Stop-Process -Force

# MSTSC reset
$mstscRegPaths = @(
    "HKCU:\Software\Microsoft\Terminal Server Client",
    "HKCU:\Software\Microsoft\Terminal Server Client\Default",
    "HKCU:\Software\Microsoft\Terminal Server Client\Servers",
    "HKCU:\Software\Microsoft\Terminal Server Client\LocalDevices",
    "HKLM:\Software\Microsoft\Terminal Server Client"
)

foreach ($path in $mstscRegPaths)
{
    if (Test-Path $path)
    {
        Write-Host "Removing MSTSC registry: $path" -ForegroundColor Cyan
        Remove-Item -Path $path -Recurse -Force
    }
}

$mstscCache = "$env:LOCALAPPDATA\Microsoft\Terminal Server Client\Cache"
if (Test-Path $mstscCache)
{
    Write-Host "Clearing MSTSC cache..." -ForegroundColor Cyan
    Remove-Item $mstscCache -Recurse -Force
}

# MSRDC reset
$msrdcPaths = @(
    "$env:LOCALAPPDATA\Microsoft\MSRDC",
    "$env:LOCALAPPDATA\Microsoft\RemoteDesktop",
    "$env:LOCALAPPDATA\Microsoft\WindowsApp\MSRDC",
    "$env:APPDATA\Microsoft\MSRDC",
    "$env:APPDATA\Microsoft\RemoteDesktop"
)

foreach ($path in $msrdcPaths)
{
    if (Test-Path $path)
    {
        Write-Host "Removing MSRDC data: $path" -ForegroundColor Cyan
        Remove-Item -Path $path -Recurse -Force
    }
}

# TERMSRV credentials
Write-Host "Clearing saved TERMSRV credentials..." -ForegroundColor Yellow
cmdkey /list | Select-String "TERMSRV/" | ForEach-Object {
    $target = $_.ToString().Split(" : ")[-1].Trim()
    Write-Host "Deleting credential: $target" -ForegroundColor Cyan
    cmdkey /delete:$target | Out-Null
}

# ============================================================
# RESTART SERVICES
# ============================================================

Write-Host "Restarting Remote Desktop Services..." -ForegroundColor Yellow
Start-Service TermService -ErrorAction SilentlyContinue

gpupdate /force

# ============================================================
# REBOOT PROMPT
# ============================================================

Write-Host ""
Write-Host "----------------------------------------"
Write-Host "Remote Desktop reset completed."
Write-Host "Do you want to reboot now? (Y/N)"
Write-Host "----------------------------------------"
Write-Host ""

$choice = Read-Host "Enter choice"

switch ($choice.ToUpper())
{
    "Y"
    {
        Write-Host "Rebooting system..." -ForegroundColor Yellow
        Restart-Computer -Force
    }
    "N"
    {
        Write-Host "Reboot skipped. You may reboot later." -ForegroundColor Green
    }
    default
    {
        Write-Host "Invalid choice. Reboot skipped." -ForegroundColor DarkYellow
    }
}
