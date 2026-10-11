#InitiateDeploymentProcess.ps1
<#
Replace the values ALL CAPS below with your desired values.

Will create an App Registration with the name: <APIAPPREGNAME>api
i.e. If $ApiAppRegName = "my", the App Registration Name will be: myapi
IF $ApiAppRegName="myapi", the App Registration name will be the same: myapi
$ApiAppRegName = "APIAPPREGNAME"

Will create an App Registration with the name: <CLIENTAPPNAME>
$ClientAppRegName= "CLIENTAPPNAME"

Will create an Azure App Service with the name: <WEBSITENAME>.azurewebsites.us
i.e.: if $SiteName = "test", the app service will be created: test.azurewebsites.us
$AppName = "WEBSITENAME"

Will create an App Registration with the name: <RESOURCEGROUPBASENAME>ResGoup<Environment>
i.e. if $ResGroupName = test and $Environment=Dev, the resource group will be:  testResGroupDev
$ResGroupName= "RESOURCEGROUPBASENAME"

Possible values: test|dev|prod
$Environment = "ENVIRONMENT"

Possible Location values: usgovvirginia | usgovtexas | usgovarizona | usdodeast | usdodcentral
$Location = "'LOCATION"
#>

Import-Module -name Microsoft.Graph.Applications
#Install-Module -name Microsoft.Graph.Applications

#$global:ApiAppRegName = "APIAPPREGNAME"
#$global:ClientAppRegName= "CLIENTAPPNAME"
$ResGroupName= "RESOURCEGROUPBASENAME"
$Environment = "ENVIRONMENT"
$AppName = "WEBSITENAME"
$Location = "'LOCATION"


$global:debugFlag ="true"
$today = Get-Date -Format 'ddd'
#$ApiAppRegName = $today+"api"
#$global:ApiAppRegName = $today
#$global:ClientAppRegName = $today + "Client"
$ResGroupName = $today
$Environment = "test"
$SiteName = $today + "Site"
$AppName = $today + "Site"

$Location = "usgovvirginia"

if($Environment -eq "Test" -or $Environment -eq "Dev")
{
   # Write-Host "Test"
    $global:TemplateParameterFile = "..\main.parameters.dev.json"
}
else
{
    #Write-Host "Prod"
    $global:TemplateParameterFile = "..\main.parameters.prod.json"
}

#Output file and the json file needed for the Bicep deployment
$todayLong = Get-Date -Format "MM-dd-yyyy-HH-mm"
$OutFile = "..\logs\OutputFile_" + $todayLong + ".txt"

$todayShort = Get-Date -Format 'MM-dd-yyyy'
$jsonFileName = "DeploymentOutput-" + $todayShort + ".json"
$OutFileJSON= "..\logs\$jsonFileName"

$OutFile = "..\logs\OutputFile_" + $todayShort + ".txt"


& "$PSScriptRoot\ConnectToMSGraph.ps1"
& "$PSScriptRoot\CreateResourceGroup.ps1"
& "$PSScriptRoot\CreateAppRoles.ps1"
& "$PSScriptRoot\SetApplicationIdURI.ps1"
& "$PSScriptRoot\CreateAppRegistration.ps1"
& "$PSScriptRoot\CreateScopes.ps1"
& "$PSScriptRoot\CreateServicePrincipal.ps1"
& "$PSScriptRoot\AddAPIPermissions.ps1"
& "$PSScriptRoot\StartBicepDeploy.ps1"
& "$PSScriptRoot\RunDeployment.ps1"

<#
RunDeployment `
    -ApiAppRegName $ApiAppRegName `
    -ClientAppRegName $ClientAppRegName `
    -ResGroupName $ResGroupName `
    -Environment $Environment `
    -Location $Location `
    -AppName $AppName 
#>

RunDeployment `
    -ResGroupName $ResGroupName `
    -Environment $Environment `
    -Location $Location `
    -AppName $AppName `
		-SiteName $SiteName