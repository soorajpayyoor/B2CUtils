<# 
B2C Functions

Written by Phil Whipps
UNIFY Solutions

#>
function Get-TenantAccessToken
{
param(
    $TenantId,
	[bool]$ForeAuthn
    )


	$adal = "$PSScriptRoot\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
	if (!(Test-Path $adal)) { Throw "Could not find $adal. Please make sure you run this obtain the full ExploreAdmin folder and run the script from there."; return;}
	[System.Reflection.Assembly]::LoadFile($adal) > $null

	$adalWin = "$PSScriptRoot\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll";
	if (!(Test-Path $adal)) { Throw "Could not find $adal. Please make sure you run this obtain the full ExploreAdmin folder and run the script from there."; return;}
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
  Sets a default tenant for B2CUtils.

 .Description
  Because I am lazy and do not want to enter the TenantId each Time, this allows me to set the default tenant to be used..

 .Parameter TenantId
  The name of the B2C Tenant.
  

 .Example
   # Set the default Tenant.
   Set-B2CDefaultTenant -TenantId "myb2ctenant.onmicrosoft.com"

 .LINK
	https://github.com/WhippsP/B2CUtils
   
#>

function Set-B2CDefaultTenant {
param(
   [Parameter(Mandatory=$true)]
    [AllowEmptyString()]
    [string]$TenantId
    )
	#Export Default Values for Functions )
	$global:PSDefaultParameterValues = @{"*-B2C*:TenantId"=$TenantId}
	
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

$accessToken = Get-TenantAccessToken -TenantId $TenantId -ForeAuthn $ForeAuthn


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

$accessToken = Get-TenantAccessToken -TenantId $TenantId -ForeAuthn $ForeAuthn

$PolicyList = Invoke-WebRequest "https://main.b2cadmin.ext.azure.com/api/policyList?tenantId=$TenantId" -Method Get -Headers @{Authorization="Bearer $accessToken"}


([xml]$PolicyList.content).ArrayOfPolicy.Policy.POlicyID


}

<# 
 .Synopsis
  Gets a B2C Policy.

 .Description
  Retrives a Trust Framework Policy from B2C.

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

	$accessToken = Get-TenantAccessToken -TenantId $TenantId -ForeAuthn $ForeAuthn

$pol = Invoke-WebRequest "https://main.b2cadmin.ext.azure.com/api/TrustFramework/GetAsXml?api-version=1&TenantId=$TenantId&PolicyId=$PolicyId&SendAsAttachment=false&GetBasePolicies=$GetBasePolicies" -Method Get -Headers @{Authorization="Bearer $accessToken"}
([xml]$pol.content)
}


<# 
 .Synopsis
  Upload a policy to B2C.

 .Description
  This function uploads a B2C Policy.

 .Parameter TenantId
  The name of the B2C Tenant.
  
  .Parameter Policy
  Specify the Policy XML Content.
  
  .Parameter OverwriePolicy
  Overwrites the Policy - Default is $True.

 .Parameter ForeAuthn
  Forces you to re-authenticate.
  

 .Example
   # Upload a Policies.
   $policy = Get-Content -raw "C:\Temp\B2CPolicy.xml"
   Set-B2CPolicy -TenantId "myb2ctenant.onmicrosoft.com" -Policy $policy

 .Example
   # Upload a Policies with .
   $policy = Get-Content -raw "C:\Temp\B2CPolicy.xml" 
   Set-B2CPolicy -TenantId "myb2ctenant.onmicrosoft.com" -Policy $policy -OverwriePolicy $False
   
 .LINK
	https://github.com/WhippsP/B2CUtils
   
#>
function Set-B2CPolicy {
param(
	[Parameter(Mandatory=$true)]
    [string]$TenantId,
	[Parameter(Mandatory=$true)]
	[string]$Policy,
	[bool]$OverwriePolicy=$true,
	[switch]$ForeAuthn
    )
	Add-Type -AssemblyName System.Web
	$accessToken = Get-TenantAccessToken -TenantId $TenantId -ForeAuthn $ForeAuthn
	
	# Policy Must be HTML Encoded within a String Element
	
    $PostStr = '<string xmlns="http://schemas.microsoft.com/2003/10/Serialization/">' + [System.Web.HttpUtility]::HtmlEncode($Policy) + '</string>'
	
	
	try{
		$webAppResponse = Invoke-WebRequest "https://main.b2cadmin.ext.azure.com/api/trustframework?tenantId=$TenantId&OverwriteIfExists=$OverwriePolicy" -Method Post -Headers @{Authorization="Bearer $accessToken"} -ContentType "application/xml" -Body $PostStr
	}
	catch {
			#Report Returned Error to The User
			$result = $_.Exception.Response.GetResponseStream()
			$reader = New-Object System.IO.StreamReader($result)
			$reader.BaseStream.Position = 0
			$reader.DiscardBufferedData()
			$responseBody = $reader.ReadToEnd();
			Write-Error ([xml]$responseBody).Error.ExceptionMessage
	}

}

<# 
 .Synopsis
  Deletes a B2C Policy.

 .Description
  Removes a Trust Framework Policy from B2C.

 .Parameter TenantId
  The name of the B2C Tenant.
  
  .Parameter PolicyId
  Specify the name of the Policy to remove.
  
  .Parameter ForeAuthn
  Forces you to re-authenticate.
  

 .Example
   # Remove a Policy.
   Remove-B2CPolicy -TenantId "myb2ctenant.onmicrosoft.com" -PolicyId B2C_1A_Policy1

 .LINK
	https://github.com/WhippsP/B2CUtils
   
#>
function Remove-B2CPolicy {
param(
	[Parameter(Mandatory=$true)]
    [string]$TenantId,
	[Parameter(Mandatory=$true)]
	[string]$PolicyId,
	[switch]$ForeAuthn
    )

	$accessToken = Get-TenantAccessToken -TenantId $TenantId -ForeAuthn $ForeAuthn
	try{
		$pol = Invoke-WebRequest "https://main.b2cadmin.ext.azure.com/api/TrustFramework/?api-version=1&TenantId=$TenantId&PolicyId=$PolicyId" -Method Delete -Headers @{Authorization="Bearer $accessToken"}
	} 
	catch {
			#Report Returned Error to The User
			$result = $_.Exception.Response.GetResponseStream()
			$reader = New-Object System.IO.StreamReader($result)
			$reader.BaseStream.Position = 0
			$reader.DiscardBufferedData()
			$responseBody = $reader.ReadToEnd();
			Write-Error ([xml]$responseBody).Error.ExceptionMessage
	}

	
}


function Get-B2CCertificate {

}

function Remove-B2CCertificate {

}

function New-B2CCertificate {

}

function Remove-B2CKeyContainer {

}

function New-B2CKeyContainer {

}

function Set-B2CKeyContainer {

}

function Get-B2CKeyContainer {

}



export-modulemember -Function *-B2C*

