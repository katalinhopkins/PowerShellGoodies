#CreateAppRegistration

Function global:CreateAppRegistration
{
    Param(
      [Parameter(Mandatory = $true)] [String]$AppName    		
    )

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START CreateAppRegistration FOR $AppName *****************"
    
    $AdApplication = Get-AzADApplication -DisplayName $AppName    
       
    #create a new Azure Active Directory App Reg
    if (($AdApplication.DisplayName.Length).Equals(0))
    {
        #depending on the name, the app registrations need different configurations.
        #API app registration
        #if (! $ApiAppRegName.ToLower().Contains("api")) 
        if ($AppName -match 'api')
        {
            #Create the App Roles at the time of creation
            $AppRoles = New-Object System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphAppRole]             
            $newAppRole = CreateAppRole `
                -AllowedMemberTypes "User" `
                -Description "Admin users of the DTP API" `
                -DisplayName  "DTP API Admins" `
                -Value "DTPAPI.Admins"                 
    
            $AppRoles += $newAppRole
            Write-Host -ForegroundColor Green "CreateAppRegistration[31] newAppRole.DisplayName= " $newAppRole.DisplayName

            $newAppRole = CreateAppRole `
                -AllowedMemberTypes "User" `
                -Description "Standard users of the DTP API" `
                -DisplayName  "DTP Users" `
                -Value "DTP.Users"                
            
            $AppRoles += $newAppRole
						Write-Host -ForegroundColor Green "CreateAppRegistration[49] newAppRole.DisplayName= " $newAppRole.DisplayName
            #create a new Azure Active Directory
            $AdApplication = New-AzADApplication `
                -DisplayName $AppName `
                -SigninAudience "AzureADMyOrg" `
                -AppRole $AppRoles

            #create a client secret key which will expire in two years.
            $AppId = $AdApplication.AppId
            $AppObjectId = $AdApplication.Id
            #Write-Host  -ForegroundColor Cyan "CreateAppRegistration[26] API.AppId:" $AppId
            #Write-Host  -ForegroundColor Cyan  "CreateAppRegistration[27] API.appObjectId:" $AppObjectId

            $appPassword = New-AzADAppCredential -ObjectId $AppObjectId -EndDate (Get-Date).AddYears(2)
            $PlaintextSecretTest = $appPassword.SecretText
            #write-host -ForegroundColor Cyan -BackgroundColor Black  "CreateAppRegistration[30] secret: $PlaintextSecretTest"
            
            #$json | Add-Member -Type NoteProperty -Name 'WebExisting' -Value 'false'
            $object.Add("ApiAppRegName", $AppName) 
            $object.Add("ApiClientId", $AppId)
            $object.Add("ApiClientSecret",$PlaintextSecretTest)
            $object.Add("ApiAppObjectId", $AppObjectId)
            $object.Add("ApiExisting", "false")

            #Configure ApplicationId URI
            SetApplicationIdURI -AppId $AppId 
      
            "API App Registration Name:	" +	$AppName  >> $OutFile
            "API App Registration ID:	" + $AppId  >> $OutFile
            "API App Registration Secret:	" + $PlaintextSecretTest  >> $OutFile
        }
        #CLIENT APP REGISTRATION
        else
        {
            $webAppUrl = "https://$AppName.azurewebsites.us"
            # when you add a redirect URI Azure creates a "web" policy.
            $redirectUris = @()
            $redirectUris += "$webAppUrl"
           # Write-Host -ForegroundColor Green "CreateAppRegistration[64] redirecturi:"  $redirectUris
            
            #Create the App Roles at the time of creation
            $AppRoles = New-Object System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphAppRole]             
            $newAppRole = CreateAppRole `
                -DisplayName  "DTP Admins" `
                -Description "Admin enabled users of the DTP web application" `
                -Value "DTP.Admins" `
                -AllowedMemberTypes "User"
    
            $AppRoles += $newAppRole
            Write-Host -ForegroundColor Green "CreateAppRegistration[193] newAppRole.DisplayName= " $newAppRole.DisplayName

            $newAppRole = CreateAppRole `
                -DisplayName  "DTP Users" `
                -Description "Normal users of the DTP web application" `
                -Value "DTP.Users" `
                -AllowedMemberTypes "User"
            
            $AppRoles += $newAppRole
						
            #Create the App Registration
            $AdApplication = New-AzADApplication `
                -DisplayName $AppName `
                -SigninAudience "AzureADMyOrg" `
                -ReplyUrls $redirectUris `
                -AppRole $AppRoles

            $AppId = $AdApplication.AppId
            $AppObjectId = $AdApplication.Id
            #Write-Host  -ForegroundColor Cyan "CreateAppRegistration[72] WebClient.AppId:" $AppId
            #Write-Host  -ForegroundColor Cyan "CreateAppRegistration[73] WebClient.appObjectId:" $AppObjectId
            $object.Add("WebAppRegName", $AppName) 
            $object.Add("WebClientId", $AppId)
            $object.Add("WebAppObjectId", $AppObjectId)
            $object.Add("WebExisting", "false")

            #Write-Host -ForegroundColor Cyan  -BackgroundColor Black "[80] WebClient: " $AdApplication.DisplayName
            "WebSite App Registration Name:	" +	$AppName  >> $OutFile
            "WebSite App Registration ID:	" + $AppId  >> $OutFile					
        }#else
    }
    #EXISTING APP REGISTRATION
    else
	{
        Write-Host -ForegroundColor Red  -BackgroundColor Black "CreateAppRegistration[133] EXISTING app registration:" $AdApplication.DisplayName
        #Write-Host -ForegroundColor Red  -BackgroundColor Black "CreateAppRegistration[134] json "
        $json = Get-Content -Raw $OutFileJSON | Out-String | ConvertFrom-Json
        
        $object.Add("ApiAppRegName", $json.ApiAppRegName) 
        $object.Add("ApiClientId", $json.ApiClientId)
        $object.Add("ApiClientSecret",$json.ApiClientSecret)
        $object.Add("WebAppRegName", $json.WebAppRegName) 
        $object.Add("WebClientId", $json.WebClientId)
        $object.Add("WebAppObjectId", $json.WebAppObjectId)     
        $object.Add("ApiExisting", $json.ApiExisting)  
        $object.Add("WebExisting", $json.WebExisting)  
    }
    
    $json = ConvertTo-Json $object

    $json > $OutFileJSON 

    #DEBUG
    #$clientObj = ConvertFrom-Json $json

		<#Write-Host -ForegroundColor Cyan "CreateAppRegistration[105]  App Registration Name:" $clientObj[0].AppName
    Write-Host -ForegroundColor Cyan "CreateAppRegistration[106]  App Registration AppID:" $clientObj[0].ClientId
    Write-Host -ForegroundColor Cyan "CreateAppRegistration[107]  App Registration Object ID:" $clientObj[0].AppObjectId
		#>
    #"WebSite App Registration Secret:	" + $clientObj[0].clientSecret  >> $OutFile
    <#if ($clientObj[0].clientSecret.Length -gt 0)
    {
        #$AppName + " Secret	" + $clientObj[0].clientSecret  >> $OutFile
        Write-Host -ForegroundColor Cyan "CreateAppRegistration[111] API App Registration clientSecret:" $clientObj[0].ClientSecret
    }#>

    
    Write-Host  -ForegroundColor Cyan  "CreateAppRegistration[171] $AppName json:"
    Write-Host $json
    
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n *************[$today] EXITING CreateAppRegistration for $AppName *****************"

    
    return $json
} #end of func CreateAppRegistration
