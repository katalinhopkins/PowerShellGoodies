#CleanUpMyPath
# ============================================================
# Clean PSModulePath for user scope
# ============================================================

Write-Host "=== Cleaning PSModulePath ===" -ForegroundColor Cyan

$DesiredPaths = @(
    "C:\Users\1263888436.ctr\WindowsPowerShell\Modules",
    "C:\Users\1263888436.ctr\WindowsPowerShell",
    "C:\Program Files\WindowsPowerShell\Modules",
    "C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules"
)

$Current = [Environment]::GetEnvironmentVariable("PSModulePath", "User")

$Cleaned = $Current -split ";" |
    Where-Object { $_ -and ($DesiredPaths -contains $_) } |
    Sort-Object -Unique

# Rebuild PSModulePath
$NewPSModulePath = ($Cleaned -join ";")

Write-Host "New PSModulePath:" -ForegroundColor Yellow
$Cleaned | ForEach-Object { Write-Host $_ }

# Write back to User environment
[Environment]::SetEnvironmentVariable("PSModulePath", $NewPSModulePath, "User")

Write-Host ""
Write-Host "=== PSModulePath cleaned successfully ===" -ForegroundColor Green
Write-Host "Restart PowerShell to apply changes."
