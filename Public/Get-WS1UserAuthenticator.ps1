<#
.SYNOPSIS
Retrieves authenticator information for a specific Workspace ONE user.

.DESCRIPTION
Fetches authenticator of a user based on their username in Workspace ONE.

.PARAMETER AccessToken
The OAuth access token to authenticate API requests.

.PARAMETER AccessURL
The base URL for Workspace ONE Access.

.PARAMETER Username
The username of the user to retrieve authenticator information.

.EXAMPLE
$authenticatorInfo = Get-WS1UserAuthenticator -AccessToken $token -AccessURL "access.workspaceone.com" -Username "john.doe"
#>
Function Get-WS1UserAuthenticator {
    param (
        [string]$AccessToken,
        [string]$AccessURL,        
        [string]$Username
    )

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type"  = "application/json"
    }

    try {
        $tmpUser = Get-WS1UserByUsername -AccessToken $AccessToken -AccessURL $AccessURL -Username $Username
        $tmpUserId = $tmpUser.id

        if ($tmpUser) {
            $response = Invoke-RestMethod -Uri "https://${AccessURL}/authcontrol/authenticators/${tmpUserId}?authType=00000000-0000-0000-0000-000000000028" -Method GET -Headers $headers -ErrorAction Stop
            return $response
        }
    }
    catch {
        Write-Error "Failed to get users at ${AccessURL}: $($_.Exception.Message)"
        return $null
    }
}