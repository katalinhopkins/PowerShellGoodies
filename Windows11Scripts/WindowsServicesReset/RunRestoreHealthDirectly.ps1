#Run RestoreHealth directly (skip ScanHealth)
#RunRestoreHealthDirectly
<#
This is the operation that actually repairs the component store.
If RestoreHealth:
hangs
deadlocks
reboots the PC
fails with error 0x800f081f
fails with error 0x800f0982
fails with error 0x80073712
#>
DISM /Online /Cleanup-Image /RestoreHealth
