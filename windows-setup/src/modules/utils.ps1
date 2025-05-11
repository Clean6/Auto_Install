function Log-Message {
    param (
        [string]$Message
    )
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
}

function Test-Connection {
    param (
        [string]$Url
    )
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicP
        return $response.StatusCode -eq 200
    } catch {
        return $false
    }
}