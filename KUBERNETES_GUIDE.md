# ☸️ Kubernetes Deployment Guide (Advanced)

> **Note:** Hướng dẫn này dành cho những ai muốn deploy lên Kubernetes (production-ready)

---

## 📚 Mục Lục

1. [Giới Thiệu Kubernetes](#-giới-thiệu-kubernetes)
2. [So Sánh Docker Compose vs Kubernetes](#-so-sánh-docker-compose-vs-kubernetes)
3. [Chuẩn Bị](#-chuẩn-bị)
4. [Deployment on Kubernetes](#-deployment-on-kubernetes)
5. [Monitoring & Logging](#-monitoring--logging)

---

## ☸️ Giới Thiệu Kubernetes

### Tại Sao Kubernetes?

**Docker Compose:** Tốt cho development/demo nhưng không phù hợp production vì:
- ❌ Không auto-scaling
- ❌ Không self-healing
- ❌ Không rolling updates
- ❌ Không service discovery advanced
- ❌ Không multi-node

**Kubernetes:** Perfect cho production vì:
- ✅ Auto-scaling based on load
- ✅ Self-healing (restart crashed pods)
- ✅ Rolling updates with zero downtime
- ✅ Service discovery & load balancing
- ✅ Multi-node cluster management
- ✅ Resource management
- ✅ Ingress & TLS

---

## 📊 So Sánh Docker Compose vs Kubernetes

| Feature | Docker Compose | Kubernetes |
|---------|---|---|
| **Scope** | Single machine | Distributed cluster |
| **Scaling** | Manual | Automatic (HPA) |
| **Updates** | Rolling/manual | Rolling updates (automatic) |
| **Self-healing** | ❌ No | ✅ Yes |
| **Service Discovery** | Basic (DNS) | Advanced (service mesh ready) |
| **Monitoring** | Limited | Rich ecosystem |
| **Learning Curve** | Easy | Steep |
| **Production Ready** | ❌ No | ✅ Yes |
| **Cost** | Low | Varies (can be expensive) |

---

## 🛠️ Chuẩn Bị

### 1. Cài Đặt Kubernetes Locally

#### Option A: Docker Desktop (Recommended)
```powershell
# Enable Kubernetes in Docker Desktop
# Settings → Kubernetes → Enable Kubernetes → Apply & Restart

# Verify installation
kubectl version --client
kubectl get nodes
```

#### Option B: Minikube (Lightweight)
```powershell
# Install Minikube
choco install minikube
minikube start

# Verify
minikube status
kubectl get nodes
```

### 2. Cài Đặt kubectl CLI
```powershell
# Using Chocolatey
choco install kubernetes-cli

# Verify
kubectl version --client
```

### 3. Cài Đặt Helm (Package Manager for Kubernetes)
```powershell
choco install kubernetes-helm

# Verify
helm version
```

---

## ☸️ Deployment on Kubernetes

### 1. Create Kubernetes Manifests

#### identity-service-deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: identity-service
  labels:
    app: identity-service
spec:
  replicas: 2  # Auto-scale to 2 pods
  selector:
    matchLabels:
      app: identity-service
  template:
    metadata:
      labels:
        app: identity-service
    spec:
      containers:
      - name: identity-service
        image: book-identity-service:latest
        ports:
        - containerPort: 8080
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "docker"
        - name: SPRING_DATASOURCE_URL
          value: "jdbc:mysql://mysql-service:3306/book_identity"
        - name: SPRING_DATASOURCE_USERNAME
          valueFrom:
            secretKeyRef:
              name: mysql-credentials
              key: username
        - name: SPRING_DATASOURCE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-credentials
              key: password
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /identity/actuator/health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /identity/actuator/health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: identity-service
spec:
  type: ClusterIP
  ports:
  - port: 8080
    targetPort: 8080
    protocol: TCP
  selector:
    app: identity-service
```

#### mysql-deployment.yaml
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0.40-debian
        ports:
        - containerPort: 3306
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-credentials
              key: password
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
      volumes:
      - name: mysql-storage
        persistentVolumeClaim:
          claimName: mysql-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: mysql-service
spec:
  type: ClusterIP
  ports:
  - port: 3306
    targetPort: 3306
  selector:
    app: mysql
```

#### api-gateway-deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api-gateway
  template:
    metadata:
      labels:
        app: api-gateway
    spec:
      containers:
      - name: api-gateway
        image: book-api-gateway:latest
        ports:
        - containerPort: 8888
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "docker"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: api-gateway
spec:
  type: LoadBalancer
  ports:
  - port: 8888
    targetPort: 8888
  selector:
    app: api-gateway
```

#### Ingress.yaml
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: book-ingress
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: nginx
  rules:
  - host: bookteria.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-gateway
            port:
              number: 8888
  tls:
  - hosts:
    - bookteria.example.com
    secretName: bookteria-tls
```

### 2. Create Secrets for Sensitive Data

```powershell
# Create secret for MySQL credentials
kubectl create secret generic mysql-credentials `
  --from-literal=username=root `
  --from-literal=password=12345

# Create secret for JWT
kubectl create secret generic jwt-secret `
  --from-literal=signer-key="1TjXchw5FloESb63Kc+DFhTARvpWL4jUGCwfGWxuG5SIf/1y/LgJxHnMqaF6A/ij"

# Verify
kubectl get secrets
```

### 3. Deploy to Kubernetes

```powershell
# Apply all configurations
kubectl apply -f mysql-deployment.yaml
kubectl apply -f identity-service-deployment.yaml
kubectl apply -f api-gateway-deployment.yaml

# OR apply directory
kubectl apply -f ./k8s/

# Verify deployments
kubectl get deployments
kubectl get pods
kubectl get services

# Monitor pods
kubectl logs -f deployment/identity-service
kubectl describe pod <pod-name>

# Scale deployment
kubectl scale deployment identity-service --replicas=3
```

---

## 📊 Monitoring & Logging

### 1. Prometheus + Grafana

```yaml
# prometheus-deployment.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    scrape_configs:
    - job_name: 'identity-service'
      static_configs:
      - targets: ['identity-service:8080']
        labels:
          service: 'identity'
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
      - name: prometheus
        image: prom/prometheus
        volumeMounts:
        - name: config
          mountPath: /etc/prometheus
      volumes:
      - name: config
        configMap:
          name: prometheus-config
---
apiVersion: v1
kind: Service
metadata:
  name: prometheus
spec:
  type: NodePort
  ports:
  - port: 9090
    nodePort: 30090
  selector:
    app: prometheus
```

### 2. ELK Stack for Logging

```bash
# Using Helm
helm repo add elastic https://helm.elastic.co
helm install elasticsearch elastic/elasticsearch
helm install kibana elastic/kibana
helm install filebeat elastic/filebeat
```

### 3. Check Logs

```powershell
# Real-time logs
kubectl logs -f deployment/identity-service

# Previous logs (if pod crashed)
kubectl logs --previous deployment/identity-service

# All pods of deployment
kubectl logs -f deployment/identity-service -c identity-service

# Specific pod
kubectl logs <pod-name>
```

---

## 🔄 Rolling Updates

### Blue-Green Deployment

```powershell
# Update image
kubectl set image deployment/identity-service \
  identity-service=book-identity-service:v2

# Check rollout status
kubectl rollout status deployment/identity-service

# Rollback if needed
kubectl rollout undo deployment/identity-service

# Check rollout history
kubectl rollout history deployment/identity-service
```

---

## 📈 Auto-Scaling

### Horizontal Pod Autoscaler (HPA)

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: identity-service-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: identity-service
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

---

## 🚀 Production Checklist

- [ ] All services have health checks configured
- [ ] Persistent volumes for databases configured
- [ ] Secrets management implemented
- [ ] Resource requests and limits set
- [ ] HPA configured for auto-scaling
- [ ] Monitoring (Prometheus/Grafana) deployed
- [ ] Logging (ELK Stack) deployed
- [ ] Ingress with TLS configured
- [ ] Network policies configured
- [ ] RBAC (Role-Based Access Control) setup
- [ ] Backup & disaster recovery plan

---

## 📞 Useful Kubernetes Commands

```powershell
# Cluster
kubectl cluster-info
kubectl get nodes
kubectl describe node <node-name>

# Deployments
kubectl get deployments
kubectl describe deployment <deployment-name>
kubectl edit deployment <deployment-name>
kubectl delete deployment <deployment-name>

# Pods
kubectl get pods
kubectl get pods -A  # All namespaces
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl exec -it <pod-name> bash

# Services
kubectl get services
kubectl describe service <service-name>
kubectl port-forward service/<service-name> 8080:8080

# Debugging
kubectl explain deployment
kubectl api-resources
kubectl config view
```

---

## 📚 Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [Helm Charts](https://helm.sh/docs/)
- [Prometheus Kubernetes Integration](https://prometheus.io/docs/prometheus/latest/configuration/configuration/)

---

## 🎓 Summary

**Docker Compose** = Development/Demo  
**Kubernetes** = Production

Gunakan Kubernetes ketika:
- ✅ Perlu auto-scaling
- ✅ Perlu high availability
- ✅ Multi-node cluster
- ✅ Production environment
- ✅ Complex orchestration

---

**Happy Kubernetes Deployment! ☸️**

