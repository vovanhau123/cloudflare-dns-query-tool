@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion

rem === Configuration Information ===
set ZONE_ID=
set DOMAIN=
set API_TOKEN=
set CHECK_INTERVAL=900
set LOG_FILE=dns_updater.log
set DISCORD_WEBHOOK=
set DISCORD_USER_ID= 
set DISCORD_NOTIFY_INTERVAL=5 

echo ===== Cloudflare DNS Automatic Update Tool =====
echo Running in continuous mode (Check every %CHECK_INTERVAL% seconds)
echo Press Ctrl+C to stop the program
echo.

rem === Create or open log file ===
echo %date% %time% - Application started >> %LOG_FILE%

:MAIN_LOOP
echo.
echo ===== New check [%date% %time%] =====
echo %date% %time% - Starting check >> %LOG_FILE%

rem === Get current IP address ===
echo Getting your current IP address...
for /f %%a in ('curl -s https://api.ipify.org') do set CURRENT_IP=%%a
if "!CURRENT_IP!"=="" (
    echo [ERROR] Unable to get current IP address.
    echo %date% %time% - [ERROR] Unable to get current IP address >> %LOG_FILE%
    
    rem === Send Discord notification when IP can't be retrieved ===
    call :SEND_DISCORD_NOTIFICATION "[ERROR] Unable to get current IP address."
    
    goto :WAIT
)
echo Current IP address: !CURRENT_IP!
echo %date% %time% - Current IP address: !CURRENT_IP! >> %LOG_FILE%
echo.

rem === Create temporary PowerShell script to handle JSON ===
echo $zoneId = '%ZONE_ID%' > get_dns.ps1
echo $domain = '%DOMAIN%' >> get_dns.ps1
echo $apiToken = '%API_TOKEN%' >> get_dns.ps1
echo. >> get_dns.ps1
echo $headers = @{ >> get_dns.ps1
echo     "Authorization" = "Bearer $apiToken" >> get_dns.ps1
echo     "Content-Type" = "application/json" >> get_dns.ps1
echo } >> get_dns.ps1
echo. >> get_dns.ps1
echo try { >> get_dns.ps1
echo     $response = Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/zones/$zoneId/dns_records?name=$domain&type=A" -Method Get -Headers $headers >> get_dns.ps1
echo     if ($response.success -eq $true -and $response.result.Count -gt 0) { >> get_dns.ps1
echo         $recordId = $response.result[0].id >> get_dns.ps1
echo         $oldIp = $response.result[0].content >> get_dns.ps1
echo         Write-Output "RECORD_ID=$recordId" >> get_dns.ps1
echo         Write-Output "OLD_IP=$oldIp" >> get_dns.ps1
echo     } else { >> get_dns.ps1
echo         Write-Output "ERROR=DNS record not found" >> get_dns.ps1
echo     } >> get_dns.ps1
echo } catch { >> get_dns.ps1
echo     Write-Output "ERROR=API connection error: $_" >> get_dns.ps1
echo } >> get_dns.ps1

rem === Execute PowerShell script ===
echo Querying DNS information from Cloudflare...
powershell -ExecutionPolicy Bypass -File get_dns.ps1 > dns_info.txt

rem === Read results from PowerShell ===
set RECORD_ID=
set OLD_IP=
set ERROR=
for /f "tokens=1,* delims==" %%a in (dns_info.txt) do (
    if "%%a"=="RECORD_ID" set RECORD_ID=%%b
    if "%%a"=="OLD_IP" set OLD_IP=%%b
    if "%%a"=="ERROR" set ERROR=%%b
)

if defined ERROR (
    echo [ERROR] !ERROR!
    echo %date% %time% - [ERROR] !ERROR! >> %LOG_FILE%
    
    rem === Send Discord notification when API error occurs ===
    call :SEND_DISCORD_NOTIFICATION "[ERROR] !ERROR!"
    
    goto :CLEANUP
)

if not defined RECORD_ID (
    echo [ERROR] Unable to extract DNS record ID.
    echo %date% %time% - [ERROR] Unable to extract DNS record ID >> %LOG_FILE%
    
    rem === Send Discord notification when ID cannot be extracted ===
    call :SEND_DISCORD_NOTIFICATION "[ERROR] Unable to extract DNS record ID."
    
    goto :CLEANUP
)

echo Current DNS information:
echo - Domain: %DOMAIN%
echo - Record ID: !RECORD_ID!
echo - Current IP in DNS: !OLD_IP!
echo.

rem === Check if update is needed ===
if "!OLD_IP!"=="!CURRENT_IP!" (
    echo [NOTICE] IP address in DNS already matches current IP.
    echo No update needed.
    echo %date% %time% - IP has not changed, no update needed >> %LOG_FILE%
    goto :CLEANUP
)

rem === Create PowerShell script to update DNS ===
echo $zoneId = '%ZONE_ID%' > update_dns.ps1
echo $recordId = '!RECORD_ID!' >> update_dns.ps1
echo $domain = '%DOMAIN%' >> update_dns.ps1
echo $newIp = '!CURRENT_IP!' >> update_dns.ps1
echo $apiToken = '%API_TOKEN%' >> update_dns.ps1
echo. >> update_dns.ps1
echo $headers = @{ >> update_dns.ps1
echo     "Authorization" = "Bearer $apiToken" >> update_dns.ps1
echo     "Content-Type" = "application/json" >> update_dns.ps1
echo } >> update_dns.ps1
echo. >> update_dns.ps1
echo $body = @{ >> update_dns.ps1
echo     type = "A" >> update_dns.ps1
echo     name = "$domain" >> update_dns.ps1
echo     content = "$newIp" >> update_dns.ps1
echo     ttl = 1 >> update_dns.ps1
echo     proxied = $true >> update_dns.ps1
echo } | ConvertTo-Json >> update_dns.ps1
echo. >> update_dns.ps1
echo try { >> update_dns.ps1
echo     $response = Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/zones/$zoneId/dns_records/$recordId" -Method Put -Headers $headers -Body $body >> update_dns.ps1
echo     if ($response.success -eq $true) { >> update_dns.ps1
echo         Write-Output "SUCCESS=true" >> update_dns.ps1
echo     } else { >> update_dns.ps1
echo         Write-Output "ERROR=Update failed: $($response.errors | ConvertTo-Json)" >> update_dns.ps1
echo     } >> update_dns.ps1
echo } catch { >> update_dns.ps1
echo     Write-Output "ERROR=API connection error: $_" >> update_dns.ps1
echo } >> update_dns.ps1

