#!/bin/bash
set -e  # Exit on error

# Step 1: Install required packages (curl and wget)
echo "Installing required packages..."
if ! command -v curl &> /dev/null; then
    echo "Installing curl..."
    sudo apt-get update && sudo apt-get install -y curl
fi

if ! command -v wget &> /dev/null; then
    echo "Installing wget..."
    sudo apt-get install -y wget
fi

# Step 2: Install Docker
echo "Setting up Docker..."
DOCKER_VERSION="20.10.24"
curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz -o docker.tgz

mkdir -p /tmp/docker-install
tar xzvf docker.tgz --strip 1 -C /tmp/docker-install

# Step 3: Verify Docker Client
echo "Verifying Docker client..."
/tmp/docker-install/docker --version

# Step 4: Install and Start Rootless Docker Daemon
echo "Setting up rootless Docker..."
export PATH=/tmp/docker-install:$PATH  # Add Docker binaries to PATH
chmod +x /tmp/docker-install/dockerd/dockerd-rootless-setuptool.sh
/tmp/docker-install/dockerd/dockerd-rootless-setuptool.sh install

# Load environment variables for rootless Docker
export DOCKER_HOST=unix:///run/user/$UID/docker.sock

# Step 5: Build and Run the Docker Container
echo "Building and running Docker container..."
# Ensure dockerd is running (may need to start it manually)
systemctl --user start docker

# Wait a few seconds to ensure Docker daemon is ready
sleep 5

# Proceed with build and run
/tmp/docker-install/docker build -t my-python-app .
/tmp/docker-install/docker run -d -p 4000:80 my-python-app

echo "Setup complete! Visit http://localhost:4000 in your browser."