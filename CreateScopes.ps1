#CreateScopes
Function global:CreateScopes{ 
  Param(
    [Parameter(Mandatory = $true)] [String]$AppName
  #, [Parameter(Mandatory = $true)] [String]$Scope	
  )
		$today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START CreateScopes FOR $AppName *****************"    
    
    if(($app = Get-AzADApplication -Filter "DisplayName eq '$($AppName)'"  -ErrorAction SilentlyContinue))
    {    
      $Scopes = New-Object -TypeName "System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphPermissionScope]"
    
			if($app.Api.Oauth2PermissionScope.Count -gt 0)
			{
					Write-Host -ForegroundColor Green "CreateScopes[17] app.Api.Oauth2PermissionScope.Count:" $app.Api.Oauth2PermissionScope.Count
					$app.Api.Oauth2PermissionScopes | foreach-object { $scopes.Add($_) }
			}
    
			#$ifScopeWithSameValueExist = $app.Api.Oauth2PermissionScopes | Select-Object Value | Where-Object {$_.Value -eq "$($scope)"}

			$Scope = New-Object -TypeName "Microsoft.Graph.PowerShell.Models.MicrosoftGraphPermissionScope"     
			$Scope.Id = New-Guid
			$Scope.Value = "user_impersonation"
			$Scope.UserConsentDisplayName = "User Permit to use DTP"
			$Scope.UserConsentDescription = "Permit use of DTP for Users and Admins"
			$Scope.AdminConsentDisplayName = "Permit use of DTP"
			$Scope.AdminConsentDescription = "Permit use of DTP"
			$Scope.IsEnabled = $true
			$Scope.Type = "User"
			$Scopes.Add($Scope)
    }
}


Function global:CreateScope
{
    param
    (
          [Parameter(Mandatory = $true)] [string] $AppName
        , [Parameter(Mandatory = $true)] [string] $Value
        , [Parameter(Mandatory = $true)][string] $UserConsentDisplayName
        , [Parameter(Mandatory = $true)][string] $UserConsentDescription
        , [Parameter(Mandatory = $true)][string] $AdminConsentDisplayName
        , [Parameter(Mandatory = $true)][string] $AdminConsentDescription
        , [Parameter(Mandatory = $true)][string] $IsEnabled
        , [Parameter(Mandatory = $true)][string] $Type
    )
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"    
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START CreateScope FOR $AppName *****************"    
    try 
    {
        if(($app = Get-AzADApplication -Filter "DisplayName eq '$($AppName)'"  -ErrorAction SilentlyContinue))
        {           
            $Scopes = New-Object -TypeName "System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphPermissionScope]"
            $Scope = New-Object -TypeName "Microsoft.Graph.PowerShell.Models.MicrosoftGraphPermissionScope"             
            $Scope.Id = New-Guid
            $Scope.Value = $value
            $Scope.UserConsentDisplayName = $UserConsentDisplayName
            $Scope.UserConsentDescription = $UserConsentDescription
            $Scope.AdminConsentDisplayName = $AdminConsentDisplayName
            $Scope.AdminConsentDescription = $AdminConsentDescription            
            $Scope.IsEnabled = $true
            $Scope.Type = "User"
        
            $Scopes.Add($Scope)
            $app.Api.Oauth2PermissionScope = $Scopes
            Set-AzADApplication -ObjectId $app.Id -Api $app.Api
            #Write-Host -ForegroundColor Green "CreateScopes[75] Scope '$Scope.Value' added"
        }
    }
    catch {
        $message = $_.Exception.message
        Write-Host -ForegroundColor Red "CreateScopes[80] ##vso[task.LogIssue type=error;] $message `n"
        
        exit 1
    }
    
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED CreateScope FOR $AppName *****************"    
    return $Scope
}

