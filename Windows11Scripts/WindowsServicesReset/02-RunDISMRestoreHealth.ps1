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
#Write-Host "Starting DISM /Online /Cleanup-Image /RestoreHealth...." -ForegroundColor Green
Write-Host "Starting DISM /Online /Cleanup-Image /RestoreHealth /LimitAccess /Source:WIM... " -ForegroundColor Cyan 
#DISM /Online /Cleanup-Image /RestoreHealth

#Run RestoreHealth without Windows Update
DISM /Online /Cleanup-Image /RestoreHealth /LimitAccess /Source:WIM


Write-Host "RestoreHealth is COMPLETE..."
Write-Host (Get-Date -Format "yyyy-MM-dd HH:mm:ss")  -ForegroundColor Yellow
Write-Host "REBOOTING NOW" -ForegroundColor Red
Restart-Computer