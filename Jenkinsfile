pipeline {

    agent any

    environment {
        IMAGE_NAME = "jenkins-docker-compose-assessment-app"
        COMPOSE_FILE = "docker-compose.yml"
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
                '''
            }
        }

        stage('Trivy Security Scan') {
            steps {
                sh '''
                    trivy image ${IMAGE_NAME}:latest
                '''
            }
        }

        stage('Generate Trivy Report') {
            steps {
                sh '''
                    trivy image ${IMAGE_NAME}:latest > trivy-report.txt
                '''
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    docker compose up -d
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

        success {
            echo 'CI/CD pipeline completed successfully.'
        }

        failure {
            echo 'CI/CD pipeline failed. Check the stage logs.'
        }
    }
}
