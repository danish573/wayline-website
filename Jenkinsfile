pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials')
        DOCKER_IMAGE = 'dkhan573/wayline-website'
        K8S_DIR = 'k8s'
        MONITORING_DIR = 'monitoring'
        EC2_HOST = '65.0.169.106'     // ✅ Replace with your EC2 public IP
        SSH_KEY = 'Mumbai'             // ✅ Jenkins SSH Key Credential ID
        USER = 'ubuntu'
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/danish573/wayline-website.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE:$BUILD_NUMBER .'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh '''
                        echo "$PASSWORD" | docker login -u "$USERNAME" --password-stdin
                        docker tag $DOCKER_IMAGE:$BUILD_NUMBER $DOCKER_IMAGE:latest
                        docker push $DOCKER_IMAGE:$BUILD_NUMBER
                        docker push $DOCKER_IMAGE:latest
                    '''
                }
            }
        }

        stage('Copy Files to EC2') {
            steps {
                sshagent (credentials: ["${SSH_KEY}"]) {
                    sh '''
                        scp -o StrictHostKeyChecking=no -r $K8S_DIR $MONITORING_DIR $USER@$EC2_HOST:/home/$USER/project/
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes (K3s)') {
            steps {
                sshagent (credentials: ["${SSH_KEY}"]) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no $USER@$EC2_HOST '
                            kubectl apply -f /home/$USER/project/k8s/deployment.yaml
                            kubectl apply -f /home/$USER/project/k8s/service.yaml
                            kubectl get pods -o wide
                            kubectl get svc -o wide
                        '
                    '''
                }
            }
        }

        stage('Deploy Monitoring Stack (Prometheus + Grafana)') {
            steps {
                sshagent (credentials: ["${SSH_KEY}"]) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no $USER@$EC2_HOST '
                            kubectl apply -f /home/$USER/project/monitoring/prometheus-deployment.yaml
                            kubectl apply -f /home/$USER/project/monitoring/prometheus-service.yaml
                            kubectl apply -f /home/$USER/project/monitoring/grafana-deployment.yaml
                            kubectl apply -f /home/$USER/project/monitoring/grafana-service.yaml
                            kubectl get pods -n default
                            kubectl get svc -n default
                        '
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '✅ Deployment completed successfully!'
        }
        failure {
            echo '❌ Deployment failed. Check Jenkins logs for details.'
        }
    }
}
