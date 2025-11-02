#!/bin/bash

# --- YOU MUST EDIT THESE VARIABLES ---
AWS_ACCOUNT_ID="711379610491"
AWS_REGION="us-east-1"
ECR_REPO_NAME="my-cicd-app"
# --- STOP EDITING ---

CONTAINER_NAME="my-app"

# Log in to AWS ECR
# Note: We must use the EC2 instance's permissions, but since we installed awscli...
# ...and the Jenkinsfile uses aws-creds for the login in the 'Build' stage...
# ...we need to log in *on the EC2 instance*.
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# Stop and remove the old container if it exists
if [ $(docker ps -a -q -f name=${CONTAINER_NAME}) ]; then
    echo "Stopping and removing old container..."
    docker stop ${CONTAINER_NAME}
    docker rm ${CONTAINER_NAME}
fi

# Pull the 'latest' image from ECR
echo "Pulling latest image..."
docker pull ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:latest

# Run the new container
echo "Running new container..."
docker run -d --name ${CONTAINER_NAME} -p 80:3000 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:latest

echo "Deployment complete!"