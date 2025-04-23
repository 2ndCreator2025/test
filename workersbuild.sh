#!/bin/bash
set -e  # Exit on error

# 1. Install prerequisites
echo "Installing required packages..."
sudo apt-get update
sudo apt-get install -y curl wget uidmap

# 2. Install Docker binaries
echo "Downloading Docker..."
DOCKER_VERSION="20.10.24"
curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz -o docker.tgz
mkdir -p /tmp/docker-install
tar xzvf docker.tgz --strip 1 -C /tmp/docker-install

# 3. Set up rootless Docker
echo "Configuring rootless Docker..."
export PATH=/tmp/docker-install:$PATH
chmod +x /tmp/docker-install/dockerd/dockerd-rootless-setuptool.sh

# Run rootless setup
/tmp/docker-install/dockerd/dockerd-rootless-setuptool.sh install --force

# Load rootless environment
export XDG_RUNTIME_DIR=/run/user/$UID
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock

# 4. Start Docker daemon
echo "Starting Docker..."
systemctl --user start docker
sleep 5  # Wait for daemon initialization

# 5. Verify Docker operation
echo "Verifying Docker..."
docker ps  # Simple test command

# 6. Build and run container
echo "Building and running application..."
docker build -t my-python-app .
docker run -d -p 4000:80 my-python-app

echo "Setup complete! Access your app at http://localhost:4000"