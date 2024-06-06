pipeline {
    agent none 
    environment {
        AWS_ACCOUNT_ID = "590183940136"
        AWS_DEFAULT_REGION = "us-east-1"
        IMAGE_REPO_NAME = "nebo_cicd"
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
        GIT_REPO_URL = 'https://github.com/ucarvaja/NEBo_CICD.git' 
    }
    stages {
        stage('CheckOut') {
            agent { label 'jenkins_slave_1' }
            steps {
                script {
                    checkout scm: [$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: "${GIT_REPO_URL}"]]]
                }
            }
        }

        stage('Integration and Unit Tests') {
            agent { label 'sonar_slave' }
            steps {
                script {
                    // check out repo
                    checkout scm: [$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: "${GIT_REPO_URL}"]]]
                    dir('data') {
                        sh 'go test -v -run TestSuggestionsHandler'
                        sh 'go test -v -run TestCalculateScore'
                    }  
                }
            }
        }
        // Uncomment and configure SonarQube stages if necessary.
        // ...
        stage('Build Image and Push to ECR') {
            agent { label 'jenkins_slave_1' }
            steps {
                script {
                    sh 'docker rmi $(docker images -q) --force || true'
                    sh 'aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${REPOSITORY_URI}'
                    def commitId = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    dockerImage = docker.build "${REPOSITORY_URI}:${commitId}"
                    sh "docker push ${REPOSITORY_URI}:${commitId}"
                    sh 'docker logout'
                }
            }
        }
    }
}
