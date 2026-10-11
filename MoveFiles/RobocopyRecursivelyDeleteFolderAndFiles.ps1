$FolderPath = "\\DS224\Local\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data\Application Data"
$EmptyFolder = "$env:TEMP\EmptyFolder"

New-Item -ItemType Directory -Path $EmptyFolder -Force | Out-Null
robocopy $EmptyFolder $FolderPath /MIR | Out-Null
Remove-Item $FolderPath -Recurse -Force
Remove-Item $EmptyFolder -Recurse -Force