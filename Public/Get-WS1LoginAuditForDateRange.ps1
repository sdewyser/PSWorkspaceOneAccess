<#
.SYNOPSIS
Retrieves login audit events or other object types for a specified date range.

.DESCRIPTION
This function retrieves audit events from the Workspace ONE Access API for a specified date range. It allows filtering by object type (default is LOGIN events) and can return data in pages with a specified page size. The function converts the provided date range into epoch milliseconds and constructs the appropriate API URL to fetch the audit data.

.PARAMETER AccessURL
The base URL for the Workspace ONE Access service.

.PARAMETER AccessToken
The OAuth access token used to authenticate the API requests.

.PARAMETER StartDate
The start date of the audit query range (required). This date is converted to epoch milliseconds for the API query.

.PARAMETER EndDate
The end date of the audit query range (required). This date is converted to epoch milliseconds for the API query.

.PARAMETER ObjectType
The type of object for the audit events (optional, default is "LOGIN"). Other object types may include "LAUNCH", "GROUP", etc.

.PARAMETER PageSize
The number of records to retrieve per page (optional, default is 5000). The API supports up to 5000 records per request.

.EXAMPLE
$auditLogs = Get-WS1LoginAuditForDateRange -AccessURL "access.workspaceone.com" -AccessToken $token -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date)
This will retrieve LOGIN audit events for the last 7 days.

.EXAMPLE
$auditLogs = Get-WS1LoginAuditForDateRange -AccessURL "access.workspaceone.com" -AccessToken $token -StartDate (Get-Date).AddMonths(-1) -EndDate (Get-Date) -ObjectType "LAUNCH"
This will retrieve LAUNCH audit events for the last month.
#>
Function Get-WS1LoginAuditForDateRange {
    param (
        [string]$AccessURL,
        [string]$AccessToken,
        [datetime]$StartDate,
        [datetime]$EndDate,
        [string]$ObjectType = "LOGIN", # Default to LOGIN events, modify as needed
        [int]$PageSize = 5000          # Default page size
    )

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Accept"        = "application/json"  # Adjusted for the new API response type
    }

    # Convert dates to epoch milliseconds (correct format)
    $fromMillis = [math]::Round((($StartDate - (Get-Date "1970-01-01"))).TotalMilliseconds)
    $toMillis = [math]::Round((($EndDate - (Get-Date "1970-01-01"))).TotalMilliseconds)

    # Ensure fromMillis and toMillis are valid (positive numbers)
    if ($fromMillis -lt 0 -or $toMillis -lt 0) {
        Write-Error "Invalid date conversion. Please check the StartDate and EndDate parameters."
        return
    }

    # Construct the URL with additional query parameters
    $url = "https://$AccessURL/analytics/reports/audit?fromMillis=$fromMillis&toMillis=$toMillis&objectType=$ObjectType&pageSize=$PageSize"

    try {
        # Invoke the API call
        $response = Invoke-RestMethod -Method GET -Uri $url -Headers $headers -ErrorAction Stop
        # Display the full response for debugging
        write-output "Audit report retrieved successfully."

        # Loop through the data and format it for better readability
        foreach ($event in $response.data) {
            $timestamp = [datetime]::FromFileTimeUtc($event[0])  # Convert timestamp from milliseconds
            $userDomain = $event[1]
            $eventType = $event[2]
            $details = $event[4] | ConvertFrom-Json  # Convert the JSON string to an object

            write-output "Date and Time: $timestamp"
            write-output "User Domain: $userDomain"
            write-output "Event Type: $eventType"
            write-output "Details: $($details | ConvertTo-Json -Depth 3)"
            write-output "--------------------------------------------"
        }

        # Return the full response if you still want to use it further
        return $response
    }
    catch {
        Write-Error "Failed to retrieve audit report: $_"
    }
}