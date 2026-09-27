# ============================================================
# FULL SYSTEM REPAIR - MASTER SCRIPT
# Loads all SECTION scripts and exposes unified execution
# This calls the orchestrator inside SECTION 9, which then calls:
# Manifest processing
# Core service reset
# Duplicate per‑user cleanup
# Third‑party cleanup
# WMI repair
# Windows Update repair
# Credential Provider repair
# All with your logging framework active.

# ============================================================

# 1. Run the master script
# .\FullSystemRepair_Master.ps1
# 2. Execute the full repair
# Invoke-FullSystemRepair

# ============================================================

# Base path where your SECTION scripts live
$basePath = "D:\GitHub\PowerShellGoodies\Windows11Scripts"

# List of SECTION files in correct order
$sections = @(
    "SECTION 1 - LOGGING FRAMEWORK.ps1",
    "SECTION 2 - MANIFEST PROCESSING SUBSYSTEM.ps1",
    "SECTION 3 - CORE WINDOWS SERVICE RESET SUBSYSTEM.ps1",
    "SECTION 4 - DUPLICATE PER-USER SERVICE CLEANUP SUBSYSTEM.ps1",
    "SECTION 5 - THIRD-PARTY SERVICE REMOVAL SUBSYSTEM.ps1",
    "SECTION 6 - WMI REPOSITORY REPAIR SUBSYSTEM.ps1",
    "SECTION 7 - WINDOWS UPDATE REPAIR SUBSYSTEM.ps1",
    "SECTION 8 - CREDENTIAL PROVIDER REPAIR SUBSYSTEM.ps1",
    "SECTION 9 - MAIN EXECUTION BLOCK (FINAL ASSEMBLY).ps1"
)

Write-Host "Loading subsystem modules..." -ForegroundColor Cyan

foreach ($file in $sections)
{
    $fullPath = Join-Path $basePath $file

    if (Test-Path $fullPath)
    {
        Write-Host "Importing: $file" -ForegroundColor White
        . $fullPath
    }#end if block
    else
    {
        Write-Host "ERROR: Missing file → $file" -ForegroundColor Red
    }#end else block
}#end foreach block

Write-Host "All subsystem modules loaded." -ForegroundColor Green


# ============================================================
# Unified Execution Function
# ============================================================

function Invoke-FullSystemRepair
{
    Write-Host "Executing full Windows 11 Enterprise 25H2 repair sequence..." -ForegroundColor Magenta

    try
    {
        Run-FullSystemRepair

        Write-Host "Full repair sequence completed successfully." -ForegroundColor Green
    }#end try block
    catch
    {
        Write-Host "Critical failure during full repair sequence." -ForegroundColor Red
        Write-Host $_ -ForegroundColor DarkRed
    }#end catch block
}#end function Invoke-FullSystemRepair

Write-Host "Master script initialized. Use Invoke-FullSystemRepair to begin." -ForegroundColor Cyan

Invoke-FullSystemRepair
