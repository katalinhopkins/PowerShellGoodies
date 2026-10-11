#AppRolesProcess
#.\CreateAppRoles.ps1 -AppName "TueClient" -AppRolesList "DTP Admins,DTP Users"

Function global:CreateAppRole
{
  param(

    [Parameter(Mandatory = $true)]
    [string[]] $AllowedMemberTypes,

    [Parameter(Mandatory = $true)]
    [string] $Description,

    [Parameter(Mandatory = $true)]
    [String] $DisplayName,
        
    [Parameter(Mandatory = $true)]
    [string] $Value,
        
    [switch] $Disabled

    
)
$today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"    
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START CreateAppRole *****************"        
    try 
    {       
        Write-Host -ForegroundColor Green "CreateAppRole[105] DisplayName:" $DisplayName
        Write-Host -ForegroundColor Green "CreateAppRole[106] Description:" $Description
        #Write-Host -ForegroundColor Green "CreateAppRole[] :"
        
        $AppRole = New-Object Microsoft.Graph.PowerShell.Models.MicrosoftGraphAppRole
        $AppRole.AllowedMemberTypes = New-Object System.Collections.Generic.List[string]                
                
        $AppRole.DisplayName = $DisplayName
        $AppRole.Description = $Description
        $AppRole.Value = $Value;
        $AppRole.Id = New-Guid
        $AppRole.IsEnabled =  (-not $Disabled)
        $AppRole.AllowedMemberTypes = @($AllowedMemberTypes)
        return $AppRole
   }
    catch {
        $message = $_.Exception.message
        Write-Host -ForegroundColor Red  "`CreateAppRole[129] ##vso[task.LogIssue type=error;] $message"
        exit 1
    }
   $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss" 
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED CreateAppRole  *****************"
}

<#
Function global:UpdateAppRoles
{
    param (
        [Parameter(Mandatory = $true)]
        [String] $AppName,  
        
        [Parameter(Mandatory = $true)]    
        [Object] $AppRole
    )
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START UpdateAppRoles FOR $AppName *****************"        
    
    try 
    {
      
        #Write-Host "UpdateAppRoles[25] AppName:" $AppName
        #Write-Host "UpdateAppRoles[26] AppRole.DisplayName:" $AppRole.DisplayName
        #Write-Host "UpdateAppRoles[] :"
    
        if(
            #($Application = Get-AzADApplication -Filter "DisplayName eq '$($AppName)'"  -ErrorAction SilentlyContinue)
            ($Application = Get-AzADApplication -DisplayName $AppName  -ErrorAction SilentlyContinue)
        )
        {
            $AppId = $Application.AppId
            $AppObjectId = $Application.Id
            $AppRoles = $Application.AppRole

            Write-Host -ForegroundColor Cyan "UpdateAppRoles[32] AppRoles.Count=" $AppRoles.Count          
            if($AppRoles.Count -eq 0)
            {
                $AppRoles = New-Object System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphAppRole]
             #   Write-Host -ForegroundColor Green "UpdateAppRoles[36] Created New MicrosoftGraphAppRole List for AppRoles"
            }
            else{            
                Write-Host -ForegroundColor Green "UpdateAppRoles[40] Existing AppRoles are present"
            }

            $i=0
            foreach ($role in $AppRoles) {               
              #  Write-Host "[$i] role.disp-" $role.DisplayName
                #Write-Host "[$i] role.disp-" $AppRoles[$i].DisplayName
               # Write-Host "[$i] AppRole.disp-" $AppRole.DisplayName

                if($role.DisplayName -eq $AppRole.DisplayName)
                {
                    Write-Host -f Yellow "UpdateAppRoles[54] ##[warning] [$i] ' $($role.DisplayName)' already exists"                    
                    return
                } 
                $i++
            }

            #Write-Host -ForegroundColor Cyan "UpdateAppRoles[55] AppRole.DisplayName=" $AppRole.DisplayName
            #Write-Host -ForegroundColor Cyan "UpdateAppRoles[56] description=" $description     
        
            $AppRoles += $newAppRole        

           Update-AzADApplication -ObjectId $AppObjectId -AppRole $AppRoles
           Write-Host -f Green "UpdateAppRoles[64] ##[section] App role '$($AppRole)' added successfully"
           
        }
        else
        {
            Write-Host -f Yellow "UpdateAppRoles[69] ##[warning] Application with name '$($DisplayName)' does not Exists"            
            return
        }
    }
    catch
    {
        $message = $_.Exception.message
        Write-Host  "`UpdateAppRoles[] ##vso[task.LogIssue type=error;] $message"
        exit 1        
    }
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED UpdateAppRoles FOR $AppName *****************"        
}#UpdateAppRoles

#>

#& "$PSScriptRoot\ConnectToMSGraph.ps1"
<#
Function AppRolesProcess {
    param(
    [Parameter(Mandatory = $true)]
    [String] $AppName,
    [Parameter(Mandatory = $true)]
    [String] $AppRolesList
    )
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START AppRolesProcess FOR $AppName *****************"        
    $AppRoles = $AppRolesList.Split(",")
    Write-Host "AppRolesProcess[147] AppRoles.Count=" $AppRoles.Count
    # Connect-AzureAD automatically
    #ConnectToMSGraph
          
    #Write-Host "AppRolesProcess[128] Creating app roles '$($AppRolesList)' for '$($AppName)'..."
    
    $i=0
    foreach ($item in $AppRoles) 
    {
        $item = $item.Trim()
        #Write-Host -ForegroundColor Yellow "AppRolesProcess[$i] item: $item"
        $i++
        #Write-Host -ForegroundColor Yellow "AppRolesProcess[136] Calling[$i] CreateAudienceAppRoles for: $item"
        CreateAudienceAppRoles -AppName $AppName -AppRole $item 
        #Write-Host -ForegroundColor Yellow "AppRolesProcess[138] FINISHED[$i] CreateAudienceAppRoles for: $item"
    }
		$today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] FINISHED AppRolesProcess FOR $AppName *****************"
}
#>
#AppRolesProcess

#.\CreateAppRoles.ps1 -AppName "c" -AppRolesList "DTP Admins,DTP Users"
#AppRolesProcess -AppName "TueClient" -AppRolesList "DTP Admins,DTP Users"
#AppRolesProcess -AppName "TueClient" -AppRolesList "DTP Admin"
<#

$newAppRole = CreateAppRole `
    -DisplayName  "DTP Admins" `
    -Description "Admin enabled users of the DTP web application" `
    -Value "DTP.Admins" `
    -AllowedMemberTypes "User"

    Write-Host -ForegroundColor Green "[193] newAppRole.DisplayName= " $newAppRole.DisplayName
    
    
CreateAudienceAppRoles -AppName "TueClient" -AppRole $newAppRole 


$newAppRole = CreateAppRole `
    -DisplayName  "DTP Users" `
    -Description "Normal users of the DTP web application" `
    -Value "DTP.Users" `
    -AllowedMemberTypes "User"
CreateAudienceAppRoles -AppName "TueClient" -AppRole $newAppRole 


#>