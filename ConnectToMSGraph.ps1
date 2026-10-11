#ConnectToMSGraph

<#\RUN:
.\ConnectToMSGraph.ps1  -SignInAudience AzureADMyOrg

.\ConnectToMSGraph.ps1 -AppName "PowerShell Graph Tutorial" -SignInAudience AzureADMyOrg

AzureADMyOrg	Only users in your Microsoft 365 organization
AzureADMultipleOrgs	Users in any Microsoft 365 organization (work or school accounts)
AzureADandPersonalMicrosoftAccount	Users in any Microsoft 365 organization (work or school accounts) and personal Microsoft accounts
PersonalMicrosoftAccount	Only personal Microsoft accounts
#>

Function global:ConnectToMSGraph{
Param(
  [Parameter(Mandatory=$false,
  HelpMessage="The sign in audience for the app")]
  [ValidateSet("AzureADMyOrg", "AzureADMultipleOrgs", `
  "AzureADandPersonalMicrosoftAccount", "PersonalMicrosoftAccount")]
  [String]
  $SignInAudience = "AzureADandPersonalMicrosoftAccount",

  [Parameter(Mandatory=$false)]
  [Switch]
  $StayConnected = $false
)

$today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
Write-Host -ForegroundColor Magenta -BackgroundColor Black  "`n*************[$today] Connecting to Azure and MS Graph *****************"

# Tenant to use in authentication.
# See https://docs.microsoft.com/azure/active-directory/develop/v2-oauth2-device-code#device-authorization-request
$authTenant = switch ($SignInAudience)
{
  "AzureADMyOrg" { "tenantId" }
  "AzureADMultipleOrgs" { "organizations" }
  "AzureADandPersonalMicrosoftAccount" { "common" }
  "PersonalMicrosoftAccount" { "consumers" }
  default { "invalid" }
}


if ($authTenant -eq "invalid")
{
  Write-Host -ForegroundColor Red "Invalid sign in audience:" $SignInAudience
  Exit
}

Connect-AzAccount -EnvironmentName AzureUSGovernment

# Requires an admin
Connect-MgGraph -Environment USGov -Scopes "Directory.AccessAsUser.All, Application.ReadWrite.All, User.Read" -ErrorAction Stop
#Connect-MgGraph -Scopes "Application.ReadWrite.All User.Read" -UseDeviceAuthentication -ErrorAction Stop

# Get context for access to tenant ID
$context = Get-MgContext -ErrorAction Stop

#Write-Host -ForegroundColor Cyan "Tenant:" $authTenant
if ($authTenant -eq "tenantId")
{
  $authTenant = $context.TenantId
}

$global:subscription = Get-AzSubscription
$global:SubscriptionName = $subscription.Name
$global:SubscriptionId = $subscription.Id

$global:azureContext = Get-AzContext
$global:Tenant = (Get-AzTenant).Name
$global:TenantId = (Get-AzTenant).Id

$today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
Write-Host -ForegroundColor Green -BackgroundColor Black  "`n*************[$today] CONNECTED to Azure and MS Graph ***************"
}
