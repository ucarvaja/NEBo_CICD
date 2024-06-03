pipeline {
    agent none 
    environment {
        AWS_ACCOUNT_ID = "59018394013"
        AWS_DEFAULT_REGION = "us-east-1"
        IMAGE_REPO_NAME = "nebo_cicd"
        IMAGE_TAG = "latest"
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
        GIT_REPO_URL = 'https://github.com/ucarvaja/NEBo_CICD.git' // Repositorio público
    }
    stages {
        stage('Logging into AWS ECR') {
            agent { label 'jenkins_slave_1' }
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                        sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${REPOSITORY_URI}"
                    }
                }
            }
        }
        
        stage('Cloning Git') {
            agent { label 'jenkins_slave_1' } // Utiliza cualquier agente disponible
            steps {
                script {
                    checkout scm: [$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: "${GIT_REPO_URL}"]]]
                }
            }
        }

        stage('Building image') {
            agent { label 'jenkins_slave_1' }
            steps {
                script {
                    dockerImage = docker.build "${REPOSITORY_URI}:${IMAGE_TAG}"
                }
            }
        }

        stage('Pushing to ECR') {
            agent { label 'jenkins_slave_1' } // Usa el mismo agente para construir y subir la imagen
            steps {
                script {
                    sh "docker push ${REPOSITORY_URI}:${IMAGE_TAG}"
                }
            }
        }
    }
}
