#Step 1 — Run SFC (repairs file-level corruption)
<#
This repairs:
Broken system files
Missing files
Hash mismatches
CBS registry inconsistencies
This step often “unsticks” DISM.

When it finishes: Reboot
#>
Write-Host (Get-Date -Format "yyyy-MM-dd HH:mm:ss")  -ForegroundColor Yellow
sfc /scannow

Write-Host "scannow is Complete...." -ForegroundColor Cyan
Write-Host (Get-Date -Format "yyyy-MM-dd HH:mm:ss")  -ForegroundColor Yellow
Write-Host "REBOOTING NOW" -ForegroundColor Red
Restart-Computer