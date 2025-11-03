
pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID      = "711379610491" 
        AWS_REGION          = "us-east-1" 
        ECR_REPO_NAME       = "my-cicd-app" 
        EC2_PUBLIC_IP       = "3.90.44.19" 
        AWS_CREDS           = "aws-creds" 
        SSH_CREDS           = "ec2-ssh-key" 

        PATH                = "/usr/local/bin:/opt/homebrew/bin:${env.PATH}"
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code...'
                git branch: 'main', url: 'https://github.com/HARINIM28/my-cicd-app.git'
            }
        }

        stage('Build') {
            steps {
                echo 'Building the application...'
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
                
            }
        }

       stage('Build & Tag Docker Image') {
            steps {
                script {
                    // 1. Build the Docker image 
                    echo "Building Docker image..."
                    docker.build(env.ECR_REPO_NAME, "--platform linux/amd64 .")

                    // 2. Use the 'withCredentials' block to securely access your aws-creds
                    withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY', credentialsId: 'aws-creds')]) {
                        
                        echo "Logging in to AWS ECR..."
                        // 3. Get the login password from AWS and pipe it to docker login
                        sh "aws ecr get-login-password --region ${env.AWS_REGION} | docker login --username AWS --password-stdin ${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com"
                        
                        echo "Tagging image for ECR..."
                        // 4. Tag the image with the full ECR path and build number
                        sh "docker tag ${env.ECR_REPO_NAME}:latest ${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.ECR_REPO_NAME}:${env.BUILD_NUMBER}"
                        
                        // 5. Tag the image with the full ECR path and 'latest'
                        sh "docker tag ${env.ECR_REPO_NAME}:latest ${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.ECR_REPO_NAME}:latest"

                        echo "Pushing image with build number..."
                        // 6. Push the build number tag
                        sh "docker push ${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.ECR_REPO_NAME}:${env.BUILD_NUMBER}"
                        
                        echo "Pushing image with latest tag..."
                        // 7. Push the 'latest' tag
                        sh "docker push ${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.ECR_REPO_NAME}:latest"
                    }
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                echo "Deploying version ${env.BUILD_NUMBER} to EC2..."
                sshagent([env.SSH_CREDS]) {
                    sh "ssh -o StrictHostKeyChecking=no ec2-user@${env.EC2_PUBLIC_IP} 'bash -s' < ./deploy.sh"
                }
            }
        }
    }
    
    
}