# 📚 Bookteria - Microservices Demo Project

> **A Comprehensive Microservices Architecture Demo**  
> Demonstrating independent deployment, scalability, and resilience of microservices

![Architecture](Architecture.jpg)

---

## 📖 Mục Lục

- [Giới Thiệu](#-giới-thiệu)
- [Kiến Trúc Hệ Thống](#-kiến-trúc-hệ-thống)
- [Các Services](#-các-services)
- [Công Nghệ Sử Dụng](#-công-nghệ-sử-dụng)
- [Yêu Cầu Hệ Thống](#-yêu-cầu-hệ-thống)
- [Khởi Động Nhanh](#-khởi-động-nhanh)
- [Hướng Dẫn Chi Tiết](#-hướng-dẫn-chi-tiết)
- [Demo Scenarios](#-demo-scenarios)
- [Troubleshooting](#-troubleshooting)

---

## 🎯 Giới Thiệu

**Bookteria** là một dự án demo về kiến trúc **microservices** mô phỏng một mạng xã hội chia sẻ sách. 

### Mục Tiêu Demo

✅ **Chứng minh tính độc lập:** Tắt 1 service → các service khác vẫn hoạt động  
✅ **Chứng minh tính scalability:** Update/rebuild 1 service mà không ảnh hưởng toàn hệ thống  
✅ **Chứng minh tính resilience:** Services tự động restart khi bị crash  
✅ **Chứng minh communication:** Services giao tiếp qua network & message queue  

---

## 🏗️ Kiến Trúc Hệ Thống

### Sơ Đồ Tổng Quát

```
┌─────────────────────────────────────────────────────┐
│           Frontend (React Web App)                  │
│              Port: 3000                             │
└────────────────────┬────────────────────────────────┘
                     │ HTTP
┌────────────────────▼────────────────────────────────┐
│         API Gateway (Spring Cloud Gateway)          │
│              Port: 8888                             │
│  (Routing, Load Balancing, Rate Limiting)           │
└──────┬──────────┬─────────┬──────────┬──────────────┘
       │          │         │          │
   HTTP│      HTTP│    HTTP│       HTTP│
       │          │         │          │
   ┌───▼──┐  ┌───▼──┐  ┌──▼───┐  ┌──▼────┐
   │IDENTITY
   │:8080 │  │PROFILE
   │:8081 │  │ POST │  │ FILE │
   └─┬────┘  └──┬───┘  └──┬───┘  └──┬────┘
     │         │         │         │
┌────▼─────────▼────────┬┴──────────▼──────┐
│    Databases & Queues │                  │
│                       │                  │
│ MySQL | MongoDB | Neo4j | Kafka          │
└───────────────────────┴──────────────────┘
```

### Design Principles

- **Microservices Pattern:** Mỗi service độc lập
- **API Gateway Pattern:** Single entry point
- **Event-Driven Architecture:** Sử dụng Kafka message queue
- **Database per Service:** Mỗi service quản lý data riêng
- **Service Discovery:** Sử dụng Docker DNS

---

## 🔧 Các Services

### 1. **API Gateway** 
- **Port:** 8888
- **Chức Năng:** Entry point, routing, request transformation
- **Công Nghệ:** Spring Cloud Gateway
- **Routes to:** Tất cả các microservices

### 2. **Identity Service** 
- **Port:** 8080
- **Context Path:** `/identity`
- **Database:** MySQL
- **Chức Năng:** 
  - User authentication (JWT)
  - User registration & management
  - User profile management
- **Dependencies:** MySQL, Kafka

### 3. **Profile Service**
- **Port:** 8081
- **Context Path:** `/profile`
- **Database:** Neo4j (Graph Database)
- **Chức Năng:**
  - User profile information
  - Social connections (friend relationships)
  - User recommendations
- **Dependencies:** Neo4j

### 4. **Post Service**
- **Port:** 8083
- **Context Path:** `/post`
- **Database:** MySQL
- **Chức Năng:**
  - Create, read, update, delete posts
  - Post likes & comments
  - Feed management
- **Dependencies:** MySQL, Kafka

### 5. **File Service**
- **Port:** 8084
- **Context Path:** `/file`
- **Database:** MySQL
- **Chức Năng:**
  - File upload/download
  - Image optimization
  - File storage management
- **Dependencies:** MySQL, Kafka

### 6. **Chat Service**
- **Port:** 8085
- **Context Path:** `/chat`
- **Database:** MongoDB (NoSQL)
- **Chức Năng:**
  - Real-time messaging
  - Chat history
  - Message storage
- **Dependencies:** MongoDB

### 7. **Notification Service**
- **Port:** 8082
- **Context Path:** `/notification`
- **Database:** MySQL
- **Chức Năng:**
  - Push notifications
  - Email notifications
  - Notification history
- **Dependencies:** MySQL, Kafka

### 8. **Web App (Frontend)**
- **Port:** 3000
- **Framework:** React 18
- **Features:**
  - User authentication UI
  - Profile management
  - Post creation & viewing
  - File upload
  - Chat interface
  - Notification center

---

## 💻 Công Nghệ Sử Dụng

### Backend
- **Framework:** Spring Boot 3.2.5
- **Java Version:** 21
- **API Gateway:** Spring Cloud Gateway
- **Database:**
  - MySQL 8.0 (Relational Data)
  - MongoDB 8.0 (Document Data)
  - Neo4j 5.24 (Graph Data)
- **Message Queue:** Apache Kafka 3.7
- **Authentication:** JWT (Spring Security)
- **API Documentation:** Swagger/OpenAPI

### Frontend
- **Framework:** React 18
- **UI Library:** Material-UI (MUI)
- **HTTP Client:** Axios
- **Routing:** React Router v6
- **Build Tool:** Create React App

### DevOps & Deployment
- **Containerization:** Docker
- **Orchestration:** Docker Compose
- **Building:** Maven 3.9

---

## 🖥️ Yêu Cầu Hệ Thống

### Phần Cứng (Minimum)
- **CPU:** 4 cores
- **RAM:** 8GB (khuyến nghị 16GB)
- **Disk:** 20GB available space

### Phần Mềm
- **Docker Desktop:** v4.0+ (includes Docker Engine + Docker Compose)
  - [Download Windows](https://www.docker.com/products/docker-desktop)
- **Git:** v2.30+
- **PowerShell or Terminal**

### Kiểm Tra Cài Đặt
```powershell
docker --version          # Docker 24.0+
docker-compose --version  # Docker Compose 2.0+
```

---

## 🚀 Khởi Động Nhanh

### 3 Bước Đơn Giản

```powershell
# 1. Clone/Open project
cd D:\UIT\Co_So_Ha_Tang\Book

# 2. Build Docker images (first time: 5-15 minutes)
docker-compose build

# 3. Start all services
docker-compose up -d

# 4. Check status
docker-compose ps
```

### Truy Cập Ứng Dụng

- **Web App:** http://localhost:3000
- **API Gateway:** http://localhost:8888
- **Services Health:** http://localhost:8080/identity/actuator/health

---

## 📚 Hướng Dẫn Chi Tiết

### 📖 Quick Start Guide
Xem file [`QUICK_START.md`](./QUICK_START.md) để bắt đầu trong 5 phút.

### 📘 Docker Deployment Guide
Xem file [`DOCKER_DEPLOYMENT_GUIDE.md`](./DOCKER_DEPLOYMENT_GUIDE.md) để biết chi tiết đầy đủ về:
- Cài đặt Docker
- Build & Run containers
- Manage services
- Debugging & Logs
- Troubleshooting common issues
- Security best practices

---

## 🎬 Demo Scenarios

### Demo Independence of Microservices

Xem file [`DEMO_SCENARIOS.md`](./DEMO_SCENARIOS.md) cho hướng dẫn chi tiết về:

#### Scenario 1: Stop 1 Service → Others Still Running
```powershell
docker-compose stop identity-service
docker-compose ps                    # Các service khác vẫn "Up"
curl http://localhost:8888/actuator/health  # Gateway vẫn hoạt động
docker-compose up -d identity-service      # Khởi động lại
```

#### Scenario 2: Update Code → Rebuild Without Affecting Others
```powershell
# Sửa code identity-service
docker-compose build identity-service
docker-compose up -d identity-service
# Các services khác vẫn chạy bình thường
```

#### Scenario 3: Service Auto-Recovery
```powershell
docker kill identity-service
Start-Sleep -Seconds 5
docker-compose ps  # identity-service sẽ "Up" lại tự động
```

#### Scenario 4: Scaling & Load Balancing
```powershell
docker-compose up -d --scale post-service=3
```

---

## 📊 Services Communication Flow

### Synchronous (HTTP/REST)
```
Web App → API Gateway → Services → Services (Inter-service calls)
```

### Asynchronous (Event-Driven)
```
Service A → Kafka Topic → Service B (Event Publishing/Subscription)
```

### Example: User Registration Flow
```
1. Web App → API Gateway → Identity Service (POST /register)
2. Identity Service → MySQL (Save user)
3. Identity Service → Kafka Topic (UserCreated event)
4. Profile Service → Kafka (Listen UserCreated)
5. Profile Service → Neo4j (Create user node)
6. Notification Service → Kafka (Listen UserCreated)
7. Notification Service → Send welcome email
```

---

## 🔧 Các Lệnh Thường Sử Dụng

```powershell
# Viewing & Monitoring
docker-compose ps                    # Xem status tất cả services
docker-compose logs -f               # Xem logs realtime (tất cả)
docker-compose logs -f identity-service  # Logs của 1 service

# Managing Services
docker-compose up -d                 # Start all services
docker-compose down                  # Stop all services
docker-compose stop identity-service # Stop 1 service
docker-compose restart identity-service  # Restart 1 service

# Building & Updating
docker-compose build                 # Build tất cả images
docker-compose build identity-service    # Build 1 service
docker-compose up -d identity-service    # Restart with new image

# Cleaning Up
docker-compose down -v               # Stop & remove volumes
docker image prune -a                # Remove unused images
docker volume prune                  # Remove unused volumes
```

---

## 🐛 Troubleshooting

### Problem: Port Already in Use
```powershell
# Find process using port
netstat -ano | findstr :8080
# Kill process
taskkill /PID <PID> /F
```

### Problem: Container Won't Start
```powershell
# Check logs
docker-compose logs identity-service

# Rebuild
docker-compose build --no-cache identity-service
docker-compose up -d identity-service
```

### Problem: Out of Memory
Increase Docker memory in Docker Desktop Settings → Resources → Memory (8GB+)

### Problem: Database Connection Failed
```powershell
# Check database container
docker exec mysql mysql -u root -p12345 -e "SELECT 1;"
docker exec mongodb mongosh -u root -p root --authSource admin
```

---

## 📁 Project Structure

```
Book/
├── api-gateway/              # API Gateway (Spring Cloud Gateway)
│   ├── src/
│   ├── Dockerfile
│   ├── pom.xml
│   └── application-docker.yaml
├── identity-service/         # Authentication & User Management
│   ├── src/
│   ├── Dockerfile
│   ├── pom.xml
│   └── application-docker.yaml
├── profile-service/          # User Profiles (Neo4j)
├── post-service/             # Posts & Social Features
├── file-service/             # File Upload/Download
├── chat-service/             # Chat (MongoDB)
├── notification-service/     # Notifications
├── web-app/                  # React Frontend
├── docker-compose.yml        # Docker Compose Configuration
├── DOCKER_DEPLOYMENT_GUIDE.md    # Detailed deployment guide
├── DEMO_SCENARIOS.md         # Demo scripts & scenarios
├── QUICK_START.md            # Quick start (5 minutes)
├── .env.example              # Environment variables template
├── manage.bat                # Windows management script
└── README.md                 # This file
```

---

## 🎓 Key Learning Points

### Microservices Benefits Demonstrated

1. **Independence:** Mỗi service deploy riêng biệt
2. **Scalability:** Scale từng service theo nhu cầu
3. **Technology Flexibility:** Mỗi service dùng tech khác nhau
4. **Fault Isolation:** Service bị crash không affect others
5. **Team Autonomy:** Teams có thể work independently
6. **Rapid Development:** Deploy changes nhanh chóng

### How This Project Demonstrates Concepts

- **Service Independence:** `docker-compose stop` one service
- **Communication:** Services communicate via API Gateway & Kafka
- **Resilience:** Services auto-restart with `restart: unless-stopped`
- **Scalability:** Can rebuild/restart individual services
- **Containerization:** Each service in isolated Docker container
- **Orchestration:** Docker Compose manages multi-container application

---

## 🔐 Security Notes

⚠️ **WARNING:** Cấu hình này chỉ dành cho **DEMO/Development**

Đối với Production:
- ✅ Sử dụng strong passwords
- ✅ Implement proper secrets management
- ✅ Enable HTTPS/TLS
- ✅ Implement rate limiting
- ✅ Use API authentication & authorization
- ✅ Regular security scanning
- ✅ Use Kubernetes instead of Docker Compose

---

## 📞 Support & Resources

### Documentation Files
- [`QUICK_START.md`](./QUICK_START.md) - 5 minute quickstart
- [`DOCKER_DEPLOYMENT_GUIDE.md`](./DOCKER_DEPLOYMENT_GUIDE.md) - Complete guide
- [`DEMO_SCENARIOS.md`](./DEMO_SCENARIOS.md) - Demo scripts

### External Resources
- [Docker Documentation](https://docs.docker.com/)
- [Spring Boot Guides](https://spring.io/guides)
- [Microservices Patterns](https://microservices.io/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)

---

## 📝 Log Files & Debugging

### View all logs
```powershell
docker-compose logs -f
```

### View specific service logs
```powershell
docker-compose logs -f identity-service
```

### View logs with timestamps
```powershell
docker-compose logs -f --timestamps
```

### Access service shell
```powershell
docker exec -it identity-service bash
```

---

## 🚀 Next Steps for Production

1. **Kubernetes:** Migrate from Docker Compose to Kubernetes
2. **Service Mesh:** Implement Istio/Linkerd for advanced networking
3. **Monitoring:** Add Prometheus + Grafana for metrics
4. **Tracing:** Implement Jaeger for distributed tracing
5. **Logging:** Add ELK Stack (Elasticsearch + Logstash + Kibana)
6. **CI/CD:** Setup GitHub Actions / Jenkins for automation

---

## 📄 License

This project is for educational/demo purposes.

---

## 👨‍💻 Author

**DevTeria** - Microservices Architecture Demo  
Created for: Teaching & Presentation

---

**Ready to deploy? Let's go! 🚀**

**Bắt đầu:**
```powershell
cd D:\UIT\Co_So_Ha_Tang\Book
docker-compose build
docker-compose up -d
docker-compose ps
```

Truy cập: http://localhost:3000
