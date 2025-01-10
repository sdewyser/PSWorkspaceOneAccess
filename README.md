
# PSWorkspaceOneAccess

## 📋 Overview
The **PSWorkspaceOneAccess** PowerShell module simplifies interactions with VMware Workspace ONE Access. It offers a set of functions to manage OAuth authentication and token retrieval for various Workspace ONE Access operations. This module is particularly useful for administrators and developers integrating Workspace ONE capabilities into their automation workflows.

## 🛠️ Features
- **Open-WS1AccessConnection**: Establishes an OAuth connection using client credentials and retrieves an access token.
- **Get-WS1MagicToken**: Retrieves a magic token for service-to-service authentication.
- **Reset-WS1MagicToken**: Resets the magic token, generating a new one for secure authentication.
- **Remove-WS1MagicToken**: Revokes an existing magic token.
- **Add-WS1User**: Adds a new user to Workspace ONE Access.
- **Update-WS1User**: Updates user details in Workspace ONE Access.
- **Remove-WS1User**: Removes a user from Workspace ONE Access.
- **Get-WS1User**: Retrieves a list of users from Workspace ONE Access.
- **Get-WS1UserByUsername**: Retrieves a specific user from Workspace ONE Access by username.
- **Get-WS1Directory**: Retrieves information about all directories configured in Workspace ONE Access.
- **Get-WS1DirectoryById**: Retrieves detailed information about a specific directory by its ID.
- **Sync-WS1Directory**: Triggers a synchronization for a specific directory in Workspace ONE Access.
- **Get-WS1LoginAuditForUser**: Retrieves login audit logs for a specific user within a given time range.
- **Get-WS1LoginAuditForDateRange**: Retrieves login audit logs for all users within a specified date range.
- **Get-WS1AuditReport**: Retrieves a detailed audit report for Workspace ONE Access events.
- **Get-WS1AuditInformation**: Retrieves a detailed audit report for Workspace ONE Access events and replaces Get-WS1LoginAuditForUser, WS1LoginAuditForDateRange and Get-WS1AuditReport.


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

## 📚 Examples

## 🐞 Known Issues

## 💡 Tips
- Store your `ClientId` and `ClientSecret` securely using PowerShell's credential manager or environment variables.

## 📝 Changelog

### [1.0.1] - Added new command Get-WS1AuditInformation 
### [1.0.0] - Initial Release

## 🤝 Contributions

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 💬 Contact
For any questions or issues, please open an issue on the GitHub repository:

- GitHub: [sdewyser](https://github.com/sdewyser)
