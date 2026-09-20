<#
C:\GitHub\PowerShellGoodies\MoveFiles\MoveFiles.ps1
#$Source = Folder what you want to copy 
#Destination = MAKE SURE THAT THE DESTINATION IS THE PARENT FOLDER WHERE THE FILES GET COPIED/MOVED!
#Set permission up to write to Synology

#cmdkey /add:\\DS224 /user:DS224\katalinhopkins /pass:Cogito@rgo5um

#robocopy "C:\Users\kahopkin\Music" "\\DS224\MS-Surface-E6F1US5\Music" /S /ETA /COPYALL /DCOPY:DAT /R:3 /W:3 /MT:16 
cmdkey /add:10.20.30 /user:10.20.30\katalinhopkins /pass:Cogito@rgo5um
#>


#$FileName = ""
using namespace System.Collections.Generic

& "$PSScriptRoot\1_GetFiles.ps1"
& "$PSScriptRoot\2_CreateExcelTable.ps1"
& "$PSScriptRoot\3_PopulateExcelTable.ps1"
& "$PSScriptRoot\4_RobocopyMoveFiles.ps1"


# Import the required modules
#Import-Module -Name ImportExcel
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


#$Source = "C:\Kat\Flankspeed Exports"
#$Source = "C:\Kat"
#$Source = "C:\PhoneBackUps"
#$Source = "C:\PhoneBackUps\Samsung A70"
#$Source = "C:\Users\kahopkin\OneDrive - Microsoft\PhoneBackUps"
#$Source = "D:\Users\Katal\OneDrive\OneNote NoteBooks"
#$Source = ""
#$Source = ""
#$Source = "\\DS224\Documents\Certificates\Pictures"

#$Source="\\DS224\MS-Surface-E6F1US5"

