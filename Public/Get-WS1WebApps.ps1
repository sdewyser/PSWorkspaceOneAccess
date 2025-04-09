<#
.SYNOPSIS
Retrieves a list of web applications available in Workspace ONE Access.

.DESCRIPTION
Fetches web applications from the Workspace ONE Access catalog, including attributes such as labels, UI capabilities, and authentication information.

.PARAMETER AccessToken
The OAuth access token to authenticate API requests.

.PARAMETER AccessURL
The base URL for Workspace ONE Access.

.EXAMPLE
Get-WS1WebApps -AccessToken $token -AccessURL "access.workspaceone.com"
#>
function Get-WS1WebApps {
    param (
        [string]$AccessToken,
        [string]$AccessURL
    )

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Accept"        = "application/vnd.vmware.horizon.manager.catalog.item.list+json"
        "Content-Type"  = "application/vnd.vmware.horizon.manager.catalog.search+json"
    }

    $json = @{
        includeAttributes = @("labels", "uiCapabilities", "authInfo")
        includeTypes      = @("Saml11", "Saml20", "WSFed12", "WebAppLink", "AnyApp")
        nameFilter        = ""
        categories        = @()
        rootResource      = $false
    } | ConvertTo-Json -Depth 2

    $url = "https://$AccessURL/SAAS/jersey/manager/api/catalogitems/search?startIndex=0&pageSize=50"

    $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $json

    return $response.items
}