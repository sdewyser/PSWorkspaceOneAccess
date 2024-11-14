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
    param (
        [string]$AccessToken,
        [string]$AccessURL,
        [string]$Domain,
        [string]$Username
    )

    try {
        Remove-WS1MagicToken -AccessToken $AccessToken -AccessURL $AccessURL -Username $Username
        $loginLink = Get-WS1MagicToken -AccessToken $AccessToken -AccessURL $AccessURL -Domain $Domain -Username $Username
        return $loginLink
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
        $user = Get-WS1User -AccessToken $AccessToken -AccessURL $AccessURL -Username $Username
        if (-not $user) {
            throw "User ${Username} not found"
        }
        $userId = $user.id
        Invoke-RestMethod -Uri "https://${AccessURL}/SAAS/jersey/manager/api/token/auth/state/$userId" -Method DELETE -Headers $headers -ErrorAction Stop
        return "Magic Token for ${Username} removed successfully."
    }
    catch {
        Write-Error "Failed to remove Magic Token for user ${Username} at ${AccessURL}: $($_.Exception.Message)"
        return $null
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
        $response = Invoke-RestMethod -Uri "https://${AccessURL}/SAAS/jersey/manager/api/scim/Users" -Method POST -Headers $headers -Body $body -ErrorAction Stop
        return $response
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
        $response = Invoke-RestMethod -Uri "https://${AccessURL}/SAAS/jersey/manager/api/scim/Users/$UserId" -Method PATCH -Headers $headers -Body $body -ErrorAction Stop
        return $response
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
        Invoke-RestMethod -Uri "https://${AccessURL}/SAAS/jersey/manager/api/scim/Users/$UserId" -Method DELETE -Headers $headers -ErrorAction Stop
        return "User ${UserId} removed successfully."
    }
    catch {
        Write-Error "Failed to remove user ${UserId} at ${AccessURL}: $($_.Exception.Message)"
        return $null
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
$userInfo = Get-WS1User -AccessToken $token -AccessURL "access.workspaceone.com" -Username "john.doe"
#>
Function Get-WS1User {
    param (
        [string]$AccessToken,
        [string]$AccessURL,
        [string]$Username
    )

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type"  = "application/json"
    }

    try {
        $response = Invoke-RestMethod -Uri "https://${AccessURL}/SAAS/jersey/manager/api/scim/Users?filter=userName eq '${Username}'" -Method GET -Headers $headers -ErrorAction Stop
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
$users = Get-WS1Users -AccessToken $token -AccessURL "access.workspaceone.com"
#>
Function Get-WS1Users {
    param (
        [string]$AccessToken,
        [string]$AccessURL
    )

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type"  = "application/json"
    }

    try {
        $response = Invoke-RestMethod -Uri "https://${AccessURL}/SAAS/jersey/manager/api/scim/Users" -Method GET -Headers $headers -ErrorAction Stop
        return $response.Resources
    }
    catch {
        Write-Error "Failed to get users at ${AccessURL}: $($_.Exception.Message)"
        return $null
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

.EXAMPLE
$auditLogs = Get-WS1LoginAuditForUser -AccessToken $token -AccessURL "access.workspaceone.com" -Username "john.doe"
#>
Function Get-WS1LoginAuditForUser {
    param (
        [string]$AccessToken,
        [string]$AccessURL,
        [string]$Username
    )

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type"  = "application/json"
    }

    $url = "https://$AccessURL/SAAS/jersey/manager/api/auditlogs?filter=userName+eq+'$Username'+and+eventType+eq+login"

    try {
        $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
        return $response.items
    }
    catch {
        Write-Error "Failed to retrieve audit logs at ${AccessURL}: $($_.Exception.Message)"
        return $null
    }
}

<#
.SYNOPSIS
Retrieves login audit events for a specified date range.

.DESCRIPTION
Fetches login audit logs for all users within a specified time frame.

.PARAMETER AccessToken
The OAuth access token to authenticate API requests.

.PARAMETER AccessURL
The base URL for Workspace ONE Access.

.PARAMETER StartDate
The start date for the audit log query.

.PARAMETER EndDate
The end date for the audit log query.

.EXAMPLE
$auditLogs = Get-WS1LoginAuditForDateRange -AccessToken $token -AccessURL "access.workspaceone.com" -StartDate "2024-01-01" -EndDate "2024-01-31"
#>
Function Get-WS1LoginAuditForDateRange {
    param (
        [string]$AccessToken,
        [string]$AccessURL,
        [datetime]$StartDate,
        [datetime]$EndDate
    )

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type"  = "application/json"
    }

    $url = "https://$AccessURL/SAAS/jersey/manager/api/auditlogs?filter=eventType+eq+login+and+timestamp+ge+$($StartDate.ToString('yyyy-MM-dd'))+and+timestamp+le+$($EndDate.ToString('yyyy-MM-dd'))"

    try {
        $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
        return $response.items
    }
    catch {
        Write-Error "Failed to retrieve audit logs at ${AccessURL}: $($_.Exception.Message)"
        return $null
    }
}