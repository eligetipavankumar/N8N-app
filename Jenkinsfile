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
                sh "docker build -t %DOCKER_IMAGE%:build-%BUILD_NUMBER% ."
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([string(credentialsId: 'docker-pat', variable: 'hubPwd')]) {
                    sh "echo ${hubPwd} | docker login -u mekumar --password-stdin"
                    sh "docker push mekumar/n8n:$BUILD_NUMBER"
                }
            }
        }

        stage('Checkout K8S manifest SCM') {
            steps {
                git branch: 'main', url: 'https://github.com/Vinod-09/N8N-app.git'
            }
        }

        stage('Update K8S manifest & push to Repo') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'Git-pat', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                        sh '''
                        echo "Before update:"
                        cat ${MANIFEST_PATH}

                        # Replace version/tag dynamically
                         sed -i "s|image: .*/mekumar/n8n:.*|image: ${DOCKER_IMAGE}|g" ${MANIFEST_PATH}

                        echo "After update:"
                        cat ${MANIFEST_PATH}

                        git config user.email "pvk83360@gmail.com"
                        git config user.name "Vinod-09"

                        git add ${MANIFEST_PATH}
                        git commit -m "Updated deploy yaml to build ${BUILD_NUMBER} | Jenkins Pipeline" || echo "No changes to commit"

                        git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/Vinod-09/n8n-argoCD.git main
                        '''
                    }
                }
            }
        }
    }
}