#$Source="\\DS224\MS-Surface-E6F1US5\#recycle"
#$Source="\\DS224\MS-Surface-E6F1US5\_Extracted Zips"
#$Source="\\DS224\MS-Surface-E6F1US5\ACAS Documentations"
#$Source="\\DS224\MS-Surface-E6F1US5\ACAS SCANS"
#$Source="\\DS224\MS-Surface-E6F1US5\ARAG Legal"
#$Source="\\DS224\MS-Surface-E6F1US5\Azure Stuff"
#$Source="\\DS224\MS-Surface-E6F1US5\AzureStackDevelopmentKit"
#$Source="\\DS224\MS-Surface-E6F1US5\BICEP"
#$Source="\\DS224\MS-Surface-E6F1US5\Billy Miller Team"
#$Source="\\DS224\MS-Surface-E6F1US5\Blue Mountain"
#$Source="\\DS224\MS-Surface-E6F1US5\BMTN Clearance"
#$Source="\\DS224\MS-Surface-E6F1US5\Calibre Library"
#$Source="\\DS224\MS-Surface-E6F1US5\Canon Scanner"
#$Source="\\DS224\MS-Surface-E6F1US5\Certifications"
#$Source="\\DS224\MS-Surface-E6F1US5\Chewbacca"
#$Source="\\DS224\MS-Surface-E6F1US5\Chief Architect"
#$Source="\\DS224\MS-Surface-E6F1US5\Clearance"
#$Source="\\DS224\MS-Surface-E6F1US5\ColorCodes"
#$Source="\\DS224\MS-Surface-E6F1US5\Connects"
#$Source="\\DS224\MS-Surface-E6F1US5\ConsultantRole"
#$Source="\\DS224\MS-Surface-E6F1US5\Custom Office Templates"
#$Source="\\DS224\MS-Surface-E6F1US5\DeveloperStuff"
#$Source="\\DS224\MS-Surface-E6F1US5\DevStuff"
#$Source="\\DS224\MS-Surface-E6F1US5\DoD SAFE-BnY9Yn6fVAJKcySV"
#$Source="\\DS224\MS-Surface-E6F1US5\eBooks"
#$Source="\\DS224\MS-Surface-E6F1US5\Email attachments"
#$Source="\\DS224\MS-Surface-E6F1US5\Exam Dumps"
#$Source="\\DS224\MS-Surface-E6F1US5\Excel"
#$Source="\\DS224\MS-Surface-E6F1US5\Excel Stuff"
#$Source="\\DS224\MS-Surface-E6F1US5\FED Demand Dashboard"
#$Source="\\DS224\MS-Surface-E6F1US5\Federal"
#$Source="\\DS224\MS-Surface-E6F1US5\Flankspeed"
#$Source="\\DS224\MS-Surface-E6F1US5\Flow"
#$Source="\\DS224\MS-Surface-E6F1US5\Flow Exports"
#$Source="\\DS224\MS-Surface-E6F1US5\Flow Stuff"
#$Source="\\DS224\MS-Surface-E6F1US5\Github"
#$Source="\\DS224\MS-Surface-E6F1US5\Graph API"
#$Source="\\DS224\MS-Surface-E6F1US5\Hangoskonyvek"
#$Source="\\DS224\MS-Surface-E6F1US5\HR Benefits"
#$Source="\\DS224\MS-Surface-E6F1US5\IISExpress"
#$Source="\\DS224\MS-Surface-E6F1US5\INSCOM"
#$Source="\\DS224\MS-Surface-E6F1US5\Insurance Claims"
#$Source="\\DS224\MS-Surface-E6F1US5\ISV"
#$Source="\\DS224\MS-Surface-E6F1US5\ISV Teams Project"
#$Source="\\DS224\MS-Surface-E6F1US5\kahopkin"
#$Source="\\DS224\MS-Surface-E6F1US5\KB Docs"
#$Source="\\DS224\MS-Surface-E6F1US5\Kill all prev instances"
#$Source="\\DS224\MS-Surface-E6F1US5\Layout Borders"
#$Source="\\DS224\MS-Surface-E6F1US5\LearnTeamsDev"
#$Source="\\DS224\MS-Surface-E6F1US5\Microsoft.SecHealthUI_8wekyb3d8bbwe!SecHealthUI"
#$Source="\\DS224\MS-Surface-E6F1US5\Miscellaneous"
#$Source="\\DS224\MS-Surface-E6F1US5\MS Certifications"
#$Source="\\DS224\MS-Surface-E6F1US5\MS Debrief"
#$Source="\\DS224\MS-Surface-E6F1US5\My Data Sources"
#$Source="\\DS224\MS-Surface-E6F1US5\My Kindle Content"
#$Source="\\DS224\MS-Surface-E6F1US5\My Shapes"
#$Source="\\DS224\MS-Surface-E6F1US5\My Stuff on USB"
#$Source="\\DS224\MS-Surface-E6F1US5\My Web Sites"
#$Source="\\DS224\MS-Surface-E6F1US5\Nintex"
#$Source="\\DS224\MS-Surface-E6F1US5\Notebooks"
#$Source="\\DS224\MS-Surface-E6F1US5\ODIN"
#$Source="\\DS224\MS-Surface-E6F1US5\ODIN Exports"
#$Source="\\DS224\MS-Surface-E6F1US5\OneNet"
#$Source="\\DS224\MS-Surface-E6F1US5\OneNet Stuff"
#$Source="\\DS224\MS-Surface-E6F1US5\OneNote"
#$Source="\\DS224\MS-Surface-E6F1US5\OneNote Exports"
#$Source="\\DS224\MS-Surface-E6F1US5\OneNote Notebooks"
#$Source="\\DS224\MS-Surface-E6F1US5\Outlook Files"
#$Source="\\DS224\MS-Surface-E6F1US5\Outlook Macros"
#$Source="\\DS224\MS-Surface-E6F1US5\Pages from 20489B-SP2013-Advanced Solutions-Kat-Handbook"
#$Source="\\DS224\MS-Surface-E6F1US5\Paystubs"
#$Source="\\DS224\MS-Surface-E6F1US5\PBI"
#$Source="\\DS224\MS-Surface-E6F1US5\Personal"
#$Source="\\DS224\MS-Surface-E6F1US5\PhoneBackUps"
#$Source="\\DS224\MS-Surface-E6F1US5\Power BI Desktop"
#$Source="\\DS224\MS-Surface-E6F1US5\PowerApps"
#$Source="\\DS224\MS-Surface-E6F1US5\PowerShell"
#$Source="\\DS224\MS-Surface-E6F1US5\PowerShellGoodies"
#$Source="\\DS224\MS-Surface-E6F1US5\PowerShellScripts"
#$Source="\\DS224\MS-Surface-E6F1US5\Professional"
#$Source="\\DS224\MS-Surface-E6F1US5\Project Book 2"
#$Source="\\DS224\MS-Surface-E6F1US5\Recordings"
#$Source="\\DS224\MS-Surface-E6F1US5\Ringtones"
#$Source="\\DS224\MS-Surface-E6F1US5\ScheduledWorkflows"
#$Source="\\DS224\MS-Surface-E6F1US5\Segmented ACAS Scan Files"
#$Source="\\DS224\MS-Surface-E6F1US5\SharePoint"
#$Source="\\DS224\MS-Surface-E6F1US5\SharePoint Exports"
#$Source="\\DS224\MS-Surface-E6F1US5\SignedClearanceTransferDocs-06-09-2020"
#$Source="\\DS224\MS-Surface-E6F1US5\Snagit"
#$Source="\\DS224\MS-Surface-E6F1US5\Snagit Stamps"
#$Source="\\DS224\MS-Surface-E6F1US5\SPFX"
#$Source="\\DS224\MS-Surface-E6F1US5\SSL"
#$Source="\\DS224\MS-Surface-E6F1US5\Teams Documentation"
#$Source="\\DS224\MS-Surface-E6F1US5\Training"
#$Source="\\DS224\MS-Surface-E6F1US5\Travel"
#$Source="\\DS224\MS-Surface-E6F1US5\TurboTax"
#$Source="\\DS224\MS-Surface-E6F1US5\UDA"
#$Source="\\DS224\MS-Surface-E6F1US5\UsefulStuff"
#$Source="\\DS224\MS-Surface-E6F1US5\Visual Studio"
#$Source="\\DS224\MS-Surface-E6F1US5\Visual Studio 2019"
#$Source="\\DS224\MS-Surface-E6F1US5\WHCA"
#$Source="\\DS224\MS-Surface-E6F1US5\WildCatFormsDocs"
#$Source="\\DS224\MS-Surface-E6F1US5\Windows Hacks"
#$Source="\\DS224\MS-Surface-E6F1US5\WindowsPowerShell"
#$Source="\\DS224\MS-Surface-E6F1US5\Workflow Actions"
#$Source="\\DS224\MS-Surface-E6F1US5\Workflows web service Call"

