#!/bin/bash
set -e

# Stop the running container (if any)
echo "Stopping running containers"
container_id=`docker ps | awk -F " " 'NR>1 {print $1}'`
echo "Removing the container - ${container_id}"
docker rm -f "${container_id}"




