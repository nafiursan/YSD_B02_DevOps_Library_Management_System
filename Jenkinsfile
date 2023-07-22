pipeline {
    agent any
  

    tools {
        // Install the Maven version configured as "Maven_3.9.3" and add it to the path.
        maven "Maven_3.9.3"
    }

        triggers{
            pollSCM('H/2 * * * *')
        }

    stages {
        stage('Git Checkout') {
            steps {
                // Checkout the source code from Git repository
                git branch: 'master', url: 'https://github.com/nafiursan/YSD_B02_DevOps_Library_Management_System.git'
            }
        }

        stage('Add Environment Variables') {
            steps {
                // Inject database credentials as environment variables
                withCredentials([usernamePassword(credentialsId: 'DB_CREDENTIALS', passwordVariable: 'DB_PASSWORD', usernameVariable: 'DB_USERNAME')]) {
                    sh '''
                        sed -i "s|^spring\\.datasource\\.url =.*|spring.datasource.url = jdbc:mysql://mysql-service:3306/sparklmsdb?useSSL=true|" /var/lib/jenkins/workspace/On-Premise/src/main/resources/application.properties
                        sed -i "s/^spring\\.datasource\\.username =.*/spring.datasource.username = ${DB_USERNAME}/" /var/lib/jenkins/workspace/On-Premise/src/main/resources/application.properties
                        sed -i "s/^spring\\.datasource\\.password =.*/spring.datasource.password = ${DB_PASSWORD}/" /var/lib/jenkins/workspace/On-Premise/src/main/resources/application.properties
                    '''
                }
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn clean install'
            }
        }

        stage('Create Docker Image') {
            steps {
                script {
                    // Create Docker image
                    docker.build("nafiur30080/lms:${env.BUILD_ID}")
                }
            }
        }

        stage('Push to Dockerhub') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'dockerhub') {
                        def imageName = "nafiur30080/lms:${env.BUILD_NUMBER}"
                        docker.image(imageName).push("${env.BUILD_NUMBER}")
                        docker.image(imageName).push("latest")
                    }
                }
            }
        }

        stage('Delete Docker Image') {
            steps {
                script {
                    def imageToDelete = "nafiur30080/lms:${env.BUILD_ID}"

                    // Remove the Docker image
                    sh "docker rmi ${imageToDelete}"
                    sh "docker rmi nafiur30080/lms:latest"
                }
            }
        }

        stage('Delete Previous k8s Pods') {
            steps {
                withKubeConfig(credentialsId: 'kube') {
                    // Delete previous Kubernetes pods
                    sh "kubectl delete -f db.yaml"
                    sh "kubectl delete -f application.yaml"
                    sh "kubectl delete -f mysql-pv-pvc.yaml"
                }
            }
        }

        stage('Deploy Updated k8s Pods') {
            steps {
                withKubeConfig(credentialsId: 'kube') {
                    // Deploy updated Kubernetes pods
                    sh "kubectl apply -f db.yaml"
                    sh "kubectl apply -f application.yaml"
                    sh "kubectl apply -f mysql-pv-pvc.yaml"
                   // sh "kubectl apply -f mysql-secret.yaml"
              withCredentials([file(credentialsId: 'secret', variable: 'K8S_SECRET_FILE')]) {
                    sh "kubectl apply -f ${K8S_SECRET_FILE}"
                }
                    
                }
            }
        }
    }

    post {
        always {
            // Clean up any temporary files or resources here
            deleteDir()
        }

        success {
            // Perform actions if the build succeeds
            echo 'Build succeeded!'
        }

        failure {
            // Perform actions if the build fails
            echo 'Build failed!'
        }
    }
}
