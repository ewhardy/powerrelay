function Get-PowerRelayControllerInformation {
       <#
        .SYNOPSIS
        Returns all controller configuration via RestApi

        .DESCRIPTION
        Calls the top-level restapi to get all state information.
        This can take a while depending on network connection

        .PARAMETER powerRelayIp
        IPV4 of the powerRelay endpoing

        .PARAMETER SecretsFilePath
        Path to secrets file with login information
        Default: environment variable: PowerRelaySecretPath
        file is expected to be in form: username:password
        #>
        param(
        [ValidateScript({
                $outIp = $null
                [System.Net.Ipaddress]::TryParse($_,[ref]$outIp)
        })]
        [String]$powerRelayIp = "192.168.112.150",
        [ValidateScript({Test-path -Path $_})]
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