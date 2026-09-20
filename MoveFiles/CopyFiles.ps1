<#
C:\GitHub\PowerShellGoodies\MoveFiles\CopyFiles.ps1
#$Source = Folder what you want to copy 
#Destination = MAKE SURE THAT THE DESTINATION IS THE PARENT FOLDER WHERE THE FILES GET COPIED/MOVED!
#Set permission up to write to Synology

#cmdkey /add:\\DS224 /user:DS224\katalinhopkins /pass:Cogito@rgo5um

#robocopy "C:\Users\kahopkin\Music" "\\DS224\MS-Surface-E6F1US5\Music" /S /ETA /COPYALL /DCOPY:DAT /R:3 /W:3 /MT:16 

#>


using namespace System.Collections.Generic

<#
cmdkey /add:10.20.30 /user:10.20.30\katalinhopkins /pass:Cogito@rgo5um
#>

$FileName = ""

& "$PSScriptRoot\1_GetFiles.ps1"
& "$PSScriptRoot\1A_FolderAndFileCount.ps1"
& "$PSScriptRoot\2_CreateExcelTable.ps1"
& "$PSScriptRoot\3_PopulateExcelTable.ps1"
& "$PSScriptRoot\4_RobocopyMoveFiles.ps1"
& "$PSScriptRoot\5_RobocopyCopyFiles.ps1"

$debugFlag = $true

# Import the required modules
#Import-Module -Name ImportExcel
$global:Excel = 
$global:ExcelWorkBook = 
$global:ExcelWorkSheet = 
$global:Table =
$global:FileObjectList =
$global:FileObjList = 
$global:DirectoryObjects = $null	

$Headers =  "CreationTime" ,
				"LastWriteTime" ,
				"FullFileName" ,
				"ParentFolder" ,
				"Notes" ,
				"FileCount" ,
				"ItemType" ,
				"FileName" ,
				"Extension" ,
				"FullPath" ,
				"SizeKB" ,
				"SizeMB" ,
				"SizeGB" 

$WorksheetName = 'FolderContents'
$TableName = 'FilesTable'


#$Source ="C:\Users\Katal\OneDrive\MS-Surface-E6F1US5\Downloads\Executables"

#$Source ="C:\GitHub"
#$Source ="D:\Users\Katal\OneDrive\MS-Surface-E6F1US5\Downloads\Executables\7Zip"
#$Source ="D:\Users\Katal\OneDrive\MS-Surface-E6F1US5\Downloads\Executables"
#$Source ="C:\Users\katal\OneDrive\MS-Surface-E6F1US5"
#$Source ="C:\Users\katal\OneDrive\MS-Surface-E6F1US5"

#$Source="C:\Users\Katal\OneDrive\Chief Architect"
#$Source="C:\Users\Katal\OneDrive\Desktop"
#$Source="C:\Users\Katal\OneDrive\Documents"
#$Source="C:\Users\Katal\OneDrive\Email attachments"
#$Source="C:\Users\Katal\OneDrive\OneNote NoteBooks"
#$Source="C:\Users\Katal\OneDrive\Pictures"
#$Source="C:\Users\Katal\OneDrive\PowerShellGoodies"#
#$Source="C:\Users\Katal\OneDrive"

#$Source ="\\DS224\SeaGate8TB\Accounts"
#$Source ="D:\Users\Katal\OneDrive\MS-Surface-E6F1US5"
#$Source ="D:\Users\Katal\OneDrive\GitHub"
#$Source ="D:\Users\Katal\OneDrive\MS-Surface-E6F1US5\Videos"
#$Source =""
#$Source =""
$Source ="D:\Users\Katal\Anastasia\iCloudDrive"
#$Source ="C:\GitHub\PowerShellGoodies"

