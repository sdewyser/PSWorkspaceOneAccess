Function Add-WS1ADUser {
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
        [hashtable]$AdditionalProperties
    )

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type"  = "application/json"
    }

    $friendlyToSchemaMap = @{
        "TelephoneNumber" = "urn:scim:schemas:extension:workspace:tenant:itq-consultancy-b-v-2714:1.0.telephoneNumber"
        "HireDate"        = "urn:scim:schemas:extension:enterprise:1.0.hireDate"
        "BirthDate"       = "urn:scim:schemas:extension:enterprise:1.0.birthDate"
        "ManagerDN"       = "urn:scim:schemas:extension:workspace:tenant:itq-consultancy-b-v-2714:1.0.managerDN"
        # Add additional friendly properties as needed
    }

    # Map friendly property names to schema-compliant attributes
    $additionalSchemaProperties = @{}
    foreach ($key in $AdditionalProperties.Keys) {
        if ($friendlyToSchemaMap.ContainsKey($key)) {
            $additionalSchemaProperties[$friendlyToSchemaMap[$key]] = $AdditionalProperties[$key]
        } else {
            Write-Warning "Unknown property '$key' in AdditionalProperties. It will be ignored."
        }
    }

    # Build request body
    $body = @{
        "schemas"      = @(
            "urn:scim:schemas:extension:workspace:tenant:itq-consultancy-b-v-2714:1.0",
            "urn:scim:schemas:extension:workspace:mfa:1.0",
            "urn:scim:schemas:extension:workspace:1.0",
            "urn:scim:schemas:extension:enterprise:1.0",
            "urn:scim:schemas:core:1.0"
        )
        "name"         = @{
            "givenName"  = $GivenName
            "familyName" = $FamilyName
        }
        "userName"     = $Username
        "emails"       = @(
            @{
                value = $Email
            }
        )
        "phoneNumbers" = @(
            @{
                value = $Phone
            }
        )
        "urn:scim:schemas:extension:enterprise:1.0" = @{
            "organization" = $Organization
        }
    } + $additionalSchemaProperties | ConvertTo-Json -Depth 10

    try {
        if ($PSCmdlet.ShouldProcess("Adding user $Username")) {
            $response = Invoke-RestMethod -Uri "https://${AccessURL}/SAAS/jersey/manager/api/scim/Users" -Method POST -Headers $headers -Body $body -ErrorAction Stop
            return $response
        }
    }
    catch {
        Write-Error "Failed to add user $Username to Workspace ONE at $($AccessURL): $($_.Exception.Message)"
        return $null
    }
}