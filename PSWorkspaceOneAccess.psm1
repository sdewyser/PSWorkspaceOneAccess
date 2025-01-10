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

<#
.SYNOPSIS
Retrieves the Workspace ONE Magic Token.

.DESCRIPTION
Requests a one-time login link (Magic Token) for a specific user within Workspace ONE.

.PARAMETER AccessToken
The OAuth access token to authenticate API requests.

.PARAMETER AccessURL
The base URL for Workspace ONE Access.

.PARAMETER Domain
The domain name of the user.

.PARAMETER Username
The username for which to retrieve the Magic Token.

.EXAMPLE
$link = Get-WS1MagicToken -AccessToken $token -AccessURL "access.workspaceone.com" -Domain "myDomain" -Username "john.doe"
#>
Function Get-WS1MagicToken {
    param (
        [string]$AccessToken,
        [string]$AccessURL,
        [string]$Domain,
        [string]$Username
    )

    $headers = @{
        "Accept"        = "application/vnd.vmware.horizon.manager.tokenauth.link.response+json"
        "Authorization" = "Bearer $AccessToken"
        "Content-Type"  = "application/vnd.vmware.horizon.manager.tokenauth.generation.request+json"
    }

    $body = @{
        domain   = $Domain
        userName = $Username
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "https://${AccessURL}/SAAS/jersey/manager/api/token/auth/state" -Method POST -Headers $headers -Body $body -ErrorAction Stop
        return $response.loginLink
    }
    catch {
        Write-Error "Failed to get Magic Token for user ${Username} from ${AccessURL}: $($_.Exception.Message)"
        return $null
    }
}

<#
.SYNOPSIS
Resets a Workspace ONE Magic Token for a user.

.DESCRIPTION
Deletes the current Magic Token for a user and generates a new one.

.PARAMETER AccessToken
The OAuth access token to authenticate API requests.

.PARAMETER AccessURL
The base URL for Workspace ONE Access.

.PARAMETER Domain
The domain name of the user.

.PARAMETER Username
The username for whom to reset the Magic Token.

.EXAMPLE
$newLink = Reset-WS1MagicToken -AccessToken $token -AccessURL "access.workspaceone.com" -Domain "myDomain" -Username "john.doe"
#>
Function Reset-WS1MagicToken {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [string]$AccessToken,
        [string]$AccessURL,
        [string]$Domain,
        [string]$Username
    )

    try {
        if ($PSCmdlet.ShouldProcess('Removing user')) {
            Remove-WS1MagicToken -AccessToken $AccessToken -AccessURL $AccessURL -Username $Username
            $loginLink = Get-WS1MagicToken -AccessToken $AccessToken -AccessURL $AccessURL -Domain $Domain -Username $Username
            return $loginLink
        }
    }
    catch {
        Write-Error "Failed to reset Magic Token for user ${Username} at ${AccessURL}: $($_.Exception.Message)"
        return $null
    }
}

<#
.SYNOPSIS
Removes a Workspace ONE Magic Token for a user.

.DESCRIPTION
Deletes the Magic Token associated with a specified user.

.PARAMETER AccessToken
The OAuth access token to authenticate API requests.

.PARAMETER AccessURL
The base URL for Workspace ONE Access.

.PARAMETER Username
The username whose Magic Token is to be removed.

.EXAMPLE
Remove-WS1MagicToken -AccessToken $token -AccessURL "access.workspaceone.com" -Username "john.doe"
#>
Function Remove-WS1MagicToken {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [string]$AccessToken,
        [string]$AccessURL,
        [string]$Username
    )

    $headers = @{
        "Accept"        = "application/vnd.vmware.horizon.manager.tokenauth.link.response+json"
        "Authorization" = "Bearer $AccessToken"
        "Content-Type"  = "application/vnd.vmware.horizon.manager.tokenauth.generation.request+json"
    }

    try {
        $user = Get-WS1UserByUsername -AccessToken $AccessToken -AccessURL $AccessURL -Username $Username
        if (-not $user) {
            throw "User ${Username} not found"
        }
        $userId = $user.id
        if ($PSCmdlet.ShouldProcess('Removing magic token')) {
            Invoke-RestMethod -Uri "https://${AccessURL}/SAAS/jersey/manager/api/token/auth/state/$userId" -Method DELETE -Headers $headers -ErrorAction Stop
            # return "Magic Token for ${Username} removed successfully."
        }
    }
    catch {
        Write-Error "Failed to remove Magic Token for user ${Username} at ${AccessURL}: $($_.Exception.Message)"
        # return $null
    }
}

