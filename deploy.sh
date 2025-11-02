#!/bin/bash
# Exit immediately if any command fails
set -e

# --- YOU MUST EDIT THESE VARIABLES ---
AWS_ACCOUNT_ID="711379610491"
AWS_REGION="us-east-1"
ECR_REPO_NAME="my-cicd-app"
# --- STOP EDITING ---

CONTAINER_NAME="my-app"

# Log in to AWS ECR
aws ecr get-login-password --region ${AWS_REGION} | sudo docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# Stop and remove the old container if it exists (using sudo)
if [ $(sudo docker ps -a -q -f name=${CONTAINER_NAME}) ]; then
    echo "Stopping and removing old container..."
    sudo docker stop ${CONTAINER_NAME}  # <-- This line is now fixed
    sudo docker rm ${CONTAINER_NAME}
fi

# Pull the 'latest' image from ECR (using sudo)
echo "Pulling latest image..."
sudo docker pull ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:latest

# Run the new container (using sudo)
echo "Running new container..."
sudo docker run -d --name ${CONTAINER_NAME} -p 80:3000 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:latest

echo "Deployment complete!"