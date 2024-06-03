// pipeline {
//     agent any

//     stages {
//         stage('Hello') {
//             steps {
//                 echo 'Hello World'
//             }
//         }
//     }
// }

// add text



pipeline {
    agent none // no asigna un agente global, permitiendo especificar agentes por etapa
    stages {
        stage('Test Sonar Slave') {
            agent { label 'sonar_slave' } // especifica el nodo sonar_slave para esta etapa
            steps {
                script {
                    echo "Ejecutando en el nodo Sonar Slave"
                    sh 'hostname' // Ejecuta un comando simple para imprimir el nombre del host
                    sh 'echo $PATH' // Imprime la variable de entorno PATH
                }
            }
        }
        stage('Test Jenkins Slave 1') {
            agent { label 'jenkins_slave_1' } // especifica el nodo jenkins_slave_1 para esta etapa
            steps {
                script {
                    echo "Ejecutando en el nodo Jenkins Slave 1"
                    sh 'hostname' // Ejecuta un comando simple para imprimir el nombre del host
                    sh 'echo $PATH' // Imprime la variable de entorno PATH
                }
            }
        }
    }
}
