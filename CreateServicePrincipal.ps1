#CreateServicePrincipal

# Create a Service Principal Name (SPN) for the application created earlier
Function global:CreateServicePrincipal{
 Param(            
 [Parameter(Mandatory = $true)] [String]$AppId    
 )
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta  -BackgroundColor Black "`n *************[$today] START CreateServicePrincipal FOR $AppName *****************"        
    
    $PublicAzureRole = "Owner"
    $SPN = Get-AzADServicePrincipal -ApplicationId $AppId

    if($SPN.DisplayName -eq $null)
    {
        $SPN = New-AzADServicePrincipal -ApplicationId $AppId    
        Write-Host -ForegroundColor Yellow -BackgroundColor Black "CreateServicePrincipal[17] Waiting for the SPN to be created...30 seconds"
        Start-Sleep -Seconds 30
        Write-Host -ForegroundColor Yellow -BackgroundColor Black "CreateServicePrincipal[19] Created Service Principal Name (SPN):" $SPN.AppDisplayName
        #Write-Host -ForegroundColor Yellow -BackgroundColor Black "CreateServicePrincipal[20] Created Service Principal Id (SPN):" $SPN.Id

        # Assign the Service Principal Name a role
        New-AzRoleAssignment -RoleDefinitionName $PublicAzureRole -ServicePrincipalName $AppId | Out-Null

        Write-Host -ForegroundColor Yellow -BackgroundColor Black "CreateServicePrincipal[21] Wait for the AzRoleAssignment to be created...30 seconds"
        Start-Sleep -Seconds 30
        Write-Host -ForegroundColor Yellow -BackgroundColor Black "CreateServicePrincipal[23] Time is up....AzRoleAssignment CREATED"
        $RoleAssignnemt = Get-AzRoleAssignment -ObjectId $SPN.Id
    }
    else
    {
        Write-Host -ForegroundColor Green "CreateServicePrincipal[32] EXISTING SPN.Name:" $SPN.AppDisplayName
        #Write-Host -ForegroundColor Yellow -BackgroundColor Black "CreateServicePrincipal[33] SPN.Id:" $SPN.Id
        $RoleAssignnemt = Get-AzRoleAssignment -ObjectId $SPN.Id        
    }

    #$RoleAssignnemt = Get-AzRoleAssignment -ObjectId $SPN.Id
    <#
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "CreateServicePrincipal[38] AzRoleAssignment.ObjectType:" $RoleAssignnemt.ObjectType
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "CreateServicePrincipal[39] AzRoleAssignment.RoleDefinitionName:" $RoleAssignnemt.RoleDefinitionName
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "CreateServicePrincipal[40] AzRoleAssignment.Scope:" $RoleAssignnemt.Scope
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "CreateServicePrincipal[41] AzRoleAssignment.RoleAssignmentName:" $RoleAssignnemt.RoleAssignmentName   
    #>
    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n *************[$today] EXITING CreateServicePrincipal for $AppName *****************"
    return $SPN
}