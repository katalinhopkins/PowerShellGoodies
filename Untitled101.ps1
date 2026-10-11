#Write-Output (Get-Date -Format "yyyy-MM-dd HH:mm:ss") 
Write-Host (Get-Date -Format "yyyy-MM-dd HH:mm:ss")  -ForegroundColor Yellow
Get-Process dism | Format-Table
