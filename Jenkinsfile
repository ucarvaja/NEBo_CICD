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
        stage("SonarQube analysis") {
            agent {label "sonar_slave"}
            steps {
                script {
                    sh """
                    sonar-scanner \
                    -Dsonar.projectKey=NEBO_CICD \
                    -Dsonar.sources=. \
                    -Dsonar.host.url=http://ec2-54-157-154-58.compute-1.amazonaws.com:9000 \
                    -Dsonar.login=sqp_d73721d20c2c36e44b9161f49531f3d60762d658
                    """
                }
            }
                // steps{
                //     checkout scm: [$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: "${GIT_REPO_URL}"]]]
                //     script{
                //         def scannerHome = tool "sonar6.0";
                //         withSonarQubeEnv("sonarcloud") { 
                //         sh "${scannerHome}/bin/sonar-scanner"
                //         }
                //     }
        }
        

        stage("Quality Gate"){
        agent {label "sonar_slave"}  
            steps{
                checkout scm: [$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: "${GIT_REPO_URL}"]]]
                    timeout(time: 1, unit: 'HOURS') {                  
                    def qg = waitForQualityGate() 
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                            }
                    }
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
            agent {label "jenkins_slave_1"}    
            steps {
                withEnv(["AWS_ACCESS_KEY_ID=${env.AWS_ACCESS_KEY_ID}", "AWS_SECRET_ACCESS_KEY=${env.AWS_SECRET_ACCESS_KEY}", "AWS_DEFAULT_REGION=${env.AWS_DEFAULT_REGION}"]) {
                sh ""
                sh "docker build -t nebo_cicd ."
                sh "docker tag nebo_cicd:latest 590183940136.dkr.ecr.us-east-1.amazonaws.com/nebo_cicd:latest"
                sh "docker push 590183940136.dkr.ecr.us-east-1.amazonaws.com/nebo_cicd:latest"
                }
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



