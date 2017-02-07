**B2CUtils**
===================

Powershell module for B2C management
----------


**Usage**
-----

<br/>


### Import the module
To use the following function extract this Github repository to you locam machine and then from a powershell  prompt type:
```powershell
PS> Import-Module -Force B2CUtils.psm1
```

<br/>

## B2C List Functions

### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Get-B2CPolicyList

```powershell
		Get-B2CPolicyList  [-TenantId] <string> [-ForeAuthn]  [<CommonParameters>]
        Example:
        		
		PS>         
```
### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Get-B2CCertList

```powershell
		Get-B2CCertList [-TenantId] <string> [-ForeAuthn]  [<CommonParameters>]
        Example:
        		
		PS>         
```
### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Get-B2CKeyContainerList
```powershell
		Get-B2CCertList [-TenantId] <string> [-ForeAuthn]  [<CommonParameters>]
        Example:
        		
		PS>         
```

<br/>

## B2C New Functions


### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;New-B2CPolicy

```powershell
		New-B2CPolicy  [-TenantId] <string> [-ForeAuthn]  [<CommonParameters>]
        Example:
        		
		PS>         
```
### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;New-B2CCertificate

```powershell
		New-B2CCertificate  [-TenantId] <string> [-ForeAuthn]  [<CommonParameters>]
        Example:
        		
		PS>         
```
### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;New-B2CKeyContainer

```powershell
		New-B2CKeyContainer  [-TenantId] <string> [-ForeAuthn]  [<CommonParameters>]
        Example:
        		
		PS>         
```

<br/>
## B2C Get Functions


### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Get-B2CPolicy

```powershell
		Get-B2CPolicy  [-TenantId] <string> [-ForeAuthn]  [<CommonParameters>]
        Example:
        		
		PS>         
```
### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Get-B2CCertificate

```powershell
		Get-B2CCertificate  [-TenantId] <string> [-ForeAuthn]  [<CommonParameters>]
        Example:
        		
		PS>         
```
### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Get-B2CKeyContainer

```powershell
		Get-B2CKeyContainer  [-TenantId] <string> [-ForeAuthn]  [<CommonParameters>]
        Example:
        		
		PS>         
```

<br/>
## B2C Remove Functions


### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Remove-B2CPolicy

```powershell
		Remove-B2CPolicy  [-TenantId] <string> [-ForeAuthn]  [<CommonParameters>]
        Example:
        		
		PS> 
```

### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Remove-B2CCertificate

```powershell
		Remove-B2CCertificate  [-TenantId] <string> [-ForeAuthn]  [<CommonParameters>]
        Example:
		
		PS> 
```
### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Remove-B2CKeyContainer

```powershell 
		Remove-B2CKeyContainer  [-TenantId] <string> [-ForeAuthn]  [<CommonParameters>]
		Example:
		
		PS> 
```


<br/>
## Other Functions


### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Set-B2CDefaultTenant
Because I am lazy and could not be bothered entering -TenantID I created a Function to set the default TenantID. This utilised the DefaultParamater $PSDefaultParameterValues variable of Powershell V3
```powershell
		Set-B2CDefaultTenant  [-TenantId] <string> [<CommonParameters>]
        Example:
		
		PS> Set-B2CDefaultTenant -TenantId myb2ctenant.onmicrosoft.com
```
