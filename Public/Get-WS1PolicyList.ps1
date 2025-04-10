<#
.SYNOPSIS
Retrieves a list of application access policies from Workspace ONE Access.

.DESCRIPTION
Queries the Workspace ONE Access REST API to fetch paginated policy rulesets tagged as APP_ACCESS.
Handles bearer token authentication and pagination automatically.

.PARAMETER accessURL
The hostname of the Workspace ONE Access tenant.

.PARAMETER accessToken
The bearer token used to authenticate API requests.

.EXAMPLE
Get-PolicyList -accessURL $url -accessToken $token

.NOTES
Author: Stefaan
#>
function Get-WS1PolicyList {
    param (
        [Parameter(Mandatory)][string]$accessURL,
        [Parameter(Mandatory)][string]$accessToken
    )

    $pageSize = 20
    $pageNumber = 1
    $policies = @()

    do {
        $uri = "https://$accessURL/acs/rulesets?tag=APP_ACCESS&policyListType=APP_ACCESS_POLICIES&pageNumber=$pageNumber&pageSize=$pageSize"
        $headers = @{
            "Authorization" = "Bearer $accessToken"
            "Accept"        = "application/vnd.vmware.vidm.accesscontrol.ruleset.list+json"
            "User-Agent"    = "PowerShell/7.4"
        }

        try {
            $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
            if ($response.items) {
                $policies += $response.items
                $pageNumber++
            } else { break }
            if ($pageNumber -gt $response.totalPages) { break }
        } catch {
            Write-Warning "Failed to retrieve rulesets: $_"
            break
        }
    } while ($true)

    return $policies
}
