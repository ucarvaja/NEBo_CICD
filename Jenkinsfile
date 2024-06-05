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
        // stage("SonarQube analysis") {
        //     agent {label "sonar_slave"}
        //     steps {
        //         script {
        //             def scannerHome = tool 'sonar6.0'
        //             sh """
        //             sonar-scanner \
        //             -Dsonar.projectKey=NEBO_CICD \
        //             -Dsonar.sources=. \
        //             -Dsonar.host.url=http://ec2-54-157-154-58.compute-1.amazonaws.com:9000 \
        //             -Dsonar.login=sqp_d73721d20c2c36e44b9161f49531f3d60762d658
        //             """
        //         }
        //     }
        // }
        // stage("Quality Gate"){
        //     agent {label "sonar_slave"}  
        //     steps {
        //         timeout(time: 1, unit: 'HOURS') {                  
        //             script {
        //                 def qg = waitForQualityGate() 
        //                 if (qg.status != 'OK') {
        //                     error "Pipeline aborted due to quality gate failure: ${qg.status}"
        //                 }
        //             }
        //         }
        //     }
        // }
        stage('Building image') {
            agent { label 'jenkins_slave_1' }
            steps {
                script {
                    sh 'docker rmi $(docker images -q) --force || true'
                    dockerImage = docker.build "${REPOSITORY_URI}:${IMAGE_TAG}"
                }
            }
        }
        stage('Pushing to ECR') {
        agent { label 'jenkins_slave_1' }
            steps {

                sh 'aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 590183940136.dkr.ecr.us-east-1.amazonaws.com'
                sh "docker push ${REPOSITORY_URI}:${IMAGE_TAG}"
        }
        }
    }
}


//   script {
//             withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'awscreds']]) {
//                 sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION}" 
//                 sh "docker login --username AWS --password-stdin ${REPOSITORY_URI}"
//                 sh "docker push ${REPOSITORY_URI}:${IMAGE_TAG}"

//             // withEnv(["AWS_ACCESS_KEY_ID=${env.AWS_ACCESS_KEY_ID}", "AWS_SECRET_ACCESS_KEY=${env.AWS_SECRET_ACCESS_KEY}", "AWS_DEFAULT_REGION=${env.AWS_DEFAULT_REGION}"]){
//             //     // Obtener el token de inicio de sesión de ECR y pasar al inicio de sesión de Docker

//             //     //sh "TOKEN=$(aws ecr get-authorization-token --output text --query 'authorizationData[].authorizationToken')"
//             //     sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION}"
//             //     //sh "sleep 5"
//             //     sh " docker login --username AWS --password-stdin ${REPOSITORY_URI}"
//             //     // Empujar la imagen al ECR
//             //     sh "docker push ${REPOSITORY_URI}:${IMAGE_TAG}"
//                     }
//                 }