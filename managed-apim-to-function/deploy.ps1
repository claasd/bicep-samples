$rg = "function-demo"
$clientId = "some-client-id"

$result = az deployment group create -f .\main.bicep -g $rg --parameters clientId=$clientId | ConvertFrom-Json
$name = $result.properties.parameters.name.value
dotnet publish function
Compress-Archive .\function\bin\Debug\net6.0\publish\* function.zip -Force
az functionapp deployment source config-zip --src .\function.zip --resource-group $rg --name $name
