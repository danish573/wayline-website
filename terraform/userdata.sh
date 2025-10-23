#!/bin/bash
# ===========================================================
#  Wayline DevOps Auto Setup Script
#  Jenkins + Docker + K3s + Prometheus + Grafana
# ===========================================================

set -e

echo "🚀 Starting Wayline full-stack setup..."

# ===========================================================
# 1️⃣ Update and Install Basic Packages
# ===========================================================
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y curl wget git unzip apt-transport-https ca-certificates gnupg lsb-release

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
sudo systemctl enable jenkins
sudo systemctl start jenkins

# ===========================================================
# 3️⃣ Install Docker
# ===========================================================
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu
sudo usermod -aG docker jenkins
newgrp docker
docker --version

# ===========================================================
# 4️⃣ Install Lightweight Kubernetes (K3s)
# ===========================================================
echo "⚙️ Installing K3s (Lightweight Kubernetes)..."
curl -sfL https://get.k3s.io | sh -
sleep 60

# Setup kubectl config for ubuntu & Jenkins
mkdir -p /home/ubuntu/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config
sudo chmod 600 /home/ubuntu/.kube/config

# For Jenkins
sudo mkdir -p /var/lib/jenkins/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /var/lib/jenkins/.kube/config
sudo chown jenkins:jenkins /var/lib/jenkins/.kube/config

echo "✅ K3s Installed Successfully!"
kubectl get nodes

# ===========================================================
# 5️⃣ Setup Monitoring Namespace
# ===========================================================
cat <<EOF > /home/ubuntu/monitoring-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: monitoring
EOF

sudo kubectl apply -f /home/ubuntu/monitoring-namespace.yaml

# ===========================================================
# 6️⃣ Deploy Prometheus & Grafana in K8s
# ===========================================================
cat <<EOF > /home/ubuntu/prometheus-deployment.yaml
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
EOF

cat <<EOF > /home/ubuntu/prometheus-service.yaml
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

cat <<EOF > /home/ubuntu/grafana-deployment.yaml
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
EOF

cat <<EOF > /home/ubuntu/grafana-service.yaml
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

sudo kubectl apply -f /home/ubuntu/prometheus-deployment.yaml
sudo kubectl apply -f /home/ubuntu/prometheus-service.yaml
sudo kubectl apply -f /home/ubuntu/grafana-deployment.yaml
sudo kubectl apply -f /home/ubuntu/grafana-service.yaml

# ===========================================================
# 7️⃣ Firewall & Port Access
# ===========================================================
sudo ufw allow 22/tcp     # SSH
sudo ufw allow 8080/tcp   # Jenkins
sudo ufw allow 3000/tcp   # Grafana
sudo ufw allow 9090/tcp   # Prometheus
sudo ufw allow 30000:32767/tcp
sudo ufw --force enable

# ===========================================================
# 8️⃣ Output Access Info
# ===========================================================
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "------------------------------------------------------"
echo "✅ Jenkins:    http://$PUBLIC_IP:8080"
echo "✅ Prometheus: http://$PUBLIC_IP:30090"
echo "✅ Grafana:    http://$PUBLIC_IP:30300"
echo "------------------------------------------------------"
echo "🔑 Jenkins Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "------------------------------------------------------"
echo "✅ Setup Completed Successfully!"
