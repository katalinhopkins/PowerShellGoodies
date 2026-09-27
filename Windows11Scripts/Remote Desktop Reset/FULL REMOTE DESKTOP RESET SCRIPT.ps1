# ================================
# FULL REMOTE DESKTOP RESET SCRIPT
# ================================

Write-Host "Stopping Remote Desktop Services..." -ForegroundColor Yellow
Stop-Service TermService -Force

# -------------------------------
# Reset RDP Registry Configuration
# -------------------------------

$rdpRegPaths = @(
    "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server",
    "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations",
    "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\RDP\",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services",
    "HKLM:\SOFTWARE\Microsoft\Terminal Server Client",
    "HKCU:\SOFTWARE\Microsoft\Terminal Server Client"
)

foreach ($path in $rdpRegPaths) {
    if (Test-Path $path) {
        Write-Host "Resetting $path" -ForegroundColor Cyan
        Remove-Item -Path $path -Recurse -Force
    }
}

# -------------------------------
# Reset RDP Listener (WinStations)
# -------------------------------

Write-Host "Rebuilding RDP listener..." -ForegroundColor Yellow
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /f

# -------------------------------
# Reset Firewall Rules
# -------------------------------

Write-Host "Resetting firewall rules..." -ForegroundColor Yellow
Get-NetFirewallRule -DisplayName "*Remote Desktop*" | Remove-NetFirewallRule -ErrorAction SilentlyContinue

Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# -------------------------------
# Reset Group Policy RDP Settings
# -------------------------------

Write-Host "Removing GP-applied RDP policies..." -ForegroundColor Yellow
$gpPaths = @(
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services",
    "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\RemoteDesktop"
)

foreach ($path in $gpPaths) {
    if (Test-Path $path) {
        Remove-Item $path -Recurse -Force
    }
}

# -------------------------------
# Reset CredSSP / NLA / Security
# -------------------------------

Write-Host "Resetting NLA and security layers..." -ForegroundColor Yellow
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v SecurityLayer /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 1 /f

# -------------------------------
# Reset RemoteFX / Device Redirection
# -------------------------------

Write-Host "Resetting RemoteFX and redirection..." -ForegroundColor Yellow
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Terminal Server\TSAppCompat" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\DeviceRedirection" /f

# -------------------------------
# Restart Services
# -------------------------------

Write-Host "Restarting Remote Desktop Services..." -ForegroundColor Yellow
Start-Service TermService

# -------------------------------
# Force Group Policy Refresh
# -------------------------------

gpupdate /force

Write-Host "RDP reset complete. Reboot recommended." -ForegroundColor Green
