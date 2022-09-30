# Secure APIM to Function connection using managed identity

This example shows how to secure your Azure APIM to function connection using managed identities.
See [Blog Article](https://medium.com/@claasd/secure-your-azure-apim-to-function-connection-with-identity-based-authentication-79627c779e76) for more information.

To run the example, you need dotnet SDK 6.0, Azure CLI and Powershell.

Create your app-registration, and insert it into the `clientId` variable in `deploy.ps1`. 

Make sure your logged in with azure CLI and are in the correct subscription. Then, run `deploy.ps1`. 
