param(
        [String]$OutletNumber = "4",
        [String]$powerRelayIp="192.168.112.150",
        [string]$SecretsFilePath = $env:PowerRelaySecretPath
)

$secretsfile = $SecretsFilePath

$rawlogin = Get-Content -Path $secretsfile

$webLogin = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($rawlogin))

# $powerRelayIp="192.168.112.150"

##$GetStateUri = "http://$($powerRelayIp)/restapi/relay/outlets/all;/state/"

# $GetRelayInfoUri = "http://$($powerRelayIp)/restapi/relay/model/"

# # $OutletNumber = "7"

# $RelayInfoResponse = Invoke-RestMethod  `
#         -Headers @{Authorization = "Basic $webLogin" } `
#         -Uri $GetRelayInfoUri `

# Write-Host "Relay Model: $($RelayInfoResponse)"



$GetStateUri = "http://$($powerRelayIp)/restapi/relay/outlets/$($OutletNumber)/state/"

$originalStateReponse = Invoke-RestMethod  `
        -Headers @{Authorization = "Basic $webLogin" } `
        -Uri $GetStateUri `
        -ContentType "application/json"

$newStateValue = $originalStateReponse

if ($originalStateReponse -eq $False) {
    $newStateValue = "true"
} else {
    $newStateValue = "false"
}


##$GetStateUri = "http://$($powerRelayIp)/restapi/relay/outlets/all;/state/"

$setStateUri = "http://$($powerRelayIp)/restapi/relay/outlets/$($OutletNumber)/state/"

##
## DEVNOTE: content-type is **required**
$setStateHeaders = @{
    "Authorization" = "Basic $($webLogin)"
    "X-CSRF" = "x"
    "content-type" = "application/x-www-form-urlencoded"
}

$setStateBody = "value=$($newStateValue)"

# Write-Host "sending body: $($setStateBody)"

$setStateReponse = Invoke-RestMethod `
        -Headers $setStateHeaders `
        -Method 'PUT' `
        -Uri $setStateUri `
        -Body $setStateBody `
        -SkipHttpErrorCheck

if ($setStateReponse -eq [String]::Empty)
{
    $setStateReponseStatus = "Success"
} else {
    $setStateReponseStatus = "Error"
}

## get state again

$secondStateReponse = Invoke-RestMethod  -Headers @{Authorization = "Basic $webLogin" } `
        -Uri $GetStateUri `
        -ContentType "application/json"

Write-Host "Updated State: $($secondStateReponse)"


$output = [PSCustomObject]@{
        OutletNumber = $OutletNumber
        OriginalState = $originalStateReponse
        CurrentState = $secondStateReponse
        UpdateRequestResponse = $setStateReponseStatus
        UpdateRequestError = $setStateReponse.error
}

$output