#$Source="\\DS224\MS-Surface-E6F1US5\OneDriveLocal"
#$Source="\\DS224\MS-Surface-E6F1US5\Music"
#$Source="\\DS224\MS-Surface-E6F1US5\Videos"
#$Source="\\DS224\MS-Surface-E6F1US5\Pictures"
#$Source="\\DS224\MS-Surface-E6F1US5\PicturesOneDrive"

#$Source="\\DS224\MS-Surface-E6F1US5\kahopkin\OneDrive-Outlook\OneDrive\Chief Architect"
#$Source="\\DS224\MS-Surface-E6F1US5\kahopkin\OneDrive-Outlook\OneDrive\Documents"
#$Source="\\DS224\MS-Surface-E6F1US5\kahopkin\OneDrive-Outlook\OneDrive\Downloads"
#$Source="\\DS224\MS-Surface-E6F1US5\kahopkin\OneDrive-Outlook\OneDrive\Email attachments"
#$Source="\\DS224\MS-Surface-E6F1US5\kahopkin\OneDrive-Outlook\OneDrive\MS-Surface-E6F1US5\Chief Architect"
#$Source="\\DS224\MS-Surface-E6F1US5\kahopkin\OneDrive-Outlook\OneDrive\MS-Surface-E6F1US5\Documents"
#$Source="\\DS224\MS-Surface-E6F1US5\kahopkin\OneDrive-Outlook\OneDrive\MS-Surface-E6F1US5\Downloads"
#$Source="\\DS224\MS-Surface-E6F1US5\kahopkin\OneDrive-Outlook\OneDrive\MS-Surface-E6F1US5\GitHub"
#$Source="\\DS224\MS-Surface-E6F1US5\kahopkin\OneDrive-Outlook\OneDrive\MS-Surface-E6F1US5\Music"
#$Source="\\DS224\MS-Surface-E6F1US5\kahopkin\OneDrive-Outlook\OneDrive\MS-Surface-E6F1US5\OneNote NoteBooks"
#$Source="\\DS224\MS-Surface-E6F1US5\kahopkin\OneDrive-Outlook\OneDrive\MS-Surface-E6F1US5\PhoneBackUps"
#$Source="\\DS224\MS-Surface-E6F1US5\kahopkin\OneDrive-Outlook\OneDrive\MS-Surface-E6F1US5\PicturesOneDrive"
#$Source="\\DS224\MS-Surface-E6F1US5\kahopkin\OneDrive-Outlook\OneDrive\MS-Surface-E6F1US5\Training"

