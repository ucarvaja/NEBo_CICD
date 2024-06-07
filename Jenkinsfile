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
                    // check out repository
                    checkout scm: [$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: "${GIT_REPO_URL}"]]]
                    dir('data') {
                        sh 'go test -v -run TestSuggestionsHandler'
                        sh 'go test -v -run TestCalculateScore'
                        
                    }  
                }
            }
        }

        stage("SonarQube analysis") {
        agent {label "sonar_slave"}
            steps{
                checkout scm: [$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: "${GIT_REPO_URL}"]]]
            
                script{
                    def scannerHome = tool "sonar4.7";
                    withSonarQubeEnv("sonarqube") { 
                    sh "${scannerHome}/bin/sonar-scanner"
                    }
                }
            }
        }

        stage("Quality Gate"){
        agent {label "sonar_slave"}  
            steps{
                script{
                    timeout(time: 1, unit: 'HOURS') {                  
                    def qg = waitForQualityGate() 
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                            }
                        }
                    }
                }
            }

        stage('Build Image and Push to ECR') {
            agent { label 'jenkins_slave_1' }
            steps {
                script {
                    sh 'docker rmi $(docker images -q) --force || true'
                    sh 'aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${REPOSITORY_URI}'
                    def commitId = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    dockerImage = docker.build "${REPOSITORY_URI}:${commitId}"
                    sh "docker push ${REPOSITORY_URI}:${commitId}"
                    dockerImage = docker.build "${REPOSITORY_URI}:latest"
                    sh "docker push ${REPOSITORY_URI}:latest" // this is for the terraform file not recomended
                    sh 'docker logout'
                }
            }
        }
    }
}
