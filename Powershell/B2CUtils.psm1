<# 
B2C Functions

Written by Phil Whipps
UNIFY Solutions


For more info see: https://github.com/WhippsP/B2CUtils
#>

#region Module Functions
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

function GetB2CError()
{
			$result = $_.Exception.Response.GetResponseStream()
			$reader = New-Object System.IO.StreamReader($result)
			$reader.BaseStream.Position = 0
			$reader.DiscardBufferedData()
			$responseBody = $reader.ReadToEnd();
			Write-Error ([xml]$responseBody).Error.ExceptionMessage
}

#endregion

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


#region List Functions


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
   # Get a list of Certificates.
   Get-B2CCertificateList -TenantId "myb2ctenant.onmicrosoft.com"

 .Example
    #  Get a list of Certificates, after you re-authenticate..
   Get-B2CCertificateList -TenantId "myb2ctenant.onmicrosoft.com" -ForeAuthn

 .LINK
	https://github.com/WhippsP/B2CUtils
   
#>
function Get-B2CCertificateList {
param(
   [Parameter(Mandatory=$true)]
    [string]$TenantId,
	[parameter(DontShow)]
	[string]$KeyType="cert",
	[switch]$ForeAuthn,
	[switch]$raw
    )

$accessToken = Get-TenantAccessToken -TenantId $TenantId -ForeAuthn $ForeAuthn

try{
$KeyList = Invoke-WebRequest "https://main.b2cadmin.ext.azure.com/api/keylist?api-version=1&TenantId=$TenantId&KeyType=$KeyType" -Method Get -Headers @{Authorization="Bearer $accessToken"}
}
Catch
{
	GetB2CError
}
if($raw)
{
	$KeyList.content
}
else{
	([xml]$KeyList.content).ArrayOfstring.string
}

}

<# 
 .Synopsis
  Displays a list of B2C Key Containers.

 .Description
  Displays a list of B2C Key Containers used within Trust Framework Policies.

 .Parameter TenantId
  The name of the B2C Tenant.

 .Parameter ForeAuthn
  Forces you to re-authenticate.
  

 .Example
   # Get a list of Key Containers.
   Get-B2CKeyContainerList -TenantId "myb2ctenant.onmicrosoft.com"

 .Example
    #  Get a list of Key Containers., after you re-authenticate..
   Get-B2CKeyContainerList -TenantId "myb2ctenant.onmicrosoft.com" -ForeAuthn

 .LINK
	https://github.com/WhippsP/B2CUtils
   
#>
function Get-B2CKeyContainerList {
param(
   [Parameter(Mandatory=$true)]
    [string]$TenantId,
	[switch]$ForeAuthn,
	[switch]$raw
    )

	Get-B2CCertificateList -TenantId $TenantId -ForeAuthn:$ForeAuthn -raw:$raw -KeyType KeyContainer
   
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
	try {
		$PolicyList = Invoke-WebRequest "https://main.b2cadmin.ext.azure.com/api/policyList?tenantId=$TenantId" -Method Get -Headers @{Authorization="Bearer $accessToken"}
	}
	Catch
	{
		GetB2CError
	}

	([xml]$PolicyList.content).ArrayOfPolicy.Policy.POlicyID


}

#TODO: Get-B2CUserList

#endregion

