pipeline {
    agent any

    environment {
        IMAGE_NAME      = "wayline-website"
        DOCKER_HUB_USER = "dkhan573"
        EC2_HOST        = "13.201.39.245"   // Replace with EC2 public IP or DNS
        SSH_KEY         = "Mumbai"               // Jenkins credential ID for SSH key
        USER            = "ubuntu"
        TAG             = "${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/danish573/wayline-website.git'
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
                                docker run -d --name wayline-website -p 80:80 $DOCKER_HUB_USER/$IMAGE_NAME:latest
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
