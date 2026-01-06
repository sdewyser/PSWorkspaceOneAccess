
# PSWorkspaceOneAccess

## 📋 Overview
The **PSWorkspaceOneAccess** PowerShell module simplifies interactions with VMware Workspace ONE Access. It offers a set of functions to manage OAuth authentication and token retrieval for various Workspace ONE Access operations. This module is particularly useful for administrators and developers integrating Workspace ONE capabilities into their automation workflows.

## 🛠️ Features
- **Add-WS1ADUser**: Adds a new directory user to Workspace ONE Access.
- **Add-WS1User**: Adds a new user to Workspace ONE Access.
- **Get-WS1AuditInformation**: Retrieves a detailed audit report for Workspace ONE Access events and replaces Get-WS1LoginAuditForUser and WS1LoginAuditForDateRange.
- **Get-WS1AuthenticationMethods**: Retrieves the available authentication methods.
- **Get-WS1Directory**: Retrieves information about all directories configured in Workspace ONE Access.
- **Get-WS1DirectoryById**: Retrieves detailed information about a specific directory by its ID.
- **Get-WS1LoginAuditForDateRange**: Retrieves login audit logs for all users within a specified date range.
- **Get-WS1LoginAuditForUser**: Retrieves login audit logs for a specific user within a given time range.
- **Get-WS1MagicToken**: Retrieves a magic token for service-to-service authentication.
- **Get-WS1PolicyList**: Retrieves a list of configured policies.
- **Get-WS1User**: Retrieves a list of users from Workspace ONE Access.
- **Get-WS1UserByUsername**: Retrieves a specific user from Workspace ONE Access by username.
- **Get-WS1UserAuthenticator**: Retrieves authenticator of a user based on their username in Workspace ONE.
- **Get-WS1WebAppAssignments**: Retrieves assignments for a specified web application in Workspace ONE Access.
- **Get-WS1WebApps**: Retrieves a list of web applications available in Workspace ONE Access.
- **Open-WS1AccessConnection**: Establishes an OAuth connection using client credentials and retrieves an access token.
- **Remove-WS1User**: Removes a user from Workspace ONE Access.
- **Remove-WS1MagicToken**: Revokes an existing magic token.
- **Reset-WS1MagicToken**: Resets the magic token, generating a new one for secure authentication.
- **Sync-WS1Directory**: Triggers a synchronization for a specific directory in Workspace ONE Access.
- **Update-WS1ADUser**: Updates directory user details in Workspace ONE Access.
- **Update-WS1User**: Updates user details in Workspace ONE Access.
- **Get-WS1AuditReport**: Retrieves a detailed audit report for Workspace ONE Access events.


## 📦 Requirements
- PowerShell 5.1 or later
- Internet access to connect to Workspace ONE Access API
- Client credentials (Client ID and Client Secret) for Workspace ONE API

## 🔧 Installation
   ```powershell
   Install-Module -Name PSWorkspaceOneAccess -Scope CurrentUser
   ```

## 📚 Examples

Import-Module /Users/stefaandewulf/Github/PSWorkspaceOneAccess/PSWorkspaceOneAccess.psd1 # -Verbose

& "$PSScriptRoot/Private/credentials.ps1"

if ([string]::IsNullOrEmpty($accessToken)) {
    $accessToken = Open-WS1AccessConnection -ClientId $clientId -ClientSecret $clientSecret -AccessURL $accessURL
}

$policies = Get-WS1PolicyList -AccessURL $accessURL -accessToken $accessToken
Write-Host "Policy count: $($policies.Count)" -ForegroundColor DarkYellow

$authMethods = Get-WS1AuthenticationMethods -accessURL $accessURL -accessToken $accessToken
Write-Host "Enabled authentication method count: $($authMethods | Where-Object enabled -eq $true | Measure-Object | Select-Object -ExpandProperty Count)" -ForegroundColor Red

$users = Get-WS1User -AccessURL $accessURL -AccessToken $accessToken
Write-Host ( $users | Where-Object userName -eq "rsmoot" | Select-Object -ExpandProperty name ) -ForegroundColor Green

$not_me = Get-WS1UserByUsername -AccessURL $accessURL -AccessToken $accessToken -Username "rsmoot"
$not_me | Select-Object -ExpandProperty name | Select-Object @{Name = "Firstname"; Expression = { $_.givenName } }, @{Name = "Lastname"; Expression = { $_.familyName } } | Format-Table

$directory = Get-WS1Directory -AccessURL $accessURL -accessToken $accessToken
$directory = $directory | Where-Object type -eq "ACTIVE_DIRECTORY_LDAP"
Write-Host "DirectoryId: $($directory.directoryId)" -ForegroundColor Blue