#region Get Functions
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
   # Get a Policy from B2C.
   Get-B2CPolicy -TenantId "myb2ctenant.onmicrosoft.com" -PolicyId B2C_1A_Policy1

 .Example
    #  Get a Policy and associated base Policies from B2C.
   Get-B2CPolicy -TenantId "myb2ctenant.onmicrosoft.com" -PolicyId B2C_1A_Policy1 -GetBasePolicies
   
   .Example
    #  Get a Policy, after you re-authenticate..
   Get-B2CPolicy -TenantId "myb2ctenant.onmicrosoft.com" -PolicyId B2C_1A_Policy1 -ForeAuthn 

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
  Gets a B2C Certificate.

 .Description
  Retrieves a Certificate from B2C.

 .Parameter TenantId
  The name of the B2C Tenant.
  
  .Parameter CertificateId
  Specify the name of the Certificate to return. (Can not be used with AllCerts)
   
  .Parameter AllCerts
  Retrieve all associated Certificates within B2C. (Can not be used with CertificateId)

 .Parameter ForeAuthn
  Forces you to re-authenticate.
  
 .Example
   # Get a Certificate.
   Get-B2CCertificate -TenantId "myb2ctenant.onmicrosoft.com" -CertificateId MySAMLSigningCert

 .Example
    #  Get a Certificate, after you re-authenticate..
   Get-B2CCertificate -TenantId "myb2ctenant.onmicrosoft.com" -CertificateId MySAMLSigningCert  -ForceAuthn
   
   .Example
    #  Get all Certificates within B2C
   Get-B2CCertificate -TenantId "myb2ctenant.onmicrosoft.com" -AllCerts

 .LINK
	https://github.com/WhippsP/B2CUtils
   
#>
function Get-B2CCertificate {
	[CmdletBinding(DefaultParameterSetName="Cert")] 
	param(
	[Parameter(Mandatory=$true)]
    [string]$TenantId,
	[parameter(Mandatory=$true,ParameterSetName = "Cert")]
	[string]$CertificateId,
	[parameter(Mandatory=$true,ParameterSetName = "AllCerts")]
	[switch]$AllCerts,
	[switch]$ForeAuthn
    )
	
	
	$accessToken = Get-TenantAccessToken -TenantId $TenantId -ForeAuthn $ForeAuthn

	$CrtArray = @()
	
	Try{
		$enc = [system.Text.Encoding]::ASCII
		if(!$AllCerts)
		{
			$CertEndpoint = "&CertificateId=$CertificateId";
		}
		$Crts = Invoke-WebRequest "https://main.b2cadmin.ext.azure.com/api/certificate?api-version=1&TenantId=$TenantId$CertEndpoint" -Method Get -Headers @{Authorization="Bearer $accessToken"}

		
		foreach ($crt in ([xml]$Crts.content).ArrayOfCertificateInfo.CertificateInfo)
		{
		
			$X509Cert = $null
			$X509Cert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2
			$X509Cert.Import($enc.GetBytes($crt.X509Certificate2.RawData.InnerText))
			$CrtArray += $X509Cert
		}
		
	}
	Catch [System.Net.WebException]
	{
		GetB2CError
	}
	
	
	if($CrtArray.length -eq 1)
	{
		$CrtArray[0]
	}
	else
	{
		$CrtArray
	}
	
}

<# 
 .Synopsis
  Gets a B2C Key Container.

 .Description
  Retrieves a Key Container from B2C.

 .Parameter TenantId
  The name of the B2C Tenant.
  
  .Parameter KeyContainerId
  Specify the name of the Key Container to return. (Can not be used with AllCerts)
   
 .Parameter ForeAuthn
  Forces you to re-authenticate.
  
 .Example
   # Get a Key Container.
   Get-B2CKeyContainer -TenantId "myb2ctenant.onmicrosoft.com" -KeyContainerId MySAMLSigningCert

 .Example
    #  Get a Key Container, after you re-authenticate..
   Get-B2CKeyContainer -TenantId "myb2ctenant.onmicrosoft.com" -KeyContainerId MySAMLSigningCert  -ForceAuthn

 .LINK
	https://github.com/WhippsP/B2CUtils
   
#>
function Get-B2CKeyContainer {
	param(
	[Parameter(Mandatory=$true)]
    [string]$TenantId,
	[Parameter(Mandatory=$true)]
	[string]$KeyContainerId,
	[switch]$ForeAuthn
    )
	
	
	$accessToken = Get-TenantAccessToken -TenantId $TenantId -ForeAuthn $ForeAuthn

	Try{
		$KeyContainer = Invoke-WebRequest "https://main.b2cadmin.ext.azure.com/api/keycontainer?api-version=1&TenantId=$TenantId&StorageReferenceId=$KeyContainerId" -Method Get -Headers @{Authorization="Bearer $accessToken"}
	}
	Catch
	{
		GetB2CError
	}
	([xml]$KeyContainer.content)
}


