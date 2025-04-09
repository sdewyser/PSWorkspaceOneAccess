<#
.SYNOPSIS
    Triggers a synchronization for a specified Workspace ONE directory.

.DESCRIPTION
    The `Sync-WS1Directory` function sends a request to sync a directory within Workspace ONE Access.
    It uses the Workspace ONE REST API and requires authentication through an access token.

.PARAMETER DirectoryId
    The unique identifier of the Workspace ONE directory to be synchronized.

.PARAMETER AccessURL
    The base URL of the Workspace ONE Access tenant (e.g., mytenant.vmwareidentity.com).

.PARAMETER accessToken
    The OAuth2 token used to authenticate API requests.

.EXAMPLE
    Sync-WS1Directory -DirectoryId "directory12345" -AccessURL "mytenant.vmwareidentity.com" -accessToken "eyJhbGciOiJIUz..."

    This example triggers a synchronization for the directory with the ID `directory12345`.
#>
Function Sync-WS1Directory {
    param (
        [string]$DirectoryId,
        [string]$AccessURL,
        [string]$accessToken
    )

    $baseUri = "https://$AccessURL"
    $apiEndpoint = "/SAAS/jersey/manager/api/connectormanagement/directoryconfigurations/$DirectoryId/sync/v2"
    $url = "$baseUri$apiEndpoint"

    $headers = @{
        "Authorization" = "Bearer $accessToken"
        "Content-Type"  = "application/vnd.vmware.horizon.manager.connector.management.directory.sync.trigger.v2+json"
    }

    $jsonBody = @{
        "ignoreSafeguards" = $false
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Method POST -Uri $url -Headers $headers -Body $jsonBody -ErrorAction Stop

        Write-Output "Directory $DirectoryId synced successfully."
        write-output $response
    }
    catch {
        Write-Error "Failed to sync directory: $_"
    }
}