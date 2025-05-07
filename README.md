# Cloudflare DNS Auto Updater

[English](#english) | [Tiếng Việt](#vietnamese)

<a name="english"></a>
## English

### Overview
A Windows batch script that automatically updates your Cloudflare DNS records when your public IP address changes. This tool is useful for maintaining access to home servers or services when you have a dynamic IP address.

> 💻 **Note:** The primary script (`cloudflare-dns-finder.bat`) is designed for Windows. See the [Cross-Platform Usage](#cross-platform) section for running on Linux or macOS.

### Features
- Automatically detects changes in your public IP address
- Updates Cloudflare DNS A records when IP changes
- Runs continuously with configurable check intervals
- Logs all activities and changes
- Sends Discord notifications on errors or successful updates
- Includes repeated notifications for critical issues

### Important Note
> ⚠️ **WARNING:** This script is designed for **dynamic IP addresses only**. It will not work correctly with static IP configurations.

#### Dynamic vs Static IP
- **Dynamic IP:** An IP address that changes periodically, typically assigned by your ISP. Common on:
  - Home internet connections
  - Residential broadband
  - Mobile hotspots
  - Most consumer routers

- **Static IP:** A fixed IP address that doesn't change. Common on:
  - Business internet connections
  - Dedicated servers
  - Enterprise networks
  - Some premium ISP packages

### Prerequisites
- Windows operating system
- PowerShell 5.1 or higher
- Cloudflare account with API token
- Zone ID for your domain
- Discord webhook URL (optional, for notifications)
- **Dynamic IP address** (not static)

### Setup
1. Edit the configuration section at the beginning of the script:
   ```batch
   rem === Configuration Information ===
   set ZONE_ID=your-zone-id                REM Zone ID CloudFlare of the domain itself that you want to automatically change
   set DOMAIN=your-domain.com              REM Domain CloudFlare that you want to check and change
   set API_TOKEN=your-api-token            REM API token of CloudFlare's DNS itself
   set CHECK_INTERVAL=900                  REM The number of seconds to check DNS
   set LOG_FILE=dns_updater.log            REM Log file name
   set DISCORD_WEBHOOK=your-webhook-url    REM Webhook discord URL
   set DISCORD_USER_ID=your-user-id        REM Users id tag for notifications
   set DISCORD_NOTIFY_INTERVAL=5           REM Seconds to wait between user tags via webhook discord
   ```

2. Save the file as `cloudflare-dns-finder.bat`

3. Run the script by double-clicking or from command prompt

### Configuration Options
- `ZONE_ID`: Your Cloudflare Zone ID
- `DOMAIN`: The domain name to update
- `API_TOKEN`: Your Cloudflare API token with DNS edit permissions
- `CHECK_INTERVAL`: Time between checks in seconds (default: 900 = 15 minutes)
- `LOG_FILE`: Name of the log file
- `DISCORD_WEBHOOK`: Discord webhook URL for notifications
- `DISCORD_USER_ID`: Discord user ID to mention in notifications
- `DISCORD_NOTIFY_INTERVAL`: Time between repeated notifications in seconds

### Security Note
⚠️ **Important**: Never share your API token. Consider using environment variables for sensitive information in production environments.

### How It Works
1. The script checks your current public IP address using ipify.org
2. It retrieves the current DNS record from Cloudflare
3. If the IP addresses don't match, it updates the Cloudflare DNS record
4. The script logs all actions and sends notifications if configured
5. It sleeps for the configured interval before checking again

### Troubleshooting
- Check the log file for detailed error messages
- Ensure your API token has the correct permissions
- Verify your Zone ID and domain name are correct
- Make sure your system can access the internet and Cloudflare's API

<a name="cross-platform"></a>
### Cross-Platform Usage
While the original script is a Windows batch file, you can run similar functionality on other operating systems:

#### Linux Version
Create a shell script (`cloudflare-dns-finder.sh`):

```bash
#!/bin/bash

# === Configuration Information ===
ZONE_ID="your-zone-id"         # Zone ID CloudFlare of the domain
DOMAIN="your-domain.com"       # Domain CloudFlare to check and change
API_TOKEN="your-api-token"     # API token of CloudFlare's DNS
CHECK_INTERVAL=900             # Seconds between checks
LOG_FILE="dns_updater.log"     # Log file name
DISCORD_WEBHOOK="your-url"     # Discord webhook URL
DISCORD_USER_ID="your-id"      # Discord user ID
DISCORD_NOTIFY_INTERVAL=5      # Seconds between notifications

# Function to log messages
log_message() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
  echo "$1"
}

# Function to send Discord notifications
send_discord() {
  if [ -n "$DISCORD_WEBHOOK" ]; then
    curl -H "Content-Type: application/json" \
      -d "{\"content\":\"<@$DISCORD_USER_ID> $1\"}" \
      "$DISCORD_WEBHOOK"
  fi
}

# Main loop
while true; do
  # Get current public IP
  CURRENT_IP=$(curl -s https://api.ipify.org)
  
  if [ -z "$CURRENT_IP" ]; then
    log_message "ERROR: Could not retrieve current IP address"
    send_discord "ERROR: Could not retrieve current IP address"
    sleep "$CHECK_INTERVAL"
    continue
  fi
  
  # Get current DNS record
  DNS_RECORD=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A&name=$DOMAIN" \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Content-Type: application/json")
  
  RECORD_ID=$(echo "$DNS_RECORD" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
  DNS_IP=$(echo "$DNS_RECORD" | grep -o '"content":"[^"]*"' | head -1 | cut -d'"' -f4)
  
  if [ -z "$RECORD_ID" ]; then
    log_message "ERROR: Could not retrieve DNS record ID"
    send_discord "ERROR: Could not retrieve DNS record ID"
    sleep "$CHECK_INTERVAL"
    continue
  fi
  
  # Update DNS if IP has changed
  if [ "$CURRENT_IP" != "$DNS_IP" ]; then
    log_message "IP changed: $DNS_IP -> $CURRENT_IP"
    
    UPDATE_RESULT=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
      -H "Authorization: Bearer $API_TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"type\":\"A\",\"name\":\"$DOMAIN\",\"content\":\"$CURRENT_IP\",\"ttl\":1,\"proxied\":false}")
    
    SUCCESS=$(echo "$UPDATE_RESULT" | grep -o '"success":[^,]*' | cut -d':' -f2)
    
    if [ "$SUCCESS" = "true" ]; then
      log_message "DNS record updated successfully"
      send_discord "DNS record updated successfully: $DOMAIN now points to $CURRENT_IP"
    else
      log_message "ERROR: Failed to update DNS record"
      send_discord "ERROR: Failed to update DNS record"
    fi
  else
    log_message "IP unchanged: $CURRENT_IP"
  fi
  
  sleep "$CHECK_INTERVAL"
done
```

Make it executable:
```
chmod +x cloudflare-dns-finder.sh
```

Run it:
```
./cloudflare-dns-finder.sh
```

For background execution:
```
nohup ./cloudflare-dns-finder.sh &
```

#### macOS Version
The Linux script above will work on macOS as well. Additionally, you can create a launchd service:

1. Create the shell script as shown above
2. Create a plist file in `~/Library/LaunchAgents/com.user.cloudflareupdater.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.cloudflareupdater</string>
    <key>ProgramArguments</key>
    <array>
        <string>/path/to/cloudflare-dns-finder.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>/tmp/cloudflare-updater.err</string>
    <key>StandardOutPath</key>
    <string>/tmp/cloudflare-updater.out</string>
</dict>
</plist>
```

3. Load the service:
```
launchctl load ~/Library/LaunchAgents/com.user.cloudflareupdater.plist
```

---

<a name="vietnamese"></a>
## Tiếng Việt

### Tổng quan
Script batch Windows tự động cập nhật bản ghi DNS Cloudflare khi địa chỉ IP công cộng của bạn thay đổi. Công cụ này hữu ích để duy trì quyền truy cập vào máy chủ hoặc dịch vụ tại nhà khi bạn có địa chỉ IP động.

> 💻 **Lưu ý:** Script chính (`cloudflare-dns-finder.bat`) được thiết kế cho Windows. Xem phần [Sử dụng đa nền tảng](#su-dung-da-nen-tang) để chạy trên Linux hoặc macOS.

### Tính năng
- Tự động phát hiện thay đổi địa chỉ IP công cộng
- Cập nhật bản ghi DNS A của Cloudflare khi IP thay đổi
- Chạy liên tục với khoảng thời gian kiểm tra có thể cấu hình
- Ghi nhật ký tất cả hoạt động và thay đổi
- Gửi thông báo Discord khi có lỗi hoặc cập nhật thành công
- Bao gồm thông báo lặp lại cho các vấn đề quan trọng

### Lưu ý quan trọng
> ⚠️ **CẢNH BÁO:** Script này chỉ được thiết kế cho **địa chỉ IP động**. Nó sẽ không hoạt động chính xác với cấu hình IP tĩnh.

#### IP động và IP tĩnh
- **IP động:** Địa chỉ IP thay đổi định kỳ, thường được cấp bởi nhà cung cấp dịch vụ internet (ISP). Thường thấy trên:
  - Kết nối internet hộ gia đình
  - Băng thông rộng dân cư
  - Điểm phát sóng di động
  - Hầu hết bộ định tuyến tiêu dùng

- **IP tĩnh:** Địa chỉ IP cố định không thay đổi. Thường thấy trên:
  - Kết nối internet doanh nghiệp
  - Máy chủ chuyên dụng
  - Mạng doanh nghiệp
  - Một số gói ISP cao cấp

### Yêu cầu
- Hệ điều hành Windows
- PowerShell 5.1 trở lên
- Tài khoản Cloudflare với API token
- Zone ID cho tên miền của bạn
- Discord webhook URL (tùy chọn, cho thông báo)
- **Địa chỉ IP động** (không phải IP tĩnh)

### Cài đặt
1. Chỉnh sửa phần cấu hình ở đầu script:
   ```batch
   rem === Thông tin cấu hình ===
   set ZONE_ID=your-zone-id                REM Zone ID CloudFlare của tên miền mà bạn muốn tự động thay đổi
   set DOMAIN=your-domain.com              REM Tên miền CloudFlare mà bạn muốn kiểm tra và thay đổi
   set API_TOKEN=your-api-token            REM API token của DNS CloudFlare
   set CHECK_INTERVAL=900                  REM Số giây giữa các lần kiểm tra DNS
   set LOG_FILE=dns_updater.log            REM Tên tệp nhật ký
   set DISCORD_WEBHOOK=your-webhook-url    REM URL webhook Discord
   set DISCORD_USER_ID=your-user-id        REM ID người dùng để gắn thẻ trong thông báo
   set DISCORD_NOTIFY_INTERVAL=5           REM Số giây chờ giữa các lần gắn thẻ người dùng qua webhook Discord
   ```

2. Lưu tệp với tên `cloudflare-dns-finder.bat`

3. Chạy script bằng cách nhấp đúp hoặc từ dòng lệnh

### Tùy chọn cấu hình
- `ZONE_ID`: Zone ID Cloudflare của bạn
- `DOMAIN`: Tên miền cần cập nhật
- `API_TOKEN`: API token Cloudflare với quyền chỉnh sửa DNS
- `CHECK_INTERVAL`: Thời gian giữa các lần kiểm tra tính bằng giây (mặc định: 900 = 15 phút)
- `LOG_FILE`: Tên của tệp nhật ký
- `DISCORD_WEBHOOK`: URL webhook Discord cho thông báo
- `DISCORD_USER_ID`: ID người dùng Discord để đề cập trong thông báo
- `DISCORD_NOTIFY_INTERVAL`: Thời gian giữa các thông báo lặp lại tính bằng giây

### Lưu ý bảo mật
⚠️ **Quan trọng**: Không bao giờ chia sẻ API token của bạn. Hãy cân nhắc sử dụng biến môi trường cho thông tin nhạy cảm trong môi trường sản xuất.

### Cách thức hoạt động
1. Script kiểm tra địa chỉ IP công cộng hiện tại của bạn sử dụng ipify.org
2. Nó truy xuất bản ghi DNS hiện tại từ Cloudflare
3. Nếu địa chỉ IP không khớp, nó sẽ cập nhật bản ghi DNS Cloudflare
4. Script ghi lại tất cả các hành động và gửi thông báo nếu được cấu hình
5. Nó chờ trong khoảng thời gian được cấu hình trước khi kiểm tra lại

### Xử lý sự cố
- Kiểm tra tệp nhật ký để biết thông báo lỗi chi tiết
- Đảm bảo API token của bạn có đúng quyền
- Xác minh Zone ID và tên miền của bạn là chính xác
- Đảm bảo hệ thống của bạn có thể truy cập internet và API của Cloudflare

<a name="su-dung-da-nen-tang"></a>
### Sử dụng đa nền tảng
Mặc dù script gốc là tệp batch Windows, bạn có thể chạy chức năng tương tự trên các hệ điều hành khác:

#### Phiên bản Linux
Tạo script shell (`cloudflare-dns-finder.sh`):

```bash
#!/bin/bash

# === Thông tin cấu hình ===
ZONE_ID="your-zone-id"         # Zone ID CloudFlare của tên miền
DOMAIN="your-domain.com"       # Tên miền CloudFlare cần kiểm tra và thay đổi
API_TOKEN="your-api-token"     # API token của CloudFlare DNS
CHECK_INTERVAL=900             # Số giây giữa các lần kiểm tra
LOG_FILE="dns_updater.log"     # Tên tệp nhật ký
DISCORD_WEBHOOK="your-url"     # URL webhook Discord
DISCORD_USER_ID="your-id"      # ID người dùng Discord
DISCORD_NOTIFY_INTERVAL=5      # Số giây giữa các thông báo

# Hàm ghi nhật ký
log_message() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
  echo "$1"
}

# Hàm gửi thông báo Discord
send_discord() {
  if [ -n "$DISCORD_WEBHOOK" ]; then
    curl -H "Content-Type: application/json" \
      -d "{\"content\":\"<@$DISCORD_USER_ID> $1\"}" \
      "$DISCORD_WEBHOOK"
  fi
}

# Vòng lặp chính
while true; do
  # Lấy địa chỉ IP công cộng hiện tại
  CURRENT_IP=$(curl -s https://api.ipify.org)
  
  if [ -z "$CURRENT_IP" ]; then
    log_message "LỖI: Không thể lấy địa chỉ IP hiện tại"
    send_discord "LỖI: Không thể lấy địa chỉ IP hiện tại"
    sleep "$CHECK_INTERVAL"
    continue
  fi
  
  # Lấy bản ghi DNS hiện tại
  DNS_RECORD=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A&name=$DOMAIN" \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Content-Type: application/json")
  
  RECORD_ID=$(echo "$DNS_RECORD" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
  DNS_IP=$(echo "$DNS_RECORD" | grep -o '"content":"[^"]*"' | head -1 | cut -d'"' -f4)
  
  if [ -z "$RECORD_ID" ]; then
    log_message "LỖI: Không thể lấy ID bản ghi DNS"
    send_discord "LỖI: Không thể lấy ID bản ghi DNS"
    sleep "$CHECK_INTERVAL"
    continue
  fi
  
  # Cập nhật DNS nếu IP đã thay đổi
  if [ "$CURRENT_IP" != "$DNS_IP" ]; then
    log_message "IP đã thay đổi: $DNS_IP -> $CURRENT_IP"
    
    UPDATE_RESULT=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
      -H "Authorization: Bearer $API_TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"type\":\"A\",\"name\":\"$DOMAIN\",\"content\":\"$CURRENT_IP\",\"ttl\":1,\"proxied\":false}")
    
    SUCCESS=$(echo "$UPDATE_RESULT" | grep -o '"success":[^,]*' | cut -d':' -f2)
    
    if [ "$SUCCESS" = "true" ]; then
      log_message "Đã cập nhật bản ghi DNS thành công"
      send_discord "Đã cập nhật bản ghi DNS thành công: $DOMAIN giờ trỏ đến $CURRENT_IP"
    else
      log_message "LỖI: Không thể cập nhật bản ghi DNS"
      send_discord "LỖI: Không thể cập nhật bản ghi DNS"
    fi
  else
    log_message "IP không thay đổi: $CURRENT_IP"
  fi
  
  sleep "$CHECK_INTERVAL"
done
```

Làm cho nó có thể thực thi:
```
chmod +x cloudflare-dns-finder.sh
```

Chạy nó:
```
./cloudflare-dns-finder.sh
```

Để chạy ở chế độ nền:
```
nohup ./cloudflare-dns-finder.sh &
```

#### Phiên bản macOS
Script Linux ở trên cũng hoạt động trên macOS. Ngoài ra, bạn có thể tạo dịch vụ launchd:

1. Tạo script shell như đã nêu ở trên
2. Tạo tệp plist trong `~/Library/LaunchAgents/com.user.cloudflareupdater.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.cloudflareupdater</string>
    <key>ProgramArguments</key>
    <array>
        <string>/path/to/cloudflare-dns-finder.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>/tmp/cloudflare-updater.err</string>
    <key>StandardOutPath</key>
    <string>/tmp/cloudflare-updater.out</string>
</dict>
</plist>
```

3. Tải dịch vụ:
```
launchctl load ~/Library/LaunchAgents/com.user.cloudflareupdater.plist
```
