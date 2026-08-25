#!/bin/bash
# deploy.sh — runs ON the EC2 instance (invoked remotely by GitHub Actions over SSH).
#
# Simulates a blue/green deployment:
#   1. Start the NEW version alongside the old one, on a temporary port (3001).
#   2. Health-check the new version.
#   3. Only if it's healthy: stop the old version and promote the new one
#      to the real port (3000).
#   4. If the new version fails its health check, it's torn down and the
#      old version keeps serving traffic untouched (a rollback).
#
# This means a broken deploy never takes down the live app.

set -e

IMAGE="mutshutshudzi/crud-app:latest"
LIVE_PORT=3000
STAGING_PORT=3001
LIVE_CONTAINER="crud-app"
STAGING_CONTAINER="crud-app-staging"

echo "==> Pulling latest image..."
docker pull "$IMAGE"

echo "==> Removing any leftover staging container..."
docker rm -f "$STAGING_CONTAINER" 2>/dev/null || true

echo "==> Starting new (green) version on staging port $STAGING_PORT..."
docker run -d \
  --name "$STAGING_CONTAINER" \
  -p ${STAGING_PORT}:${LIVE_PORT} \
  -e PORT=${LIVE_PORT} \
  -e POSTGRES_HOST="$POSTGRES_HOST" \
  -e POSTGRES_PORT=5432 \
  -e POSTGRES_USER="$POSTGRES_USER" \
  -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
  -e POSTGRES_DB="$POSTGRES_DB" \
  -e POSTGRES_SSL=true \
  "$IMAGE"

echo "==> Health-checking staging container..."
HEALTHY=false
for i in $(seq 1 10); do
  if curl -sf "http://localhost:${STAGING_PORT}/health" > /dev/null; then
    HEALTHY=true
    break
  fi
  echo "    Not ready yet (attempt $i/10)..."
  sleep 3
done

if [ "$HEALTHY" = true ]; then
  echo "==> Staging is healthy. Promoting to live (blue -> green swap)..."
  docker rm -f "$LIVE_CONTAINER" 2>/dev/null || true
  docker rm -f "$STAGING_CONTAINER"

  docker run -d \
    --name "$LIVE_CONTAINER" \
    --restart unless-stopped \
    -p ${LIVE_PORT}:${LIVE_PORT} \
    -e PORT=${LIVE_PORT} \
    -e POSTGRES_HOST="$POSTGRES_HOST" \
    -e POSTGRES_PORT=5432 \
    -e POSTGRES_USER="$POSTGRES_USER" \
    -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
    -e POSTGRES_DB="$POSTGRES_DB" \
    -e POSTGRES_SSL=true \
    "$IMAGE"

  echo "==> Deployment successful."
else
  echo "==> Staging failed health checks. Rolling back — live version untouched."
  docker rm -f "$STAGING_CONTAINER" 2>/dev/null || true
  exit 1
fi
