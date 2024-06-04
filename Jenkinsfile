pipeline {
    agent none 
    environment {
        AWS_ACCOUNT_ID = "59018394013"
        AWS_DEFAULT_REGION = "us-east-1"
        IMAGE_REPO_NAME = "nebo_cicd"
        IMAGE_TAG = "latest"
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
        
        stage('Building image') {
            agent { label 'jenkins_slave_1' }
            steps {
                script {
                    dockerImage = docker.build "${REPOSITORY_URI}:${IMAGE_TAG}"
                }
            }
        }
    stage ('Build and Push to ECR') {
            agent {label "slave_jenkins"}
            
            
            steps {
                //checkout([$class: "GitSCM",branches: [[name: '*/test']], extensions: [], userRemoteConfigs: [[credentialsId: 'github-ssh-key-new', url: 'https://github.com/Felipe8617/gowebapp.git']]])
                
                withEnv(["AWS_ACCESS_KEY_ID=${env.AWS_ACCESS_KEY_ID}", "AWS_SECRET_ACCESS_KEY=${env.AWS_SECRET_ACCESS_KEY}", "AWS_DEFAULT_REGION=${env.AWS_DEFAULT_REGION}"]) {
                // sh "aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/u9q6y4u2"
                sh ""
                sh "docker build -t nebo_cicd ."
                sh "docker tag nebo_cicd:latest 590183940136.dkr.ecr.us-east-1.amazonaws.com/nebo_cicd:latest"
                sh "docker push 590183940136.dkr.ecr.us-east-1.amazonaws.com/nebo_cicd:latest"
                }
            }
        }

        // stage('Pushing to ECR') {
        //     agent { label 'jenkins_slave_1' }
        //     steps {
        //         script {
        //             withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'awscreds']]) {
        //                 sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${REPOSITORY_URI}"
        //                 sh "docker push ${REPOSITORY_URI}:${IMAGE_TAG}"
        //             }
        //         }
        //     }
        // }
    }
}



