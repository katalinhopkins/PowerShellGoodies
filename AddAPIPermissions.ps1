#AddAPIPermissions
<#
AddAPIPermissions -AppId $AppId -PermissionParent $PermissionParent
#>

Function global:AddAPIPermissions{
 Param(      
      [Parameter(Mandatory = $true)] [String]$AppName
    , [Parameter(Mandatory = $true)] [String]$AppId
    , [Parameter(Mandatory = $true)] [String]$AppObjectId
    , [Parameter(Mandatory = $true)] [String]$PermissionParent
    , [Parameter(Mandatory = $true)] [String[]]$RequiredDelegatedPermissionNames           

 )
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START AddAPIPermissions FOR $AppName *****************"    
    
   # Write-Host -ForegroundColor Yellow "AddAPIPermissions[32] AppId:" $AppId    
   # Write-Host -ForegroundColor Yellow "AddAPIPermissions[32] AppObjectId:" $AppObjectId    

    #<#
    #DEBUG
		<#		
    $i=0
    Write-Host -ForegroundColor Yellow "AddAPIPermissions[17] RequiredDelegatedPermissionNames:"    
    foreach ($item in $RequiredDelegatedPermissionNames) {
        $item = $item.Trim()
        Write-Host "[$i]=" $item
        $i++
    }    
   #>
   
    #MS Graph
    if($PermissionParent -eq "Microsoft Graph" )
    {
        #Write-Host -ForegroundColor Yellow "AddAPIPermissions[37] PermissionParent:" $PermissionParent
        $GraphId = (Get-AzADServicePrincipal -DisplayName "$PermissionParent").AppId
        #Write-Host -ForegroundColor Yellow "AddAPIPermissions[40] GraphId:" $GraphId
        
        $GraphSPN = Get-MgServicePrincipal -Filter "AppId eq '$GraphId'"
        #Write-Host -ForegroundColor Yellow "AddAPIPermissions[43] GraphSPN.Id:" $GraphSPN.Id
        
        # Get all available Delegated permissions (Scope) for Microsoft Graph
        $AllDelegatedPermissions = $GraphSPN.Oauth2PermissionScopes        
    }
    #Other Permission Parent
    else
    {
        $GraphSPN = Get-MgServicePrincipal -Filter "AppId eq '$PermissionParent'"
        $AllDelegatedPermissions = $GraphSPN.Oauth2PermissionScopes    
        #Write-Host -ForegroundColor Green "Other Permission[53] PermissionParent:" $PermissionParent        
    }

    $RequiredDelegatedPermissions = $AllDelegatedPermissions | Where-Object -FilterScript { $_.Value -in $RequiredDelegatedPermissionNames }
    
    # Create a RequiredResourceAccess object containing the required application and delegated permissions
    $RequiredPermissions = New-Object -TypeName "Microsoft.Graph.PowerShell.Models.MicrosoftGraphRequiredResourceAccess"
    $RequiredPermissions.ResourceAppId = $GraphSPN.AppId
    $i=0
    # Create delegated permission objects (Scope)
    #Write-Host -ForegroundColor Blue -BackgroundColor White "AddAPIPermissions[62] NewDelegatedPermissions: LOOP"
    foreach ($RequiredDelegatedPermission in $RequiredDelegatedPermissions) 
    {
        $NewDelegatedPermission = New-Object -TypeName "Microsoft.Graph.PowerShell.Models.MicrosoftGraphResourceAccess" -Property @{ Id = $RequiredDelegatedPermission.Id; Type = "Scope" }
        $RequiredPermissions.ResourceAccess += $NewDelegatedPermission
        #Write-Host "[$i]" $NewDelegatedPermission.Id        
        $i++
    }
    #Write-Host -ForegroundColor Yellow "AddAPIPermissions[78] RequiredPermissions.ResourceAccess"
   
    # Grant admin consent for the new permissions
    # The error "no reply URLs configured" can be safely ignored, the consent will have worked, this simply means that you have no redirect URIs configured for your app registration
    #Start-Process -FilePath "https://login.microsoftonline.us/common/adminconsent?client_id=$($AppId)"
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n *************[$today] EXITING AddAPIPermissions for $AppName *****************"
    return $RequiredPermissions
}#AddAPIPermissions