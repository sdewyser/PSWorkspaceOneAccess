<#
.SYNOPSIS
Retrieves assignments for a specified web application in Workspace ONE Access.

.DESCRIPTION
Fetches entitlement details for a specific web application, including assigned users and groups.

.PARAMETER AccessToken
The OAuth access token to authenticate API requests.

.PARAMETER AccessURL
The base URL for Workspace ONE Access.

.PARAMETER AppID
The unique identifier of the web application whose assignments need to be retrieved.

.EXAMPLE
Get-WS1WebAppAssignments -AccessToken $token -AccessURL "access.workspaceone.com" -AppID "12345"
#>
function Get-WS1WebAppAssignments {
    param (
        [string]$AccessToken,
        [string]$AccessURL,
        [string]$AppID
    )

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type"  = "application/vnd.vmware.horizon.manager.entitlements.definition.catalogitem+json"
    }

    $url = "https://$AccessURL/SAAS/jersey/manager/api/entitlements/definitions/catalogitems/$AppID"
    $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers

    return $response.items
}