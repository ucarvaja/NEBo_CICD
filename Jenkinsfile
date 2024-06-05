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
        // IMAGE_TAG is removed since it will be dynamically generated later.
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
        GIT_REPO_URL = 'https://github.com/ucarvaja/NEBo_CICD.git' 
    }
    stages {
        stage('CheckOut') {
            agent { label 'jenkins_slave_1' }
            steps {
                script {
                    // Performs the checkout and sets the GIT_COMMIT variable.
                    checkout scm: [$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: "${GIT_REPO_URL}"]]]
                }
            }
        }

        stage('Test') {
            agent { label 'sonar_slave' }
            steps {
                script {
                    // Set up Go environment if necessary
                    sh 'export GOPATH=$WORKSPACE'
                    sh 'export PATH=$PATH:$GOPATH/bin'

                    // Navigate to the directory containing Go files
                    dir('data') {
                        // Run unit tests
                        sh 'go test -v ./... -run Unit'
                        // Run integration tests
                        sh 'go test -v ./... -run Integration'
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
                    // Removes existing images to avoid disk space issues.
                    sh 'docker rmi $(docker images -q) --force || true'
                    // Authenticates with ECR.
                    sh 'aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${REPOSITORY_URI}'
                    // Gets the current commit hash.
                    def commitId = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    // Builds the Docker image with the commit tag.
                    dockerImage = docker.build "${REPOSITORY_URI}:${commitId}"
                    // Pushes the image to ECR with the commit tag.
                    sh "docker push ${REPOSITORY_URI}:${commitId}"
                    // Logs out of ECR to ensure credentials do not remain on the agent.
                    sh 'docker logout'
                }
            }
        }
    }
}
