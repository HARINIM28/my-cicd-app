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

        PATH                = "/usr/local/bin:${env.PATH}"
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
                    // Build the Docker image
                    docker.build(env.ECR_REPO_NAME, ".")
                    
                    // Tag the image
                    docker.withRegistry("https://${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com", "aws-creds") {
                        docker.image(env.ECR_REPO_NAME).push("${env.BUILD_NUMBER}")
                        docker.image(env.ECR_REPO_NAME).push("latest")
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