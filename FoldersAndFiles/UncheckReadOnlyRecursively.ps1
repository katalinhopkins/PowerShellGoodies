<#Change ReadOnly Property 
Recursively processes files and folders.
Only increments the counter when the ReadOnly attribute was actually set and successfully removed.
Writes a line for each item changed.
Tracks failures separately.
Displays a summary at the end.
#>


$Path = ""
$Path = ""
$Path = ""
$Path = "C:\Users\katal\AppData"

Write-Host -ForegroundColor Magenta "`nProcessing Path: " -NoNewline
Write-Host -ForegroundColor White $Path

$ChangedCount = 0
$FailedCount = 0

# Process root folder plus all child items
$Items = @(Get-Item -LiteralPath $Path -Force) +
         @(Get-ChildItem -LiteralPath $Path -Recurse -Force -ErrorAction SilentlyContinue)

$Total = $Items.Count
$Current = 0

foreach ($Item in $Items)
{
    $Current++

    Write-Progress -Activity "Removing ReadOnly / Hidden / System attributes" `
                   -Status "$Current of $Total" `
                   -PercentComplete (($Current / $Total) * 100)

    try
    {
        $OldAttributes = $Item.Attributes

        # Only process items that have at least one of the target attributes
        if (
            ($OldAttributes -band [System.IO.FileAttributes\\]::ReadOnly) -or
            ($OldAttributes -band [System.IO.FileAttributes\\]::Hidden) -or
            ($OldAttributes -band [System.IO.FileAttributes\\]::System)
        )
        {
            $Item.Attributes = $OldAttributes `
                -band (-bnot [System.IO.FileAttributes\\]::ReadOnly) `
                -band (-bnot [System.IO.FileAttributes\\]::Hidden) `
                -band (-bnot [System.IO.FileAttributes\\]::System)

            Write-Host -ForegroundColor Green "[CHANGED]" -NoNewline
            Write-Host " $($Item.FullName)"

            Write-Host -ForegroundColor DarkGray "    Old: $OldAttributes"
            Write-Host -ForegroundColor DarkGray "    New: $($Item.Attributes)"

            $ChangedCount++
        }
    }
    catch
    {
        Write-Host -ForegroundColor Red "[FAILED]" -NoNewline
        Write-Host " $($Item.FullName)"

        Write-Host -ForegroundColor DarkRed "    $($_.Exception.Message)"

        $FailedCount++
    }
}

Write-Progress -Activity "Removing ReadOnly / Hidden / System attributes" -Completed

Host ""


For($j=0;$j -cle 120;$j++)
{ 
	Write-Host -ForegroundColor Yellow "#" -NoNewline
	If($j -eq 120) {Write-Host -ForegroundColor Yellow "#"}
}#>

Write-Host -ForegroundColor Cyan "Summary:"
Write-Host -ForegroundColor DarkCyan "Path                  : $Path"
Write-Host -ForegroundColor Magenta "Items Scanned         : $Total"
Write-Host -ForegroundColor Green "Attributes Changed    : $ChangedCount"
Write-Host -ForegroundColor Red "Failures              : $FailedCount"

For($j=0;$j -cle 120;$j++)
{ 
	Write-Host -ForegroundColor Yellow "#" -NoNewline
	If($j -eq 120) {Write-Host -ForegroundColor Yellow "#"}
}#>