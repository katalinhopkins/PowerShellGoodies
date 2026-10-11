
Function global:SetApplicationIdURI
{
    Param(
     [Parameter(Mandatory = $true)] [String]$AppId
    )
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START SetApplicationIdURI *****************"
    $appIDUri = "api://" + $AppId
    
    #Update-AzADApplication -ApplicationId $newapp.AppId -ReplyUrl $redirectUris | Out-Null
    Update-AzADApplication -ApplicationId $appId -IdentifierUris $appIDUri
    #Write-Host  -ForegroundColor Cyan "CreateAppRegistration[47] Updated API URI:"  $appIDUri
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED SetApplicationIdURI*****************"
}#SetApplicationIdURI