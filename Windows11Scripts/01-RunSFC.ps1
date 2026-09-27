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

sfc /scannow
