#!/bin/bash
# Install jenkins #
sudo apt update
sudo apt upgrade -y

sudo apt install openjdk-17-jdk -y
java -version

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
/usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
/etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins

#Install Docker#
sudo apt update -y
sudo apt upgrade -y
sudo apt install docker.io -y
sudo systemctl daemon-reload
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu
sudo usermod -aG docker jenkins # <-- Add this line
newgrp docker # Apply the group membership changes

# ...

docker --version
jenkins --version
