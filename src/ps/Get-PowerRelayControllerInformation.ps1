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
        file content is expected to be: username:password
        Only first line of file is read, all other content is ignored
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

        $rawlogin = Get-Content -TotalCount 1 -Path $secretsfile

        $webLogin = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($rawlogin))

        $GetRelayInfoUri = "http://$($powerRelayIp)/restapi/"


        $RelayInfoResponse = Invoke-RestMethod  `
                -Method Get `
                -Headers @{Authorization = "Basic $webLogin" } `
                -Uri $GetRelayInfoUri

        $RelayInfoResponse
}