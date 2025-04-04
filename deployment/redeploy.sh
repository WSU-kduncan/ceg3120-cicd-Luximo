#!/bin/bash

# Redeploy Script for Birds Gone Wild App
# ----------------------------------------
# This script performs the following actions:
# 1. Pulls the latest Docker image from DockerHub
# 2. Stops and removes any existing container
# 3. Starts a new container using the updated image

# Configuration
IMAGE_NAME="luximo1/otuvedo-ceg3120:latest"
CONTAINER_NAME="lux-app"
PORT_MAPPING="4200:4200"

echo "Step 1: Pulling the latest image from DockerHub..."
docker pull $IMAGE_NAME

echo "Step 2: Stopping and removing any existing container..."
docker stop $CONTAINER_NAME 2>/dev/null || echo "No running container to stop."
docker rm $CONTAINER_NAME 2>/dev/null || echo "No container to remove."

echo "Step 3: Starting a new container using the latest image..."
docker run -d --name $CONTAINER_NAME -p $PORT_MAPPING $IMAGE_NAME

echo "Redeployment complete. The application should now be running on port 4200."