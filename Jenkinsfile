<<<<<<< HEAD
pipeline {
    agent any
<<<<<<< HEAD
    environment {
          S3_BUCKET = "static-wl-website-s3-bucket"
          AWS_REGION = "ap-south-1"
    }


    stages{
        stage('checkout code')
        {
        steps{
            git branch: 'main', url: 'https://github.com/danish573/STATIC-WEB-APP.git'
            }
        }
        stage('Minify files')
        {
            steps{
                echo "Minifying HTML, CSS and JS..."
                sh 'bash scripts/minify_and_deploy.sh minify'
            }
        }
          stage('Deploy to S3'){
            steps{
                echo "Deploying Static site to S3"
                sh "bash scripts/minify_and_deploy.sh deploy $S3_BUCKET $AWS_REGION"
=======

    environment {
        IMAGE_NAME      = "wayline-website"
        DOCKER_HUB_USER = "dkhan573"
        EC2_HOST        = "YOUR.EC2.PUBLIC.IP"   // Replace with EC2 public IP or DNS
        SSH_KEY         = "Mumbai"               // Jenkins credential ID for SSH key
        USER            = "ubuntu"
        TAG             = "${BUILD_NUMBER}"
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
>>>>>>> c69f2bc (Initial commit for Wayline Infratech Jenkins pipeline)
            }
        }
    }

<<<<<<< HEAD
   post {
    success {
        echo "✅ Deployment Successful! Site is live at: http://${env.S3_BUCKET}.s3-website-${env.AWS_REGION}.amazonaws.com"
    }
    failure {
        echo "❌ Build failed! Check logs."
    }
}


}
=======
    post {
        success {
            echo "✅ CI/CD Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Please check the Jenkins console output."
        }
    }
}
>>>>>>> c69f2bc (Initial commit for Wayline Infratech Jenkins pipeline)
=======
pipeline {
    agent any
<<<<<<< HEAD
    environment {
          S3_BUCKET = "static-wl-website-s3-bucket"
          AWS_REGION = "ap-south-1"
    }


    stages{
        stage('checkout code')
        {
        steps{
            git branch: 'main', url: 'https://github.com/danish573/STATIC-WEB-APP.git'
            }
        }
        stage('Minify files')
        {
            steps{
                echo "Minifying HTML, CSS and JS..."
                sh 'bash scripts/minify_and_deploy.sh minify'
            }
        }
          stage('Deploy to S3'){
            steps{
                echo "Deploying Static site to S3"
                sh "bash scripts/minify_and_deploy.sh deploy $S3_BUCKET $AWS_REGION"
=======

    environment {
        IMAGE_NAME      = "wayline-website"
        DOCKER_HUB_USER = "dkhan573"
        EC2_HOST        = "YOUR.EC2.PUBLIC.IP"   // Replace with EC2 public IP or DNS
        SSH_KEY         = "Mumbai"               // Jenkins credential ID for SSH key
        USER            = "ubuntu"
        TAG             = "${BUILD_NUMBER}"
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
>>>>>>> c69f2bc (Initial commit for Wayline Infratech Jenkins pipeline)
            }
        }
    }

<<<<<<< HEAD
   post {
    success {
        echo "✅ Deployment Successful! Site is live at: http://${env.S3_BUCKET}.s3-website-${env.AWS_REGION}.amazonaws.com"
    }
    failure {
        echo "❌ Build failed! Check logs."
    }
}


}
=======
    post {
        success {
            echo "✅ CI/CD Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Please check the Jenkins console output."
        }
    }
}
>>>>>>> c69f2bc (Initial commit for Wayline Infratech Jenkins pipeline)
>>>>>>> 521f1da (prject)
