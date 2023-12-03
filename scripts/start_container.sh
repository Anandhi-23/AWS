#!/bin/bash
set -e

# Pull the Docker image from Docker Hub
docker pull anandhi23/kaizen_app:latest

# Run the Docker image as a container
docker run -d -p 8000:8000 anandhi23/kaizen_app:latest






