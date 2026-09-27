<# 
EdgeProfileClone.ps1
.SYNOPSIS
    Clone a Microsoft Edge profile from SOURCE to TARGET machine without using Sync.

.DESCRIPTION
    This script:
    - Locates Edge User Data folder
    - Lists available profiles
    - Lets you choose a source profile (or specify by name)
    - Prepares a destination profile (newly created on target)
    - Injects the source profile contents into the destination profile folder
    - Preserves extensions, settings, favorites, cookies, sessions, etc.

    Usage pattern:
    - Run once on SOURCE to export profile to a portable folder (USB / network share)
    - Run once on TARGET to import into a newly created Edge profile

    IMPORTANT:
    - On TARGET, you must first create a new profile in Edge UI, then close Edge.
    - Then run this script in "Import" mode pointing to that new profile folder.

.NOTES
    Author: Copilot
    Style: Verbose, deterministic, color-coded, explicit blocks
#>

param
(
    [Parameter(Mandatory = $false)]
    [ValidateSet("Export", "Import")]
    [string]
    $Mode = "Export",

    [Parameter(Mandatory = $false)]
    [string]
    $SourceProfileName,   # e.g. "Default" or "Profile 1"

    [Parameter(Mandatory = $false)]
    [string]
    $DestinationProfileName, # e.g. "Profile 4" (newly created on TARGET)

    [Parameter(Mandatory = $false)]
    [string]
    $TransferPath = "$env:USERPROFILE\EdgeProfileTransfer"  # Folder to store/export/import profile
)

#region Helper functions

function Write-Info
{
    param
    (
        [string] $Message
    )

    Write-Host "[INFO ] $Message" -ForegroundColor Cyan
} #end function Write-Info

function Write-Warn
{
    param
    (
        [string] $Message
    )

    Write-Host "[WARN ] $Message" -ForegroundColor Yellow
} #end function Write-Warn

function Write-ErrorMsg
{
    param
    (
        [string] $Message
    )

    Write-Host "[ERROR] $Message" -ForegroundColor Red
} #end function Write-ErrorMsg

function Write-Success
{
    param
    (
        [string] $Message
    )

    Write-Host "[ OK  ] $Message" -ForegroundColor Green
} #end function Write-Success

function Get-EdgeUserDataPath
{
    # Edge User Data base path
    $path = Join-Path $env:LOCALAPPDATA "Microsoft\Edge\User Data"
    return $path
} #end function Get-EdgeUserDataPath

function Get-EdgeProfiles
{
    param
    (
        [string] $UserDataPath
    )

    # Profiles are typically: "Default", "Profile 1", "Profile 2", etc.
    $dirs = Get-ChildItem -Path $UserDataPath -Directory -ErrorAction SilentlyContinue |
            Where-Object {
                $_.Name -eq "Default" -or $_.Name -like "Profile *"
            }

    return $dirs
} #end function Get-EdgeProfiles

function Select-ProfileInteractive
{
    param
    (
        [System.IO.DirectoryInfo[]] $Profiles,
        [string] $Prompt
    )

    Write-Info $Prompt

    $index = 0
    foreach ($p in $Profiles)
    {
        Write-Host "[$index] $($p.Name)" -ForegroundColor White
        $index++
    } #end foreach

    $selection = Read-Host "Enter index of profile"
    if (-not ($selection -as [int] -ge 0 -and $selection -as [int] -lt $Profiles.Count))
    {
        Write-ErrorMsg "Invalid selection index."
        return $null
    } #end if

    return $Profiles[$selection]
} #end function Select-ProfileInteractive

function Ensure-Directory
{
    param
    (
        [string] $Path
    )

    if (-not (Test-Path -Path $Path))
    {
        Write-Info "Creating directory: $Path"
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
    } #end if
} #end function Ensure-Directory

#endregion Helper functions

#region Main

Write-Host "==========================================" -ForegroundColor DarkCyan
Write-Host "   Edge Profile Migration (No Sync)       " -ForegroundColor DarkCyan
Write-Host "==========================================" -ForegroundColor DarkCyan
Write-Host "Mode: $Mode" -ForegroundColor DarkCyan
Write-Host ""


$edgeUserDataPath = Get-EdgeUserDataPath
if (-not (Test-Path -Path $edgeUserDataPath))
{
    Write-ErrorMsg "Edge User Data path not found: $edgeUserDataPath"
    Write-ErrorMsg "Is Microsoft Edge installed for this user?"
    exit 1
} #end if

Write-Info "Edge User Data path: $edgeUserDataPath"

$profiles = Get-EdgeProfiles -UserDataPath $edgeUserDataPath
if (-not $profiles -or $profiles.Count -eq 0)
{
    Write-Warn "No Edge profiles found in: $edgeUserDataPath"
    Write-Warn "You may need to start Edge once to create a profile."
    exit 1
} #end if

Write-Info "Found profiles:"
foreach ($p in $profiles)
{
    Write-Host " - $($p.Name)" -ForegroundColor White
} #end foreach

Ensure-Directory -Path $TransferPath
Write-Info "Transfer path: $TransferPath"

