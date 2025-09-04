pipeline {
    agent any

    environment {
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKER_IMAGE = "eligetipavankumar/n8n:${BUILD_NUMBER}"
        GIT_REPO = 'https://github.com/eligetipavankumar/N8n-app.git'
        MANIFEST_PATH = "C:/Program Files/Jenkins/kubeconfig"
    }

    stages {

        stage('Docker Build') {
            steps {
                bat "docker build -t ${DOCKER_IMAGE} ."
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'DOCKER_USER', 
                                                 usernameVariable: 'HUB_USER', 
                                                 passwordVariable: 'HUB_PWD')]) {
                    bat """
                    echo %HUB_PWD% | docker login -u %HUB_USER% --password-stdin
                    docker push ${DOCKER_IMAGE}
                    """
                }
            }
        }

        stage('Checkout K8S manifest SCM') {
            steps {
                git branch: 'main', url: "${GIT_REPO}"
            }
        }

        stage('Update K8S manifest & push to Repo') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'GitHub', variable: 'GITHUB_TOKEN')]) {
                        bat """
                        echo Before update:
                        type "${MANIFEST_PATH}"

                        REM Replace Docker image tag dynamically
                        powershell -Command "(Get-Content '${MANIFEST_PATH}') -replace 'image: .*/n8n:.*', 'image: ${DOCKER_IMAGE}' | Set-Content '${MANIFEST_PATH}'"

                        echo After update:
                        type "${MANIFEST_PATH}"

                        git config user.email "eligetipavan@gmail.com"
                        git config user.name "eligetipavankumar"

                        git add "${MANIFEST_PATH}"
                        git commit -m "Updated deploy yaml to build ${IMAGE_TAG} | Jenkins Pipeline" || echo No changes to commit

                        git push https://${GITHUB_TOKEN}@github.com/eligetipavankumar/N8n-app.git main
                        """
                    }
                }
            }
        }

    } // end of stages
} // end of pipeline
