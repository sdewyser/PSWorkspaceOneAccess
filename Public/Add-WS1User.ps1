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
        [string]$Organization,
        [string]$Domain
    )

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type"  = "application/json"
    }

    $body = @{
        "schemas"                                                                  = @(
            # "urn:scim:schemas:extension:workspace:tenant:itq-consultancy-b-v-2714:1.0",
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
            "domain"            = $Domain
            "userPrincipalName" = $Username
        }
        "urn:scim:schemas:extension:enterprise:1.0"                                = @{
            "organization" = $Organization
        }
        <#"urn:scim:schemas:extension:workspace:tenant:itq-consultancy-b-v-2714:1.0" = @{
            "telephoneNumber" = $Phone
        }#>
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