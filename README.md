# Cloudflare DNS Record Finder | Công cụ Truy vấn DNS Cloudflare

[English](#english) | [Tiếng Việt](#vietnamese)

<a name="english"></a>
## English

### Overview
A PowerShell script to query DNS records from Cloudflare API. This tool helps you find specific DNS records in your Cloudflare zones.

### Features
- Retrieve all DNS records from a Cloudflare zone
- Find specific A records by domain name
- Display DNS Record ID for further operations

### Prerequisites
- PowerShell 5.1 or higher
- Cloudflare account with API key
- Zone ID for your domain

### Usage
1. Update the variables at the beginning of the script with your information:
   ```powershell
   $email = "your-email@example.com"
   $apiKey = "your-api-key"
   $zoneID = "your-zone-id"
   $domainToFind = "Domain name" 
   ```
2. Run the script in PowerShell

### Security Note
⚠️ **Important**: Never commit your API keys directly in the script. Consider using environment variables or a secure configuration file instead.

### Example Implementation
```powershell
# Load configuration from secure file or environment variables
$email = $env:CLOUDFLARE_EMAIL
$apiKey = $env:CLOUDFLARE_API_KEY
$zoneID = $env:CLOUDFLARE_ZONE_ID
$domainToFind = "Domain name"

# Rest of the script remains the same
```

---

<a name="vietnamese"></a>
## Tiếng Việt

### Tổng quan
Script PowerShell để truy vấn bản ghi DNS từ API Cloudflare. Công cụ này giúp bạn tìm các bản ghi DNS cụ thể trong các zone Cloudflare của mình.

### Tính năng
- Lấy tất cả bản ghi DNS từ zone Cloudflare
- Tìm bản ghi A cụ thể theo tên miền
- Hiển thị ID bản ghi DNS để thực hiện các thao tác tiếp theo

### Yêu cầu
- PowerShell 5.1 trở lên
- Tài khoản Cloudflare với API key
- ID zone cho tên miền của bạn

### Cách sử dụng
1. Cập nhật các biến ở đầu script với thông tin của bạn:
   ```powershell
   $email = "your-email@example.com"
   $apiKey = "your-api-key"
   $zoneID = "your-zone-id"
   $domainToFind = "Domain name"
   ```
2. Chạy script trong PowerShell

### Lưu ý bảo mật
⚠️ **Quan trọng**: Không bao giờ commit API key trực tiếp trong script. Hãy cân nhắc sử dụng biến môi trường hoặc file cấu hình an toàn.

### Ví dụ triển khai
```powershell
# Tải cấu hình từ file an toàn hoặc biến môi trường
$email = $env:CLOUDFLARE_EMAIL
$apiKey = $env:CLOUDFLARE_API_KEY
$zoneID = $env:CLOUDFLARE_ZONE_ID
$domainToFind = "Domain name"

# Phần còn lại của script giữ nguyên
```
