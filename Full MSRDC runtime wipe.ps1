# ============================================
# FULL MSRDC RUNTIME WIPE (CLIENT-ONLY)
# ============================================

Write-Host "Stopping Remote Desktop clients..." -ForegroundColor Yellow
Get-Process msrdc -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process mstsc -ErrorAction SilentlyContinue | Stop-Process -Force

# --------------------------------------------
# Wipe MSRDC / Windows App data folders
# --------------------------------------------

$msrdcDataPaths = @(
    "$env:LOCALAPPDATA\Microsoft\MSRDC",
    "$env:LOCALAPPDATA\Microsoft\RemoteDesktop",
    "$env:LOCALAPPDATA\Microsoft\WindowsApp\MSRDC",
    "$env:APPDATA\Microsoft\MSRDC",
    "$env:APPDATA\Microsoft\RemoteDesktop"
)

foreach ($path in $msrdcDataPaths) {
    if (Test-Path $path) {
        Write-Host "Removing MSRDC data: $path" -ForegroundColor Cyan
        Remove-Item -Path $path -Recurse -Force
    }
}

# --------------------------------------------
# Wipe MSRDC runtime / package folders
# --------------------------------------------

$runtimePatterns = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.RemoteDesktop*",
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsAppRuntime*",
    "$env:LOCALAPPDATA\Microsoft\WindowsAppRuntime*",
    "$env:PROGRAMDATA\Microsoft\MSRDC*"
)

foreach ($pattern in $runtimePatterns) {
    Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host "Removing runtime/package: $($_.FullName)" -ForegroundColor Cyan
        Remove-Item -Path $_.FullName -Recurse -Force
    }
}

# --------------------------------------------
# Remove MSRDC-related registry keys (per-user)
# --------------------------------------------

$msrdcRegPaths = @(
    "HKCU:\Software\Microsoft\MSRDC",
    "HKCU:\Software\Microsoft\RemoteDesktop",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\App Paths\msrdc.exe"
)

foreach ($regPath in $msrdcRegPaths) {
    if (Test-Path $regPath) {
        Write-Host "Removing MSRDC registry: $regPath" -ForegroundColor Cyan
        Remove-Item -Path $regPath -Recurse -Force
    }
}

# --------------------------------------------
# Clean up legacy Store Remote Desktop remnants
# --------------------------------------------

$legacyPatterns = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.RemoteDesktop_*",
    "$env:LOCALAPPDATA\Packages\Microsoft.RemoteDesktopPreview_*"
)

foreach ($pattern in $legacyPatterns) {
    Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host "Removing legacy Remote Desktop package: $($_.FullName)" -ForegroundColor Cyan
        Remove-Item -Path $_.FullName -Recurse -Force
    }
}

# --------------------------------------------
# Clear TERMSRV saved credentials only
# --------------------------------------------

Write-Host "Clearing saved TERMSRV credentials..." -ForegroundColor Yellow
cmdkey /list | Select-String "TERMSRV/" | ForEach-Object {
    $target = $_.ToString().Split(" : ")[-1].Trim()
    Write-Host "Deleting credential: $target" -ForegroundColor Cyan
    cmdkey /delete:$target | Out-Null
}

Write-Host "Full MSRDC runtime wipe complete." -ForegroundColor Green
Write-Host "Reboot recommended, then reinstall/open the Windows App and re-add workspaces." -ForegroundColor Green
