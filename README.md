
# PSWorkspaceOneAccess

## 📋 Overview
The **PSWorkspaceOneAccess** PowerShell module simplifies interactions with VMware Workspace ONE Access. It offers a set of functions to manage OAuth authentication and token retrieval for various Workspace ONE Access operations. This module is particularly useful for administrators and developers integrating Workspace ONE capabilities into their automation workflows.

## 🛠️ Features
- **Open-WS1AccessConnection**: Establishes an OAuth connection using client credentials and retrieves an access token for Workspace ONE Access.
- **Get-WS1MagicToken**: Generates a one-time login (Magic Token) for user authentication within Workspace ONE Access.
- **Remove-WS1MagicToken**: Deletes the current one-time login (Magic Token) for user authentication within Workspace ONE Access.
- **Reset-WS1MagicToken**: Deletes the current and generates a new one-time login (Magic Token) for user authentication within Workspace ONE Access.
- **Sync-WS1Directory**: Triggers a synchronization for a specified Workspace ONE directory configuration.
- **Get-WS1DirectoryById**: Retrieves detailed information about a specific Workspace ONE directory by its ID.
- **Get-WS1Directoriy**: Lists all directory configurations available in Workspace ONE Access.
- **Get-WS1LoginAuditForDateRange**: Retrieves login audit logs for a specified date range from Workspace ONE Access.
- **Invoke-WS1RestMethod**: Sends a generic REST API request to Workspace ONE Access, providing flexibility for various endpoints and methods.
- **Get-WS1AccessToken**: Retrieves a new OAuth access token using stored credentials or provided parameters.
- **GGet-WS1User**: Retrieves a list of users from Workspace ONE Access.
- **GGet-WS1UserByUsername**: Retrieves a specific user from Workspace ONE Access based on their username.


## 📦 Requirements
- PowerShell 5.1 or later
- Internet access to connect to Workspace ONE Access API
- Client credentials (Client ID and Client Secret) for Workspace ONE API

## 🔧 Installation

1. Clone this repository or download the `PSWorkspaceOneAccess.psm1` file directly.

   ```shell
   git clone https://github.com/yourusername/PSWorkspaceOneAccess.git
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

### 2. (Coming Soon) Get-WS1MagicToken
This function will generate a Magic Token for user authentication in Workspace ONE Access. Stay tuned for updates.

## 📚 Examples

## 🐞 Known Issues

## 💡 Tips
- Store your `ClientId` and `ClientSecret` securely using PowerShell's credential manager or environment variables.
- Use `-Verbose` with functions for additional output during debugging.

## 📝 Changelog

### [1.0.0] - Initial Release

## 🤝 Contributions

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 💬 Contact
For any questions or issues, please open an issue on the GitHub repository, or reach out directly:

- GitHub: [ysdewyser](https://github.com/sdewyser)
