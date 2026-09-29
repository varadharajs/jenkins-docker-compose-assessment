pipeline {

    agent any

    environment {
        IMAGE_NAME = "jenkins-docker-compose-assessment-app"
        IMAGE_TAG = "${BUILD_NUMBER}"
        PREVIOUS_TAG_FILE = ".previous_image_tag"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    cd app
                    npm install
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''
                    cd app
                    npm test
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker compose build
                    docker tag docker-compose-cicd-app:latest \
                        ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }

        stage('Trivy Security Scan') {
            steps {
                sh '''
                    trivy image ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }

        stage('Generate Trivy Report') {
            steps {
                sh '''
                    trivy image ${IMAGE_NAME}:${IMAGE_TAG} > trivy-report.txt
                '''
            }
        }

        stage('Save Previous Version') {
            steps {
                sh '''
                    CURRENT_IMAGE=$(docker ps \
                        --filter "name=docker-compose-cicd-app" \
                        --format "{{.Image}}" | head -n 1 || true)

                    if [ -n "$CURRENT_IMAGE" ]; then
                        echo "$CURRENT_IMAGE" > ${PREVIOUS_TAG_FILE}
                    else
                        echo "NONE" > ${PREVIOUS_TAG_FILE}
                    fi

                    cat ${PREVIOUS_TAG_FILE}
                '''
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    IMAGE_NAME=${IMAGE_NAME} IMAGE_TAG=${IMAGE_TAG} \
                    docker compose up -d --force-recreate
                '''
            }
        }

        stage('Health Check') {
            steps {
                sh '''
                    sleep 15

                    docker compose ps

                    curl --fail http://localhost:3000/health
                '''
            }
        }

        stage('Cleanup') {
            steps {
                sh '''
                    docker image prune -f
                '''
            }
        }
    }

    post {

        always {
            archiveArtifacts artifacts: 'trivy-report.txt',
                             allowEmptyArchive: true
        }

        failure {
            echo 'Deployment failed. Rollback should be performed using the previous image version.'
        }

        success {
            echo 'CI/CD pipeline completed successfully.'
        }
    }
}
