<#
.SYNOPSIS
Retrieves audit information from Workspace ONE for specified criteria.

.DESCRIPTION
The Get-WS1AuditInformation function retrieves audit logs from Workspace ONE, including details such as timestamps, events, and additional information. The data can be filtered by username, date range, and object type. It handles paginated responses to gather all available audit records.

.PARAMETER AccessToken
The OAuth access token used to authenticate API requests.

.PARAMETER AccessURL
The base URL for Workspace ONE Access.

.PARAMETER Username
(Optional) The username to filter the audit logs for a specific user.

.PARAMETER StartDate
The start date for the audit log search. Defaults to 3 days prior to the current date.

.PARAMETER EndDate
The end date for the audit log search. Defaults to the current date.

.PARAMETER ObjectType
The type of object to filter the audit logs by. Acceptable values are:
- Group
- LAUNCH
- LOGIN_ERROR
- DyrectorySyncProfile
- AppEntitlement
- LAUNCH_ERROR
- None (default)

.PARAMETER PageSize
The number of records to retrieve per page. Defaults to 500.

.EXAMPLE
Get-WS1AuditInformation -AccessToken $token -AccessURL "access.workspaceone.com" -Username "john.doe@example.com" -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date) -ObjectType "LOGIN_ERROR" -PageSize 100

Retrieves audit logs for the user `john.doe@example.com`, filtered by the object type `LOGIN_ERROR`, for the past 7 days with 100 records per page.

.EXAMPLE
Get-WS1AuditInformation -AccessToken $token -AccessURL "access.workspaceone.com" -StartDate (Get-Date).AddDays(-1)

Fetches all audit logs for the last 24 hours.

.EXAMPLE
Get-WS1AuditInformation -AccessToken $token -AccessURL "access.workspaceone.com" -ObjectType "Group"

Retrieves all audit logs related to groups.

.NOTES
Ensure that the AccessToken has sufficient permissions to access the audit API in Workspace ONE.

#>
Function Get-WS1AuditInformation {
    param (
        [string]$AccessToken,
        [string]$AccessURL,
        [string]$Username = $null,
        [datetime]$StartDate = (Get-Date).AddDays(-3), # Default to last 3 days
        [datetime]$EndDate = (Get-Date),
        [ValidateSet ("Group", "LAUNCH", "LOGIN_ERROR", "DyrectorySyncProfile", "AppEntitlement", "LAUNCH_ERROR", "None")] # Predefined values
        [string]$ObjectType = "None",
        [int]$PageSize = 500
    )

    $apiEndpoint = "/analytics/reports/audit"

    # Convert StartDate and EndDate to epoch milliseconds
    $fromMillis = [math]::Round((($StartDate - (Get-Date "1970-01-01"))).TotalMilliseconds)
    $toMillis = [math]::Round((($EndDate - (Get-Date "1970-01-01"))).TotalMilliseconds)

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type"  = "application/json"
    }

    try {
        $events = @()
        $page_rotator = $true
        $event_page = 0

        while ($page_rotator) {
            try {
                $startIndex = ($event_page * $PageSize)

                # Check API pagination limits (e.g., maximum startIndex)
                if ($startIndex -ge 10000) {
                    # Write-Host "Reached API pagination limit. Stopping further requests."
                    $page_rotator = $false
                    break
                }

                if ($ObjectType -ne "None") {
                    $filter = "?fromMillis=$fromMillis&toMillis=$toMillis&objectType=$ObjectType&pageSize=$PageSize&startIndex=$startIndex"
                }
                else {
                    $filter = "?fromMillis=$fromMillis&toMillis=$toMillis&pageSize=$PageSize&startIndex=$startIndex"
                }

                $url = "https://$AccessURL$apiEndpoint$filter"

                $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get

                if (-not $response.data) {
                    Write-Host "No data returned from API."
                    break
                }

                $events += $response.data

                # Stop pagination if fewer items than PageSize are returned
                if ($response.data.count -lt $PageSize) {
                    $page_rotator = $false
                }

                $event_page++
            }
            catch {
                # Write-Error "Error during API call: $($_.Exception.Message)"
                break
            }
        }

        # Transform events into desired format
        $result = @()

        foreach ($jsonArray in $events) {
            $timestampMs = [double]$jsonArray[0]
            $readableDate = [datetime]::UnixEpoch.AddMilliseconds($timestampMs)

            $result += [PSCustomObject]@{
                Timestamp = $readableDate.ToString("dd-MM-yyyy HH:mm:ss")
                Email     = $jsonArray[1]
                Event     = $jsonArray[2]
                ExtraInfo = if ($null -ne $jsonArray[4]) { 
                    $jsonArray[4] | ConvertFrom-Json 
                }
                else { 
                    $null 
                }
            }
        }
        # Filter results by Username if provided
        if ($Username) {
            $result = $result | Where-Object {
                $_.ExtraInfo -and $_.ExtraInfo.actorUserName -eq $Username
            }
        }

        return $result
    }
    catch {
        Write-Error "Failed to retrieve login audit logs: $($_.Exception.Message)"
        return $null
    }
}