$directoryInfo = Get-WS1DirectoryById -AccessURL $accessURL -AccessToken $accessToken -DirectoryId $directory.directoryId
Write-Host "DirectoryId: $($directoryInfo.directoryId)" -ForegroundColor Cyan

Remove-WS1MagicToken -AccessURL $accessURL -AccessToken $accessToken -Username $not_me.userName
$magicToken = Get-WS1MagicToken -AccessURL $accessURL -AccessToken $accessToken -Domain $domain -Username $not_me.userName

$magicToken = Reset-WS1MagicToken -AccessURL $accessURL -AccessToken $accessToken -Domain $domain -Username $not_me.userName

Write-Host "$($magicToken.replace($accessURL,"<accessURL>"))" -ForegroundColor Red

Remove-Module PSWorkspaceOneAccess # -Verbose

## 🚀 Output

Policy count: 5                                                                                                         
Enabled authentication method count: 16
@{givenName=Rudiger; familyName=Smoot}

Firstname Lastname
--------- --------
Rudiger   Smoot

DirectoryId: f37e07c3-3d2d-4e82-85b1-5bad6ee60d5d                                                                       
DirectoryId: f37e07c3-3d2d-4e82-85b1-5bad6ee60d5d                                                                       

 https://<accessURL>/SAAS/auth/login?token=eyJpZCI6IjJlY2U3ZTc2LTk1YTgtNDBkOS1iMDdjLTAxOGQzMDljNWIzYyIsInZhbHVlIjoicXlTUEcyd3kzZHRnZXVWbjhMemtZR3Z3eHg4VWhjYUkiLCJzaWduYXR1cmUiOiJhbW1KaGl4eWtrZUlVTEMvRUxQaHRMRUpteFpraGZIa1d1RmlkeWRpUm9QRkZ3Kzk3OU5VanRwL0FkdmNMOFJUM0d6akUzRlFObU5rRUlONWhhSWtVTTFqMjIrckMwYmIxRjBRSThReUF3Y1J6ZklvTGY0OGdVSXhFdmY5Y3dLK1RPNy9oWWlEMFpYN2YyR1hQSnJYaUZTL3FEZWdKOFN4UHpPMXlYV05heTE4eEpEWE92SjZqcUdad2JWU3RQZlIreUNwUW52RDJsWGZ1dCtTbElBQXVBaU1kSkdkRVJUMC9ESjZCQm5iZmZINnF6R0tSSmZFamVMQzF5NU5aazRTem8yMHJHQjFUM1p4NXdEanQ0UVR3UkFUMWRTbTUvcVJnWTBnQ3g4NTZ4Vkkwek8yeUN1ZUxLb0FkcW5ycWZSNDlhQVQ0ODYydkI4dHlPOUp5enR5b28rYmFuQzlJeXNBckl1dmgzZFVsYmlLaTNnb29EN2tHd0MwbDh2d21CZEI0R1RFVjJhMEVlTGw4MmVFK25rTFpZV2NMSGtTRUJLMXVmNGhmZ24zWUVPMTVVazN6enFQYVJnVy9qY1I2ejFxSFVLbm1XeVRiZUpKeG40NFhtdHhxYTUvL0I2MVpjWVdsY2UxUCtwLzM2ekRXSDk2K3J5SDRrUStaU2hHM1IveDlST3V4T3hQeHJHTUxnZC9SdE1WeTR3VGVicU5pLzdNeEpQalNCdUdCWll2UTN2RjNmb1BxZkFxaVV3VjlUa0p2UjduTkc5aU90TElsZWRVakQxN0s4TXRUVk0rQjVqWEF4eUtxRVNNamJFNEk1Ry9zTmpUdElOMVo3OVBKYVBJbWYrMGNib1pqMWx2WHpFZGhoZ1pKTE16MUJPMWFlOEVKSlVvaGlYOEdIVT0ifQ%253D%253D&userstore=Userstore_f37e07c3-3d2d-4e82-85b1-5bad6ee60d5d

## 🐞 Known Issues

## 💡 Tips
- Store your `ClientId` and `ClientSecret` securely using PowerShell's credential manager or environment variables.

## 📝 Changelog

### [2.0.0] - New file and folder structure. New functions Get-WS1Policies and Get-WS1AuthenticationMethods
### [1.2.0] - Added new commands Get-WS1WebApps and Get-WS1WebAppAssignments
### [1.1.0] - Updated Add-WS1User and Update-WS1User with additional properties so a Active Directory user can added and/or updated (test)
### [1.0.1] - Added new command Get-WS1AuditInformation 
### [1.0.0] - Initial Release

## 🤝 Contributions

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 💬 Contact
For any questions or issues, please open an issue on the GitHub repository:

- GitHub: [sdewyser](https://github.com/sdewyser)
