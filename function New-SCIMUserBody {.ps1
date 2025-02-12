function New-SCIMUserBody {
    param (
        [string]$userName,
        [string]$displayName,
        [string]$firstname,
        [string]$lastname,
        [string]$email,
        [string]$phoneNumber,
        [string]$userPrincipalName,
        [string]$userDomain
    )

    $body = @{
        phoneNumbers = @(@{
            operation = "add"
            type = "work"
            primary = $true
            value = $PhoneNumber
            display = $PhoneNumber
        })
        emails = @(@{
            operation = "add"
            type = "work"
            primary = $true
            value = $Email
            display = $Email
        })
        userName = $UserName
        displayName = $DisplayName
        active = $true
        name = @{
            givenName = $FirstName
            familyName = $LastName
            formatted = "$FirstName $LastName"
        }
        "urn:scim:schemas:extension:workspace:1.0" = @{
            #distinguishedName = $DistinguishedName
            domain = $userDomain
            #internalUserType = "PROVISIONED"
            #softDeleted = $false
            userPrincipalName = $UserPrincipalName
            userStatus = "1"
            #userStoreUuid = "19175b6d-a656-451a-9d25-b62e12d90a24"
            #firstLoginUrl = "https://your-login-url"
        }
    }

    # Convert the hashtable to JSON with proper depth
    return $body | ConvertTo-Json -Depth 10
}

Function Add-WS1TestUser {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [string]$AccessToken,
        [string]$AccessURL,
        [string]$body
    )

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type"  = "application/json"
    }

    try {
        if ($PSCmdlet.ShouldProcess('Adding user')) {
            $response = Invoke-RestMethod -Uri "https://${AccessURL}/SAAS/jersey/manager/api/scim/Users" -Method POST -Headers $headers -Body $body -ErrorAction Stop
            return $response
        }
    }
    catch {
        Write-Error "Failed to add user to Workspace ONE at ${AccessURL}: $($_.Exception.Message)"
        return $null
    }
}

function Get-WS1WebApps {
    param (
        [string]$AccessToken,
        [string]$AccessURL
    )

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Accept"        = "application/json"
        "Content-Type"  = "application/json"
    }

    $json = @{
        includeAttributes = @("labels", "uiCapabilities", "authInfo")
        includeTypes      = @("Saml11", "Saml20", "WSFed12", "WebAppLink", "AnyApp")
        nameFilter        = ""
        categories        = @()
        rootResource      = $false
    } | ConvertTo-Json -Depth 2

    $url = "https://$AccessURL/SAAS/jersey/manager/api/catalogitems/search?startIndex=0&pageSize=50"

    $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers # -Body $json

    return $response.items
}

function Get-WS1WebAppAssignments {
    param (
        [string]$AccessToken,
        [string]$AccessURL,
        [string]$AppID
    )

    $headers = @{
        Authorization = "Bearer $AccessToken"
        Accept        = "application/json"
    }

    $url = "$AccessURL/SAAS/jersey/manager/api/scim/Apps/$AppID/Assignments"
    $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers

    return $response.resources
}