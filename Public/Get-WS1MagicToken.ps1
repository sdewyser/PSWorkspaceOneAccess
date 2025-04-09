<#
.SYNOPSIS
Retrieves the Workspace ONE Magic Token.

.DESCRIPTION
Requests a one-time login link (Magic Token) for a specific user within Workspace ONE.

.PARAMETER AccessToken
The OAuth access token to authenticate API requests.

.PARAMETER AccessURL
The base URL for Workspace ONE Access.

.PARAMETER Domain
The domain name of the user.

.PARAMETER Username
The username for which to retrieve the Magic Token.

.EXAMPLE
$link = Get-WS1MagicToken -AccessToken $token -AccessURL "access.workspaceone.com" -Domain "myDomain" -Username "john.doe"
#>
Function Get-WS1MagicToken {
    param (
        [string]$AccessToken,
        [string]$AccessURL,
        [string]$Domain,
        [string]$Username
    )

    $headers = @{
        "Accept"        = "application/vnd.vmware.horizon.manager.tokenauth.link.response+json"
        "Authorization" = "Bearer $AccessToken"
        "Content-Type"  = "application/vnd.vmware.horizon.manager.tokenauth.generation.request+json"
    }

    $body = @{
        domain   = $Domain
        userName = $Username
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "https://${AccessURL}/SAAS/jersey/manager/api/token/auth/state" -Method POST -Headers $headers -Body $body -ErrorAction Stop
        return $response.loginLink
    }
    catch {
        Write-Error "Failed to get Magic Token for user ${Username} from ${AccessURL}: $($_.Exception.Message)"
        return $null
    }
}