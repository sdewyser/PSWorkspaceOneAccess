<#
.SYNOPSIS
Retrieves a list of authentication methods configured in Workspace ONE Access.

.DESCRIPTION
Calls the Workspace ONE Access API endpoint to retrieve a summary of all available authentication methods,
their names, UUIDs, enabled status, and ownership.

.PARAMETER accessURL
The hostname of the Workspace ONE Access tenant.

.PARAMETER accessToken
The bearer token used to authenticate API requests.

.EXAMPLE
Get-AuthenticationMethods -accessURL $url -accessToken $token

.NOTES
Author: Stefaan
#>
function Get-WS1AuthenticationMethods {
    param (
        [Parameter(Mandatory)][string]$accessURL,
        [Parameter(Mandatory)][string]$accessToken
    )

    $uri = "https://$accessURL/SAAS/jersey/manager/api/amms/authmethods"

    $headers = @{
        "Authorization" = "Bearer $accessToken"
        "Accept"        = "application/vnd.vmware.vidm.amms.auth.methods.summary.list+json"
        "User-Agent"    = "PowerShell/7.4"
    }

    try {
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get

        if ($response.items) {
            return $response.items
        }
        else {
            Write-Warning "No authentication methods returned."
            return @()
        }
    }
    catch {
        Write-Warning "Failed to retrieve auth methods: $_"
        return @()
    }
}
