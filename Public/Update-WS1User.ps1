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
            #"urn:scim:schemas:extension:workspace:tenant:itq-consultancy-b-v-2714:1.0",
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
        <#"urn:scim:schemas:extension:workspace:tenant:itq-consultancy-b-v-2714:1.0" = @{
            "telephoneNumber" = $Phone
        }#>
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