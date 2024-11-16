@{
    # General Information
    ModuleVersion              = '1.0.0'
    GUID                       = 'a0fa36d3-b309-4ef7-a0d6-9bc60197e56d'  # Generate a unique GUID using PowerShell [guid]::NewGuid()
    Author                     = 'Stefaan Dewulf'
    CompanyName                = 'dewyser.net'
    Description                = 'A PowerShell module for managing Workspace ONE Access users.'
    
    # Module Features
    FunctionsToExport          = @(
        'Open-WS1AccessConnection',
        'Get-WS1MagicToken',
        'Reset-WS1MagicToken',
        'Remove-WS1MagicToken',
        'Add-WS1User',
        'Update-WS1User',
        'Remove-WS1User',
        'Get-WS1User',
        'Get-WS1UserByUsername',
        'Get-WS1Directory',
        'Get-WS1DirectoryById',
        'Sync-WS1Directory',
        'Get-WS1LoginAuditForUser',
        'Get-WS1LoginAuditForDateRange'
    )
    CmdletsToExport            = @()  # Leave blank if only exporting functions
    VariablesToExport          = @()
    AliasesToExport            = @()

    # Compatibility
    PowerShellVersion          = '5.1'  # Specify the minimum version of PowerShell required
    CLRVersion                 = '4.0'
    DotNetFrameworkVersion     = '4.7.2'  # Specify the required .NET version, if applicable
    ProcessorArchitecture      = 'None'  # Could be x86, x64, or Any

    # Help Info
    HelpInfoURI                = 'https://github.com/sdewyser/PSWorkspaceOneAccess#readme'  # Provide a URL to online documentation if available

    # Logging & Tracing
    PrivateData                = @{
        PSData = @{
            Tags         = @('WorkspaceONE', 'PowerShell', 'Automation', 'Access', 'Omnissa')
            ReleaseNotes = @'
                Initial release of the Workspace ONE management module:
                - Authentication and token management
                - User CRUD operations
                - Audit log retrieval
'@
        }
    }
}