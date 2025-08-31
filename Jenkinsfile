pipeline {
    agent any

    environment {
        // Use kubeconfig for kubectl
        KUBECONFIG = "E:\\jenkins\\kube\\configure\\config"
        DOCKER_IMAGE = "mekumar/n8n"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Vinod-09/N8N-app.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    bat """
                    echo ===== Building Docker Image =====
                    docker build -t %DOCKER_IMAGE%:build-%BUILD_NUMBER% .
                    """
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        bat """
                        echo ===== Logging into DockerHub =====
                        echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
                        docker push %DOCKER_IMAGE%:build-%BUILD_NUMBER%
                        """
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo "===== Deploying to Kubernetes ====="

                    // Try rolling update first
                    def status = bat(script: "kubectl set image deployment/n8n-deployment n8n=%DOCKER_IMAGE%:build-%BUILD_NUMBER% -n default", returnStatus: true)

                    if (status != 0) {
                        echo "Deployment not found, applying manifests instead..."
                        bat """
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                        kubectl apply -f k8s/ingress.yaml
                        """
                    }
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    bat """
                    echo ===== Verifying Pods =====
                    kubectl get pods -n default
                    kubectl get svc -n default
                    kubectl get ingress -n default
                    """
                }
            }
        }
    }
}
