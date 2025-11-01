function Get-RelayPowerState {
        param(
                [String]$OutletNumber = "7",
                [String]$powerRelayIp = "192.168.112.150",
        [string]$SecretsFilePath = $env:PowerRelaySecretPath
)

        $secretsfile = $SecretsFilePath

        $rawlogin = Get-Content -Path $secretsfile

        $webLogin = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($rawlogin))

        $GetRelayInfoUri = "http://$($powerRelayIp)/restapi/relay/model/"


        $RelayInfoResponse = Invoke-RestMethod  `
                -Headers @{Authorization = "Basic $webLogin" } `
                -Uri $GetRelayInfoUri `

        Write-Output "Model: $($RelayInfoResponse)"

        $GetStateUri = "http://$($powerRelayIp)/restapi/relay/outlets/$($OutletNumber)/state/"



        $stateReponse = Invoke-RestMethod  `
                -Headers @{Authorization = "Basic $webLogin" } `
                -Uri $GetStateUri `
                -ContentType "application/json"

        Write-Host "Relay State: $($stateReponse)"

        $output = [PSCustomObject]@{
                PowerRelayModel = $RelayInfoResponse
                OutletNumber    = $OutletNumber
                CurrentState    = $stateReponse
        }
        $output

}