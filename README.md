# Jenkins CI/CD Pipeline with Docker Compose Deployment

## 1. Project Overview

This project demonstrates a CI/CD pipeline using Jenkins, GitHub, Docker, Docker Compose, and Trivy.

The pipeline automatically checks out application source code from GitHub, installs dependencies, runs tests, builds a Docker image, performs a Trivy security scan, generates a security report, deploys the application using Docker Compose, performs a health check, and cleans unused Docker images.

The project also demonstrates persistent PostgreSQL storage and rollback concepts.

---

## 2. Technologies Used

- GitHub
- Jenkins
- Git
- Docker
- Docker Compose
- Node.js
- Express.js
- PostgreSQL
- Trivy
- Linux/Ubuntu

---

## 3. Project Structure

```text
jenkins-docker-compose-assessment/
│
├── .dockerignore
├── Dockerfile
├── Jenkinsfile
├── docker-compose.yml
├── trivy-report.txt
├── README.md
│
└── app/
    ├── package.json
    └── server.js
