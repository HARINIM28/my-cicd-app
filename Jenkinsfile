// Jenkinsfile
pipeline {
    agent any

    
    // --- YOU MUST EDIT THESE VARIABLES ---
    environment {
        AWS_ACCOUNT_ID      = "711379610491" // Find this in the AWS console
        AWS_REGION          = "us-east-1" // Or your default region
        ECR_REPO_NAME       = "my-cicd-app" // The ECR repo name you created
        EC2_PUBLIC_IP       = "3.90.44.19" // Get this from the EC2 dashboard
        AWS_CREDS           = "aws-creds" // The ID you gave your AWS credentials in Jenkins
        SSH_CREDS           = "ec2-ssh-key" // The ID you gave your SSH credentials in Jenkins

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
                // For Node.js, this would be 'npm install'
                // Since Docker handles this, we can just log a message.
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
                // Add your test command here, e.g., 'npm test'
            }
        }

       stage('Build & Tag Docker Image') {
            steps {
                script {
                    // 1. Build the Docker image (this part was already working)
                    echo "Building Docker image..."
                    docker.build(env.ECR_REPO_NAME, ".")

                    // 2. Use the 'withCredentials' block to securely access your aws-creds
                    // This is a different, more direct way to use the credential
                    withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY', credentialsId: 'aws-creds')]) {
                        
                        echo "Logging in to AWS ECR..."
                        // 3. Get the login password from AWS and pipe it to docker login
                        // The 'aws' command will automatically use the credentials from step 2
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
                    // Use ssh-keyscan to add the host's key to known_hosts to avoid prompt
                    // Use -o StrictHostKeyChecking=no as a simpler, less secure alternative
                    sh "ssh -o StrictHostKeyChecking=no ec2-user@${env.EC2_PUBLIC_IP} 'bash -s' < ./deploy.sh"
                }
            }
        }
    }
    
    post {
        // This 'post' block runs after all stages
        success {
            echo 'Pipeline succeeded!'
            // Add email notification step here
            mail to: 'your-email@example.com',
                 subject: "SUCCESS: Pipeline ${env.JOB_NAME} [${env.BUILD_NUMBER}]",
                 body: "Pipeline ran successfully. See build at ${env.BUILD_URL}"
        }
        failure {
            echo 'Pipeline failed.'
            // Add email notification step here
            mail to: 'your-email@example.com',
                 subject: "FAILED: Pipeline ${env.JOB_NAME} [${env.BUILD_NUMBER}]",
                 body: "Pipeline failed. See build at ${env.BUILD_URL}"
        }
    }
}