<#
#$Source="D:\Users\Katal\OneDrive\Desktop"
$Source="D:\Users\Katal\OneDrive\Documents"
$Source="D:\Users\Katal\OneDrive\Downloads"
$Source="D:\Users\Katal\OneDrive\Music"
$Source="D:\Users\Katal\OneDrive\Nintex"
$Source="D:\Users\Katal\OneDrive\Notebooks"
#>
#$Source="D:\Users\Katal\OneDrive\OneNote NoteBooks"
<#$Source="D:\Users\Katal\OneDrive\PhoneBackUps"
$Source="D:\Users\Katal\OneDrive\Pictures"
$Source="D:\Users\Katal\OneDrive\PicturesOneDrive"
$Source="D:\Users\Katal\OneDrive\PowerApps"
$Source="D:\Users\Katal\OneDrive\PowerShellGoodies"
$Source="D:\Users\Katal\OneDrive\Ringtones"
$Source="D:\Users\Katal\OneDrive\Training"
$Source="D:\Users\Katal\OneDrive\Videos"
#$Source="D:\Users\Katal\OneDrive\Voice Recorder"
$Source="\\DS224\MS-Surface-E6F1US5\Documents"
#>

#$Source = "\\DS224\Documents\Professional"
#$Source="\\DS224\MS-Surface-E6F1US5\Personal\Pets"

#$Destination = "D:\Users\Katal\OneDrive"
#$Destination = "\\DS224\Documents"
$Destination = "\\DS224\Anastasia"

#$Destination = "\\DS224\MS-Surface-E6F1US5"
#$Destination = ""
#$Destination = ""
#$Destination = ""
#$Destination = ""
#$Destination = ""
#$Destination = ""
#$Destination = ""
#W:\Anastasia
#$Source ="C:\Users\katal\source\repos\PowerShellGoodies"
#$Destination = "C:\Users\katal\source\repos"
#$Destination = "D:\Users\Katal\OneDrive\Documents"
#$Destination = "D:\Users\Katal\OneDrive\Documents\MyPets"

$ScriptLocation = Get-Location
	$ScriptPath = $ScriptLocation.Path
	$ScriptName = ""

$CopyOnlyFLag = $true
#$CopyOnlyFLag = $false
$today = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
For($j=0;$j -cle 120;$j++)
{ 
	Write-Host -ForegroundColor Yellow "#" -NoNewline
	If($j -eq 120) {Write-Host -ForegroundColor Yellow "#"}
}#>

Write-Host -ForegroundColor Magenta "*************[$today] STARTING CopyFiles *****************"
<#For($j=0;$j -cle 120;$j++)
{ 
	Write-Host -ForegroundColor Magenta "*" -NoNewline
	If($j -eq 120) {Write-Host -ForegroundColor Magenta "*"}
}#>


#$Destination = $DestinationFolder

$SourceFolder = Get-Item -Path $Source
$SourceFolderName = $SourceFolder.Name
$DestinationFolder = $Destination + "\" + $SourceFolderName
$today = Get-Date -Format 'yyyy-MM-dd-HH-mm-ss'
#$ExcelFileName = $Destination + "\" + $today + "_" + $SourceFolder.Name + ".xlsx"
$ExcelFileName = $Source + "\" + $SourceFolder.Name + "_" + $today + ".xlsx"
$TodayFolder  = (Get-Date -Format 'yyyy-MM-dd-HH-mm-ss')
$SourceFolder = Get-Item -Path $Source
$LogFile = $Destination + "\" + $SourceFolder.Name + "_" + $TodayFolder + ".log"

