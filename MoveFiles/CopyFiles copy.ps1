<#
C:\GitHub\PowerShellGoodies\MoveFiles\CopyFiles.ps1
#$Source = Folder what you want to copy 
#Destination = MAKE SURE THAT THE DESTINATION IS THE PARENT FOLDER WHERE THE FILES GET COPIED/MOVED!
#Set permission up to write to Synology

#cmdkey /add:\\DS224 /user:DS224\katalinhopkins /pass:Cogito@rgo5um

#robocopy "C:\Users\kahopkin\Music" "\\DS224\MS-Surface-E6F1US5\Music" /S /ETA /COPYALL /DCOPY:DAT /R:3 /W:3 /MT:16 

#>


using namespace System.Collections.Generic

#cmdkey /add:10.20.30 /user:10.20.30\katalinhopkins /pass:Cogito@rgo5um

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


#$Source="\\DS224\MS-Surface-E6F1US5"
#$Source="C:\GitHub\PowerShellGoodies"

#$Source="\\DS224\MS-Surface-E6F1US5\Documents"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\Azure Stuff"
#$Source="\\DS224\MS-Surface-E6F1US5\BICEP"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\Billy Miller Team"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\Blue Mountain"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\Canon Scanner"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\Chief Architect Premier X12 Data"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\Connects"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\ConsultantRole"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\Custom Office Templates"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\DevStuff"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\Excel"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\Flankspeed Exports"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\Flow"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\Graph API"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\INSCOM"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\ISV Teams Project"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\KB Docs"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\LearnTeamsDev"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\My Kindle Content"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\Nintex"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\OneNet"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\OneNote Notebooks"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\Outlook Files"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\PowerShellScripts"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\Teams Documentation"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\Travel"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\UsefulStuff"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\Visual Studio 2017"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\Visual Studio 2019"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\Visual Studio 2022"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents\WindowsPowerShell"
#$Source="\\DS224\MS-Surface-E6F1US5\AzureStackDevelopmentKit"
#$Source="\\DS224\MS-Surface-E6F1US5\Desktop"
#$Source="\\DS224\MS-Surface-E6F1US5\Documents"
#$Source="\\DS224\MS-Surface-E6F1US5\Downloads\FlowExport"
#$Source="\\DS224\MS-Surface-E6F1US5\Kat-DESKTOP-SL4OKMD"
#$Source="\\DS224\MS-Surface-E6F1US5\Music"
#$Source="\\DS224\MS-Surface-E6F1US5\Nintex"
#$Source="\\DS224\MS-Surface-E6F1US5\Notebooks"
#$Source="\\DS224\MS-Surface-E6F1US5\OneNote NoteBooks"
#$Source="\\DS224\MS-Surface-E6F1US5\PicturesOneDrive"
#$Source="\\DS224\MS-Surface-E6F1US5\PowerApps"
#$Source="\\DS224\MS-Surface-E6F1US5\PowerShellScripts"
#$Source="\\DS224\MS-Surface-E6F1US5\Recordings"
#$Source="\\DS224\MS-Surface-E6F1US5\Training"
#$Source="\\DS224\MS-Surface-E6F1US5\Training-DESKTOP-SL4OKMD"
#$Source="\\DS224\MS-Surface-E6F1US5\TSI"
#$Source="\\DS224\MS-Surface-E6F1US5\Videos"
#$Source="\\DS224\MS-Surface-E6F1US5\Whiteboards"

#$Source = "\\DS224\MS-Surface-E6F1US5\Downloads\Executables\My Stuff on USB"
#$Source = "\\DS224\MS-Surface-E6F1US5\PicturesOneDrive"
#$Source = "\\DS224\MS-Surface-E6F1US5\Training"
#$Source = "\\DS224\MS-Surface-E6F1US5\Documents\Flow"

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
$Source ="D:\Users\Katal\OneDrive\MS-Surface-E6F1US5\Videos"
#$Source =""
#$Source =""
#$Source =""
#$Source =""
#$Source =""

<#
#2025-03-08
$Source="\\DS224\MS-Surface-E6F1US5\Documents\Chief Architect Templates"
$Source="\\DS224\MS-Surface-E6F1US5\Documents\Clearance"
$Source="\\DS224\MS-Surface-E6F1US5\Documents\eBooks"
$Source="\\DS224\MS-Surface-E6F1US5\Documents\HR Benefits"
$Source="\\DS224\MS-Surface-E6F1US5\Documents\Flow"
$Source="\\DS224\MS-Surface-E6F1US5\Documents\Miscellaneous"
$Source="\\DS224\MS-Surface-E6F1US5\Documents\Personal"
$Source="\\DS224\MS-Surface-E6F1US5\Documents\Snagit"
$Source="\\DS224\MS-Surface-E6F1US5\Documents\Snagit Stamps"
$Source="\\DS224\MS-Surface-E6F1US5\Documents\Training"
$Source="\\DS224\MS-Surface-E6F1US5\Documents\TurboTax"
$Source="\\DS224\MS-Surface-E6F1US5\Documents\UsefulStuff"
$Source ="C:\OneDriveLocal"