<#
.SYNOPSIS
Adds a new user to Workspace ONE.

.DESCRIPTION
Creates a new user in Workspace ONE with specified details.

.PARAMETER AccessToken
The OAuth access token to authenticate API requests.

.PARAMETER AccessURL
The base URL for Workspace ONE Access.

.PARAMETER Username
The username for the new user.

.PARAMETER GivenName
The given name of the user.

.PARAMETER FamilyName
The family name of the user.

.PARAMETER Phone
The phone number of the user.

.PARAMETER Email
The email address of the user.

.PARAMETER Organization
The organization name for the user.

.EXAMPLE
Add-WS1User -AccessToken $token -AccessURL "access.workspaceone.com" -Username "new.user" -GivenName "New" -FamilyName "User" -Phone "1234567890" -Email "new.user@example.com" -Organization "Sales"
#>
Function Add-WS1User {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [string]$AccessToken,
        [string]$AccessURL,
        [string]$Username,
        [string]$GivenName,
        [string]$FamilyName,
        [string]$Phone,
        [string]$Email,
        [string]$Organization
    )

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type"  = "application/json"
    }

    $body = @{
        "schemas"                                                                  = @(
            "urn:scim:schemas:extension:workspace:tenant:itq-consultancy-b-v-2714:1.0",
            "urn:scim:schemas:extension:workspace:mfa:1.0",
            "urn:scim:schemas:extension:workspace:1.0",
            "urn:scim:schemas:extension:enterprise:1.0",
            "urn:scim:schemas:core:1.0"
        )
        "name"                                                                     = @{
            "givenName"  = $GivenName
            "familyName" = $FamilyName
        }
        "userName"                                                                 = $Username
        "emails"                                                                   = @(
            @{
                value = $Email
            }
        )
        "phoneNumbers"                                                             = @(
            @{
                value = $Phone
            }
        )
        "urn:scim:schemas:extension:workspace:1.0"                                 = @{
            "domain"            = "ssp"
            "userPrincipalName" = $Username
        }
        "urn:scim:schemas:extension:enterprise:1.0"                                = @{
            "organization" = $Organization
        }
        "urn:scim:schemas:extension:workspace:tenant:itq-consultancy-b-v-2714:1.0" = @{
            "telephoneNumber" = $Phone
        }
    } | ConvertTo-Json -Depth 5

    try {
        if ($PSCmdlet.ShouldProcess('Adding user')) {
            $response = Invoke-RestMethod -Uri "https://${AccessURL}/SAAS/jersey/manager/api/scim/Users" -Method POST -Headers $headers -Body $body -ErrorAction Stop
            return $response
        }
    }
    catch {
        Write-Error "Failed to add user ${Username} to Workspace ONE at ${AccessURL}: $($_.Exception.Message)"
        return $null
    }
}

<#
.SYNOPSIS
Updates an existing user's information in Workspace ONE.

.DESCRIPTION
Modifies the details of a specified user in Workspace ONE, such as name, phone, and email.

.PARAMETER AccessToken
The OAuth access token to authenticate API requests.

.PARAMETER AccessURL
The base URL for Workspace ONE Access.

.PARAMETER UserId
The unique identifier of the user to be updated.

.PARAMETER GivenName
The updated given name of the user.

.PARAMETER FamilyName
The updated family name of the user.

.PARAMETER Username
The updated username of the user.

.PARAMETER Phone
The updated phone number of the user.

.PARAMETER Email
The updated email address of the user.

