#!/usr/bin/env bash
set -e
AWS_ACC=$(aws sts get-caller-identity --query Account --output text)
REGION=us-west-2
IMAGE="$AWS_ACC.dkr.ecr.$REGION.amazonaws.com/my-graal-lambda:jit"

docker build -f docker/Dockerfile -t my-graal-lambda .
aws ecr describe-repositories --repository-names my-graal-lambda >/dev/null 2>&1 || \
    aws ecr create-repository --repository-name my-graal-lambda >/dev/null
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $AWS_ACC.dkr.ecr.$REGION.amazonaws.com
docker tag my-graal-lambda "$IMAGE"
docker push "$IMAGE"

aws lambda create-function \
  --function-name graal-jfr-demo \
  --package-type Image \
  --code ImageUri="$IMAGE" \
  --role arn:aws:iam::${AWS_ACC}:role/LambdaRole \
  --memory-size 512 \
  --timeout 10
