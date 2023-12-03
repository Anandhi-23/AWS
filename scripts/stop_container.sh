#!/bin/bash
set -e

# Stop the running container (if any)
echo "Stopping running containers"
container_id=`docker ps | awk -F " " 'NR>1 {print $1}'`
if [ -n "${container_id}" ]; then
  echo "Container ID found: ${container_id}"
  echo "Removing the container - ${container_id}"
  docker rm -f "${container_id}"
else
  echo "No running containers found"
fi




