<#
.SYNOPSIS
Removes a Workspace ONE Magic Token for a user.

.DESCRIPTION
Deletes the Magic Token associated with a specified user.

.PARAMETER AccessToken
The OAuth access token to authenticate API requests.

.PARAMETER AccessURL
The base URL for Workspace ONE Access.

.PARAMETER Username
The username whose Magic Token is to be removed.

.EXAMPLE
Remove-WS1MagicToken -AccessToken $token -AccessURL "access.workspaceone.com" -Username "john.doe"
#>
Function Remove-WS1MagicToken {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [string]$AccessToken,
        [string]$AccessURL,
        [string]$Username
    )

    $headers = @{
        "Accept"        = "application/vnd.vmware.horizon.manager.tokenauth.link.response+json"
        "Authorization" = "Bearer $AccessToken"
        "Content-Type"  = "application/vnd.vmware.horizon.manager.tokenauth.generation.request+json"
    }

    try {
        $user = Get-WS1UserByUsername -AccessToken $AccessToken -AccessURL $AccessURL -Username $Username
        if (-not $user) {
            throw "User ${Username} not found"
        }
        $userId = $user.id
        if ($PSCmdlet.ShouldProcess('Removing magic token')) {
            Invoke-RestMethod -Uri "https://${AccessURL}/SAAS/jersey/manager/api/token/auth/state/$userId" -Method DELETE -Headers $headers -ErrorAction Stop
            # return "Magic Token for ${Username} removed successfully."
        }
    }
    catch {
        Write-Error "Failed to remove Magic Token for user ${Username} at ${AccessURL}: $($_.Exception.Message)"
        # return $null
    }
}