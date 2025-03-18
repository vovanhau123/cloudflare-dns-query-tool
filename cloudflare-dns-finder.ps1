# Cloudflare DNS Record Finder
# Author: [Your name]

# Cloudflare authentication information - DO NOT enter real values here
$email = ""     # Your Cloudflare email
$apiKey = ""    # Your Cloudflare API Key
$zoneID = ""    # Zone ID of the domain you need to check
$domainToFind = "jason.io.vn" # Domain name to find

# Configuration to load from file or environment variables
if ([string]::IsNullOrEmpty($email)) {
    # Load from environment variables or configuration file
    $email = $env:CLOUDFLARE_EMAIL
    $apiKey = $env:CLOUDFLARE_API_KEY
    $zoneID = $env:CLOUDFLARE_ZONE_ID
}

# API URL to get DNS records list
$url = "https://api.cloudflare.com/client/v4/zones/$zoneID/dns_records"

# Headers for API
$headers = @{
    "X-Auth-Email" = $email
    "X-Auth-Key" = $apiKey
    "Content-Type" = "application/json"
}

try {
    # Send GET request to retrieve DNS records list
    $response = Invoke-RestMethod -Uri $url -Method GET -Headers $headers
    
    # Find A record for the domain to search
    $record = $response.result | Where-Object { $_.name -eq $domainToFind -and $_.type -eq "A" }
    
    if ($record) {
        $recordID = $record.id
        Write-Host "DNS Record ID for $domainToFind is: $recordID"
    } else {
        Write-Host "No A record found for $domainToFind in the zone."
    }
} catch {
    Write-Host "Error when retrieving DNS records list: $_"
    Write-Host "Error details: $($_.Exception.Message)"
}