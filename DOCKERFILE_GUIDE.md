# 🐳 Dockerfile Overview

Hướng dẫn chi tiết về các Dockerfile trong project.

---

## 📋 Dockerfile Structure

### Java Services Dockerfile

Tất cả Java services (identity-service, profile-service, post-service, file-service, chat-service, notification-service, api-gateway) sử dụng cùng một template:

```dockerfile
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Copy tất cả file cần thiết
COPY . .

# Build application using Maven
RUN chmod +x mvnw && ./mvnw clean package -DskipTests

# Expose port (default 8080)
EXPOSE 8080

# Run application
ENTRYPOINT ["java", "-jar", "target/*.jar"]
```

### Giải Thích

1. **Base Image:** `eclipse-temurin:21-jre-alpine`
   - JRE 21 (Java Runtime Environment)
   - Alpine Linux (lightweight, ~100MB)

2. **Working Directory:** `/app`
   - Nơi application sẽ chạy trong container

3. **Copy Files:** `COPY . .`
   - Copy toàn bộ source code vào container
   - Bao gồm pom.xml, mvnw, src/, etc.

4. **Build:** `./mvnw clean package -DskipTests`
   - Sử dụng Maven wrapper (mvnw)
   - Build jar file
   - Skip tests để nhanh hơn

5. **Expose:** `EXPOSE 8080`
   - Declare port (chỉ documentation, không bắt buộc)

6. **Run:** `ENTRYPOINT ["java", "-jar", "target/*.jar"]`
   - Chạy jar file khi container start

---

## 🐳 React Web App Dockerfile

```dockerfile
# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build React app
RUN npm run build

# Production stage
FROM node:18-alpine

WORKDIR /app

# Install serve (static file server)
RUN npm install -g serve

# Copy built app from builder stage
COPY --from=builder /app/build ./build

EXPOSE 3000

CMD ["serve", "-s", "build", "-l", "3000"]
```

### Giải Thích

1. **Multi-stage build:**
   - Stage 1 (builder): Build React app
   - Stage 2 (production): Serve built app

2. **Builder Stage:**
   - Install dependencies
   - Build optimized production bundle
   - Result: `/app/build` folder

3. **Production Stage:**
   - Lightweight Node.js Alpine image
   - Copy only the built app (not source)
   - Use `serve` to serve static files
   - Much smaller final image

3. **Benefits:**
   - Smaller image size (no node_modules, no source code)
   - Better security (no dev dependencies)
   - Faster startup

---

## 🔍 Building Dockerfiles

### Build Single Service

```powershell
cd identity-service
docker build -t book-identity-service:latest .

# Or
docker-compose build identity-service
```

### Build All Services

```powershell
docker-compose build

# With no cache (rebuild from scratch)
docker-compose build --no-cache
```

### Check Image Size

```powershell
docker images | grep book-

# Output:
# REPOSITORY                      TAG       SIZE
# book-identity-service           latest    200MB
# book-api-gateway                latest    190MB
# book-web-app                    latest    150MB
```

---

## 🐛 Dockerfile Optimization Tips

### 1. Use Alpine Images
```dockerfile
# Bad: ~800MB
FROM openjdk:17

# Good: ~150MB  
FROM eclipse-temurin:21-jre-alpine
```

### 2. Multi-stage Builds
```dockerfile
# Bad: Source code + dependencies = 500MB
FROM node:18
COPY . .
RUN npm install
RUN npm run build

# Good: Only production app = 100MB
FROM node:18 AS builder
COPY . .
RUN npm install && npm run build

FROM node:18-alpine
COPY --from=builder /app/build ./build
```

### 3. Minimize Layers
```dockerfile
# Bad: 3 layers
RUN apt-get update
RUN apt-get install -y curl
RUN rm -rf /var/lib/apt/lists/*

# Good: 1 layer
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
```

### 4. Cache Layer Ordering
```dockerfile
# Put frequently changing stuff at the end
FROM node:18-alpine
WORKDIR /app

# This rarely changes
COPY package*.json ./
RUN npm ci

# This changes often
COPY . .
RUN npm run build
```

---

## 🚀 Docker Build Commands

### Basic Build

```powershell
# Build from Dockerfile in current directory
docker build -t myapp:1.0 .

# Build with custom Dockerfile
docker build -f Dockerfile.prod -t myapp:prod .

# Build with build arguments
docker build --build-arg JAVA_VERSION=21 -t myapp .
```

### Advanced Build Options

```powershell
# No cache (rebuild everything)
docker build --no-cache -t myapp .

# Progress output
docker build --progress=plain -t myapp .

# Build for multiple platforms
docker buildx build --platform linux/amd64,linux/arm64 -t myapp .

# Squash layers (reduce image size)
docker build --squash -t myapp .
```

