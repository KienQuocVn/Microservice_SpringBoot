# 🧪 API Testing Guide

Hướng dẫn test các API của microservices.

---

## 🛠️ Công Cụ

### Sử dụng cURL (Command Line)
```powershell
curl http://localhost:8080/identity/health
```

### Sử dụng Postman/Insomnia
- Import collection từ Swagger docs
- Test requests trực tiếp

### Sử dụng Swagger UI
```
http://localhost:8080/identity/swagger-ui.html
```

---

## 📋 Danh Sách API

### Health Check Endpoints

```powershell
# API Gateway
curl http://localhost:8888/actuator/health

# Identity Service
curl http://localhost:8080/identity/actuator/health

# Profile Service
curl http://localhost:8081/profile/actuator/health

# Post Service
curl http://localhost:8083/post/actuator/health

# File Service
curl http://localhost:8084/file/actuator/health

# Chat Service
curl http://localhost:8085/chat/actuator/health

# Notification Service
curl http://localhost:8082/notification/actuator/health
```

### Identity Service APIs

```powershell
# Register user
curl -X POST http://localhost:8888/api/v1/identity/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "user1",
    "email": "user1@example.com",
    "password": "password123"
  }'

# Login
curl -X POST http://localhost:8888/api/v1/identity/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "user1",
    "password": "password123"
  }'

# Get user info
curl http://localhost:8888/api/v1/identity/users/1 \
  -H "Authorization: Bearer <token>"
```

### Profile Service APIs

```powershell
# Get profile
curl http://localhost:8888/api/v1/profile/users/1

# Update profile
curl -X PUT http://localhost:8888/api/v1/profile/users/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "bio": "Book lover"
  }'

# Get recommendations
curl http://localhost:8888/api/v1/profile/users/1/recommendations
```

### Post Service APIs

```powershell
# Create post
curl -X POST http://localhost:8888/api/v1/post/posts \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Great book",
    "content": "This book is amazing",
    "authorId": 1
  }'

# Get all posts
curl http://localhost:8888/api/v1/post/posts

# Get post by ID
curl http://localhost:8888/api/v1/post/posts/1

# Like post
curl -X POST http://localhost:8888/api/v1/post/posts/1/like \
  -H "Content-Type: application/json" \
  -d '{"userId": 1}'
```

### File Service APIs

```powershell
# Upload file
curl -X POST http://localhost:8888/api/v1/file/upload \
  -F "file=@path/to/file.pdf" \
  -H "Authorization: Bearer <token>"

# Download file
curl http://localhost:8888/api/v1/file/download/1 \
  -o downloaded_file.pdf

# Get file info
curl http://localhost:8888/api/v1/file/files/1
```

### Chat Service APIs

```powershell
# Send message
curl -X POST http://localhost:8888/api/v1/chat/messages \
  -H "Content-Type: application/json" \
  -d '{
    "senderId": 1,
    "receiverId": 2,
    "message": "Hello!"
  }'

# Get conversations
curl http://localhost:8888/api/v1/chat/conversations/1

# Get messages
curl http://localhost:8888/api/v1/chat/conversations/1/messages
```

### Notification Service APIs

```powershell
# Get notifications
curl http://localhost:8888/api/v1/notification/notifications/1

# Mark as read
curl -X PUT http://localhost:8888/api/v1/notification/notifications/1/read

# Send notification
curl -X POST http://localhost:8888/api/v1/notification/notifications \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "message": "New post from your friend"
  }'
```

---

## 🧪 Integration Testing Scenarios

### Scenario 1: Complete User Flow

```powershell
# 1. Register user
$registerResponse = curl -X POST http://localhost:8888/api/v1/identity/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "Test123!"
  }' -s

echo "Registered: $registerResponse"

# 2. Login
$loginResponse = curl -X POST http://localhost:8888/api/v1/identity/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "Test123!"
  }' -s

echo "Login response: $loginResponse"

# Extract token (depends on response format)
# $token = $loginResponse | ConvertFrom-Json | Select-Object -ExpandProperty token

# 3. Update profile
curl -X PUT http://localhost:8888/api/v1/profile/users/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $token" \
  -d '{
    "name": "Test User",
    "bio": "Love reading books"
  }' -s

# 4. Create post
curl -X POST http://localhost:8888/api/v1/post/posts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $token" \
  -d '{
    "title": "My Favorite Book",
    "content": "Just finished an amazing book!"
  }' -s

# 5. Like post
curl -X POST http://localhost:8888/api/v1/post/posts/1/like \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $token" \
  -d '{}' -s

# 6. Send message
curl -X POST http://localhost:8888/api/v1/chat/messages \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $token" \
  -d '{
    "receiverId": 2,
    "message": "Hi there!"
  }' -s

echo "Complete user flow tested successfully!"
```

---

## 📊 Load Testing

### Sử dụng Apache JMeter hoặc Artillery

```bash
# Install Artillery
npm install -g artillery

# Create load-test.yml
cat > load-test.yml << EOF
config:
  target: "http://localhost:8888"
  phases:
    - duration: 60
      arrivalRate: 10
      name: "Warm up"
    - duration: 120
      arrivalRate: 50
      name: "Ramp up"
    - duration: 60
      arrivalRate: 100
      name: "Spike"

scenarios:
  - name: "Test API Gateway"
    flow:
      - get:
          url: "/actuator/health"
      - get:
          url: "/api/v1/profile/users/1"
EOF

# Run load test
artillery run load-test.yml
```

---

## 🔍 Debugging Network Issues

### Check DNS Resolution

```powershell
# From your machine
nslookup identity-service

# From inside a container
docker exec identity-service nslookup profile-service
```

### Test Container Communication

```powershell
# From identity-service container
docker exec identity-service curl http://profile-service:8080/profile/actuator/health

# From api-gateway container
docker exec api-gateway curl http://identity-service:8080/identity/actuator/health
```

### Monitor Network

```powershell
# Check network details
docker network inspect book_microservice-network

# Monitor packets
docker exec identity-service tcpdump -i eth0
```

---

## ✅ Testing Checklist

- [ ] Health checks pass for all services
- [ ] API Gateway routing works
- [ ] Inter-service communication works
- [ ] Database connectivity verified
- [ ] Message queue (Kafka) working
- [ ] Load testing completed
- [ ] Error handling tested
- [ ] Performance acceptable

---

**Happy Testing! 🚀**

