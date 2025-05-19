# AWS Lambda with GraalVM and JFR

This project demonstrates how to run a Java Lambda function using GraalVM with Java Flight Recorder (JFR) enabled.

## Prerequisites

- AWS CLI installed and configured
- Docker installed
- Maven installed
- An AWS account with appropriate permissions
- An IAM role named `LambdaRole` with basic Lambda execution permissions

## Building and Deploying

1. Build the Docker image and deploy to Lambda:
```bash
./buildAndDeploy.sh
```

The script will:
- Build a Docker image with GraalVM JDK 21
- Create an ECR repository if it doesn't exist
- Push the image to ECR
- Create or update the Lambda function

