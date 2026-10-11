
<#
StartBicepDeploy
 # , [Parameter(Mandatory = $true)] [String]$ResourceId
#>
Function global:StartBicepDeploy {
    Param(
          [Parameter(Mandatory = $true)] [String]$ResGroupName
        , [Parameter(Mandatory = $true)] [String]$Environment
        , [Parameter(Mandatory = $true)] [String]$Location
        , [Parameter(Mandatory = $true)] [String]$SiteName
        , [Parameter(Mandatory = $false)] [object]$AppName
        , [Parameter(Mandatory = $false)] [object]$ApiAppRegJson
        , [Parameter(Mandatory = $false)] [object]$ClientAppRegJson
        
    )
   
    Write-Host -ForegroundColor Magenta -BackgroundColor Black "************* START StartBicepDeploy Function *****************"
    $templateFile = '..\main.bicep'
    <#
    $today = Get-Date -Format 'MM-dd-yyyy-HH-mm-ss'
    $DeploymentName = "Deployment_" + $today

    "DeploymentName: " + $DeploymentName >> $OutFile
    #>
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[126] Subscription:  $subscriptionName"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[25] ResGroupName: $ResGroupName"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[26] ResourceId: $ResourceId"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[27] EnvType:  $Environment"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[28] Location:  $location"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[29] SiteName:  $SiteName"
		#Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[29] AppName:  $AppName"
    #Write-Host -ForegroundColor Green -BackgroundColor Black  "StartBicepDeploy[30] DeploymentName:  $DeploymentName"
    
    $apiClientObj = ConvertFrom-Json $ApiAppRegJson
    $ApiClientId = $apiClientObj[0].ApiClientId
    Write-Host -ForegroundColor Cyan "StartBicepDeploy[74] ApiClientId:"  $ApiClientId

    $webClientObj = ConvertFrom-Json $ClientAppRegJson
    $WebClientId = $webClientObj[0].WebClientId
    Write-Host -ForegroundColor Cyan "StartBicepDeploy[78] WebClientId:"  $WebClientId

    if ($apiClientObj[0].ApiClientSecret.Length -gt 0)
    {
        $ApiClientSecret = $apiClientObj[0].ApiClientSecret
        $SecureApiClientSecret = ConvertTo-SecureString $ApiClientSecret -AsPlainText -Force
        #   Write-Host -ForegroundColor Cyan -BackgroundColor Black  "StartBicepDeploy[202] ApiClientSecret:" $ApiClientSecret
        #  Write-Host -ForegroundColor Cyan -BackgroundColor Black  "StartBicepDeploy[203] SecureApiClientSecret:" $SecureApiClientSecret            
    }

    <#
    #Create Keyvault
    $keyVaultName = "kv-$AppName-$Environment"
    Write-Host -ForegroundColor Yellow -BackgroundColor Black  "StartBicepDeploy[53] keyVaultName:" $keyVaultName            

    $login = 'jaifairfax' # The login that you used in the previous step.
    $password = '77jZ@kBB1b0M54Ej' # The password that you used in the previous step.

    $sqlServerAdministratorLogin = ConvertTo-SecureString $login -AsPlainText -Force
    $sqlServerAdministratorPassword = ConvertTo-SecureString $password -AsPlainText -Force

    New-AzKeyVault -VaultName $keyVaultName -Location $Location -EnabledForTemplateDeployment
    Set-AzKeyVaultSecret -VaultName $keyVaultName -Name 'sqlServerAdministratorLogin' -SecretValue $sqlServerAdministratorLogin
    Set-AzKeyVaultSecret -VaultName $keyVaultName -Name 'sqlServerAdministratorPassword' -SecretValue $sqlServerAdministratorPassword
    #>


    if($debugFlag)
    {
        #Write-Host -ForegroundColor Yellow -BackgroundColor Black  "StartBicepDeploy[66] debugFlag:  $debugFlag"
        Write-Host -ForegroundColor White -BackgroundColor Black  "StartBicepDeploy[38] BICEP Command: "
        #Write-Host -ForegroundColor Cyan 
        #"New-AzSubscriptionDeployment -Name $DeploymentName -Location $Location -TemplateFile $templateFile -ResourceGroupName $ResGroupName -EnvironmentType $Environment -SiteName $SiteName -AppName $AppName -TemplateParameterFile $TemplateParameterFile"

"`nNew-AzSubscriptionDeployment ```
-Name $DeploymentName ```
-Location $Location ```
-TemplateFile $templateFile ```
-ResourceGroupName $ResGroupName ```
-EnvironmentType $Environment ```
-SiteName $SiteName ```
-AppName $AppName ```
-ApiClientId $ApiClientId ```
-ApiClientSecret $ApiClientSecret ```
-WebClientId $WebClientId ```
-TemplateParameterFile $TemplateParameterFile" >> $OutFile


Write-Host -ForegroundColor Cyan "New-AzSubscriptionDeployment ```
-Name $DeploymentName ```
-Location $Location ```
-TemplateFile $templateFile ```
-ResourceGroupName $ResGroupName ```
-EnvironmentType $Environment ```
-SiteName $SiteName ```
-AppName $AppName ```
-ApiClientId $ApiClientId ```
-ApiClientSecret $ApiClientSecret ```
-WebClientId $WebClientId ```
-TemplateParameterFile $TemplateParameterFile"
            

        New-AzSubscriptionDeployment `
            -Name $DeploymentName `
            -Location $Location `
            -TemplateFile $templateFile `
            -ResourceGroupName $ResGroupName `
            -EnvironmentType $Environment `
						-SiteName $SiteName `
            -AppName $AppName `
            -ApiClientId $ApiClientId `
            -ApiClientSecret $ApiClientSecret `
            -WebClientId $WebClientId `
            -TemplateParameterFile $TemplateParameterFile 
                
    }
    else
    {

        #Write-Host -ForegroundColor Red -BackgroundColor Black  "StartBicepDeploy[35] debugFlag:  $debugFlag"
        Write-Host -ForegroundColor White -BackgroundColor Black  "StartBicepDeploy[71] ApiAppRegJson:"  $ApiAppRegJson
        Write-Host -ForegroundColor White -BackgroundColor Black  "StartBicepDeploy[72] ClientAppRegJson:"  $ClientAppRegJson
        
        #Write-Host -ForegroundColor Cyan -BackgroundColor Black  "StartBicepDeploy[206] ApiClientId:" $ApiClientId
        #Write-Host -ForegroundColor Cyan -BackgroundColor Black  "StartBicepDeploy[207] WebClientId:" $WebClientId
        $SecureApiClientId = ConvertTo-SecureString $ApiClientId -AsPlainText -Force
        $SecureWebClientId = ConvertTo-SecureString $WebClientId -AsPlainText -Force
        #Write-Host -ForegroundColor Cyan -BackgroundColor Black  "StartBicepDeploy[210] ApiClientSecret:" $ApiClientSecret
        #Write-Host -ForegroundColor Yellow -BackgroundColor Blue  "StartBicepDeploy[211] **** STARTING AzSubscriptionDeployment *****"
        
        Write-Host -ForegroundColor White -BackgroundColor Black  "StartBicepDeploy[95] BICEP Command: "

        Write-Host -ForegroundColor Cyan "New-AzSubscriptionDeployment `
            -Name $DeploymentName ```
            -Location $Location ```
            -TemplateFile $templateFile ```
            -ResourceGroupName $ResGroupName ```
            -EnvironmentType $Environment ```
						-SiteName $SiteName ```
            -AppName $AppName ```
            -ApiClientId $SecureApiClientId ```
            -ApiClientSecret $SecureApiClientSecret ```
            -WebClientId $SecureWebClientId ```
            -TemplateParameterFile $TemplateParameterFile"

        New-AzSubscriptionDeployment `
            -Name $DeploymentName `
            -Location $Location `
            -TemplateFile $templateFile `
            -ResourceGroupName $ResGroupName `
            -EnvironmentType $Environment `
						-SiteName $SiteName `
            -AppName $AppName `
            -ApiClientId $SecureApiClientId `
            -ApiClientSecret $SecureApiClientSecret `
            -WebClientId $SecureWebClientId `
            -TemplateParameterFile $TemplateParameterFile 

    }

    Write-Host -ForegroundColor Yellow -BackgroundColor Blue  "StartBicepDeploy[90] **** FINISHED AzSubscriptionDeployment *****"
    Write-Host -ForegroundColor Magenta -BackgroundColor Black  "StartBicepDeploy************* EXITING StartBicepDeploy Function *****************"    

}#end of StartBicepDeploy