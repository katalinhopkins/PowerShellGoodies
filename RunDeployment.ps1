#RunDeployment
<#
This script creates and configures two app registrations and
then it start a Bicep script that deploys the Data Transfer Portal application.
It writes an Output.txt file and saves it in the same directory where the deploy script is located.
The file contains the app registration data: ids, secret, tenantid, subscriptionid, etc.
This is a plain text file for the person who runs the deployment.
The resources the script creates are:
Resource Group
Function App
App Service
App Service Plan
Storage Account
Log Analytics Workspace
Application Insigths for the API
Application Insigths for the Web Client
#>

Function global:RunDeployment {
    Param(
          [Parameter(Mandatory = $true)] [String]$ResGroupName
        , [Parameter(Mandatory = $true)] [String]$Environment
        , [Parameter(Mandatory = $true)] [String]$Location        
        , [Parameter(Mandatory = $false)] [String]$AppName
        , [Parameter(Mandatory = $true)] [String]$SiteName
    )

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n*************[$today] START RunDeployment *****************"

    #Connect to Az and MS Graph   
    ConnectToMSGraph
    
    $todayFN = Get-Date -Format 'MM-dd-yyyy-HH-mm-ss'
    $DeploymentName = "Deployment_" + $todayFN

    $ResGroupName = $ResGroupName
    #Create Resource Group
	#$ResGroupName += "rg-"+ $AppName + "-"  + (Get-Culture).TextInfo.ToTitleCase($Environment)
    $ResGroupName += "rg-"+ (Get-Culture).TextInfo.ToLower($AppName) + "-"  + (Get-Culture).TextInfo.ToLower($Environment)

    
    "["+ $today +"] Starting Deployment: " + $DeploymentName > $OutFile
    "Tenant:	" + $Tenant  >> $OutFile
    "TenantId:	" + $TenantId  >> $OutFile
    "SubscriptionName:	" + $SubscriptionName  >> $OutFile
    "SubscriptionId:	" + $SubscriptionId  >> $OutFile
    "Environment:	$Environment"  >> $OutFile    
    "AppName:	$AppName"  >> $OutFile
    "ResourceGroup:	$ResGroupName"  >> $OutFile
	"SiteName:	$SiteName"  >> $OutFile
    "Location:	$Location"  >> $OutFile

    #Write-Host -ForegroundColor Yellow "RunDeployment[205] Supplied Parameters:"
    #Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue "RunDeployment[57] "
    <#
    Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "RunDeployment[208] ApiAppRegName: $ApiAppRegName"
    Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "RunDeployment[] ClientAppRegName: $ClientAppRegName"
    Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "RunDeployment[] ResGroupName: $ResGroupName"
    Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "RunDeployment[] Environment: $Environment"
    Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "RunDeployment[] AppName: $AppName"
    Write-Host -ForegroundColor Yellow -BackgroundColor DarkBlue  "RunDeployment[214] Location: $Location"
   #>
   
   
    $ResourceId = CreateResourceGroup `
        -ResGroupName $ResGroupName `
        -Environment $Environment `
        -Location $Location

    Write-Host -ForegroundColor Yellow -BackgroundColor Black "RunDeployment[68] ResGroupName: $ResGroupName"
    #>
    $object = @{}
    if (! $AppName.ToLower().Contains("api"))
    {
        $ApiAppRegName = $AppName + 'api'
        #Write-Host -ForegroundColor Yellow -BackgroundColor Black "RunDeployment[222] ApiAppRegName: $ApiAppRegName"
    }
       
    if (Test-Path $OutFileJSON) 
    {
        $FullPath = Get-ChildItem -Path $OutFileJSON | select FullName
        Write-Host "RunDeployment[77] jsonFileName.FullPath: " $FullPath
        Write-Host "RunDeployment[78] File: $OutFileJSON Exists"

        $FileExists = $true
        $json = Get-Content $OutFileJSON | Out-String | ConvertFrom-Json
        
        $object.Add("Tenant", $json.Tenant) 
        $object.Add("TenantId", $json.TenantId)
        $object.Add("SubscriptionId",$json.SubscriptionId)
        $object.Add("ApiAppRegName", $json.ApiAppRegName) 
        $object.Add("ApiClientId", $json.ApiClientId)
        $object.Add("ApiClientSecret",$json.ApiClientSecret)
        $object.Add("WebAppRegName", $json.WebAppRegName) 
        $object.Add("WebClientId", $json.WebClientId)
        $object.Add("WebAppObjectId", $json.WebAppObjectId)
        
        #$json | Add-Member -Type NoteProperty -Name 'WebExisting' -Value 'false'
        #$json | Add-Member -Type NoteProperty -Name 'Existing' -Value 'true'

        #$json | ConvertTo-Json | Set-Content $jsonFileName
        #$appjson = ConvertTo-Json $object
        $ApiAppRegJson = ConvertTo-Json $object
        $ClientAppRegJson = $ApiAppRegJson
    }
    else
    {
        Write-Host "RunDeployment[101] $jsonFileName Doesn't Exists"
        $object = @{
            Tenant = $Tenant
            TenantId = $TenantId
            SubscriptionId = $SubscriptionId        
        }
        #$object

        $FileExists = $false
        
        $ApiAppRegJson = ConfigureAPI -AppName $ApiAppRegName
        #$ApiAppRegJson
        
        $ClientAppRegJson = ConfigureWebClient -AppName $AppName
        #$ClientAppRegJson        
    }      
#>
    Write-Host -ForegroundColor Cyan -BackgroundColor DarkBlue "RunDeployment[120] *********** STARTING StartBicepDeploy **********"
    
    <#if($debugFlag)
    {
      StartBicepDeploy `
            -ResGroupName $ResGroupName `
            -Environment $Environment `
            -Location $Location `
            -AppName $AppName `       
       
    }
    else
    {  
    #>
    
    StartBicepDeploy `
            -ResGroupName $ResGroupName `
            -Environment $Environment `
            -Location $Location `
            -SiteName $SiteName `
            -AppName $AppName `
            -ApiAppRegJson $ApiAppRegJson `
            -ClientAppRegJson $ClientAppRegJson
    #}  
        
    Write-Host -ForegroundColor Red -BackgroundColor Black "`nPLEASE SEE APP REGISTRATION INFO IN OUTPUT FILE: $OutFile*****************"

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Green -BackgroundColor Black  "`n*************[$today] DEPLOYMENT COMPLETED *****************"
    
}#RunDeployment

