pipeline {
    agent any

    environment {
        DOCKERHUB = credentials('docker-cred')    // DockerHub creds ID
        DOCKER_IMAGE = "mekumar/n8n"
        KUBECONFIG = 'E:\\jenkins\\kube\\config'  // kubeconfig path
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Vinod-09/N8N-app.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                bat """
                    docker build -t %DOCKER_IMAGE%:build-%BUILD_NUMBER% .
                """
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    bat """
                        echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
                        docker push %DOCKER_IMAGE%:build-%BUILD_NUMBER%
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    try {
                        bat "kubectl set image deployment/n8n-deployment n8n=%DOCKER_IMAGE%:build-%BUILD_NUMBER% -n default"
                    } catch (err) {
                        echo "Deployment not found, applying manifests instead..."
                        bat "kubectl apply -f k8s/ --validate=false"
                    }
                }
            }
        }
    }
}