### View Build Output

```powershell
# Verbose output
docker build --progress=plain -t myapp .

# Check each layer
docker history myapp:latest
```

---

## 📊 Docker Image Analysis

### List Layers

```powershell
docker history book-identity-service:latest
```

Output:
```
IMAGE          CREATED        CREATED BY                                      SIZE
abc123...      5 minutes ago  /bin/sh -c #(nop)  ENTRYPOINT ["java" "-jar"…  0B
def456...      5 minutes ago  /bin/sh -c #(nop)  EXPOSE 8080                 0B
ghi789...      5 minutes ago  /bin/sh -c chmod +x mvnw && ./mvnw clean …     200MB
jkl012...      6 minutes ago  /bin/sh -c #(nop) COPY dir:abc in /app          5MB
mno345...      1 hour ago     /bin/sh -c #(nop)  WORKDIR /app                 0B
pqr678...      1 hour ago     /bin/sh -c #(nop)  FROM eclipse-temurin:21…    200MB
```

### Inspect Image

```powershell
docker inspect book-identity-service:latest

# Get specific info
docker inspect --format='{{json .Config.Env}}' book-identity-service:latest
```

### Find Large Layers

```powershell
docker history --no-trunc book-identity-service:latest | sort -k5 -h
```

---

## 🔐 Security Best Practices

### 1. Use Non-root User

```dockerfile
FROM eclipse-temurin:21-jre-alpine

# Create non-root user
RUN addgroup -g 1001 appgroup && \
    adduser -D -u 1001 -G appgroup appuser

WORKDIR /app
COPY . .
RUN ./mvnw clean package -DskipTests

# Switch to non-root user
USER appuser:appgroup

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "target/*.jar"]
```

### 2. Health Checks

```dockerfile
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app
COPY . .
RUN ./mvnw clean package -DskipTests && \
    apt-get update && apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "target/*.jar"]
```

### 3. Scan for Vulnerabilities

```powershell
# Using Trivy
trivy image book-identity-service:latest

# Using Docker Scout
docker scout cves book-identity-service:latest
```

---

## 📦 Dockerfile Locations

```
Book/
├── api-gateway/
│   └── Dockerfile              # API Gateway
├── identity-service/
│   └── Dockerfile              # Identity Service
├── profile-service/
│   └── Dockerfile              # Profile Service
├── post-service/
│   └── Dockerfile              # Post Service
├── file-service/
│   └── Dockerfile              # File Service
├── chat-service/
│   └── Dockerfile              # Chat Service
├── notification-service/
│   └── Dockerfile              # Notification Service
├── web-app/
│   └── Dockerfile              # React Frontend
└── docker-compose.yml          # Docker Compose config
```

---

## 🔧 Troubleshooting Dockerfiles

### Problem: Build Fails

```powershell
# Check build logs
docker build --progress=plain -t myapp .

# Use buildkit for better error messages
$env:DOCKER_BUILDKIT=1
docker build -t myapp .
```

### Problem: Image Too Large

```powershell
# Check layer sizes
docker history myapp:latest

# Solutions:
# 1. Use Alpine base image
# 2. Use multi-stage builds
# 3. Remove build dependencies
# 4. Clean up package manager cache
```

### Problem: Container Won't Start

```powershell
# Check error
docker logs <container-id>

# Run interactively for debugging
docker run -it myapp:latest bash
```

---

## 📝 Example: Optimized Spring Boot Dockerfile

```dockerfile
# ============== BUILDER STAGE ==============
FROM eclipse-temurin:21-maven:latest AS builder

WORKDIR /build

# Copy pom.xml and fetch dependencies (cached layer)
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy source and build
COPY src ./src
RUN mvn clean package -DskipTests

# ============== RUNTIME STAGE ==============
FROM eclipse-temurin:21-jre-alpine

# Install curl for health checks
RUN apk add --no-cache curl

# Create non-root user
RUN addgroup -g 1001 appgroup && \
    adduser -D -u 1001 -G appgroup appuser

WORKDIR /app

# Copy jar from builder
COPY --from=builder /build/target/*.jar app.jar

# Set ownership
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser:appgroup

EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
```

---

## 🎯 Key Takeaways

✅ Sử dụng Alpine images để reduce size  
✅ Sử dụng multi-stage builds  
✅ Cache dependencies layer  
✅ Put changing content at the end  
✅ Use non-root user cho security  
✅ Add health checks  
✅ Keep images lean and focused  
✅ Scan images for vulnerabilities  

---

**Happy Containerizing! 🐳**

