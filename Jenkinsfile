pipeline {

    agent any

    environment {
        IMAGE_NAME = "jenkins-docker-compose-assessment-app"
        IMAGE_TAG = "${BUILD_NUMBER}"
        PREVIOUS_IMAGE_FILE = ".previous_image"
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

        stage('Save Previous Version') {
            steps {
                sh '''
                    PREVIOUS_IMAGE=$(docker inspect \
                        --format='{{.Config.Image}}' \
                        jenkins-docker-compose-assessment-app-1 2>/dev/null || true)

                    if [ -n "$PREVIOUS_IMAGE" ]; then
                        echo "$PREVIOUS_IMAGE" > ${PREVIOUS_IMAGE_FILE}
                        echo "Previous image: $PREVIOUS_IMAGE"
                    else
                        echo "NONE" > ${PREVIOUS_IMAGE_FILE}
                        echo "No previous application container found."
                    fi
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    IMAGE_NAME=${IMAGE_NAME} IMAGE_TAG=${IMAGE_TAG} \
                    docker compose build
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
                    trivy image ${IMAGE_NAME}:${IMAGE_TAG} \
                    > trivy-report.txt
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
                    echo "Waiting for application..."

                    sleep 15

                    docker compose ps

                    echo "Checking application health..."

                    curl --fail --retry 5 --retry-delay 3 \
                        http://localhost:3000/health

                    echo ""
                    echo "Application health check passed."
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
            echo "Pipeline failed."

            script {
                def previousImage = sh(
                    script: "cat ${PREVIOUS_IMAGE_FILE} 2>/dev/null || echo NONE",
                    returnStdout: true
                ).trim()

                if (previousImage && previousImage != "NONE") {

                    echo "Rolling back to: ${previousImage}"

                    sh """
                        docker compose down

                        docker tag ${previousImage} \
                            ${IMAGE_NAME}:rollback

                        IMAGE_NAME=${IMAGE_NAME} IMAGE_TAG=rollback \
                        docker compose up -d

                        sleep 15

                        curl --fail \
                            http://localhost:3000/health
                    """

                    echo "Rollback completed successfully."

                } else {
                    echo "No previous image available for rollback."
                }
            }
        }

        success {
            echo "CI/CD pipeline completed successfully."
        }
    }
}
