pipeline {
    agent any

    environment {
        IMAGE_NAME      = "wayline-website"
        DOCKER_HUB_USER = "dkhan573"
        EC2_HOST        = "13.201.39.245"   // Replace with your EC2 public IP or DNS
        SSH_KEY         = "Mumbai"           // Jenkins credential ID for SSH key
        USER            = "ubuntu"
        TAG             = "${BUILD_NUMBER}"

        # Kubernetes & monitoring directories
        K8S_DIR         = "k8s"
        MONITORING_DIR  = "monitoring"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/danish573/STATIC-WEB-APP.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                        echo "🏗️ Building Docker image..."
                        docker build -t $IMAGE_NAME:$TAG .
                        docker tag $IMAGE_NAME:$TAG $DOCKER_HUB_USER/$IMAGE_NAME:latest
                        docker tag $IMAGE_NAME:$TAG $DOCKER_HUB_USER/$IMAGE_NAME:$TAG
                    """
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    echo "📦 Pushing Docker image to Docker Hub..."
                    withDockerRegistry([credentialsId: 'dockerhub', url: 'https://index.docker.io/v1/']) {
                        sh """
                            docker push $DOCKER_HUB_USER/$IMAGE_NAME:latest
                            docker push $DOCKER_HUB_USER/$IMAGE_NAME:$TAG
                        """
                    }
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    echo "🚀 Deploying container on EC2..."
                    sshagent(credentials: [SSH_KEY]) {
                        sh """
                            ssh -o StrictHostKeyChecking=no $USER@$EC2_HOST '
                                docker rm -f wayline || true &&
                                docker pull $DOCKER_HUB_USER/$IMAGE_NAME:latest &&
                                docker run -d --name wayline -p 80:80 $DOCKER_HUB_USER/$IMAGE_NAME:latest
                            '
                        """
                    }
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                echo "🌐 Website deployed successfully! Visit: http://$EC2_HOST"
            }
        }

        // -------------------- New Stages for Kubernetes & Monitoring --------------------

        stage('Deploy to Kubernetes Cluster') {
            steps {
                script {
                    echo "🚀 Deploying Kubernetes manifests..."
                    sshagent(credentials: [SSH_KEY]) {
                        sh """
                            ssh -o StrictHostKeyChecking=no $USER@$EC2_HOST '
                                kubectl apply -f ~/project/${K8S_DIR}/namespace.yaml ||
                                kubectl create namespace wayline-monitoring;

                                kubectl apply -f ~/project/${K8S_DIR}/deployment.yaml;
                                kubectl apply -f ~/project/${K8S_DIR}/service.yaml;

                                echo "✅ Application deployed on Kubernetes!"
                            '
                        """
                    }
                }
            }
        }

        stage('Setup Prometheus and Grafana') {
            steps {
                script {
                    echo "📊 Deploying Prometheus and Grafana..."
                    sshagent(credentials: [SSH_KEY]) {
                        sh """
                            ssh -o StrictHostKeyChecking=no $USER@$EC2_HOST '
                                kubectl apply -f ~/project/${MONITORING_DIR}/prometheus-deployment.yaml;
                                kubectl apply -f ~/project/${MONITORING_DIR}/prometheus-service.yaml;
                                kubectl apply -f ~/project/${MONITORING_DIR}/grafana-deployment.yaml;
                                kubectl apply -f ~/project/${MONITORING_DIR}/grafana-service.yaml;

                                echo "✅ Prometheus & Grafana deployed successfully!"
                            '
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ CI/CD Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Please check the Jenkins console output."
        }
    }
}
