#CreateResourceGroup
<#
Checks to see if the resourceGroup by that name exists, if not, creates it
#>
Function global:CreateResourceGroup 
{
    Param(
          [Parameter(Mandatory = $true)] [String]$ResGroupName
        , [Parameter(Mandatory = $true)] [String]$Environment
        , [Parameter(Mandatory = $true)] [String]$Location
    )

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    Write-Host -ForegroundColor Cyan -BackgroundColor DarkBlue  "`n *************[$today] START CreateResourceGroup  *****************"
    
    #Write-Host -ForegroundColor Cyan  -BackgroundColor DarkBlue "CreateResourceGroup[16] ResGroupName: " $ResGroupName

    $myResourceGroup = Get-AzResourceGroup -Name $ResGroupName -ErrorVariable notPresent -ErrorAction SilentlyContinue
    if ($notPresent) 
    {
        # ResourceGroup doesn't exist
        $myResourceGroup = New-AzResourceGroup -Name $ResGroupName -Location $Location
        #Write-Host -ForegroundColor Cyan -BackgroundColor DarkBlue "CreateResourceGroup[20] Creating New ResourceGroup: "  $ResGroupName
        $ResourceId = $myResourceGroup.ResourceId
        Write-Host -ForegroundColor Cyan -BackgroundColor DarkBlue "CreateResourceGroup[20] Creating New ResourceGroup: "  $ResourceId
    }
    else 
    {
        $myResourceGroup = Get-AzResourceGroup -Name $ResGroupName
        # ResourceGroup exists: get its resourceID
        $ResourceId = $myResourceGroup.ResourceId
        Write-Host -ForegroundColor Red -BackgroundColor DarkBlue "CreateResourceGroup[30] EXISTING ResourceGroup: "$ResGroupName
        Write-Host -ForegroundColor Red -BackgroundColor DarkBlue "Returning ResourceID: " $ResourceId
    }

    "Resource Group Name: " + $ResGroupName >> $OutFile
    "Resource Group's ResourceId: " + $ResourceId >> $OutFile

    $today = Get-Date -Format "MM-dd-yyyy-HH-mm:ss"
    #Write-Host -ForegroundColor Cyan -BackgroundColor DarkBlue "CreateResourceGroup[38] ResourceGroup: "  $ResGroupName  " CREATED"
    Write-Host -ForegroundColor Green  -BackgroundColor DarkBlue "`n ******[$today] FINISHED CreateResourceGroup: $ResGroupName *********"
    
    return $ResourceId
}#CreateResourceGroup