#TODO: Get-B2CUser

#endregion

#region New Functions

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
   New-B2CPolicy -TenantId "myb2ctenant.onmicrosoft.com" -Policy $policy

 .Example
   # Upload a Policies with .
   $policy = Get-Content -raw "C:\Temp\B2CPolicy.xml" 
   New-B2CPolicy -TenantId "myb2ctenant.onmicrosoft.com" -Policy $policy -OverwriePolicy $False
   
 .LINK
	https://github.com/WhippsP/B2CUtils
   
#>
function New-B2CPolicy {
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
	Catch
	{
		GetB2CError
	}

}

<# 
 .Synopsis
  Upload a Key Container to B2C

 .Description
  This function uploads a B2C Policy.

 .Parameter TenantId
  The name of the B2C Tenant.
  
  .Parameter KeyContainerId
  Specify the KeyContainerId.
  
  .Parameter UnencodedString
  Specifies the string to Store
  
  .Parameter keyId
  
  .Parameter SecretType
  
  .Parameter Expiration
  
  .Parameter DeltaNotBefore
  
  .Parameter keySize
    
  .Parameter OverwriteIfExists
  If the Key Container exists setting this switch will overwrite it.
  
 .Parameter ForeAuthn
  Forces you to re-authenticate.
  
 .Example
   # Set a Key Container.
   New-B2CKeyContainer -TenantId "myb2ctenant.onmicrosoft.com" -KeyContainerId NewKeyContainer -UnencodedString "String to Store"

 .Example
   # Set a Key Container forceing Authentication first.
   New-B2CKeyContainer -TenantId "myb2ctenant.onmicrosoft.com" -KeyContainerId NewKeyContainer -UnencodedString "String to Store" -ForceAuthn
   
   .Example
   # Create an RSA Key Container.
   New-B2CKeyContainer -KeyContainerId mysigncert -keyId mycigncert -SecretType rsa -Expiration 0 -DeltaNotBefore 0 -keySize 2048

   .Example
   #Create an RSA Key Container. forceing Authentication first.
   New-B2CKeyContainer -KeyContainerId mysigncert -keyId mycigncert -SecretType rsa -Expiration 0 -DeltaNotBefore 0 -keySize 2048 -ForceAuthn
   
 .LINK
	https://github.com/WhippsP/B2CUtils
   
