#
<#
This is the operation that actually repairs the component store.
If RestoreHealth:
hangs
deadlocks
reboots the PC
fails with error 0x800f081f
fails with error 0x800f0982
fails with error 0x80073712

When it finishes: REBOOT
#>
Write-Host (Get-Date -Format "yyyy-MM-dd HH:mm:ss")  -ForegroundColor Yellow
DISM /Online /Cleanup-Image /RestoreHealth

Write-Host "RestoreHealth is COMPLETE..."
Write-Host (Get-Date -Format "yyyy-MM-dd HH:mm:ss")  -ForegroundColor Yellow
Write-Host "REBOOTING NOW" -ForegroundColor Red
Restart-Computer