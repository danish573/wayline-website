#!/bin/bash
# ===========================================================
#  Wayline DevOps Full Setup Script
#  Jenkins + Docker + Kubernetes + Prometheus + Grafana
# ===========================================================

# --- Update and Upgrade ---
sudo apt update -y && sudo apt upgrade -y

# --- Install Basic Tools ---
sudo apt install -y curl wget git unzip apt-transport-https ca-certificates gnupg lsb-release

# ===========================================================
#  Install Java & Jenkins
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
#  Install Docker
# ===========================================================
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu
sudo usermod -aG docker jenkins
newgrp docker

# ===========================================================
#  Install Kubernetes (kubectl + minikube)
# ===========================================================
# --- Install kubectl ---
sudo curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s \
https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
sudo chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# --- Install Minikube ---
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/

# --- Start Minikube with Docker driver ---
sudo minikube start --driver=docker

# ===========================================================
#  Install Prometheus
# ===========================================================
cd /opt
sudo wget https://github.com/prometheus/prometheus/releases/download/v2.50.0/prometheus-2.50.0.linux-amd64.tar.gz
sudo tar xvf prometheus-2.50.0.linux-amd64.tar.gz
sudo mv prometheus-2.50.0.linux-amd64 prometheus
cd prometheus

# Create systemd service for Prometheus
sudo bash -c 'cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
After=network.target

[Service]
ExecStart=/opt/prometheus/prometheus --config.file=/opt/prometheus/prometheus.yml --web.listen-address=0.0.0.0:9090
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus

# ===========================================================
#  Install Grafana
# ===========================================================
sudo apt install -y adduser libfontconfig1
wget https://dl.grafana.com/oss/release/grafana_10.4.1_amd64.deb
sudo dpkg -i grafana_10.4.1_amd64.deb
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

# ===========================================================
#  Configure Kubernetes Deployments (Prometheus + Grafana)
# ===========================================================
cat <<EOF > /root/monitoring-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: monitoring
EOF

kubectl apply -f /root/monitoring-namespace.yaml

# Prometheus NodePort Service
cat <<EOF > /root/prometheus-service.yaml
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

kubectl apply -f /root/prometheus-service.yaml

# Grafana NodePort Service
cat <<EOF > /root/grafana-service.yaml
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

kubectl apply -f /root/grafana-service.yaml

# ===========================================================
#  Firewall Rules
# ===========================================================
sudo ufw allow 22/tcp     # SSH
sudo ufw allow 8080/tcp   # Jenkins
sudo ufw allow 3000/tcp   # Grafana
sudo ufw allow 9090/tcp   # Prometheus
sudo ufw allow 80/tcp     # Web App
sudo ufw reload

# ===========================================================
#  Jenkins Setup Notes
# ===========================================================
echo "------------------------------------------------------"
echo "✅ Jenkins:  http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
echo "✅ Prometheus: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):30090"
echo "✅ Grafana: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):30300"
echo "------------------------------------------------------"

# Print Jenkins password
echo "🔑 Jenkins Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
