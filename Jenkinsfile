// Jenkinsfile
pipeline {
    agent any
    tools {
        maven 'Maven-3.9.6' // This name MUST match the name you set in Step 1
    }
    environment {
        // --- REPLACE THESE VALUES ---
        AWS_REGION        = "eu-north-1"
        ECR_REPO_URI      = "450049924511.dkr.ecr.eu-north-1.amazonaws.com/shruti-ese-app-repo"
        DEPLOY_SERVER_IP  = "ec2-16-170-203-230.eu-north-1.compute.amazonaws.com"
        APP_NAME          = "shruti-ese-app"
        // --- -------------------- ---
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code from GitHub...'
                git branch: 'main', url: 'https://github.com/ShrutiThiagu/Devops_ESE_lab.git'
            }
        }
	stage('Build') {
            steps {
                echo 'Building the Java application with Maven...'
                script {
                    // --- BRUTE FORCE MAVEN INSTALL ---
                    // This command checks for a maven folder. If it doesn't exist,
                    // it downloads and unzips it.
                    sh 'ls -d apache-maven-3.9.6 || (wget https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz && tar -xzf apache-maven-3.9.6-bin.tar.gz)'
                    
                    // Define the path to our manually downloaded Maven
                    def mvnHome = "${env.WORKSPACE}/apache-maven-3.9.6"
                    
                    // Call it using the full path
                    sh "${mvnHome}/bin/mvn clean package"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                // Build the image and tag it with the ECR URI and build number
                sh "docker build -t ${env.APP_NAME} ."
                sh "docker tag ${env.APP_NAME}:latest ${env.ECR_REPO_URI}:${env.BUILD_NUMBER}"
                sh "docker tag ${env.APP_NAME}:latest ${env.ECR_REPO_URI}:latest"
            }
        }

        stage('Push to AWS ECR') {
            steps {
                echo 'Logging in to ECR and pushing image...'
                // Jenkins uses the EC2 IAM Role automatically. No keys needed!
                // This command gets a login password and pipes it to docker login
                sh "aws ecr get-login-password --region ${env.AWS_REGION} | docker login --username AWS --password-stdin ${env.ECR_REPO_URI}"

                // Push both tags
                sh "docker push ${env.ECR_REPO_URI}:${env.BUILD_NUMBER}"
                sh "docker push ${env.ECR_REPO_URI}:latest"
            }
        }

	stage('Deploy to EC2') {
            steps {
                echo "Deploying to ${env.DEPLOY_SERVER_IP}..."
                withCredentials([sshUserPrivateKey(credentialsId: 'ec2-ssh-key', keyFileVariable: 'keyFile')]) {
                    sh """
                        ssh -i \${keyFile} -o StrictHostKeyChecking=no ec2-user@${env.DEPLOY_SERVER_IP} '

                        echo "--- Logged into deployment server ---"

                        # Log in to ECR on the deployment server
                        aws ecr get-login-password --region ${env.AWS_REGION} | docker login --username AWS --password-stdin ${env.ECR_REPO_URI}

                        # Pull the latest image
                        docker pull ${env.ECR_REPO_URI}:latest

                        # Stop and remove the old container, if it exists
                        docker stop ${env.APP_NAME} || true
                        docker rm ${env.APP_NAME} || true

                        echo "--- Starting new container ---"

                        # Run the new container
                        docker run -d -p 80:80 --name ${env.APP_NAME} ${env.ECR_REPO_URI}:latest
                        '
                """
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up Docker images...'
            // Clean up the local Jenkins workspace
            sh "docker rmi ${env.ECR_REPO_URI}:${env.BUILD_NUMBER} || true"
            sh "docker rmi ${env.ECR_REPO_URI}:latest || true"
        }
        success {
            echo 'Pipeline finished successfully!'
            // Add email notification step here
        }
        failure {
            echo 'Pipeline FAILED.'
            // Add email notification step here
        }
    }
}