.EXAMPLE
Update-WS1User -AccessToken $token -AccessURL "access.workspaceone.com" -UserId "12345" -GivenName "Updated" -FamilyName "User" -Username "updated.user" -Phone "9876543210" -Email "updated.user@example.com"
#>
Function Update-WS1User {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [string]$AccessToken,
        [string]$AccessURL,
        [string]$UserId,
        [string]$GivenName,
        [string]$FamilyName,
        [string]$Username,
        [string]$Phone,
        [string]$Email
    )

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type"  = "application/json"
    }

    $body = @{
        "schemas"                                                                  = @(
            "urn:scim:schemas:extension:workspace:tenant:itq-consultancy-b-v-2714:1.0",
            "urn:scim:schemas:extension:workspace:mfa:1.0",
            "urn:scim:schemas:extension:workspace:1.0",
            "urn:scim:schemas:extension:enterprise:1.0",
            "urn:scim:schemas:core:1.0"
        )
        "name"                                                                     = @{
            "givenName"  = $GivenName
            "familyName" = $FamilyName
        }
        "userName"                                                                 = $Username
        "emails"                                                                   = @(
            @{
                value = $Email
            }
        )
        "phoneNumbers"                                                             = @(
            @{
                value = $Phone
            }
        )
        "urn:scim:schemas:extension:workspace:tenant:itq-consultancy-b-v-2714:1.0" = @{
            "telephoneNumber" = $Phone
        }
    } | ConvertTo-Json

    try {
        if ($PSCmdlet.ShouldProcess('Updating user')) {
            $response = Invoke-RestMethod -Uri "https://${AccessURL}/SAAS/jersey/manager/api/scim/Users/$UserId" -Method PATCH -Headers $headers -Body $body -ErrorAction Stop
            return $response
        }
    }
    catch {
        Write-Error "Failed to update user ${UserId} at ${AccessURL}: $($_.Exception.Message)"
        return $null
    }
}

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

<#
.SYNOPSIS
Retrieves information for a specific Workspace ONE user.

.DESCRIPTION
Fetches details of a user based on their username in Workspace ONE.

.PARAMETER AccessToken
The OAuth access token to authenticate API requests.

.PARAMETER AccessURL
The base URL for Workspace ONE Access.

.PARAMETER Username
The username of the user to retrieve.

.EXAMPLE
$userInfo = Get-WS1UserByUsername -AccessToken $token -AccessURL "access.workspaceone.com" -Username "john.doe"
#>
Function Get-WS1UserByUsername {
    param (
        [string]$AccessToken,
        [string]$AccessURL,
        [string]$Username
    )

    $apiEndpoint = "/SAAS/jersey/manager/api/scim/Users"
    $username = $username.Replace("@", "%40")
    $filter = "?filter=userName%20eq%20%22$username%22&sortOrder=descending"

    $url = "https://$AccessURL$apiEndpoint$filter"

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type"  = "application/json"
    }

    try {
        $response = Invoke-RestMethod -Uri $url -Method GET -Headers $headers -ErrorAction Stop
        return $response.Resources | Select-Object -First 1
    }
    catch {
        Write-Error "Failed to retrieve user ${Username} from ${AccessURL}: $($_.Exception.Message)"
        return $null
    }
}

<#
.SYNOPSIS
Retrieves a list of all users in Workspace ONE.

.DESCRIPTION
Fetches information about all users in the Workspace ONE environment.

.PARAMETER AccessToken
The OAuth access token to authenticate API requests.

.PARAMETER AccessURL
The base URL for Workspace ONE Access.

.EXAMPLE
$users = Get-WS1User -AccessToken $token -AccessURL "access.workspaceone.com"
#>
Function Get-WS1User {
    param (
        [string]$AccessToken,
        [string]$AccessURL
    )

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type"  = "application/json"
    }

    try {
        $response = Invoke-RestMethod -Uri "https://${AccessURL}/SAAS/jersey/manager/api/scim/Users?count=9999" -Method GET -Headers $headers -ErrorAction Stop
        return $response.Resources
    }
    catch {
        Write-Error "Failed to get users at ${AccessURL}: $($_.Exception.Message)"
        return $null
    }
}

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