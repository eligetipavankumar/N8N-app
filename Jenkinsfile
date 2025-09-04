pipeline {
    agent any

    environment {
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKER_IMAGE = "eligetipavankumar/n8n:{BUILD_NUMBER}"
        GIT_REPO = 'https://github.com/eligetipavankumar/N8n-app.git'
        MANIFEST_PATH = "C:/Program Files/Jenkins/kubeconfig"
    }

    stages {

        stage('Docker Build') {
            steps {
                sh "docker build -t eligetipavankumar/n8n:${IMAGE_TAG} ."
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([string(credentialsId: 'DOCKER_USER', variable: 'HUB_PWD')]) {
                    sh """
                    echo ${HUB_PWD} | docker login -u eligetipavankumar --password-stdin
                    docker push ${DOCKER_IMAGE}:${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Checkout K8S manifest SCM') {
            steps {
                git branch: 'main', url: 'https://github.com/eligetipavankumar/N8n-app.git'
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
                        sed -i "s|image: .*/n8n:.*|image: ${DOCKER_IMAGE}|g" ${MANIFEST_PATH}

                        echo "After update:"
                        cat ${MANIFEST_PATH}

                        git config user.email "eligetipavan@gmail.com"
                        git config user.name "eligetipavankumar"

                        git add ${MANIFEST_PATH}
                        git commit -m "Updated deploy yaml to build ${IMAGE_TAG} | Jenkins Pipeline" || echo "No changes to commit"

                        git push https://${GITHUB_TOKEN}@github.com/eligetipavankumar/N8n-app.git main
                        """
                    }
                }
            }
        }
    }
}
