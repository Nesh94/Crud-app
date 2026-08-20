#!/bin/bash
# Runs once when each EC2 instance boots.
# Installs Docker, then starts the CRUD app container pointed at RDS.

dnf update -y
dnf install -y docker
systemctl enable docker
systemctl start docker

docker pull ${docker_image}

docker run -d \
  --name crud-app \
  --restart unless-stopped \
  -p ${app_port}:${app_port} \
  -e PORT=${app_port} \
  -e POSTGRES_HOST=${db_host} \
  -e POSTGRES_PORT=5432 \
  -e POSTGRES_USER=${db_username} \
  -e POSTGRES_PASSWORD=${db_password} \
  -e POSTGRES_DB=${db_name} \
  -e POSTGRES_SSL=true \
  ${docker_image}
