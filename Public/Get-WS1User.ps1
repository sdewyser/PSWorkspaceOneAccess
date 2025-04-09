<#
.SYNOPSIS
Retrieves a list of all users in Workspace ONE.

.DESCRIPTION
Fetches information about all users in the Workspace ONE environment.

.PARAMETER AccessToken
The OAuth access token to authenticate API requests.

.PARAMETER AccessURL
The base URL for Workspace ONE Access.

.EXAMPLE
$users = Get-WS1User -AccessToken $token -AccessURL "access.workspaceone.com"
#>
Function Get-WS1User {
    param (
        [string]$AccessToken,
        [string]$AccessURL
    )

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type"  = "application/json"
    }

    try {
        $response = Invoke-RestMethod -Uri "https://${AccessURL}/SAAS/jersey/manager/api/scim/Users?count=9999" -Method GET -Headers $headers -ErrorAction Stop
        return $response.Resources
    }
    catch {
        Write-Error "Failed to get users at ${AccessURL}: $($_.Exception.Message)"
        return $null
    }
}