Function global:ConfigureAPI{
Param(
          [Parameter(Mandatory = $true)] [String]$AppName
    )

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n*************[$today] START ConfigureAPI App: $AppName *****************"
    #Create API App Registration

    $ApiAppRegJson = CreateAppRegistration $AppName
    Write-Host -ForegroundColor Cyan "ConfigureAPI[162] $AppName : $AppName Created"

    $clientObj = ConvertFrom-Json $ApiAppRegJson
   <# 
    Write-Host -ForegroundColor Yellow "ConfigureAPI[34] SubscriptionId: " $clientObj[0].SubscriptionId
    Write-Host -ForegroundColor Yellow "ConfigureAPI[35] TenantId:" $clientObj[0].TenantId
    Write-Host -ForegroundColor Yellow "ConfigureAPI[36] AppName:" $clientObj[0].AppName
    Write-Host -ForegroundColor Yellow "ConfigureAPI[37] ApiClientId: "$clientObj[0].ApiClientId
    Write-Host -ForegroundColor Yellow "ConfigureAPI[38] ApiAppObjectId: "$clientObj[0].ApiAppObjectId
    Write-Host -ForegroundColor Yellow "ConfigureAPI[38] ApiExisting: "$clientObj[0].ApiExisting
    #>
    $AppId = $clientObj[0].ApiClientId
    $AppObjectId = $clientObj[0].ApiAppObjectId
    $AppName = $clientObj[0].ApiAppRegName

    if($clientObj[0].ApiExisting -eq 'false')
    {
        $ExposeScope = CreateScope `
            -AppName "$AppName" `
            -Value "DTP10.Users" `
            -UserConsentDisplayName "User Permit to use $AppName" `
            -UserConsentDescription "Permit use of $AppName for Users and Admins" `
            -AdminConsentDisplayName "Permit use of $AppName" `
            -AdminConsentDescription "Permit use of $AppName" `
            -IsEnabled $true `
            -Type "User"

        Write-Host -ForegroundColor Yellow "ConfigureAPI[54] ExposeScope.Value:" $ExposeScope.Value
        #$SPN = CreateServicePrincipal -AppId $AppId
        #Write-Host -ForegroundColor Yellow "ConfigureAPI[56] Spn.AppDisplayName:" $Spn.AppDisplayName

        #Azure Storage:
        $PermissionParent = "e406a681-f3d4-42a8-90b6-c2b029497af1"
        $PermissionParentName = "Azure Storage"
        $RequiredDelegatedPermissionNames =
        @(
            "user_impersonation"
        )

        Write-Host -ForegroundColor Yellow "ConfigureAPI[66] AddAPIPermissions: $PermissionParentName.$RequiredDelegatedPermissionNames for $AppName"

        $RequiredPermissions = AddAPIPermissions `
            -AppName $AppName `
            -AppId $AppId `
            -AppObjectId $AppObjectId `
            -PermissionParent $PermissionParent `
            -RequiredDelegatedPermissionNames $RequiredDelegatedPermissionNames

        #MS Graph Delegated Permissions:
        $PermissionParent = "Microsoft Graph"
        $RequiredDelegatedPermissionNames =
        @(
            "Directory.AccessAsUser.All",
            "Directory.Read.All",
            "IdentityUserFlow.Read.All"
            "User.Read",
            "User.Read.All"
        )

        Write-Host -ForegroundColor Yellow "ConfigureAPI[86] AddAPIPermissions: $PermissionParentName.$RequiredDelegatedPermissionNames for $AppName"

        $GraphRequiredPermissions = AddAPIPermissions `
            -AppName $AppName `
            -AppId $AppId `
            -AppObjectId $AppObjectId `
            -PermissionParent $PermissionParent `
            -RequiredDelegatedPermissionNames $RequiredDelegatedPermissionNames


        #Azure Service Management:
        $PermissionParent = "40a69793-8fe6-4db1-9591-dbc5c57b17d8"
        $PermissionParentName = "Azure Service Management"
        $RequiredDelegatedPermissionNames =
            @(
                "user_impersonation"
            )

        Write-Host -ForegroundColor Yellow "ConfigureAPI[104] AddAPIPermissions: $PermissionParentName.$RequiredDelegatedPermissionNames for $AppName"

        $AzServiceMgmtPermissions = AddAPIPermissions `
            -AppName $AppName `
            -AppId $AppId `
            -AppObjectId $AppObjectId `
            -PermissionParent $PermissionParent `
            -RequiredDelegatedPermissionNames $RequiredDelegatedPermissionNames

        $RequiredResourcesAccessList = New-Object System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphRequiredResourceAccess]
        $RequiredResourcesAccessList.Add($RequiredPermissions)
        $RequiredResourcesAccessList.Add($GraphRequiredPermissions)
	    $RequiredResourcesAccessList.Add($AzServiceMgmtPermissions)

        # Add the permissions to the application
        Update-MgApplication -ApplicationId $AppObjectId -RequiredResourceAccess $RequiredResourcesAccessList
        
        
    }#clientObj[0].Existing -eq 'false'
    else
    {
        Write-Host -ForegroundColor Yellow "ConfigureAPI[129] clientObj[0].Existing: " $clientObj[0].Existing
         $json = Get-Content -Raw $jsonFileName | Out-String | ConvertFrom-Json
        
        $object.Add("ApiAppRegName", $json.AppName) 
        $object.Add("ApiClientId", $json.ApiClientId)
        $object.Add('ApiClientSecret',$json.ApiClientSecret)
        $object.Add("WebAppRegName", $json.WebAppRegName) 
        $object.Add("WebClientId", $json.WebClientId)
        $object.Add("WebAppObjectId", $json.WebAppObjectId)     
        $object.Add("ApiExisting", $json.ApiExisting)  
        $object.Add("WebExisting", $json.WebExisting)  
        $ApiAppRegJson = ConvertTo-Json $object
    }
    
    Write-Host -ForegroundColor Green "ConfigureAPI[143] $AppName Application's API Permissions are updated!"
    Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n*************[$today] FINISHED ConfigureAPI App: $AppName *************"
    return $ApiAppRegJson
}#ConfigureAPI

Function global:ConfigureWebClient{
    Param(
          [Parameter(Mandatory = $true)] [String]$AppName
    )

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n*************[$today] START ConfigureWebClient *****************"

    #Create webAPI app Registration
    
    $clientAppRegJson = CreateAppRegistration -AppName $AppName
    Write-Host -ForegroundColor Cyan -BackgroundColor DarkBlue "ConfigureWebClient[157] AppName:  $AppName Created"

    $clientObj = ConvertFrom-Json $clientAppRegJson
    Write-Host -ForegroundColor Yellow "ConfigureWebClient[161] SubscriptionId: " $clientObj[0].SubscriptionId
    Write-Host -ForegroundColor Yellow "ConfigureWebClient[] TenantId:" $clientObj[0].TenantId
    Write-Host -ForegroundColor Yellow "ConfigureWebClient[] WebAppRegName:" $clientObj[0].WebAppRegName
    Write-Host -ForegroundColor Yellow "ConfigureWebClient[] WebClientId: "$clientObj[0].WebClientId
    Write-Host -ForegroundColor Yellow "ConfigureWebClient[] WebAppObjectId: "$clientObj[0].WebAppObjectId
    Write-Host -ForegroundColor Yellow "ConfigureWebClient[166] WebExisting: "$clientObj[0].WebExisting
    
    $AppId = $clientObj[0].WebClientId
    $AppObjectId = $clientObj[0].WebAppObjectId
    $AppName = $clientObj[0].WebAppRegName

    if($clientObj[0].WebExisting -eq 'false')
    {
        #$SPN = CreateServicePrincipal -AppId $AppId
        #Write-Host -ForegroundColor Yellow "ConfigureWebClient[128] Spn.AppDisplayName:" $Spn.AppDisplayName

        #MS Graph Delegated Permissions:
        $PermissionParent = "Microsoft Graph"
        $RequiredDelegatedPermissionNames =
        @(
            "IdentityUserFlow.Read.All",
            "offline_access",
            "openid",
            "profile",
            "User.Read"
        )
        Write-Host -ForegroundColor Yellow "ConfigureWebClient[187] AddAPIPermissions: $PermissionParentName.$RequiredDelegatedPermissionNames for $AppName"

        $GraphRequiredPermissions = AddAPIPermissions `
            -AppName $AppName `
            -AppId $AppId `
            -AppObjectId $AppObjectId `
            -PermissionParent $PermissionParent `
            -RequiredDelegatedPermissionNames $RequiredDelegatedPermissionNames


        $PermissionParentName = "Data Transfer Portal 1.0 API's"
        $PermissionParent = "435ed1e5-e4ab-4205-a2f5-2726945d19be"
        $RequiredDelegatedPermissionNames =
        @(
            "DTP10.Users"
        )
        Write-Host -ForegroundColor Yellow "ConfigureWebClient[203] AddAPIPermissions: $PermissionParentName.$RequiredDelegatedPermissionNames for $AppName"

        $RequiredPermissions = AddAPIPermissions `
            -AppName $AppName `
            -AppId $AppId `
            -AppObjectId $AppObjectId `
            -PermissionParent $PermissionParent `
            -RequiredDelegatedPermissionNames $RequiredDelegatedPermissionNames

        $RequiredResourcesAccessList = New-Object System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphRequiredResourceAccess]
        $RequiredResourcesAccessList.Add($RequiredPermissions)
        $RequiredResourcesAccessList.Add($GraphRequiredPermissions)

        # Add the permissions to the application
        Update-MgApplication -ApplicationId $AppObjectId -RequiredResourceAccess $RequiredResourcesAccessList
        Write-Host -ForegroundColor Green "ConfigureWebClient[218] $AppName Application's API Permissions are updated!"
        #Write-Host -ForegroundColor Cyan $ApiAppRegJson       
       
    }#clientObj[0].Existing -eq 'false'
    else
    {
        Write-Host -ForegroundColor Yellow "ConfigureWebClient[224] clientObj[0].Existing: " $clientObj[0].Existing
        $json = Get-Content -Raw $jsonFileName | Out-String | ConvertFrom-Json
        
        $object.Add("ApiAppRegName", $json.ApiAppRegName) 
        $object.Add("ApiClientId", $json.ApiClientId)
        $object.Add('ApiClientSecret',$json.ApiClientSecret)
        $object.Add("WebAppRegName", $json.WebAppRegName) 
        $object.Add("WebClientId", $json.WebClientId)
        $object.Add("WebAppObjectId", $json.WebAppObjectId)     
        $object.Add("ApiExisting", $json.ApiExisting)  
        $object.Add("WebExisting", $json.WebExisting)  
        $clientAppRegJson = ConvertTo-Json $object
    }

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n*************[$today] FINISHED ConfigureWebClient *****************"
    return $clientAppRegJson
}#ConfigureWebClient