rem === Update DNS record ===
echo Updating DNS record with new IP...
powershell -ExecutionPolicy Bypass -File update_dns.ps1 > update_result.txt

rem === Read update results ===
set UPDATE_SUCCESS=
set UPDATE_ERROR=
for /f "tokens=1,* delims==" %%a in (update_result.txt) do (
    if "%%a"=="SUCCESS" set UPDATE_SUCCESS=%%b
    if "%%a"=="ERROR" set UPDATE_ERROR=%%b
)

if defined UPDATE_SUCCESS (
    echo [SUCCESS] DNS updated for %DOMAIN%
    echo - Old IP: !OLD_IP!
    echo - New IP: !CURRENT_IP!
    echo %date% %time% - [SUCCESS] IP updated from !OLD_IP! to !CURRENT_IP! >> %LOG_FILE%
) else (
    echo [ERROR] Unable to update DNS.
    if defined UPDATE_ERROR echo Error details: !UPDATE_ERROR!
    echo %date% %time% - [ERROR] Unable to update DNS: !UPDATE_ERROR! >> %LOG_FILE%
    
    rem === Send Discord notification when DNS update fails ===
    call :SEND_DISCORD_NOTIFICATION "[ERROR] Unable to update DNS for %DOMAIN%. Details: !UPDATE_ERROR!"
)

:CLEANUP
del dns_info.txt 2>nul
del get_dns.ps1 2>nul
del update_dns.ps1 2>nul
del update_result.txt 2>nul

:WAIT
echo.
echo Waiting %CHECK_INTERVAL% seconds before next check...
echo Press Ctrl+C to exit program

rem === Countdown so user can see remaining time ===
for /l %%i in (%CHECK_INTERVAL%,-1,1) do (
    title Cloudflare DNS Update - Next check in %%i seconds
    timeout /t 1 /nobreak >nul
)

goto :MAIN_LOOP

:END
echo.
echo Program terminated.

rem === Function to send Discord Webhook notification ===
:SEND_DISCORD_NOTIFICATION
setlocal
set "MESSAGE=%~1"
set "MESSAGE=%MESSAGE:"=\"%"

rem === Create temporary PowerShell file to send Discord notification ===
echo $webhookUrl = '%DISCORD_WEBHOOK%' > send_discord.ps1
echo $userId = '%DISCORD_USER_ID%' >> send_discord.ps1
echo $content = "<@$userId> %MESSAGE% (Time: %date% %time%)" >> send_discord.ps1
echo. >> send_discord.ps1
echo $payload = @{ >> send_discord.ps1
echo     content = $content >> send_discord.ps1
echo } | ConvertTo-Json >> send_discord.ps1
echo. >> send_discord.ps1
echo try { >> send_discord.ps1
echo     Invoke-RestMethod -Uri $webhookUrl -Method Post -ContentType "application/json" -Body $payload >> send_discord.ps1
echo     Write-Output "Discord notification sent successfully." >> send_discord.ps1
echo } catch { >> send_discord.ps1
echo     Write-Output "Error sending Discord notification: $_" >> send_discord.ps1
echo } >> send_discord.ps1

echo Sending notification to Discord...
powershell -ExecutionPolicy Bypass -File send_discord.ps1
del send_discord.ps1 2>nul

rem === Create loop to send repeated notifications every DISCORD_NOTIFY_INTERVAL seconds ===
echo Sending repeated notifications every %DISCORD_NOTIFY_INTERVAL% seconds...
for /l %%j in (1,1,5) do (
    timeout /t %DISCORD_NOTIFY_INTERVAL% /nobreak >nul
    
    rem === Create temporary PowerShell file to send Discord notification ===
    echo $webhookUrl = '%DISCORD_WEBHOOK%' > send_discord.ps1
    echo $userId = '%DISCORD_USER_ID%' >> send_discord.ps1
    echo $content = "<@$userId> %MESSAGE% (Repeat %%j - Time: %date% %time%)" >> send_discord.ps1
    echo. >> send_discord.ps1
    echo $payload = @{ >> send_discord.ps1
    echo     content = $content >> send_discord.ps1
    echo } | ConvertTo-Json >> send_discord.ps1
    echo. >> send_discord.ps1
    echo try { >> send_discord.ps1
    echo     Invoke-RestMethod -Uri $webhookUrl -Method Post -ContentType "application/json" -Body $payload >> send_discord.ps1
    echo     Write-Output "Discord notification sent successfully (repeat %%j)." >> send_discord.ps1
    echo } catch { >> send_discord.ps1
    echo     Write-Output "Error sending Discord notification: $_" >> send_discord.ps1
    echo } >> send_discord.ps1
    
    powershell -ExecutionPolicy Bypass -File send_discord.ps1
    del send_discord.ps1 2>nul
)

endlocal
goto :eof