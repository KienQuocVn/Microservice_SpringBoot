# 📚 Hướng Dẫn Deploy Microservices với Docker Compose

**Tác giả:** DevTeria Microservices  
**Ngày cập nhật:** 2024  
**Mục đích:** Demo triển khai các microservices độc lập sử dụng Docker Compose

---

## 📋 Mục Lục

1. [Yêu Cầu Hệ Thống](#yêu-cầu-hệ-thống)
2. [Kiến Trúc Hệ Thống](#kiến-trúc-hệ-thống)
3. [Hướng Dẫn Cài Đặt](#hướng-dẫn-cài-đặt)
4. [Chạy Docker Compose](#chạy-docker-compose)
5. [Các Lệnh Quan Trọng](#các-lệnh-quan-trọng)
6. [Demo: Tắt/Khởi Động Services](#demo-tắtkhởi-động-services)
7. [Debugging & Logs](#debugging--logs)
8. [Khắc Phục Sự Cố](#khắc-phục-sự-cố)

---

## 🖥️ Yêu Cầu Hệ Thống

### Phần Cứng
- **CPU:** 4 cores trở lên (khuyến nghị 8 cores)
- **RAM:** Tối thiểu 8GB (khuyến nghị 16GB)
- **Disk:** Tối thiểu 20GB không gian trống

### Phần Mềm
1. **Docker Desktop** (version 4.0+)
   - [Tải Docker Desktop Windows](https://www.docker.com/products/docker-desktop)
   - Bao gồm Docker Engine và Docker Compose

2. **Git** (để clone project)
   - [Tải Git](https://git-scm.com/)

3. **Maven** (optional - nếu build cục bộ)
   - Version 3.8+
   - [Tải Maven](https://maven.apache.org/)

### Kiểm Tra Cài Đặt
```powershell
# Kiểm tra Docker
docker --version
docker-compose --version

# Kiểm tra docker daemon chạy
docker ps
```

---

## 🏗️ Kiến Trúc Hệ Thống

### Sơ Đồ Kiến Trúc

```
┌─────────────────────────────────────────────────────────────┐
│                     WEB APP (React)                         │
│                   Port: 3000                                │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│                   API GATEWAY                               │
│              Port: 8888                                     │
│  (Spring Cloud Gateway - Route requests to services)        │
└────────────────┬───────────┬────────┬───────────┬───────────┘
                 │           │        │           │
    ┌────────────▼─┐  ┌──────▼──┐   ┌─▼────────┐ └──────┐
    │  IDENTITY    │  │ PROFILE │   │   POST   │        │
    │  SERVICE     │  │ SERVICE │   │ SERVICE  │        │
    │  :8080       │  │ :8081   │   │  :8083   │        │
    └─────────────┬┘  └────┬────┘   └─┬────────┘   ┌─────▼──────┐
                  │         │          │            │   FILE     │
                  │         │          │            │  SERVICE   │
                  │         │          │            │   :8084    │
                  │         │          │            └────────────┘
          ┌───────▼─────────▼──────────▼──────┐
          │       SHARED DATABASES            │
          │  ┌─────────────┐  ┌─────────────┐ │
          │  │   MySQL     │  │  MongoDB    │ │
          │  │  :3307      │  │  :27017     │ │
          │  └─────────────┘  └─────────────┘ │
          │  ┌─────────────┐  ┌─────────────┐ │
          │  │  Neo4j      │  │   Kafka     │ │
          │  │  :7687      │  │  :9092      │ │
          │  └─────────────┘  └─────────────┘ │
          └─────────────────────────────────────┘
```

### Services và Ports

| Service | Container Name | Internal Port | External Port | Kiểu Database |
|---------|---|---|---|---|
| API Gateway | api-gateway | 8888 | 8888 | - |
| Identity Service | identity-service | 8080 | 8080 | MySQL |
| Profile Service | profile-service | 8081 | 8081 | Neo4j |
| Post Service | post-service | 8083 | 8083 | MySQL |
| File Service | file-service | 8084 | 8084 | MySQL |
| Chat Service | chat-service | 8085 | 8085 | MongoDB |
| Notification Service | notification-service | 8082 | 8082 | MySQL |
| Web App (React) | web-app | 3000 | 3000 | - |
| MySQL Database | mysql | 3306 | 3307 | - |
| MongoDB | mongodb | 27017 | 27017 | - |
| Neo4j | neo4j | 7687 | 7687 | - |
| Kafka | kafka | 9092 | 9092 | - |

---

## 🚀 Hướng Dẫn Cài Đặt

### Bước 1: Cài Đặt Docker Desktop

1. **Tải và cài đặt** Docker Desktop từ [docker.com](https://www.docker.com/products/docker-desktop)
2. **Khởi động** Docker Desktop
3. **Bật WSL2 backend** (Windows):
   - Mở PowerShell với quyền admin:
     ```powershell
     wsl --install
     wsl --set-default-version 2
     ```

### Bước 2: Clone Project

```powershell
# Mở PowerShell
cd D:\UIT\Co_So_Ha_Tang\Book

# Clone repository (nếu chưa có)
git clone <repository-url> .
```

### Bước 3: Kiểm Tra Cấu Trúc Project

```powershell
ls  # Kiểm tra xem có các thư mục service
```

Các thư mục quan trọng:
- `api-gateway/` - API Gateway (Spring Cloud Gateway)
- `identity-service/` - Xác thực & quản lý người dùng
- `profile-service/` - Quản lý profile người dùng
- `post-service/` - Quản lý bài viết
- `file-service/` - Quản lý file
- `chat-service/` - Chat service
- `notification-service/` - Thông báo
- `web-app/` - Frontend React
- `docker-compose.yml` - Cấu hình Docker Compose

---

## 🐳 Chạy Docker Compose

### Bước 1: Build Images

```powershell
# Đứng trong thư mục gốc project
cd D:\UIT\Co_So_Ha_Tang\Book

# Build tất cả images (lần đầu tiên sẽ mất 5-15 phút)
docker-compose build

# Hoặc build với --no-cache (nếu gặp vấn đề cache)
docker-compose build --no-cache
```

### Bước 2: Khởi Động Tất Cả Services

```powershell
# Khởi động tất cả services ở background
docker-compose up -d

# Hoặc chạy ở foreground (để xem logs realtime)
docker-compose up
```

### Bước 3: Kiểm Tra Services Đang Chạy

```powershell
# Liệt kê tất cả containers
docker-compose ps

# Kiểm tra logs tất cả services
docker-compose logs -f

# Kiểm tra logs của một service cụ thể
docker-compose logs -f identity-service
```

### Bước 4: Truy Cập Ứng Dụng

- **Web App:** http://localhost:3000
- **API Gateway:** http://localhost:8888
- **Identity Service:** http://localhost:8080/identity/swagger-ui.html (nếu có)

---

## 📝 Các Lệnh Quan Trọng

### Quản Lý Services

```powershell
# Khởi động tất cả services
docker-compose up -d

# Dừng tất cả services (nhưng giữ lại containers)
docker-compose stop

# Dừng và xóa tất cả containers
docker-compose down

# Dừng một service cụ thể
docker-compose stop identity-service

# Khởi động lại một service cụ thể
docker-compose restart identity-service

# Xem trạng thái services
docker-compose ps
```

### Xem Logs

```powershell
# Xem logs realtime của tất cả services
docker-compose logs -f

# Xem logs của một service cụ thể
docker-compose logs -f identity-service

# Xem logs của nhiều services
docker-compose logs -f identity-service profile-service

# Xem logs lịch sử (100 dòng cuối)
docker-compose logs --tail=100 identity-service
```

### Build lại Images

```powershell
# Build lại một service sau khi thay đổi code
docker-compose build identity-service
docker-compose up -d identity-service

# Build tất cả với --no-cache
docker-compose build --no-cache
```

### Xoá và Dọn Dẹp

```powershell
# Xóa tất cả containers nhưng giữ images
docker-compose down

# Xóa tất cả containers, volumes, networks
docker-compose down -v

# Xóa images
docker-compose down -v --rmi all

# Xóa unused images
docker image prune -a

# Xóa unused volumes
docker volume prune
```

---

## 🎯 Demo: Tắt/Khởi Động Services

### Tình Huống 1: Tắt 1 Service → Service Khác Vẫn Chạy

**Mục tiêu:** Chứng minh services độc lập, tắt identity-service không ảnh hưởng các services khác.

```powershell
# 1. Khởi động tất cả services
docker-compose up -d

# 2. Kiểm tra tất cả services chạy
docker-compose ps

# Output:
# NAME                    STATUS
# identity-service        Up 10 seconds
# profile-service         Up 10 seconds
# post-service            Up 10 seconds
# file-service            Up 10 seconds
# chat-service            Up 10 seconds
# notification-service    Up 10 seconds
# api-gateway             Up 10 seconds
# web-app                 Up 10 seconds
# mysql                   Up 20 seconds
# mongodb                 Up 20 seconds
# neo4j                   Up 20 seconds
# kafka                   Up 20 seconds

# 3. Tắt identity-service
docker-compose stop identity-service

# 4. Kiểm tra trạng thái
docker-compose ps

# Output: identity-service sẽ hiển thị "Exited (0)"
# Các services khác vẫn "Up"

# 5. Test API Gateway vẫn hoạt động
curl http://localhost:8888/api/v1/profile/users

# 6. Test gọi đến identity-service sẽ bị lỗi
curl http://localhost:8888/api/v1/identity/login

# 7. Khởi động lại identity-service
docker-compose up -d identity-service

# 8. Kiểm tra trạng thái
docker-compose ps
# identity-service sẽ "Up" lại
```

### Tình Huống 2: Update 1 Service → Không Ảnh Hưởng Service Khác

**Mục tiêu:** Chứng minh có thể rebuild 1 service mà không ảnh hưởng services khác.

```powershell
# 1. Sửa code trong identity-service
# Ví dụ: chỉnh sửa file src/main/java/...

# 2. Build lại image identity-service
docker-compose build identity-service

# 3. Khởi động lại service này
docker-compose up -d identity-service

# 4. Kiểm tra logs
docker-compose logs -f identity-service

# 5. Xác nhận các services khác vẫn chạy bình thường
docker-compose ps

# Output: Tất cả services khác vẫn "Up" và không bị interrupt
```

### Tình Huống 3: Test Service Resilience

```powershell
# 1. Xem logs realtime
docker-compose logs -f

# 2. Trong cửa sổ khác, tắt một service
docker-compose stop chat-service

# 3. Quan sát logs - các services khác không có lỗi

# 4. Khởi động lại chat-service
docker-compose up -d chat-service

# 5. Xem logs khôi phục
docker-compose logs -f chat-service
```

---

## 🔍 Debugging & Logs

### Xem Logs Chi Tiết

```powershell
# Logs realtime của tất cả services
docker-compose logs -f

# Logs của identity-service với 50 dòng cuối
docker-compose logs --tail=50 identity-service

# Logs có timestamp
docker-compose logs -f --timestamps identity-service

# Logs của multiple services
docker-compose logs -f identity-service profile-service post-service
```

### Truy Cập Container Bash

```powershell
# Vào bash của một container
docker exec -it identity-service bash

# Chạy lệnh trong container
docker exec identity-service ls -la /app

# Kiểm tra network connectivity
docker exec identity-service curl http://profile-service:8081/health
```

### Health Check

```powershell
# Kiểm tra health status
docker-compose ps

# Health check chi tiết
docker exec mysql mysql -u root -p12345 -e "SELECT 1;"

# Kiểm tra Kafka
docker exec kafka kafka-topics.sh --list --bootstrap-server localhost:9092

# Kiểm tra MongoDB
docker exec mongodb mongosh -u root -p root --authSource admin
```

### Network Debugging

```powershell
# Kiểm tra network các containers
docker network ls

# Kiểm tra chi tiết network
docker network inspect book_microservice-network

# Ping giữa containers
docker exec identity-service ping profile-service

# Test kết nối đến database
docker exec identity-service curl http://mysql:3306
```

---

## ⚙️ Khắc Phục Sự Cố

### Vấn Đề 1: Ports Đã Bị Sử Dụng

**Lỗi:** `Error response from daemon: Ports are not available: exposing port UDP 5353 failed`

**Giải Pháp:**
```powershell
# Tìm process sử dụng port
netstat -ano | findstr :8080

# Kill process (Windows)
taskkill /PID <PID> /F

# Hoặc change port trong docker-compose.yml
# Thay đổi "8080:8080" -> "8090:8080"
```

### Vấn Đề 2: Container Không Khởi Động

**Lỗi:** `Container exited with code 1`

**Giải Pháp:**
```powershell
# Xem logs chi tiết
docker-compose logs identity-service

# Rebuild image
docker-compose build --no-cache identity-service

# Khởi động lại
docker-compose up -d identity-service

# Check logs
docker-compose logs -f identity-service
```

### Vấn Đề 3: Database Connection Failed

**Lỗi:** `Unable to connect to database`

**Giải Pháp:**
```powershell
# Kiểm tra MySQL container
docker exec mysql mysql -u root -p12345 -e "SELECT 1;"

# Kiểm tra MongoDB
docker exec mongodb mongosh -u root -p root --authSource admin --eval "db.adminCommand('ping')"

# Kiểm tra Neo4j
docker exec neo4j cypher-shell -u neo4j -p 12345678

# Xem logs database
docker-compose logs mysql
docker-compose logs mongodb
```

### Vấn Đề 4: Out of Memory

**Lỗi:** Containers bị kill hoặc Docker Desktop crash

**Giải Pháp:**
```powershell
# Kiểm tra resource usage
docker stats

# Tăng memory cho Docker Desktop:
# Settings → Resources → Memory (tăng lên 8GB+)

# Dừng services không cần thiết
docker-compose stop search-service book-service mobile-app
```

### Vấn Đề 5: Network Connectivity Issues

**Lỗi:** Services không thể kết nối với nhau

**Giải Pháp:**
```powershell
# Kiểm tra network
docker network inspect book_microservice-network

# Restart network
docker-compose down
docker-compose up -d

# Test connectivity từ container
docker exec identity-service curl http://profile-service:8081/health
```

### Vấn Đề 6: Volume Permissions (Linux/Mac)

**Lỗi:** Permission denied khi read/write volumes

**Giải Pháp:**
```powershell
# Xóa volumes cũ
docker-compose down -v

# Tạo lại volumes
docker-compose up -d

# Hoặc fix permissions
docker exec -u root mysql chown -R mysql:mysql /var/lib/mysql
```

---

## 📊 Monitoring & Performance

### Real-time Monitoring

```powershell
# Xem CPU, Memory, Network usage
docker stats

# Xem stats của một container
docker stats identity-service

# Format output
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

### Database Management

```powershell
# MySQL - Access database
docker exec -it mysql mysql -u root -p12345

# MongoDB - Access database
docker exec -it mongodb mongosh -u root -p root --authSource admin

# Neo4j - Access database (localhost:7474)
# Username: neo4j
# Password: 12345678
```

---

## 🔐 Security Best Practices

### Sản Xuất (Production)

> **CẢNH BÁO:** Các cài đặt dưới đây chỉ dành cho **DEMO**. Không dùng trong production!

**Cần thay đổi:**
- ✅ Thay đổi tất cả default passwords (MySQL, MongoDB, Neo4j)
- ✅ Sử dụng environment variables từ `.env` file
- ✅ Disable debug mode
- ✅ Sử dụng HTTPS
- ✅ Implement rate limiting
- ✅ Sử dụng secrets management tools
- ✅ Regular security scanning

**Ví dụ `.env` file:**
```env
MYSQL_ROOT_PASSWORD=your_secure_password_here
MONGODB_ROOT_PASSWORD=your_secure_password_here
NEO4J_PASSWORD=your_secure_password_here
JWT_SIGNER_KEY=your_long_secure_key_here
```

---

## 📚 Tài Liệu Tham Khảo

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Spring Boot Docker Guide](https://spring.io/guides/gs/spring-boot-docker/)
- [Microservices Patterns](https://microservices.io/)

---

## 💬 Hỗ Trợ

Nếu gặp vấn đề:

1. **Kiểm tra logs:**
   ```powershell
   docker-compose logs -f
   ```

2. **Kiểm tra services đang chạy:**
   ```powershell
   docker-compose ps
   ```

3. **Dọn dẹp và khởi động lại:**
   ```powershell
   docker-compose down -v
   docker-compose up -d
   ```

4. **Check Docker Desktop:**
   - Đảm bảo Docker Desktop đang chạy
   - Kiểm tra Settings → Resources
   - Restart Docker Desktop nếu cần

---

**Chúc bạn triển khai thành công! 🚀**

