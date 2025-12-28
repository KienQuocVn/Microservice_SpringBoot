# 🎯 Demo Script: Microservices Independence

Hướng dẫn chi tiết để demo các tình huống menunjukkan tính độc lập của microservices.

---

## 📊 Tình Huống Demo 1: Tắt 1 Service → Services Khác Vẫn Chạy

**Mục tiêu:** Chứng minh rằng việc tắt 1 service không làm ảnh hưởng đến các services khác.

### Chuẩn Bị

1. Mở **2 tab PowerShell:**
   - Tab 1: Chạy các lệnh Docker
   - Tab 2: Monitor logs realtime

### Thực Hiện Demo

**Tab 2 - Bắt đầu monitor logs:**
```powershell
cd D:\UIT\Co_So_Ha_Tang\Book
docker-compose logs -f
```

**Tab 1 - Chạy các lệnh:**

```powershell
# Bước 1: Khởi động tất cả services
cd D:\UIT\Co_So_Ha_Tang\Book
docker-compose up -d

# Bước 2: Kiểm tra tất cả services chạy
docker-compose ps

# Kỳ vọng output:
# NAME                    STATUS
# identity-service        Up 30 seconds
# profile-service         Up 30 seconds
# post-service            Up 30 seconds
# file-service            Up 30 seconds
# chat-service            Up 30 seconds
# notification-service    Up 30 seconds
# api-gateway             Up 30 seconds
# web-app                 Up 30 seconds
# mysql                   Up 40 seconds
# mongodb                 Up 40 seconds
# neo4j                   Up 40 seconds
# kafka                   Up 40 seconds

# Bước 3: Kiểm tra API Gateway hoạt động
curl http://localhost:8888/actuator/health

# Kỳ vọng: {"status":"UP"}

# Bước 4: Test API call đến một service
curl http://localhost:8888/api/v1/profile/users

# Bước 5: Tắt identity-service
docker-compose stop identity-service

# Bước 6: Kiểm tra trạng thái ngay lập tức
docker-compose ps

# Kỳ vọng: identity-service sẽ hiển thị "Exited (0)"
# Tất cả services khác vẫn "Up"

# Bước 7: API Gateway vẫn hoạt động
curl http://localhost:8888/actuator/health

# Kỳ vọng: {"status":"UP"}

# Bước 8: Test API call đến profile-service vẫn work
curl http://localhost:8888/api/v1/profile/users

# Bước 9: Test API call đến identity-service sẽ fail
curl http://localhost:8888/api/v1/identity/login

# Kỳ vọng: Connection refused hoặc service unavailable
# Nhưng API Gateway vẫn chạy!

# Bước 10: Khởi động lại identity-service
docker-compose up -d identity-service

# Bước 11: Kiểm tra lại status
docker-compose ps

# Kỳ vọng: identity-service sẽ "Up" trở lại

# Bước 12: Test lại API call
curl http://localhost:8888/api/v1/identity/login

# Kỳ vọng: Thành công
```

### Kết Luận

✅ **Chứng minh thành công:**
- Tắt identity-service không làm crash API Gateway
- Tắt identity-service không làm ảnh hưởng các services khác (profile, post, file, chat)
- Các services khác vẫn có thể nhận request và respond
- Khởi động lại service sẽ hoạt động bình thường

---

## 🔄 Tình Huống Demo 2: Update Code 1 Service → Không Ảnh Hưởng Services Khác

**Mục tiêu:** Chứng minh rằng việc rebuild và deploy một service không làm gián đoạn các services khác.

### Chuẩn Bị

1. Mở **2 tab PowerShell:**
   - Tab 1: Chạy lệnh docker-compose
   - Tab 2: Monitor logs của identity-service

### Thực Hiện Demo

**Tab 2 - Monitor logs của identity-service:**
```powershell
cd D:\UIT\Co_So_Ha_Tang\Book
docker-compose logs -f identity-service
```

**Tab 1 - Chạy các lệnh:**

```powershell
# Bước 1: Khởi động tất cả services
cd D:\UIT\Co_So_Ha_Tang\Book
docker-compose up -d

# Bước 2: Kiểm tra status
docker-compose ps

# Bước 3: Tạo một file thay đổi nhỏ trong identity-service
# Ví dụ: sửa trong identity-service/src/main/resources/application-docker.yaml
# Hoặc change một log message trong code

# Bước 4: Build lại image của identity-service (không cần rebuild các services khác)
docker-compose build identity-service

# Kỳ vọng output:
# Building identity-service
# ...
# Successfully built abc123def456
# Successfully tagged book-identity-service:latest

# Bước 5: Kiểm tra status - tất cả services vẫn chạy
docker-compose ps

# Kỳ vọng: Tất cả services vẫn "Up"

# Bước 6: Khởi động lại chỉ identity-service
docker-compose up -d identity-service

# Kỳ vọng output:
# identity-service is up to date
# hoặc
# Recreating identity-service ... done

# Bước 7: Kiểm tra logs - identity-service startup
# (Trong Tab 2, sẽ thấy service restart và start up lại)

# Bước 8: Verify tất cả services vẫn chạy
docker-compose ps

# Kỳ vọng: Tất cả services vẫn "Up"

# Bước 9: Kiểm tra API Gateway vẫn hoạt động
curl http://localhost:8888/actuator/health

# Kỳ vọng: {"status":"UP"}

# Bước 10: Test API từ các services khác
curl http://localhost:8888/api/v1/profile/users
curl http://localhost:8888/api/v1/post/posts
curl http://localhost:8888/api/v1/file/files

# Kỳ vọng: Tất cả vẫn hoạt động bình thường
```

