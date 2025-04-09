<#
.SYNOPSIS
Resets a Workspace ONE Magic Token for a user.

.DESCRIPTION
Deletes the current Magic Token for a user and generates a new one.

.PARAMETER AccessToken
The OAuth access token to authenticate API requests.

.PARAMETER AccessURL
The base URL for Workspace ONE Access.

.PARAMETER Domain
The domain name of the user.

.PARAMETER Username
The username for whom to reset the Magic Token.

.EXAMPLE
$newLink = Reset-WS1MagicToken -AccessToken $token -AccessURL "access.workspaceone.com" -Domain "myDomain" -Username "john.doe"
#>
Function Reset-WS1MagicToken {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [string]$AccessToken,
        [string]$AccessURL,
        [string]$Domain,
        [string]$Username
    )

    try {
        if ($PSCmdlet.ShouldProcess('Removing user')) {
            Remove-WS1MagicToken -AccessToken $AccessToken -AccessURL $AccessURL -Username $Username
            $loginLink = Get-WS1MagicToken -AccessToken $AccessToken -AccessURL $AccessURL -Domain $Domain -Username $Username
            return $loginLink
        }
    }
    catch {
        Write-Error "Failed to reset Magic Token for user ${Username} at ${AccessURL}: $($_.Exception.Message)"
        return $null
    }
}