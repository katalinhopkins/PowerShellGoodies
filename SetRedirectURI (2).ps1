
Function global:SetRedirectURI
{
    Param(
     #  [Parameter(Mandatory = $true)] [String]$AppId
      [Parameter(Mandatory = $true)] [String]$Urls
    )

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START SetRedirectURI *****************"
    
    
		$webAppUrl = "https://$AppName.azurewebsites.us"
    # when you add a redirect URI Azure creates a "web" policy.
    $redirectUris = @()
    $redirectUris += "$webAppUrl"
    Write-Host -ForegroundColor Green "CreateAppRegistration[64] redirecturi:"  $redirectUris


    #Update-AzADApplication -ApplicationId $newapp.AppId -ReplyUrl $redirectUris | Out-Null
    #Update-AzADApplication -ApplicationId $appId -IdentifierUris $appIDUri
    #Write-Host  -ForegroundColor Cyan "CreateAppRegistration[47] Updated API URI:"  $appIDUri
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED SetRedirectURI*****************"
}#SetApplicationIdURI