#$Source="\\DS224\MS-Surface-E6F1US5\kahopkin\OneDrive-Outlook\OneDrive\OneNote NoteBooks"
#$Source="\\DS224\MS-Surface-E6F1US5\kahopkin\OneDrive-Outlook\OneDrive\Pictures"
#$Source="\\DS224\MS-Surface-E6F1US5\kahopkin\OneDrive-Outlook\OneDrive\PowerShellGoodies"
#$Source="\\DS224\MS-Surface-E6F1US5\kahopkin\OneDrive-Outlook\OneDrive"

#$Source="\\DS224\MS-Surface-E6F1US5\Chief Architect"
#$Source="\\DS224\Documents\Personal"
$Source = "\\DS224\Downloads\Executables"


#Destination = MAKE SURE THAT THE DESTINATION IS THE PARENT FOLDER WHERE THE FILES GET COPIED/MOVED!

#$Destination = ""
#$Destination = "D:\Users\katal"
#$Destination = "C:\GitHub"
#$Destination = "\\DS224"

#$Destination = "\\DS224\Chief Architect"
#$Destination = "\\DS224\Documents"
$Destination = "\\DS224\Downloads"
#$Destination = "\\DS224\Music"
#$Destination = "\\DS224\Video"
#$Destination = "\\DS224\Photo"




$CopyOnlyFLag = $true
$debugFlag = $true


$today = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
For($j=0;$j -cle 120;$j++)
{ 
	Write-Host -ForegroundColor Yellow "*" -NoNewline
	If($j -eq 120) {Write-Host -ForegroundColor Yellow "*"}
}#>
Write-Host -ForegroundColor Magenta "*************[$today] STARTING MoveFiles *****************"
<#For($j=0;$j -cle 120;$j++)
{ 
	Write-Host -ForegroundColor Magenta "*" -NoNewline
	If($j -eq 120) {Write-Host -ForegroundColor Magenta "*"}
}#>



