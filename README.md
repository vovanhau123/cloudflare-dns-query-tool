# Cloudflare DNS Auto Updater
# Cloudflare DNS Auto Updater

[English](#english) | [Tiếng Việt](#vietnamese)

<a name="english"></a>
## English

### Overview
A Windows batch script that automatically updates your Cloudflare DNS records when your public IP address changes. This tool is useful for maintaining access to home servers or services when you have a dynamic IP address.
A Windows batch script that automatically updates your Cloudflare DNS records when your public IP address changes. This tool is useful for maintaining access to home servers or services when you have a dynamic IP address.

### Features
- Automatically detects changes in your public IP address
- Updates Cloudflare DNS A records when IP changes
- Runs continuously with configurable check intervals
- Logs all activities and changes
- Sends Discord notifications on errors or successful updates
- Includes repeated notifications for critical issues
- Automatically detects changes in your public IP address
- Updates Cloudflare DNS A records when IP changes
- Runs continuously with configurable check intervals
- Logs all activities and changes
- Sends Discord notifications on errors or successful updates
- Includes repeated notifications for critical issues

### Prerequisites
- Windows operating system
- Windows operating system
- PowerShell 5.1 or higher
- Cloudflare account with API token
- Cloudflare account with API token
- Zone ID for your domain
- Discord webhook URL (optional, for notifications)
- Discord webhook URL (optional, for notifications)

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

2. Save the file as `cloudflare_dns_updater.bat`

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

2. Save the file as `cloudflare_dns_updater.bat`

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

---

<a name="vietnamese"></a>
## Tiếng Việt

### Tổng quan
Script batch Windows tự động cập nhật bản ghi DNS Cloudflare khi địa chỉ IP công cộng của bạn thay đổi. Công cụ này hữu ích để duy trì quyền truy cập vào máy chủ hoặc dịch vụ tại nhà khi bạn có địa chỉ IP động.
Script batch Windows tự động cập nhật bản ghi DNS Cloudflare khi địa chỉ IP công cộng của bạn thay đổi. Công cụ này hữu ích để duy trì quyền truy cập vào máy chủ hoặc dịch vụ tại nhà khi bạn có địa chỉ IP động.

### Tính năng
- Tự động phát hiện thay đổi địa chỉ IP công cộng
- Cập nhật bản ghi DNS A của Cloudflare khi IP thay đổi
- Chạy liên tục với khoảng thời gian kiểm tra có thể cấu hình
- Ghi nhật ký tất cả hoạt động và thay đổi
- Gửi thông báo Discord khi có lỗi hoặc cập nhật thành công
- Bao gồm thông báo lặp lại cho các vấn đề quan trọng
- Tự động phát hiện thay đổi địa chỉ IP công cộng
- Cập nhật bản ghi DNS A của Cloudflare khi IP thay đổi
- Chạy liên tục với khoảng thời gian kiểm tra có thể cấu hình
- Ghi nhật ký tất cả hoạt động và thay đổi
- Gửi thông báo Discord khi có lỗi hoặc cập nhật thành công
- Bao gồm thông báo lặp lại cho các vấn đề quan trọng

### Yêu cầu
- Hệ điều hành Windows
- Hệ điều hành Windows
- PowerShell 5.1 trở lên
- Tài khoản Cloudflare với API token
- Zone ID cho tên miền của bạn
- Discord webhook URL (tùy chọn, cho thông báo)

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

2. Lưu tệp với tên `cloudflare_dns_updater.bat`

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
- Tài khoản Cloudflare với API token
- Zone ID cho tên miền của bạn
- Discord webhook URL (tùy chọn, cho thông báo)

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

2. Lưu tệp với tên `cloudflare_dns_updater.bat`

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