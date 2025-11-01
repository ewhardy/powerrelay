param(
        [ValidateRange(0,7)]
        [String]$OutletNumber=5,
        [ValidateSet("on","off")]
        [String]$PowerState = "off",
        [String]$powerRelayIp="192.168.112.150",
        [string]$LoginFilePath = 'D:\src\secrets\power.relay.txt'
)

##
## FUNCTIONS

function Get-OutletPowerState {
        param(
                [String]$OutletNumber,
                [String]$powerRelayIp,
                [string]$secretsFilePath
        )

        $rawlogin = Get-Content -Path $secretsFilePath

        $webLogin = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($rawlogin))

        $GetStateUri = "http://$($powerRelayIp)/restapi/relay/outlets/$($OutletNumber)/state/"

        [bool]$stateReponse = Invoke-RestMethod  `
                -Headers @{Authorization = "Basic $webLogin" } `
                -Uri $GetStateUri `
                -ContentType "application/json"

        Write-Host "Relay State: $($stateReponse)"

        $output = [PSCustomObject]@{
                OutletNumber    = $OutletNumber
                CurrentState    = $stateReponse
        }
        return $output

}


function Update-RelayPowerState {
    param(
        [String]$OutletNumber,
        [String]$powerRelayIp,
        [string]$secretsFilePath
    )

    $setOutletStateUri = "http://$($powerRelayIp)/restapi/relay/outlets/$($OutletNumber)/state/"

    ##
    ## DEVNOTE: content-type is **required**
    $setStateHeaders = @{
        "Authorization" = "Basic $($webLogin)"
        "X-CSRF"        = "x"
        "content-type"  = "application/x-www-form-urlencoded"
    }

    $setStateBody = "value=$($newStateValue)"

    $setStateReponse = Invoke-RestMethod `
        -Headers $setStateHeaders `
        -Method 'PUT' `
        -Uri $setOutletStateUri `
        -Body $setStateBody `
        -SkipHttpErrorCheck

    if ($setStateReponse -eq [String]::Empty) {
        $setStateReponseStatus = "Success"
    }
    else {
        $setStateReponseStatus = "Error"
    }


    $output = [PSCustomObject]@{
        OutletNumber          = $OutletNumber
        UpdateRequestResponse = $setStateReponseStatus
        UpdateRequestError    = $setStateReponse.error
    }
    return $output

}


$currentOutletState = Get-OutletPowerState -OutletNumber 2 -powerRelayIp $powerRelayIp -secretsFilePath $LoginFilePath

if ($currentOutletState.CurrentState -eq $true) {
    $currentState = "on"
} else {
    $currentState = "off"
}

if ($currentState -ieq $PowerState) {
    Write-Host "Outlet already $($PowerState). Exiting"
    Exit 0
} else {
    Write-Host "Turning outlet $($PowerState)"
}

$desiredPowerState = $false

if ($PowerState -ieq "on") {
    $desiredPowerState = $true
}

$setDesiredStateUri = "http://$($powerRelayIp)/restapi/relay/outlets/$($OutletNumber)/state/"

##
## DEVNOTE: content-type is **required**
$setDesiredStateHeaders = @{
    "Authorization" = "Basic $($webLogin)"
    "X-CSRF" = "x"
    "content-type" = "application/x-www-form-urlencoded"
}

$setDesiredStateBody = "value=$($desiredPowerState)"

$setDesiredStateReponse = Invoke-RestMethod `
        -Headers $setDesiredStateHeaders `
        -Method 'PUT' `
        -Uri $setDesiredStateUri `
        -Body $setDesiredStateBody `
        -SkipHttpErrorCheck

if ($setDesiredStateReponse -eq [String]::Empty) {
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