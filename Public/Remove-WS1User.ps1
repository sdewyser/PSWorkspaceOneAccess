<#
.SYNOPSIS
Removes a user from Workspace ONE.

.DESCRIPTION
Deletes a user account from Workspace ONE based on the specified user ID.

.PARAMETER AccessToken
The OAuth access token to authenticate API requests.

.PARAMETER AccessURL
The base URL for Workspace ONE Access.

.PARAMETER UserId
The unique identifier of the user to be removed.

.EXAMPLE
Remove-WS1User -AccessToken $token -AccessURL "access.workspaceone.com" -UserId "12345"
#>
Function Remove-WS1User {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [string]$AccessToken,
        [string]$AccessURL,
        [string]$UserId
    )

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type"  = "application/json"
    }

    try {
        if ($PSCmdlet.ShouldProcess('Removing user')) {
            Invoke-RestMethod -Uri "https://${AccessURL}/SAAS/jersey/manager/api/scim/Users/$UserId" -Method DELETE -Headers $headers -ErrorAction Stop
            #return "User ${UserId} removed successfully."
        }
    }
    catch {
        Write-Error "Failed to remove user ${UserId} at ${AccessURL}: $($_.Exception.Message)"
        #return $null
    }
}