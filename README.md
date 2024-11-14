
# PSWorkspaceOneAccess

## 📋 Overview
The **PSWorkspaceOneAccess** PowerShell module simplifies interactions with VMware Workspace ONE Access. It offers a set of functions to manage OAuth authentication and token retrieval for various Workspace ONE Access operations. This module is particularly useful for administrators and developers integrating Workspace ONE capabilities into their automation workflows.

## 🛠️ Features
- **Open-WS1AccessConnection**: Establishes an OAuth connection using client credentials and retrieves an access token.
- **Get-WS1MagicToken**: Generates a one-time login (Magic Token) for user authentication within Workspace ONE.

## 📦 Requirements
- PowerShell 5.1 or later
- Internet access to connect to Workspace ONE Access API
- Client credentials (Client ID and Client Secret) for Workspace ONE API

## 🔧 Installation

1. Clone this repository or download the `PSWorkspaceOneAccess.psm1` file directly.

   ```shell
   git clone https://github.com/sdewyser/PSWorkspaceOneAccess.git
   ```

2. Import the module in your PowerShell session:

   ```powershell
   Import-Module ./PSWorkspaceOneAccess/PSWorkspaceOneAccess.psm1
   ```

3. Optionally, add the module to your PowerShell profile for automatic import:

   ```powershell
   echo 'Import-Module ./PSWorkspaceOneAccess/PSWorkspaceOneAccess.psm1' >> $PROFILE
   ```

## 🚀 Usage

### 1. Open-WS1AccessConnection
The `Open-WS1AccessConnection` function retrieves an OAuth access token using client credentials.

#### Parameters:
- `-ClientId` **(string)**: The client ID for the Workspace ONE Access API.
- `-ClientSecret` **(string)**: The client secret for the Workspace ONE Access API.
- `-AccessURL` **(string)**: The base URL for Workspace ONE Access (e.g., `access.workspaceone.com`).

#### Example:

```powershell
# Retrieve an access token
$token = Open-WS1AccessConnection -ClientId "myClientId" -ClientSecret "mySecret" -AccessURL "access.workspaceone.com"

# Output the token
Write-Output "Access Token: $token"
```

If the connection fails, an error message will be displayed, and the function will return `null`.

## 📚 Examples

#### Example 1: Using the Access Token
Once you have the access token, you can use it to authenticate API requests to Workspace ONE Access:

```powershell
$token = Open-WS1AccessConnection -ClientId "myClientId" -ClientSecret "mySecret" -AccessURL "access.workspaceone.com"

# Use the token in an API call
$headers = @{ "Authorization" = "Bearer $token" }
$response = Invoke-RestMethod -Uri "https://access.workspaceone.com/SAAS/jersey/manager/api/v1/user" -Headers $headers -Method Get

# Display the response
$response
```

## 🐞 Known Issues

## 💡 Tips
- Store your `ClientId` and `ClientSecret` securely using PowerShell's credential manager or environment variables.

## 📝 Changelog

## 🤝 Contributions

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 💬 Contact
For any questions or issues, please open an issue on the GitHub repository, or reach out directly:

- GitHub: [sdewyser](https://github.com/sdewyser)
- Email: stefaan.dewulf@me.com
