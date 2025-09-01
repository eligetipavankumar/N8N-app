pipeline {
    agent any

    environment {
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKER_IMAGE = "mekumar/n8n"
        GIT_REPO = 'https://github.com/Vinod-09/N8N-app.git'
        MANIFEST_PATH = "dev/deployment.yaml"
    }

    stages {

        stage('Docker Build') {
            steps {
                sh "docker build -t mekumar/n8n:${IMAGE_TAG} ."
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([string(credentialsId: 'docker-pat', variable: 'HUB_PWD')]) {
                    sh """
                    echo ${HUB_PWD} | docker login -u mekumar --password-stdin
                    docker push ${DOCKER_IMAGE}:${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Checkout K8S manifest SCM') {
            steps {
                git branch: 'main', url: 'https://github.com/Vinod-09/n8n-argoCD.git'
            }
        }

        stage('Update K8S manifest & push to Repo') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'Git-pat', variable: 'GITHUB_TOKEN')]) {
                        sh """
                        echo "Before update:"
                        cat ${MANIFEST_PATH}

                        # Replace Docker image tag dynamically
                        sed -i "s|image: .*/mekumar/n8n:.*|image: ${DOCKER_IMAGE}|g" ${MANIFEST_PATH}

                        echo "After update:"
                        cat ${MANIFEST_PATH}

                        git config user.email "pvk83360@gmail.com"
                        git config user.name "Vinod-09"

                        git add ${MANIFEST_PATH}
                        git commit -m "Updated deploy yaml to build ${IMAGE_TAG} | Jenkins Pipeline" || echo "No changes to commit"

                        git push https://${GITHUB_TOKEN}@github.com/Vinod-09/n8n-argoCD.git main
                        """
                    }
                }
            }
        }
    }
}
