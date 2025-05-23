# Hướng dẫn cài đặt WebDatSanPickleBall

## Yêu cầu hệ thống
- .NET 8.0 SDK
- SQL Server (hoặc SQL Server Express)
- Visual Studio 2022 (hoặc Visual Studio Code)

## Các bước cài đặt

### 1. Giải nén file zip
- Giải nén file `DatSanPickleBall.zip` vào thư mục mong muốn.

### 2. Cấu hình database
- Mở file `appsettings.json` trong thư mục `WebDatSanPickleBall`
- Cập nhật connection string với thông tin database của bạn:

"ConnectionStrings": {
    "DefaultConnection": "Server=YOUR_SERVER;Database=DatSanPickleBall;Trusted_Connection=True;TrustServerCertificate=True;"
}

### 3. Xóa migration cũ
- Xóa thư mục `Migrations` trong thư mục `DAL`

### 4. Tạo migration mới
- Mở Package Manager Console (PM) trong Visual Studio
- Chạy lệnh: Add-Migration InitialCreate

### 5. Tạo database và chạy migrations
- Mở Package Manager Console (PM) trong Visual Studio
- Chạy lệnh: Update-Database

## Tài khoản mặc định
- Email: admin@datsanpickleball.com
- Password: Admin@123
