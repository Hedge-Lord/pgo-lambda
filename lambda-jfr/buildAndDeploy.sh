#!/usr/bin/env bash
set -euo pipefail

echo "Retrieving AWS account ID"
AWS_ACC=$(aws sts get-caller-identity --query Account --output text)
REGION=us-east-2

# change this to whatever you like
REPO_NAME=graal-jfr-lambda
IMAGE_TAG=latest
IMAGE_URI="$AWS_ACC.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:$IMAGE_TAG"

echo "Building Docker image"
docker build -f docker/Dockerfile -t $REPO_NAME .

echo "Ensuring ECR repository exists"
aws ecr describe-repositories --repository-names $REPO_NAME >/dev/null 2>&1 \
  || aws ecr create-repository --repository-name $REPO_NAME

echo "Logging into ECR"
aws ecr get-login-password --region $REGION \
  | docker login --username AWS --password-stdin $AWS_ACC.dkr.ecr.$REGION.amazonaws.com

echo "Tagging and pushing image to ECR"
docker tag $REPO_NAME:$IMAGE_TAG $IMAGE_URI
docker push $IMAGE_URI

echo "Deploying to Lambda"
if aws lambda get-function --function-name graal-jfr-demo >/dev/null 2>&1; then
  echo "Updating existing function to use image"
  aws lambda update-function-code \
    --function-name graal-jfr-demo \
    --image-uri $IMAGE_URI
else
  echo "Creating new image‐based Lambda function"
  aws lambda create-function \
    --function-name graal-jfr-demo \
    --package-type Image \
    --code ImageUri=$IMAGE_URI \
    --role arn:aws:iam::${AWS_ACC}:role/LambdaRole \
    --memory-size 512 \
    --timeout 10
fi