#
#If($debugFlag){	
	Write-Host -ForegroundColor Magenta "`n`$Source=" -NoNewline
	Write-Host -ForegroundColor White "`"$Source`""	

	Write-Host -ForegroundColor Magenta "`$SourceFolder=" -NoNewline
	Write-Host -ForegroundColor White "`"$SourceFolder`""

	Write-Host -ForegroundColor Green "`n`$Destination=" -NoNewline
	Write-Host -ForegroundColor White "`"$Destination`""

	Write-Host -ForegroundColor Green "`$DestinationFolder=" -NoNewline
	Write-Host -ForegroundColor White "`"$DestinationFolder`""

	Write-Host -ForegroundColor Yellow "`n`$ExcelFileName= "  -NoNewline
	Write-Host -ForegroundColor White "`"$ExcelFileName`""
		
	Write-Host -ForegroundColor Cyan "`$LogFile=" -NoNewline
	Write-Host -ForegroundColor White "`"$LogFile`""

	#Print out the folder and filecount for the source and destination
	#CountChildItems -Source $Source -Destination $DestinationFolder
#}#If($debugFlag) #> 

#If $DestinationFolder does not exist, clone the dir structure 
If( (Test-Path $DestinationFolder) -eq $false)
{

	Write-Host -ForegroundColor Red "`$DestinationFolder=" -NoNewline
	Write-Host -ForegroundColor White "`"$DestinationFolder`"" -NoNewline
	Write-Host -ForegroundColor Gray "`n #DOES NOT EXIST, CLONING DIRECTORY STRUCTURE"
	
	#$DestinationParentFolderPath = $Destination.Substring(0, $Destination.LastIndexOf("\"))
	$DestinationParentFolderPath = $DestinationFolder.Substring(0, $DestinationFolder.LastIndexOf("\"))
	$SourceParentFolderPath = $Source.Substring(0, $Source.LastIndexOf("\"))

	Write-Host -ForegroundColor Cyan "`$DestinationParentFolderPath=" -NoNewline
	Write-Host -ForegroundColor White "`"$DestinationParentFolderPath`""
	Write-Host -ForegroundColor Green "`$SourceParentFolderPath=" -NoNewline
	Write-Host -ForegroundColor White "`"$SourceParentFolderPath`""

	# clone a directory without files
	#robocopy "\\DS224\MS-Surface-E6F1US5" "C:\Kat" /DCOPY:DAT /E /XF * 
	$psCommand =  "`n robocopy " + "`"" + $SourceParentFolderPath + "`" " + "`"" + $Destination + "`"" + " /DCOPY:DAT /E /XF * " # + "/LOG:`"" + $LogFile + "`""
	Write-Host -ForegroundColor Cyan -BackgroundColor Darkblue $psCommand
	#robocopy $SourceParentFolderPath $Destination /DCOPY:DAT /E /XF * /LOG:$LogFile
	<#
	$psCommand =  "`n robocopy " + "`"" + $SourceParentFolderPath + "`" " + "`"" + $DestinationParentFolderPath + "`"" + " /DCOPY:DAT /E /XF * " #"/LOG:`"" + $LogFile + "`""
	Write-Host -ForegroundColor Cyan -BackgroundColor Darkblue $psCommand
	robocopy $SourceParentFolderPath DestinationParentFolderPath /DCOPY:DAT /E /XF * /LOG:$LogFile
	#>
	#robocopy $SourceFolder $DestinationParentFolderPath /DCOPY:DAT /E /XF *  /LOG:$LogFile
	 
}#If( (Test-Path $Destination) -eq $false)


#exit(1)

If(-not $CopyOnlyFLag)
{
	#
	# Query and store Source folder's subfulders and files in $FileObjectList

	$psCommand =  "`$FileObjectList =  GetFiles `` `n`t" + 
			"-Source `"" + $Source + "`" `` `n`t" + 
			"-Destination `"" + $Destination + "`"" 
	Write-Host -ForegroundColor Cyan  "`n[207]Calling:"
	Write-Host -ForegroundColor White $psCommand

	$FileObjectList = New-Object System.Collections.Generic.List[System.String]
	#
	$FileObjectList = GetFiles -Source $Source -Destination $Destination
	#>

	#
	#Create excel worksheet and table
	$ExcelWorkSheet = CreateExcelTable `
								-ExcelWorkBook $ExcelWorkBook `
								-WorksheetName $WorksheetName `
								-TableName $TableName `
								-Headers $Headers `
								-ExcelFileName $ExcelFileName
	#>

	#
	#Populate the excel table with the file/folder information
	$ExcelWorkSheet = PopulateExcelTable `
						-ExcelWorkSheet $ExcelWorkSheet `
						-FileObjectList $FileObjectList `
						-ExcelFileName $ExcelFileName

	#Sleep for 30 seconds so can look at excel
	Write-Host -ForegroundColor Green "Waiting for 30 seconds...." 
	$Now = Get-Date
	Write-Host -ForegroundColor Yellow "Starting at: " $Now
 
	Start-Sleep -Seconds 30; 
	$Now = Get-Date
	Write-Host -ForegroundColor Yellow "Resuming at: " $Now
	$ExcelWorkSheet.Parent.Parent.Quit()
	#>
}#If(-not $CopyOnlyFLag)

<#
# Call Robocopy to copy/move folder and its contents!
#exact folder exists as destination
#>

<#
$psCommand =  "`RobocopyMoveFiles `` `n`t" + 
		"-Source `"" + $Source + "`" `` `n`t" + 
		"-Destination `"" + $DestinationFolder + "`"" 
Write-Host -ForegroundColor Cyan  "`n#[337]Calling:"
Write-Host -ForegroundColor White $psCommand
RobocopyMoveFiles -Source $Source -Destination $DestinationFolder -LogFile $LogFile
#>

#destination is the parent folder
<#
$psCommand =  "`RobocopyMoveFiles `` `n`t" + 
		"-Source `"" + $Source + "`" `` `n`t" + 
		"-Destination `"" + $Destination + "`"" 
Write-Host -ForegroundColor Cyan  "`n#[351]Calling:"
Write-Host -ForegroundColor White $psCommand
RobocopyMoveFiles -Source $Source -Destination $Destination -LogFile $LogFile
#>



#
$psCommand =  "`RobocopyCopyFiles `` `n`t" + 
		"-Source `"" + $Source + "`" `` `n`t" + 
		"-Destination `"" + $Destination + "`"" 

Write-Host -ForegroundColor Cyan  "`n#[293]Calling:"
Write-Host -ForegroundColor White $psCommand
RobocopyCopyFiles -Source $Source -Destination $Destination -LogFile $LogFile
#>



<#
#exact folder exists as destination
$psCommand =  "`RobocopyCopyFiles `` `n`t" + 
		"-Source `"" + $Source + "`" `` `n`t" + 
		"-Destination `"" + $DestinationFolder + "`"" 

Write-Host -ForegroundColor Cyan  "`n#[274]Calling:"
Write-Host -ForegroundColor White $psCommand
RobocopyCopyFiles -Source $Source -Destination $DestinationFolder -LogFile $LogFile
#>

<#
If($debugFlag){			
}#If($debugFlag) #> 


$today = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
<#
For($j=0;$j -cle 120;$j++)
{ 
	Write-Host -ForegroundColor Magenta "*" -NoNewline
	If($j -eq 120) {Write-Host -ForegroundColor Magenta "*"}
}#>

<#
If($debugFlag){	
	Write-Host -ForegroundColor Green "`$Source=" -NoNewline
	Write-Host -ForegroundColor White "`"$Source`""	
	Write-Host -ForegroundColor Cyan "`$Destination=" -NoNewline
	Write-Host -ForegroundColor White "`"$Destination`""
}#If($debugFlag) #> 

Write-Host -ForegroundColor Magenta "*************[$today] FINISHED CopyFiles *****************"

For($j=0;$j -cle 120;$j++)
{ 
	Write-Host -ForegroundColor Yellow "#" -NoNewline
	If($j -eq 120) {Write-Host -ForegroundColor Yellow "#"}
}#>
