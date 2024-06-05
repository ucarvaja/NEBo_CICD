// pipeline {
//     agent none 
//     environment {
//         AWS_ACCOUNT_ID = "590183940136"
//         AWS_DEFAULT_REGION = "us-east-1"
//         IMAGE_REPO_NAME = "nebo_cicd"
//         IMAGE_TAG = "latest"
//         REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
//         GIT_REPO_URL = 'https://github.com/ucarvaja/NEBo_CICD.git' 
//     }
//     stages {
//         stage('CheckOut') {
//             agent { label 'jenkins_slave_1' }
//             steps {
//                 script {
//                     checkout scm: [$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: "${GIT_REPO_URL}"]]]
//                 }
//             }
//         }
//         // stage("SonarQube analysis") {
//         //     agent {label "sonar_slave"}
//         //     steps {
//         //         script {
//         //             def scannerHome = tool 'sonar6.0'
//         //             sh """
//         //             sonar-scanner \
//         //             -Dsonar.projectKey=NEBO_CICD \
//         //             -Dsonar.sources=. \
//         //             -Dsonar.host.url=http://ec2-54-157-154-58.compute-1.amazonaws.com:9000 \
//         //             -Dsonar.login=sqp_d73721d20c2c36e44b9161f49531f3d60762d658
//         //             """
//         //         }
//         //     }
//         // }
//         // stage("Quality Gate"){
//         //     agent {label "sonar_slave"}  
//         //     steps {
//         //         timeout(time: 1, unit: 'HOURS') {                  
//         //             script {
//         //                 def qg = waitForQualityGate() 
//         //                 if (qg.status != 'OK') {
//         //                     error "Pipeline aborted due to quality gate failure: ${qg.status}"
//         //                 }
//         //             }
//         //         }
//         //     }
//         // }
//         stage('Build Image and Push to ECR') {
//         agent { label 'jenkins_slave_1' }
//             steps {
//             script {    
//                 sh 'docker rmi $(docker images -q) --force || true'
//                 sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
//                 dockerImage = docker.build "${REPOSITORY_URI}:${IMAGE_TAG}"
//                 sh "docker push ${REPOSITORY_URI}:${IMAGE_TAG}"
//                 sh 'docker logout'
//                 }
//             }
//         }
//     }
// }


pipeline {
    agent none 
    environment {
        AWS_ACCOUNT_ID = "590183940136"
        AWS_DEFAULT_REGION = "us-east-1"
        IMAGE_REPO_NAME = "nebo_cicd"
        // Se elimina IMAGE_TAG ya que se generará dinámicamente más adelante.
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
        GIT_REPO_URL = 'https://github.com/ucarvaja/NEBo_CICD.git' 
    }
    stages {
        stage('CheckOut') {
            agent { label 'jenkins_slave_1' }
            steps {
                script {
                    // Realiza el checkout y establece la variable GIT_COMMIT.
                    checkout scm: [$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: "${GIT_REPO_URL}"]]]
                }
            }
        }
        // Descomenta y configura las etapas de SonarQube si es necesario.
        // ...
        stage('Build Image and Push to ECR') {
            agent { label 'jenkins_slave_1' }
            steps {
                script {
                    // Elimina imágenes existentes para evitar problemas de espacio en disco.
                    sh 'docker rmi $(docker images -q) --force || true'
                    // Autentica con ECR.
                    sh 'aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${REPOSITORY_URI}'
                    // Obtiene el hash del commit actual.
                    def commitId = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    // Construye la imagen de Docker con el tag del commit.
                    dockerImage = docker.build "${REPOSITORY_URI}:${commitId}"
                    // Sube la imagen a ECR con el tag del commit.
                    sh "docker push ${REPOSITORY_URI}:${commitId}"
                    // También sube la imagen con el tag 'latest'.
                    sh "docker tag ${REPOSITORY_URI}:${commitId} ${REPOSITORY_URI}:latest"
                    sh "docker push ${REPOSITORY_URI}:latest"
                    // Cierra la sesión en ECR para asegurarse de que las credenciales no permanezcan en el agente.
                    sh 'docker logout'
                }
            }
        }
    }
}
