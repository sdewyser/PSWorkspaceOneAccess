<#
.SYNOPSIS
Retrieves login audit events for a specific user.

.DESCRIPTION
Fetches login audit logs for a specified user in Workspace ONE.

.PARAMETER AccessToken
The OAuth access token to authenticate API requests.

.PARAMETER AccessURL
The base URL for Workspace ONE Access.

.PARAMETER Username
The username for which to retrieve login audit logs.

.PARAMETER StartDate
The start date for the query range (optional, default is 30 days ago).

.PARAMETER EndDate
The end date for the query range (optional, default is the current date).

.PARAMETER PageSize
The number of records to retrieve per page (optional, default is 1000).

.EXAMPLE
$auditLogs = Get-WS1LoginAuditForUser -AccessToken $token -AccessURL "access.workspaceone.com" -Username "john.doe"
This will retrieve login audit events for the user "john.doe" within the last 30 days.

.EXAMPLE
$auditLogs = Get-WS1LoginAuditForUser -AccessToken $token -AccessURL "access.workspaceone.com" -Username "john.doe" -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date)
This will retrieve login audit events for the user "john.doe" within the last 7 days.
#>
Function Get-WS1LoginAuditForUser {
    param (
        [string]$AccessToken,
        [string]$AccessURL,
        [string]$Username,
        [datetime]$StartDate = (Get-Date).AddDays(-30), # Default to last 30 days
        [datetime]$EndDate = (Get-Date),
        [int]$PageSize = 1000
    )

    $apiEndpoint = "/analytics/reports/audit"
    $username = $Username.Replace("@", "%40")

    # Convert StartDate and EndDate to epoch milliseconds
    $fromMillis = [math]::Round((($StartDate - (Get-Date "1970-01-01"))).TotalMilliseconds)
    $toMillis = [math]::Round((($EndDate - (Get-Date "1970-01-01"))).TotalMilliseconds)
    # Construct the filter query string (no actorUserName filter for this test)
    $filter = "?fromMillis=$fromMillis&toMillis=$toMillis&objectType=LOGIN&pageSize=$PageSize"

    $url = "https://$AccessURL$apiEndpoint$filter"

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type"  = "application/json"
    }

    write-output "Requesting data from: $url"

    try {
        # Make the API request
        $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get

        # Check if the data array is empty
        if ($response.data.Count -eq 0) {
            Write-Warning "No login events found for user $Username between $StartDate and $EndDate"
        }
        else {
            # Loop through and format the response for better clarity
            foreach ($event in $response.data) {
                $timestamp = [datetime]::FromFileTimeUtc($event[0])  # Convert from milliseconds to datetime
                $userDomain = $event[1]
                $eventType = $event[2]
                $details = $event[4] | ConvertFrom-Json  # Convert the event details JSON into a PowerShell object

                write-output "Date and Time: $timestamp"
                write-output "User Domain: $userDomain"
                write-output "Event Type: $eventType"
                write-output "Details: $($details | ConvertTo-Json -Depth 3)"
                write-output "--------------------------------------------"
            }
        }

        return $response
    }
    catch {
        Write-Error "Failed to retrieve login audit logs: $($_.Exception.Message)"
        return $null
    }
}