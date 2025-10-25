#!/bin/bash
# ===========================================================
#  Wayline DevOps Auto Setup Script (Production-Ready)
#  Jenkins + Docker + K3s + Prometheus + Grafana
# ===========================================================

set -e
echo "🚀 Starting Wayline full-stack setup..."

# ===========================================================
# 1️⃣ Update & Install Basic Packages
# ===========================================================
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y curl wget git unzip apt-transport-https ca-certificates gnupg lsb-release ufw

# ===========================================================
# 3️⃣ Install Docker
# ===========================================================
sudo apt install -y docker.io
sudo systemctl enable --now docker
sudo chmod 666 /var/run/docker.sock
sudo usermod -aG docker ubuntu
newgrp docker
docker --version

# ===========================================================
# 2️⃣ Install Java & Jenkins
# ===========================================================
sudo apt install -y openjdk-17-jdk
java -version

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update -y
sudo apt install -y jenkins
sudo systemctl enable --now jenkins
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins


# ===========================================================
# 4️⃣ Install K3s & Configure kubectl
# ===========================================================
echo "⚙️ Installing K3s..."
curl -sfL https://get.k3s.io | sh -

# Wait until K3s node is ready
echo "⏳ Waiting for K3s node to be ready..."
until kubectl get nodes >/dev/null 2>&1; do
    echo "Waiting for K3s..."
    sleep 5
done

# Configure kubeconfig for ubuntu
mkdir -p /home/ubuntu/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config
sudo chmod 600 /home/ubuntu/.kube/config

# Configure kubeconfig for Jenkins
sudo mkdir -p /var/lib/jenkins/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /var/lib/jenkins/.kube/config
sudo chown jenkins:jenkins /var/lib/jenkins/.kube/config
sudo chmod 600 /var/lib/jenkins/.kube/config

kubectl get nodes

# ===========================================================
# 5️⃣ Setup Namespaces
# ===========================================================
kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: wayline-website
---
apiVersion: v1
kind: Namespace
metadata:
  name: monitoring
EOF

# ===========================================================
# 6️⃣ Deploy Website
# ===========================================================
mkdir -p /home/ubuntu/project/k8s

cat <<EOF > /home/ubuntu/project/k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wayline-website
  namespace: wayline-website
spec:
  replicas: 2
  selector:
    matchLabels:
      app: wayline
  template:
    metadata:
      labels:
        app: wayline
    spec:
      containers:
      - name: wayline
        image: dkhan573/wayline-website:latest
        ports:
        - containerPort: 5000
        readinessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 10
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 15
          periodSeconds: 10
EOF

cat <<EOF > /home/ubuntu/project/k8s/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: wayline-service
  namespace: wayline-website
spec:
  type: NodePort
  selector:
    app: wayline
  ports:
    - port: 5000
      targetPort: 5000
      nodePort: 30001
EOF

kubectl apply -f /home/ubuntu/project/k8s/deployment.yaml
kubectl apply -f /home/ubuntu/project/k8s/service.yaml

# ===========================================================
# 7️⃣ Deploy Prometheus & Grafana
# ===========================================================
cat <<EOF > /home/ubuntu/project/k8s/prometheus-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: monitoring
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
        ports:
        - containerPort: 9090
        readinessProbe:
          httpGet:
            path: /-/ready
            port: 9090
          initialDelaySeconds: 10
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /-/healthy
            port: 9090
          initialDelaySeconds: 15
          periodSeconds: 10
EOF

cat <<EOF > /home/ubuntu/project/k8s/prometheus-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: prometheus
  namespace: monitoring
spec:
  type: NodePort
  ports:
    - port: 9090
      targetPort: 9090
      nodePort: 30090
  selector:
    app: prometheus
EOF

cat <<EOF > /home/ubuntu/project/k8s/grafana-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana
        ports:
        - containerPort: 3000
        readinessProbe:
          httpGet:
            path: /
            port: 3000
          initialDelaySeconds: 10
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /
            port: 3000
          initialDelaySeconds: 15
          periodSeconds: 10
EOF

cat <<EOF > /home/ubuntu/project/k8s/grafana-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: monitoring
spec:
  type: NodePort
  ports:
    - port: 3000
      targetPort: 3000
      nodePort: 30300
  selector:
    app: grafana
EOF

kubectl apply -f /home/ubuntu/project/k8s/prometheus-deployment.yaml
kubectl apply -f /home/ubuntu/project/k8s/prometheus-service.yaml
kubectl apply -f /home/ubuntu/project/k8s/grafana-deployment.yaml
kubectl apply -f /home/ubuntu/project/k8s/grafana-service.yaml

# ===========================================================
# 8️⃣ Firewall & Ports
# ===========================================================
sudo ufw allow 22/tcp     # SSH
sudo ufw allow 8080/tcp   # Jenkins
sudo ufw allow 3000/tcp   # Grafana
sudo ufw allow 9090/tcp   # Prometheus
sudo ufw allow 30000:32767/tcp
sudo ufw --force enable

# ===========================================================
# 9️⃣ Wait for Pods to be Ready
# ===========================================================
echo "⏳ Waiting for website pods..."
kubectl wait --for=condition=ready pod -l app=wayline -n wayline-website --timeout=120s
kubectl wait --for=condition=ready pod -l app=prometheus -n monitoring --timeout=120s
kubectl wait --for=condition=ready pod -l app=grafana -n monitoring --timeout=120s

# ===========================================================
# 🔟 Output Access Info
# ===========================================================
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "------------------------------------------------------"
echo "✅ Jenkins:    http://$PUBLIC_IP:8080"
echo "✅ Website:    http://$PUBLIC_IP:30001"
echo "✅ Prometheus: http://$PUBLIC_IP:30090"
echo "✅ Grafana:    http://$PUBLIC_IP:30300"
echo "------------------------------------------------------"
echo "🔑 Jenkins Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "------------------------------------------------------"
echo "✅ Setup Completed Successfully!"
