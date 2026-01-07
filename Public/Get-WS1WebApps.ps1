<#
.SYNOPSIS
Retrieves a list of web applications available in Workspace ONE Access.

.DESCRIPTION
Fetches web applications from the Workspace ONE Access catalog, including attributes such as labels, UI capabilities, and authentication information.

.PARAMETER AccessToken
The OAuth access token to authenticate API requests.

.PARAMETER AccessURL
The base URL for Workspace ONE Access.

.EXAMPLE
Get-WS1WebApps -AccessToken $token -AccessURL "access.workspaceone.com"
#>
function get-ws1webapps {
    param (
        [string]$accesstoken,
        [string]$accessurl,
        [int]$pagesize = 100
    )

    $headers = @{
        authorization  = "Bearer $accesstoken"
        accept         = "application/vnd.vmware.horizon.manager.catalog.item.list+json"
        "content-type" = "application/vnd.vmware.horizon.manager.catalog.search+json"
    }

    $body = @{
        includeAttributes = @("labels", "uiCapabilities", "authInfo")
        includeTypes      = @("Saml11", "Saml20", "WSFed12", "WebAppLink", "AnyApp")
        nameFilter        = ""
        categories        = @()
        rootResource      = $false
    } | ConvertTo-Json -Depth 10

    $items = @()
    $startindex = 0

    do {
        $url = "https://$accessurl/SAAS/jersey/manager/api/catalogitems/search?startIndex=$startindex&pageSize=$pagesize"
        $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body

        if ($response.items) {
            $items += $response.items
            $startindex += $response.items.count
        }
    } while ($response.items.count -eq $pagesize)

    $base = "https://$accessurl"

    $items | ForEach-Object {
        $launchhref = $_._links.'hw-launch'.href
        $selfhref = $_._links.self.href

        $auth = $_.authInfo

        # helpful “signed with” certificate (authinfo.signingCert is often empty; include all likely spots)
        $signingcert =
        $auth.signingCert ??
        $auth.signingCertificate ??
        $auth.cert ??
        $null

        [pscustomobject]@{
            # identity / basics
            uuid                    = $_.uuid
            packageversion          = $_.packageVersion
            name                    = $_.name
            productversion          = $_.productVersion
            description             = $_.description
            catalogitemtype         = $_.catalogItemType

            # visibility / flags
            visible                 = $_.visible
            internal                = $_.internal
            isprovisioningenabled   = $_.isProvisioningEnabled
            provisioningadapter     = $_.provisioningAdapter
            provisioningadapterid   = $_.provisioningAdapterId
            resourcesyncprofileid   = $_.resourceSyncProfileId

            # policy
            accesspolicysetuuid     = $_.accessPolicySetUuid
            accesspolicyname        = $_.accessPolicyName

            # icon
            cdniconurl              = $_.cdnIconUrl

            # useful links
            selfurl                 = if ($selfhref) { "$base$selfhref" }   else { $null }
            launchurl               = if ($launchhref) { "$base$launchhref" } else { $null }

            # auth / saml essentials (flattened)
            auth_type               = $auth.type
            auth_audience           = $auth.audience
            auth_recipientname      = $auth.recipientName
            auth_acsurl             = $auth.assertionConsumerServiceUrl
            auth_nameidformat       = $auth.nameIdFormat
            auth_nameid             = $auth.nameId
            auth_signaturealgorithm = $auth.signatureAlgorithm
            auth_digestalgorithm    = $auth.digestAlgorithm
            auth_signresponse       = $auth.signResponse
            auth_signassertion      = $auth.signAssertion
            auth_encryptassertion   = $auth.encryptAssertion
            auth_includedestination = $auth.includeDestination
            auth_validityseconds    = $auth.validityTimeSeconds
            auth_configureas        = $auth.configureAs
            auth_relaystate         = $auth.relayState
            auth_loginredirecturl   = $auth.loginRedirectionUrl
            auth_signingcert        = $signingcert

            # auth / saml advanced
            auth_attributes         = $auth.attributes
            auth_parameters         = $auth.parameters
            auth_claimtransforms    = $auth.claimTransformations
            auth_nameidtransform    = $auth.nameIdClaimTransformation

            # keep originals that are useful but bulky (optional, remove if you want)
            labels                  = $_.labels
            uicapabilities          = $_.uiCapabilities

            # sometimes useful for deep troubleshooting
            links                   = $_._links
        }
    }
}