#>
function New-B2CKeyContainer {
	[CmdletBinding(DefaultParameterSetName="StringKey")] 
	param(
	[parameter(Mandatory=$true,ParameterSetName = "StringKey")]
	[parameter(Mandatory=$true,ParameterSetName = "KeyContainer")]	
    [string]$TenantId,
	[parameter(Mandatory=$true,ParameterSetName = "StringKey")]
	[parameter(Mandatory=$true,ParameterSetName = "KeyContainer")]	
	[string]$KeyContainerId,
	[parameter(Mandatory=$true,ParameterSetName = "StringKey")]
	[string]$UnencodedString,
	[parameter(Mandatory=$true,ParameterSetName = "KeyContainer")]	
	[string]$keyId,
	[parameter(Mandatory=$true,ParameterSetName = "KeyContainer")]	
	[ValidateSet("rsa", "oct")]
	[string]$SecretType,
	[parameter(Mandatory=$true,ParameterSetName = "KeyContainer")]	
	[long]$Expiration,
	[parameter(Mandatory=$true,ParameterSetName = "KeyContainer")]	
	[long]$DeltaNotBefore,
	[parameter(Mandatory=$true,ParameterSetName = "KeyContainer")]	
	[string]$keySize,
	[parameter(Mandatory=$false,ParameterSetName = "StringKey")]
	[parameter(Mandatory=$false,ParameterSetName = "KeyContainer")]	
	[switch] $OverwriteIfExists
    )

	$accessToken = Get-TenantAccessToken -TenantId $TenantId -ForeAuthn $False
	
	
	switch ($PsCmdlet.ParameterSetName) {
    "KeyContainer" {
		$PostData = "<string xmlns=`"http://schemas.microsoft.com/2003/10/Serialization/`">$SecretType</string>"
		

		try{
			$webAppResponse = Invoke-WebRequest "https://cpim.windows.net/api/keycontainer?tenantId=$TenantId&storageReferenceId=$KeyContainerId&keyId=$keyId&SecretType=$SecretType&Expiration=$Expiration&DeltaNotBefore=$DeltaNotBefore&keySize=$keySize&overwriteIfExists=$OverwriteIfExists" -ContentType "application/xml; charset=utf-8" -Method Post -Headers @{Authorization="Bearer $accessToken";"referer"="https://cpim/"} -Body $PostData
		}
		Catch
		{
			GetB2CError
		}
	
    }
    "StringKey" {
		$enc = [system.Text.Encoding]::ASCII

		$Bytes = $enc.GetBytes($UnencodedString)
		$b64str = [Convert]::ToBase64String($Bytes)
		
		
		$KeyContainer = "{`"keys`":[{`"kid`":`"$KeyContainerId`",`"use`":`"sig`",`"kty`":`"oct`",`"k`":`"$b64str`"}]}"
		$KBytes = $enc.GetBytes($KeyContainer)
		$PostData = "<KeyContainerInfo xmlns:i=`"http://www.w3.org/2001/XMLSchema-instance`" z:Id=`"i1`" xmlns:z=`"http://schemas.microsoft.com/2003/10/Serialization/`" xmlns=`"http://schemas.datacontract.org/2004/07/Microsoft.Cpim.Protocols.Keys`"><StorageKeyId>$KeyContainerId</StorageKeyId><TenantId>$TenantId</TenantId><KeyContainer>" + [Convert]::ToBase64String($KBytes) + "</KeyContainer></KeyContainerInfo>"

		try{
			$webAppResponse = Invoke-WebRequest "https://cpim.windows.net/api/keycontainer?tenantId=$TenantId&overwriteIfExists=$OverwriteIfExists" -ContentType "application/xml; charset=utf-8" -Method Post -Headers @{Authorization="Bearer $accessToken";"referer"="https://cpim/"} -Body $PostData
		}
		Catch
		{
			GetB2CError
		}
    }
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
	Catch
	{
		GetB2CError
	}

	
}

<# 
 .Synopsis
  Deletes a B2C Certificate.

 .Description
  Removes a Certificate from B2C.

 .Parameter TenantId
  The name of the B2C Tenant.
  
  .Parameter CertificateId
  Specify the name of the Certificate to remove.
  
  .Parameter ForeAuthn
  Forces you to re-authenticate.
  

 .Example
   # Remove a Certificate.
   Remove-B2CCertificate -TenantId "myb2ctenant.onmicrosoft.com" -CertificateId MySAMLCert

 .LINK
	https://github.com/WhippsP/B2CUtils
   
#>
function Remove-B2CCertificate {
param(
	[Parameter(Mandatory=$true)]
    [string]$TenantId,
	[Parameter(Mandatory=$true)]
	[string]$CertificateId,
	[switch]$ForeAuthn
    )


	$accessToken = Get-TenantAccessToken -TenantId $TenantId -ForeAuthn $ForeAuthn
	try{
		$pol = Invoke-WebRequest "https://main.b2cadmin.ext.azure.com/api/certificate/?api-version=1&TenantId=$TenantId&CertificateId=$CertificateId" -Method Delete -Headers @{Authorization="Bearer $accessToken"}
	} 
	Catch
	{
		GetB2CError
	}
}

<# 
 .Synopsis
  Deletes a B2C Key COntainer.

 .Description
  Removes a Key COntainer from B2C.

 .Parameter TenantId
  The name of the B2C Tenant.
  
  .Parameter KeyContainerId
  Specify the name of the Key COntainer to remove.
  
  .Parameter ForeAuthn
  Forces you to re-authenticate.
  

 .Example
   # Remove a Key COntainer.
   Remove-B2CKeyContainer -TenantId "myb2ctenant.onmicrosoft.com" -KeyContainerId MyKeyContainer

 .LINK
	https://github.com/WhippsP/B2CUtils
   
#>
function Remove-B2CKeyContainer {
	param(
	[Parameter(Mandatory=$true)]
    [string]$TenantId,
	[Parameter(Mandatory=$true)]
	[string]$KeyContainerId,
	[switch]$ForeAuthn
    )


	$accessToken = Get-TenantAccessToken -TenantId $TenantId -ForeAuthn $ForeAuthn
	try{
		$pol = Invoke-WebRequest "https://main.b2cadmin.ext.azure.com/api/keycontainer?api-version=1&TenantId=$TenantId&StorageReferenceId=$KeyContainerId" -Method Delete -Headers @{Authorization="Bearer $accessToken"}
	} 
	Catch
	{
		GetB2CError
	}
}

#TODO: Remove-B2CUser


#endregion
<# 
 .Synopsis
  Upload a Certificate to B2C

 .Description
  This function uploads a B2C Certificate.

 .Parameter TenantId
  The name of the B2C Tenant.
  
  .Parameter CertificateId
  Specify the CertificateId.
  
  .Parameter CertificateFile
  Specifies the path to a Certifficate File to store
  
  .Parameter Password
  Specifies the Password used to read a private key.
  
  .Parameter NewSelfSignedCert
  Use this switch to generate a self signed certificate to store.
  
  .Parameter NewCertSubject
  Specifies subject if using the NewSelfSignedCert switch.
  
 .Parameter ForeAuthn
  Forces you to re-authenticate.
  
 .Example
   # New Certificate from File.
   New-B2CCertificate -TenantId "myb2ctenant.onmicrosoft.com" -CertificateId NewCert -CertificateFile "C:\temp\mycert.pfx" -Password "secret"

 .Example
   # New Certificate from Certificate.
   New-B2CCertificate -TenantId "myb2ctenant.onmicrosoft.com" -CertificateId NewCert -Certificate $MyCert
   
   .Example
   # New Self Signed Certificate.
   New-B2CCertificate -TenantId "myb2ctenant.onmicrosoft.com" -CertificateId NewCert -NewSelfSignedCert NewCertSubject "cn=idp_signing_cert.mycompany.com"

   
 .LINK
	https://github.com/WhippsP/B2CUtils
   
#>
function New-B2CCertificate {
	[CmdletBinding(DefaultParameterSetName="AddCertFile")] 
	param(
	[Parameter(Mandatory=$true,ParameterSetName = "AddCert")]
	[parameter(Mandatory=$true,ParameterSetName = "AddCertFile")]
	[parameter(Mandatory=$true,ParameterSetName = "AddSelfCert")]	
    [string]$TenantId,
	[Parameter(Mandatory=$true,ParameterSetName = "AddCert")]
	[parameter(Mandatory=$true,ParameterSetName = "AddCertFile")]
	[parameter(Mandatory=$true,ParameterSetName = "AddSelfCert")]
	[string]$CertificateId,
	[parameter(Mandatory=$true,ParameterSetName = "AddCert")]
	[System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate,
	[parameter(Mandatory=$true,ParameterSetName = "AddCertFile")]
	[string]$CertificateFile,
	[parameter(Mandatory=$false,ParameterSetName = "AddCert")]
	[parameter(Mandatory=$false,ParameterSetName = "AddCertFile")]
	[string]$Password,
	[parameter(Mandatory=$true,ParameterSetName = "AddSelfCert")]
	[string]$NewCertSubject,
	[parameter(Mandatory=$false,ParameterSetName = "AddSelfCert")]
	[switch]$NewSelfSignedCert,
	[switch]$ForeAuthn
	)
	
	if(($NewCertSubject.Length -gt 0) -and ( !$NewSelfSignedCert)) 
	{
		write-warning  "If you supply a Subject for a new Self-Signed cert you must add the -NewSelfSignedCert switch."
		break
	}
	
	If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
	{
		write-warning "You do not have Administrator rights to generate a Certificate!`nPlease re-run this script as an Administrator!`n`n"
		break;
	}
	
	$accessToken = Get-TenantAccessToken -TenantId $TenantId -ForeAuthn $False
	
	if($NewSelfSignedCert)
	{
		$Certificate = New-SelfsignedCertificate -Subject "$NewCertSubject" -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2,1.3.6.1.5.5.7.3.1") -KeyUsage KeyEncipherment, DigitalSignature  -CertStoreLocation "cert:\LocalMachine\My" -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" -KeyLength 2048 -KeyAlgorithm RSA -KeyExportPolicy Exportable -HashAlgorithm SHA256 -NotAfter (Get-Date).Add(730d)
	}
	elseif($CertificateFile -ne "")
	{
		$Certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($CertificateFile,$Password,[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)
	}
	elseif($Certificate -ne $null)
	{
		
	}
	
	$CBytes = $Certificate.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx)
	$Postdata = "<base64Binary xmlns=`"http://schemas.microsoft.com/2003/10/Serialization/`">"+ [Convert]::ToBase64String($CBytes) +"</base64Binary>"
	
	try{
		$webAppResponse = Invoke-WebRequest "https://cpim.windows.net/api/certificate?tenantId=$TenantId&certificateid=$CertificateId" -ContentType "application/xml; charset=utf-8" -Method Post -Headers @{Authorization="Bearer $accessToken";"referer"="https://cpim/"} -Body $PostData
	}
	Catch
	{
		GetB2CError
	}
	
	
}

Add-Type -TypeDefinition @"
   public enum B2CAttributeType
   {
      String=1,
      Boolean=2,
      Duration=3,
      DateTime=4,
      Int=5,
      Date=6,
      StringCollection=7,
      Long=8
   }
"@


<# 
 .Synopsis
  Create a new V1 Base Attribute in B2C

 .Description
  This function creates a B2C Attribute visible wihtin the Portal.

 .Parameter TenantId
  The name of the B2C Tenant.
  
  .Parameter AttributeName
  Specifies the name of the new attribute
  
  .Parameter AttributeType
  Specifies the Attribute Type (The can be one of String, Boolean, Duration, DateTime, Int, Date, StringCollection, Long)
  
  .Parameter AttributeDescription
  Specifies an optional description to add to the attribute.
    
 .Parameter ForeAuthn
  Forces you to re-authenticate.
  
 .Example
   # New Attribute
   New-B2CBaseAttribute -TenantId "myb2ctenant.onmicrosoft.com"  -AttributeName "NewSTR" -AttributeType String -AttributeDescription "TESTING"
   
 .LINK
	https://github.com/WhippsP/B2CUtils
   
#>
function New-B2CBaseAttribute {
	param(
	[Parameter(Mandatory=$true)]
    	[string]$TenantId,
	[Parameter(Mandatory=$true)]
	[string]$AttributeName,
	[Parameter(Mandatory=$true)]
	[B2CAttributeType]$AttributeType,
	[string]$AttributeDescription,
	[switch]$ForeAuthn
    )


	$accessToken = Get-TenantAccessToken -TenantId $TenantId -ForeAuthn $ForeAuthn
	try{

		$PostStr = '{"dataType":' + [int]$AttributeType + ',"displayName":"' + $AttributeName + '","adminHelpText":"' + $AttributeDescription + '", "userHelpText":"' + $AttributeDescription + '","userInputType":1,"userAttributeOptions":[]}'

		$PostStr
		$pol = Invoke-WebRequest "https://main.b2cadmin.ext.azure.com/api/userAttribute?tenantId=unifyb2cworkshop.onmicrosoft.com&`$orderby=DisplayName" -Method POST -ContentType "application/json" -Headers @{Authorization="Bearer $accessToken"} -Body $PostStr
	} 
	Catch
	{
		GetB2CError
	}
}

#TODO: New-B2CUser

#endregoin


export-modulemember -Function *-B2C*

