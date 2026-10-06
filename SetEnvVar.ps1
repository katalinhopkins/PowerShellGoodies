Install-Module -Name PnP.PowerShell -Scope CurrentUser

Install-Module -Name PnP.PowerShell -Scope CurrentUser
Get-Module PnP.PowerShell -ListAvailable


Import-Module PnP.PowerShell -Scope CurrentUser

Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Scope CurrentUser

Get-Module -ListAvailable Microsoft.Online.SharePoint.PowerShell


Connect-PnPOnline -Url "https://dod365.sharepoint-mil.us/sites/AFRICOM-J6-DTA" -UseWebLogin

Get-PnPSite
Get-PnPWeb

$NewPath = 'C:\Users\1263888436.ctr\Documents\WindowsPowerShell'
$env:PSModulePath = "$NewPath;$env:PSModulePath"

[Environment]::SetEnvironmentVariable(
    'PSModulePath',
    "$NewPath;$($env:PSModulePath)",
    'User'
)

#See your current PSModulePath
$env:PSModulePath -split ';'


<#
Remove it permanently
#>
$Current = [Environment]::GetEnvironmentVariable('PSModulePath', 'User')

$Updated = ($Current -split ';' |
    Where-Object { $_ -ne 'C:\Users\1263888436.ctr\OneDrive - Defense Information Systems Agency\Documents\WindowsPowerShell\Modules' }
) -join ';'

[Environment]::SetEnvironmentVariable('PSModulePath', $Updated, 'User')