$SourceFolderNameArr = $Source.split("\")
$SourceFolderName = $SourceFolderNameArr[$SourceFolderNameArr.Count-1]
$DestinationFolder = $Destination + "\" + $SourceFolderName
#$Destination = $DestinationFolder

$SourceFolder = Get-Item -Path $Source

$today = Get-Date -Format 'yyyy-MM-dd-HH-mm-ss'
$ExcelFileName = $Source + "\" + $SourceFolder.Name + "_" + $today + ".xlsx"

$SourceFolder = Get-Item -Path $Source
$LogFile = $Destination + "\" + $SourceFolder.Name + "_" + $today + ".log"

#
#If($debugFlag){	
	Write-Host -ForegroundColor Magenta "`$Source=" -NoNewline
	Write-Host -ForegroundColor White "`"$Source`""	
	Write-Host -ForegroundColor Magenta "`$SourceFolderName=" -NoNewline
	Write-Host -ForegroundColor White "`"$SourceFolderName`""	

	Write-Host -ForegroundColor Cyan "`$Destination=" -NoNewline
	Write-Host -ForegroundColor White "`"$Destination`""
	Write-Host -ForegroundColor Green "`$DestinationFolder=" -NoNewline
	Write-Host -ForegroundColor White "`"$DestinationFolder`""	
	
	Write-Host -ForegroundColor Yellow "`$ExcelFileName= "  -NoNewline
	Write-Host -ForegroundColor White "`"$ExcelFileName`""
	
	Write-Host -ForegroundColor Green "`$LogFile=" -NoNewline
	Write-Host -ForegroundColor White "`"$LogFile`""	


	#>> $LogFile
	#Print out the folder and filecount for the source and destination
	#CountChildItems -Source $Source -Destination $DestinationFolder
#}#If($debugFlag) #> 


<#
# Call Robocopy to copy/move folder and its contents!
#exact folder exists as destination

$psCommand =  "`RobocopyMoveFiles `` `n`t" + 
		"-Source `"" + $Source + "`" `` `n`t" + 
		"-Destination `"" + $DestinationFolder + "`"" 

Write-Host -ForegroundColor Cyan  "`n#[280]Calling:"
Write-Host -ForegroundColor White $psCommand
RobocopyMoveFiles -Source $Source -Destination $DestinationFolder -LogFile $LogFile
#>

#
#destination is the parent folder
$psCommand =  "`RobocopyMoveFiles `` `n`t" + 
		"-Source `"" + $Source + "`" `` `n`t" + 
		"-Destination `"" + $Destination + "`"" 
Write-Host -ForegroundColor Cyan  "`n[290]Calling:"
Write-Host -ForegroundColor White $psCommand

#
# Call Robocopy to copy/move folder and its contents!
#RobocopyMoveFiles -Source $Source -Destination $DestinationFolder -LogFile $LogFile
RobocopyMoveFiles -Source $Source -Destination $Destination -LogFile $LogFile
#RobocopyCopyFiles -Source $Source -Destination $DestinationFolder 
#>

$today = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
For($j=0;$j -cle 120;$j++)
{ 
	Write-Host -ForegroundColor Magenta "*" -NoNewline
	If($j -eq 120) {Write-Host -ForegroundColor Magenta "*"}
}#>
Write-Host -ForegroundColor Magenta "*************[$today] FINISHED MoveFiles *****************"
For($j=0;$j -cle 120;$j++)
{ 
	Write-Host -ForegroundColor Yellow "*" -NoNewline
	If($j -eq 120) 
	{
		Write-Host -ForegroundColor Yellow "*"
		"*" >> $LogFile
	}
}#>
	Write-Host -ForegroundColor Cyan "`n`$Source=" -NoNewline
	Write-Host -ForegroundColor White "`"$Source`""	
	
	Write-Host -ForegroundColor Green "`n`$Destination=" -NoNewline
	Write-Host -ForegroundColor White "`"$Destination`""

	Write-Host -ForegroundColor Green "`$LogFile=" -NoNewline
	Write-Host -ForegroundColor White "`"$LogFile`""	

	"`n`$Source=" +	 "`"$Source`""	>> $LogFile
	 "`n`$Destination=" + "`"$Destination`"" >> $LogFile
	"`$LogFile=" + "`"$LogFile`"" >> $LogFile
	 