switch ($Mode)
{
    "Export"
    {
        #region Export block

        Write-Info "Running in EXPORT mode (SOURCE machine)."

        $sourceProfileDir = $null

        if ($SourceProfileName)
        {
            Write-Info "Using specified source profile name: $SourceProfileName"
            $sourceProfileDir = $profiles | Where-Object { $_.Name -eq $SourceProfileName }

            if (-not $sourceProfileDir)
            {
                Write-ErrorMsg "Profile '$SourceProfileName' not found."
                exit 1
            } #end if
        }
        else
        {
            $sourceProfileDir = Select-ProfileInteractive -Profiles $profiles -Prompt "Select source profile to EXPORT:"
            if (-not $sourceProfileDir)
            {
                Write-ErrorMsg "No source profile selected."
                exit 1
            } #end if
        } #end if

        Write-Info "Selected source profile: $($sourceProfileDir.Name)"

        $exportTarget = Join-Path $TransferPath $sourceProfileDir.Name
        Write-Info "Export destination: $exportTarget"

        if (Test-Path -Path $exportTarget)
        {
            Write-Warn "Existing export folder found. It will be removed before export."
            Remove-Item -Path $exportTarget -Recurse -Force
        } #end if

        Write-Info "Copying profile contents..."
        Copy-Item -Path $sourceProfileDir.FullName -Destination $exportTarget -Recurse -Force

        Write-Success "Profile exported successfully."
        Write-Host "Now copy the folder '$TransferPath' to the TARGET machine (USB / network share)." -ForegroundColor Magenta

        #endregion Export block
    }

    "Import"
    {
        #region Import block

        Write-Info "Running in IMPORT mode (TARGET machine)."
        Write-Warn "IMPORTANT: Ensure Edge is CLOSED before proceeding."

        if (-not $DestinationProfileName)
        {
            Write-ErrorMsg "DestinationProfileName is required in IMPORT mode."
            Write-ErrorMsg "Example: -DestinationProfileName 'Profile 4' (newly created in Edge UI)."
            exit 1
        } #end if

        $destProfileDir = $profiles | Where-Object { $_.Name -eq $DestinationProfileName }
        if (-not $destProfileDir)
        {
            Write-ErrorMsg "Destination profile '$DestinationProfileName' not found in Edge User Data."
            Write-ErrorMsg "Create a new profile in Edge first, then close Edge, then rerun."
            exit 1
        } #end if

        Write-Info "Destination profile folder: $($destProfileDir.FullName)"

        # We expect an exported folder with some profile name under $TransferPath.
        # If SourceProfileName is provided, use that; otherwise, list available export folders.
        $importSourceDir = $null

        if ($SourceProfileName)
        {
            $candidate = Join-Path $TransferPath $SourceProfileName
            if (-not (Test-Path -Path $candidate))
            {
                Write-ErrorMsg "Exported profile '$SourceProfileName' not found under transfer path: $candidate"
                exit 1
            } #end if

            $importSourceDir = Get-Item -Path $candidate
        }
        else
        {
            Write-Info "No SourceProfileName specified. Listing available exported profiles under transfer path:"
            $exportedProfiles = Get-ChildItem -Path $TransferPath -Directory -ErrorAction SilentlyContinue

            if (-not $exportedProfiles -or $exportedProfiles.Count -eq 0)
            {
                Write-ErrorMsg "No exported profiles found under: $TransferPath"
                exit 1
            } #end if

            $importSourceDir = Select-ProfileInteractive -Profiles $exportedProfiles -Prompt "Select EXPORTED profile to IMPORT into '$DestinationProfileName':"
            if (-not $importSourceDir)
            {
                Write-ErrorMsg "No import source selected."
                exit 1
            } #end if
        } #end if

        Write-Info "Selected import source: $($importSourceDir.FullName)"

        Write-Warn "About to replace contents of destination profile folder:"
        Write-Warn "DEST: $($destProfileDir.FullName)"
        $confirm = Read-Host "Type 'YES' to confirm"
        if ($confirm -ne "YES")
        {
            Write-Warn "Import cancelled by user."
            exit 0
        } #end if

        Write-Info "Removing existing contents of destination profile (but keeping folder)..."
        Get-ChildItem -Path $destProfileDir.FullName -Force -ErrorAction SilentlyContinue |
            Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

        Write-Info "Copying imported profile contents into destination folder..."
        Copy-Item -Path $importSourceDir.FullName\* -Destination $destProfileDir.FullName -Recurse -Force

        Write-Success "Profile imported successfully."
        Write-Host "Now start Edge and open profile '$DestinationProfileName'." -ForegroundColor Magenta
        Write-Host "It should load the cloned profile (extensions, settings, favorites, cookies, sessions, etc.)." -ForegroundColor Magenta

        #endregion Import block
    }

    default
    {
        Write-ErrorMsg "Unknown Mode: $Mode. Use 'Export' or 'Import'."
        exit 1
    }
} #end switch

Write-Host ""
Write-Host "Done." -ForegroundColor Green

#endregion Main
