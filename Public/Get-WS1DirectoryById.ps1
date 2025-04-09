<#
.SYNOPSIS
    Retrieves a specific Workspace ONE directory configuration by Directory ID.

.DESCRIPTION
    The `Get-WS1DirectoryById` function retrieves configuration details of a specific Workspace ONE directory
    using its Directory ID. It uses the Workspace ONE REST API for this operation.

.PARAMETER AccessURL
    The base URL of the Workspace ONE Access tenant (e.g., mytenant.vmwareidentity.com).

.PARAMETER AccessToken
    The OAuth2 token used to authenticate API requests.

.PARAMETER DirectoryId
    The unique identifier of the Workspace ONE directory to retrieve.

.EXAMPLE
    Get-WS1Directory -AccessURL "mytenant.vmwareidentity.com" -AccessToken "eyJhbGciOiJIUz..." -DirectoryId "12345"

    This example retrieves the directory configuration for the directory with ID `12345`.
#>
Function Get-WS1DirectoryById {
    param (
        [string]$AccessURL,
        [string]$AccessToken,
        [string]$DirectoryId
    )

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
    }

    try {
        $response = Invoke-WebRequest -Uri "https://$AccessURL/SAAS/jersey/manager/api/connectormanagement/directoryconfigs/" -Headers $headers -Method Get
        $directories = $response | ConvertFrom-Json | Select-Object -ExpandProperty items
        return $directories | Where-Object { $_.directoryId -eq $DirectoryId }
    }
    catch {
        Write-Error "Failed to retrieve the Workspace ONE directory: $_"
        return $null
    }
}