#2025-03-11
$Source ="C:\OneDriveLocal\Billy Miller Team"
$Source ="C:\OneDriveLocal\Canon Scanner"
$Source ="C:\OneDriveLocal\Chief Architect Premier X12 Data"
$Source ="C:\OneDriveLocal\Clearance"
$Source ="C:\OneDriveLocal\Custom Office Templates"
$Source ="C:\OneDriveLocal\DevStuff"
$Source ="C:\OneDriveLocal\eBooks"
$Source ="C:\OneDriveLocal\Excel"
$Source ="C:\OneDriveLocal\Flow"
$Source ="C:\OneDriveLocal\HR Benefits"
$Source ="C:\OneDriveLocal\Miscellaneous"
$Source ="C:\OneDriveLocal\Music"

$Source ="C:\OneDriveLocal\Nintex"
$Source ="C:\OneDriveLocal\Snagit"
$Source ="C:\OneDriveLocal\PicturesOneDrive"
#$Source ="C:\OneDriveLocal\OneNote Notebooks"
$Source ="C:\OneDriveLocal\Personal"
$Source ="C:\OneDriveLocal\Music"
$Source ="C:\OneDriveLocal\My Kindle Content"
$Source ="C:\OneDriveLocal\Nintex"
#>

#Destination = MAKE SURE THAT THE DESTINATION IS THE PARENT FOLDER WHERE THE FILES GET COPIED/MOVED!

<##>
#$Destination = "C:\Users\kahopkin\OneDrive"
#$Destination = "C:"
#$Destination = "C:\Users\kahopkin\OneDrive\MS-Surface-E6F1US5"
#$Destination = "C:\Users\kahopkin\OneDrive"
#$Destination = "\\DS224\MS-Surface-E6F1US5"
#$Destination = "C:\OneDriveLocal"

#$Source="\\DS224\MS-Surface-E6F1US5\Downloads"


#$Destination = "\\DS224\MS-Surface-E6F1US5"

#$Destination = "C:\Users\kahopkin\OneDrive-Outlook\OneDrive\MS-Surface-E6F1US5\Documents"

#$Destination = "\\DS224\MS-Surface-E6F1US5\Training"
#$Destination = "C:\Users\kahopkin\OneDrive-Outlook\OneDrive"
#$Destination = "\\DS224\MS-Surface-E6F1US5"
#$Destination = "C:\Users\kahopkin\OneDrive-Outlook\OneDrive\Downloads\FlowExport"
#$Destination = "C:\Users\kahopkin\OneDrive-Outlook\OneDrive\Documents"
#$Destination = "D:\Users\Katal\OneDrive\Downloads"
#$Destination = "D:\Users\Katal\OneDrive\Downloads"
#>
$Destination = "D:\Users\Katal\OneDrive"
#$Destination = "\\DS224\Documents"


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
	robocopy $SourceParentFolderPath $Destination /DCOPY:DAT /E /XF * #/LOG:$LogFile
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

#
# Call Robocopy to copy/move folder and its contents!
# MOVE exact folder exists as destination
<#
#MOVE
$psCommand =  "`RobocopyMoveFiles `` `n`t" + 
		"-Source `"" + $Source + "`" `` `n`t" + 
		"-Destination `"" + $DestinationFolder + "`"" 
Write-Host -ForegroundColor Cyan  "`n#[337]Calling:"
Write-Host -ForegroundColor White $psCommand
RobocopyMoveFiles -Source $Source -Destination $DestinationFolder -LogFile $LogFile
#>

# MOVE destination is the parent folder
<#
$psCommand =  "`RobocopyMoveFiles `` `n`t" + 
		"-Source `"" + $Source + "`" `` `n`t" + 
		"-Destination `"" + $Destination + "`"" 
Write-Host -ForegroundColor Cyan  "`n#[351]Calling:"
Write-Host -ForegroundColor White $psCommand
RobocopyMoveFiles -Source $Source -Destination $Destination -LogFile $LogFile
#>


<# 
# COPY
$psCommand =  "`RobocopyCopyFiles `` `n`t" + 
		"-Source `"" + $Source + "`" `` `n`t" + 
		"-Destination `"" + $DestinationFolder + "`"" 

Write-Host -ForegroundColor Cyan  "`n#[312]Calling:"
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
