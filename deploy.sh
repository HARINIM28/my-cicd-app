#!/bin/bash

set -e


AWS_ACCOUNT_ID="711379610491"
AWS_REGION="us-east-1"
ECR_REPO_NAME="my-cicd-app"

CONTAINER_NAME="my-app"


aws ecr get-login-password --region ${AWS_REGION} | sudo docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com


if [ $(sudo docker ps -a -q -f name=${CONTAINER_NAME}) ]; then
    echo "Stopping and removing old container..."
    sudo docker stop ${CONTAINER_NAME}  
    sudo docker rm ${CONTAINER_NAME}
fi


echo "Pulling latest image..."
sudo docker pull ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:latest


echo "Running new container..."
sudo docker run -d --name ${CONTAINER_NAME} -p 80:3000 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:latest

echo "Deployment complete!"
