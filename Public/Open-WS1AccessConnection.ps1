<#
.SYNOPSIS
Opens a connection to Workspace ONE Access.

.DESCRIPTION
Generates an OAuth token using client credentials and retrieves the access token for Workspace ONE Access.

.PARAMETER ClientId
The client ID for the Workspace ONE Access API.

.PARAMETER ClientSecret
The client secret for the Workspace ONE Access API.

.PARAMETER AccessURL
The base URL for Workspace ONE Access.

.EXAMPLE
$token = Open-WS1AccessConnection -ClientId "myClientId" -ClientSecret "mySecret" -AccessURL "access.workspaceone.com"
#>
Function Open-WS1AccessConnection {
    param (
        [string]$ClientId,
        [string]$ClientSecret,
        [string]$AccessURL
    )

    $text = "${ClientId}:${ClientSecret}"
    $base64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($text))

    $headers = @{
        "Authorization" = "Basic $base64"
        "Content-Type"  = "application/x-www-form-urlencoded"
    }

    try {
        $results = Invoke-WebRequest -Uri "https://${AccessURL}/SAAS/auth/oauthtoken?grant_type=client_credentials" -Method POST -Headers $headers -ErrorAction Stop
        return ($results.Content | ConvertFrom-Json).access_token
    }
    catch {
        Write-Error "Failed to retrieve access token for URL ${AccessURL} with client ${ClientId}: $($_.Exception.Message)"
        return $null
    }
}