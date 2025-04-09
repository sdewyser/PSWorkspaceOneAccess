<#
.SYNOPSIS
    Retrieves all Workspace ONE directory configurations.

.DESCRIPTION
    The `Get-WS1Directory` function retrieves the configuration details of all Workspace ONE directories, regardless of type.
    It uses the Workspace ONE REST API for this operation.

.PARAMETER AccessURL
    The base URL of the Workspace ONE Access tenant (e.g., mytenant.vmwareidentity.com).

.PARAMETER accessToken
    The OAuth2 token used to authenticate API requests.

.EXAMPLE
    Get-WS1Directory -AccessURL "mytenant.vmwareidentity.com" -accessToken "eyJhbGciOiJIUz..."

    This example retrieves all directory configurations in the Workspace ONE tenant.
#>
Function Get-WS1Directory {
    param (
        [string]$AccessURL,
        [string]$accessToken
    )

    $headers = @{
        "Authorization" = "Bearer $accessToken"
    }

    try {
        $response = Invoke-WebRequest -Uri "https://$AccessURL/SAAS/jersey/manager/api/connectormanagement/directoryconfigs/" -Headers $headers -Method Get
        return ($response | ConvertFrom-Json | Select-Object -ExpandProperty items)
    }
    catch {
        Write-Error "Failed to retrieve Workspace ONE directories: $_"
        return $null
    }
}