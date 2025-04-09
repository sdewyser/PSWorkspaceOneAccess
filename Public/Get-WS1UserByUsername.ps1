<#
.SYNOPSIS
Retrieves information for a specific Workspace ONE user.

.DESCRIPTION
Fetches details of a user based on their username in Workspace ONE.

.PARAMETER AccessToken
The OAuth access token to authenticate API requests.

.PARAMETER AccessURL
The base URL for Workspace ONE Access.

.PARAMETER Username
The username of the user to retrieve.

.EXAMPLE
$userInfo = Get-WS1UserByUsername -AccessToken $token -AccessURL "access.workspaceone.com" -Username "john.doe"
#>
Function Get-WS1UserByUsername {
    param (
        [string]$AccessToken,
        [string]$AccessURL,
        [string]$Username
    )

    $apiEndpoint = "/SAAS/jersey/manager/api/scim/Users"
    $username = $username.Replace("@", "%40")
    $filter = "?filter=userName%20eq%20%22$username%22&sortOrder=descending"

    $url = "https://$AccessURL$apiEndpoint$filter"

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type"  = "application/json"
    }

    try {
        $response = Invoke-RestMethod -Uri $url -Method GET -Headers $headers -ErrorAction Stop
        return $response.Resources | Select-Object -First 1
    }
    catch {
        Write-Error "Failed to retrieve user ${Username} from ${AccessURL}: $($_.Exception.Message)"
        return $null
    }
}