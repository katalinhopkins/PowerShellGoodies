Get-ChildItem "\\DS224\LGGram16\Local" -Recurse -Force |
    Sort-Object FullName -Descending |
    ForEach-Object {
        Write-Host "Deleting $($_.FullName)"
        Remove-Item $_.FullName -Force -Recurse
    }
