#!/bin/bash
set -e  # Exit on error

# 1. Verify essential dependencies
check_dependency() {
    if ! command -v $1 &> /dev/null; then
        echo "ERROR: Required command '$1' not found"
        exit 1
    fi
}

echo "Checking system dependencies..."
check_dependency curl
check_dependency newuidmap
check_dependency newgidmap

# 2. Install Docker binaries
echo "Setting up Docker..."
DOCKER_VERSION="20.10.24"
DOCKER_DIR="/tmp/docker-install"
mkdir -p $DOCKER_DIR

echo "Downloading Docker ${DOCKER_VERSION}..."
curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz \
  | tar -xz --strip-components=1 -C $DOCKER_DIR

# 3. Configure rootless Docker
echo "Configuring rootless mode..."
export PATH="$DOCKER_DIR:$PATH"
chmod +x $DOCKER_DIR/dockerd/dockerd-rootless-setuptool.sh

$DOCKER_DIR/dockerd/dockerd-rootless-setuptool.sh install --force

# 4. Set environment variables
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
echo "Docker Host: $DOCKER_HOST"

# 5. Start Docker daemon
echo "Starting Docker service..."
systemctl --user start docker
sleep 2  # Brief wait for daemon initialization

# 6. Verify Docker connectivity
echo "Verifying Docker connection..."
docker version
docker ps > /dev/null  # Basic functionality check

# 7. Build and run container
echo "Building application container..."
docker build -t my-python-app .

echo "Starting application..."
docker run -d -p 4000:80 my-python-app

echo "Operation complete! Access your service at:"
echo "http://localhost:4000"