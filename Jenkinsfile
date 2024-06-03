pipeline {
    agent none // Utiliza diferentes agentes según la etapa
    environment {
        AWS_ACCOUNT_ID = "59018394013"
        AWS_DEFAULT_REGION = "us-east-1"
        IMAGE_REPO_NAME = "nebo_cicd"
        IMAGE_TAG = "latest"
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
        GIT_REPO_URL = 'git@github.com:ucarvaja/NEBo_CICD.git'
        GIT_CREDENTIALS_ID = 'git-ssh-credentials' // Reemplaza con el ID de las credenciales SSH para GitHub en Jenkins
    }
    stages {
        stage('Logging into AWS ECR') {
            agent { label 'sonar_slave' }
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) { // Asegúrate de que 'aws-credentials' es el ID correcto para tus credenciales en Jenkins
                        sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${REPOSITORY_URI}"
                    }
                }
            }
        }
        
        stage('Cloning Git') {
            agent { label 'any' } // No especifica un agente específico, utiliza cualquier disponible
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: "${GIT_CREDENTIALS_ID}", url: "${GIT_REPO_URL}"]]])
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
            agent { label 'jenkins_slave_1' } 
            steps {
                script {
                    sh "docker push ${REPOSITORY_URI}:${IMAGE_TAG}"
                }
            }
        }
    }
}
