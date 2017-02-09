# B2C to Log Analytics

 - run.csx
 - OMSUtils.csx
 - function.json
 - sample.dat
 
 Create the Function from Azure App Services and copy the above files into the function directory.
 
 or use Visual Studio Tools for Azure Functions
 https://aka.ms/FunctionsVSTools
 
 When the above is done grab the URL with your code and add it to the UserJourneyRecorderEndpoint attribute of the TrustFrameworkPolicy
 
 ```
 <TrustFrameworkPolicy ..... PolicySchemaVersion="0.3.0.0" TenantId="myb2ctenant.onmicrosoft.com" PolicyId="B2C_1A_SAML_SignIn" PublicPolicyUri="http://myb2ctenant.onmicrosoft.com/" DeploymentMode="Development" UserJourneyRecorderEndpoint=" https://b2cfunctions.azurewebsites.net/api/LogToOMS?code=qssX24597pqVadTf3d2GgYg8HAFjTLQZEVQysssLFBUa2Mg==">
 ```
 
 