### Kết Luận

✅ **Chứng minh thành công:**
- Rebuild identity-service không ảnh hưởng đến các services khác
- Các services khác vẫn hoạt động trong quá trình rebuild
- Chỉ cần update code → build → restart single service
- Không cần restart toàn bộ hệ thống

---

## 🚨 Tình Huống Demo 3: Service Crash → Tự Động Restart

**Mục tiêu:** Chứng minh rằng docker-compose có thể tự động restart services khi bị crash.

### Chuẩn Bị

Mở PowerShell đơn lẻ để chạy các lệnh.

### Thực Hiện Demo

```powershell
# Bước 1: Khởi động tất cả services
cd D:\UIT\Co_So_Ha_Tang\Book
docker-compose up -d

# Bước 2: Kiểm tra status
docker-compose ps

# Bước 3: Simulate crash bằng cách kill một container
docker kill identity-service

# Bước 4: Kiểm tra status ngay lập tức
docker-compose ps

# Kỳ vọng: identity-service sẽ hiển thị "Exited (137)"

# Bước 5: Chờ 5-10 giây
Start-Sleep -Seconds 10

# Bước 6: Kiểm tra lại status
docker-compose ps

# Kỳ vọng: identity-service sẽ "Up" lại tự động!
# Điều này là nhờ "restart: unless-stopped" trong docker-compose.yml

# Bước 7: Kiểm tra logs để confirm nó đã restart
docker-compose logs --tail=20 identity-service
```

### Kết Luận

✅ **Chứng minh thành công:**
- Service bị crash tự động restart lại
- Điều này giúp ensure high availability
- Các services khác không bị ảnh hưởng

---

## 📈 Tình Huống Demo 4: Load Balancing & Scaling (Advanced)

**Mục tiêu:** Chứng minh có thể scale một service lên nhiều instances.

### Chuẩn Bị

Sửa docker-compose.yml để scale identity-service.

### Thực Hiện Demo

```powershell
# Bước 1: Scale identity-service lên 2 instances
docker-compose up -d --scale identity-service=2

# Kỳ vọng output sẽ có lỗi port conflict
# Vì Docker cần ports khác nhau cho mỗi instance

# Bước 2: Để scale work, cần remove fixed port mappings
# và để Docker assign ports tự động
# Hoặc sử dụng load balancer (nginx, HAProxy)

# Bước 3: Check containers running
docker-compose ps
```

---

## 🎬 Tình Huống Demo 5: Network Isolation & Container Communication

**Mục tiêu:** Chứng minh containers có thể communicate với nhau qua network.

### Thực Hiện Demo

```powershell
# Bước 1: Kiểm tra network được tạo
docker network ls

# Kỳ vọng: book_microservice-network sẽ listed

# Bước 2: Kiểm tra chi tiết network
docker network inspect book_microservice-network

# Kỳ vọng: Sẽ see tất cả containers connected to network

# Bước 3: Test communication giữa containers
docker exec identity-service curl http://profile-service:8080/profile/actuator/health

# Kỳ vọng: {"status":"UP"} hoặc tương tự

# Bước 4: Test communication từ 1 service đến database
docker exec identity-service curl http://mysql:3306

# Kỳ vọng: Connection hoặc error (nhưng connection work)

# Bước 5: Kiểm tra Kafka connectivity
docker exec kafka kafka-topics.sh --list --bootstrap-server localhost:9092

# Kỳ vọng: List các topics (nếu có)
```

### Kết Luận

✅ **Chứng minh thành công:**
- Containers trong Docker network có thể communicate với nhau
- Sử dụng container name như hostname (DNS resolution)
- Services có thể connect đến databases

---

## 📝 Demo Script Chạy Tất Cả

Để chạy toàn bộ demo từ đầu đến cuối:

```powershell
# Cleanup
docker-compose down -v

# Build
docker-compose build

# Start
docker-compose up -d

# Wait for services to be ready
Start-Sleep -Seconds 30

# Demo 1: Check status
docker-compose ps

# Demo 2: API Gateway health
curl http://localhost:8888/actuator/health

# Demo 3: Stop one service
docker-compose stop identity-service
Start-Sleep -Seconds 2
docker-compose ps

# Demo 4: API Gateway still works
curl http://localhost:8888/actuator/health

# Demo 5: Restart service
docker-compose up -d identity-service

# Demo 6: All services back
docker-compose ps

# Demo 7: Build one service
docker-compose build post-service
docker-compose up -d post-service

# Demo 8: All still running
docker-compose ps

echo "Demo completed! All scenarios demonstrated successfully."
```

---

## 💡 Key Insights to Highlight

1. **Independence:** Mỗi service chạy trong container riêng
2. **Isolation:** Tắt 1 service không affect services khác
3. **Scalability:** Có thể rebuild/restart services riêng lẻ
4. **Resilience:** Services tự động restart khi crash
5. **Communication:** Services communicate via Docker network
6. **Portability:** Cùng docker-compose file chạy ở bất kỳ đâu

---

## 🎓 Kết Quả Mong Đợi

Sau khi chạy các demos này, người xem sẽ hiểu:

✅ Microservices architecture cho phép independent deployment  
✅ Mỗi service có thể develop, test, deploy riêng biệt  
✅ Services communicate qua network, không cần shared resources  
✅ Có thể tắt/khởi động/update services mà không làm gián đoạn toàn bộ hệ thống  
✅ Docker Compose là công cụ hoàn hảo để demo microservices locally  
✅ Các concepts này mở đường cho Kubernetes ở production  

---

**Chúc bạn thuyết trình thành công! 🚀**

