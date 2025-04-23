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

# Step 2: Install Rootless Docker
echo "Setting up rootless Docker..."
curl -fsSL https://get.docker.com/rootless | sh

# Step 3: Set up environment variables
echo "Setting up environment variables..."
export PATH=$HOME/bin:$PATH
export DOCKER_HOST=unix:///run/user/$UID/docker.sock

# Step 4: Start Docker daemon using sh in the background
echo "Starting Docker daemon in the background..."
nohup dockerd-rootless.sh > dockerd.log 2>&1 &
DOCKER_PID=$!
echo "Docker daemon started with PID: $DOCKER_PID"

# Step 5: Wait for Docker daemon to be ready
echo "Waiting for Docker daemon to be ready..."
sleep 5

# Step 6: Build and Run the Docker Container
echo "Building and running Docker container..."
docker build -t my-python-app .
docker run -d -p 4000:80 my-python-app

echo "Setup complete! Visit http://localhost:4000 in your browser."
echo "Add the following lines to your ~/.bashrc to make Docker available in new terminals:"
echo "export PATH=\$HOME/bin:\$PATH"
echo "export DOCKER_HOST=unix:///run/user/\$UID/docker.sock"
echo "Docker daemon log is available at: $(pwd)/dockerd.log"