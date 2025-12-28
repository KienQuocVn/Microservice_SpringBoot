# 🚀 Quick Start Guide - Khởi Động Nhanh

## Yêu Cầu Tiên Quyết

- Docker Desktop đang cài đặt và chạy
- Terminal/PowerShell
- Ít nhất 8GB RAM, 4GB để chạy Docker

## 1️⃣ Khởi Động Toàn Bộ Hệ Thống (3 Bước)

### Bước 1: Mở PowerShell
```powershell
cd D:\UIT\Co_So_Ha_Tang\Book
```

### Bước 2: Build tất cả Docker images
```powershell
docker-compose build
```
⏱️ Lần đầu tiên mất 5-15 phút (tùy vào tốc độ internet)

### Bước 3: Khởi động tất cả services
```powershell
docker-compose up -d
```

---

## 2️⃣ Kiểm Tra Status

```powershell
# Xem tất cả services
docker-compose ps

# Xem logs realtime
docker-compose logs -f
```

---

## 3️⃣ Truy Cập Ứng Dụng

| Dịch Vụ | URL | Mô Tả |
|---------|-----|-------|
| Web App | http://localhost:3000 | Frontend React |
| API Gateway | http://localhost:8888 | Entry point |
| Identity Service | http://localhost:8080 | Xác thực |
| Profile Service | http://localhost:8081 | Thông tin người dùng |
| Post Service | http://localhost:8083 | Bài viết |
| File Service | http://localhost:8084 | Quản lý file |
| Chat Service | http://localhost:8085 | Chat |
| Notification | http://localhost:8082 | Thông báo |

---

## 4️⃣ Dừng Tất Cả Services

```powershell
docker-compose down
```

---

## 🐛 Troubleshooting Nhanh

### Problem: Ports already in use
```powershell
# Windows - Tìm PID process dùng port
netstat -ano | findstr :8080
taskkill /PID <PID> /F
```

### Problem: Container không start
```powershell
# Xem chi tiết error
docker-compose logs identity-service

# Rebuild
docker-compose build --no-cache identity-service
docker-compose up -d identity-service
```

### Problem: Out of memory
Increase Docker memory:
- Docker Desktop → Settings → Resources → Memory (8GB+)

---

## 📝 Thường Xuyên Sử Dụng

```powershell
# Rebuild một service sau khi change code
docker-compose build identity-service
docker-compose up -d identity-service

# Tắt 1 service
docker-compose stop identity-service

# Khởi động lại 1 service
docker-compose up -d identity-service

# Xem logs chi tiết
docker-compose logs -f identity-service

# Dọn dẹp hoàn toàn (xóa containers, volumes)
docker-compose down -v
```

---

**Bạn đã sẵn sàng deploy! 🎉**

