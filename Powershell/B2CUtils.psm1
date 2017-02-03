<# 
B2C Functions

Written by Phil Whipps
UNIFY Solutions

#>
function Get-B2CAccessToken
{
param(
    $TenantId,
	[bool]$ForeAuthn
    )


	$adal = "$PSScriptRoot\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
	if (!(Test-Path $adal)) { "Could not find $adal. Please make sure you run this obtain the full ExploreAdmin folder and run the script from there."; return;}
	[System.Reflection.Assembly]::LoadFile($adal) > $null

	$adalWin = "$PSScriptRoot\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll";
	if (!(Test-Path $adal)) { "Could not find $adal. Please make sure you run this obtain the full ExploreAdmin folder and run the script from there."; return;}
	[System.Reflection.Assembly]::LoadFile($adalWin) > $null


	$authority = "https://login.microsoftonline.com/$TenantId";

	$resource = "https://cpimadmin.onmicrosoft.com"
	$clientId = "974c6c0f-4a8f-415d-a767-da2ddb587fc9"

	$redirectUri = "https://cpim"
		if($ForeAuthn)
		{
			$promptBehavoir = [Microsoft.IdentityModel.Clients.ActiveDirectory.PromptBehavior]::Always;
		}
		else
		{
			$promptBehavoir = [Microsoft.IdentityModel.Clients.ActiveDirectory.PromptBehavior]::Auto;
		}
	$useridentifier = [Microsoft.IdentityModel.Clients.ActiveDirectory.UserIdentifier]::AnyUser;


	$context = New-Object Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext($authority);

	$token = $context.AcquireToken($resource, $clientId, $redirectUri, $promptBehavoir,$useridentifier,"amr_values=mfa" );

	$token.AccessToken;

}


<# 
 .Synopsis
  Displays a list of B2C Certificates.

 .Description
  Displays a list of B2C Certificates used within Trust Framework Policies.

 .Parameter TenantId
  The name of the B2C Tenant.

 .Parameter ForeAuthn
  Forces you to re-authenticate.
  

 .Example
   # Get a list of Policies.
   Get-B2CCertList -TenantId "myb2ctenant.onmicrosoft.com"

 .Example
    #  Get a list of Policies, after you re-authenticate..
   Get-B2CCertList -TenantId "myb2ctenant.onmicrosoft.com" -ForeAuthn

 .LINK
	https://github.com/WhippsP/B2CUtils
   
#>
function Get-B2CCertList {
param(
   [Parameter(Mandatory=$true)]
    [string]$TenantId,
	[switch]$ForeAuthn
    )

$accessToken = Get-B2CAccessToken -TenantId $TenantId -ForeAuthn $ForeAuthn


$KeyList = Invoke-WebRequest "https://main.b2cadmin.ext.azure.com/api/keylist?api-version=1&TenantId=$TenantId&KeyType=cert" -Method Get -Headers @{Authorization="Bearer $accessToken"}


([xml]$KeyList.content).ArrayOfstring.string

}


<# 
 .Synopsis
  Displays a list of B2C Trust Framework Policies.

 .Description
  Displays a list of B2C Trust Framework Policy names based on the supplied Tenant name.

 .Parameter TenantId
  The name of the B2C Tenant.

 .Parameter ForeAuthn
  Forces you to re-authenticate.
  

 .Example
   # Get a list of Policies.
   Get-B2CPolicyList -TenantId "myb2ctenant.onmicrosoft.com"

 .Example
    #  Get a list of Policies, after you re-authenticate..
   Get-B2CPolicyList -TenantId "myb2ctenant.onmicrosoft.com" -ForeAuthn

 .LINK
	https://github.com/WhippsP/B2CUtils
   
#>
function Get-B2CPolicyList {
param(
   [Parameter(Mandatory=$true)]
    [string]$TenantId,
	[switch]$ForeAuthn
    )

$accessToken = Get-B2CAccessToken -TenantId $TenantId -ForeAuthn $ForeAuthn

$PolicyList = Invoke-WebRequest "https://main.b2cadmin.ext.azure.com/api/policyList?tenantId=$TenantId" -Method Get -Headers @{Authorization="Bearer $accessToken"}


([xml]$PolicyList.content).ArrayOfPolicy.Policy.POlicyID


}

<# 
 .Synopsis
  Gets a B2C Policy.

 .Description
  REtrives a Trust Framework Policy from B2C.

 .Parameter TenantId
  The name of the B2C Tenant.
  
  .Parameter PolicyId
  Specify the name of the Policy to return.
  
  .Parameter GetBasePolicies
  Retrive all associated Polciies within the Policy Chain.

 .Parameter ForeAuthn
  Forces you to re-authenticate.
  

 .Example
   # Get a list of Policies.
   Get-B2CPolicy -TenantId "myb2ctenant.onmicrosoft.com" -PolicyId B2C_1A_Policy1

 .Example
    #  Get a list of Policies, after you re-authenticate..
   Get-B2CPolicy -TenantId "myb2ctenant.onmicrosoft.com" -PolicyId B2C_1A_Policy1 -GetBasePolicies
   
   .Example
    #  Get a list of Policies, after you re-authenticate..
   Get-B2CPolicy -TenantId "myb2ctenant.onmicrosoft.com" -ForeAuthn -PolicyId B2C_1A_Policy1

 .LINK
	https://github.com/WhippsP/B2CUtils
   
#>
function Get-B2CPolicy {
param(
	[Parameter(Mandatory=$true)]
    [string]$TenantId,
	[Parameter(Mandatory=$true)]
	[string]$PolicyId,
	[switch]$GetBasePolicies,
	[switch]$ForeAuthn
    )

	$accessToken = Get-B2CAccessToken -TenantId $TenantId -ForeAuthn $ForeAuthn
	
$pol = Invoke-WebRequest "https://cpim.windows.net/api/TrustFramework/GetAsXml?api-version=1&TenantId=$TenantId&PolicyId=$PolicyId&SendAsAttachment=false&GetBasePolicies=$GetBasePolicies" -Method Get -Headers @{Authorization="Bearer $accessToken"}
([xml]$pol.content)
}

export-modulemember -Function Get-B2CCertList, Get-B2CPolicyList, Get-B2CPolicy
