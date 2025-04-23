#!/bin/bash
set -e  # Exit on error

# Step 1: Install required packages using curl or wget
echo "Installing required packages..."
# Install curl if not already installed
if ! command -v curl &> /dev/null; then
    echo "curl not found. Please install curl first."
    exit 1
fi

# Install wget if not already installed
if ! command -v wget &> /dev/null; then
    echo "wget not found. Please install wget first."
    exit 1
fi

# Step 2: Install Docker
echo "Setting up Docker..."
# Download the Docker binary
DOCKER_VERSION="20.10.24"  # Specify the desired Docker version
curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_VERSION.tgz -o docker.tgz

# Create a temporary directory for extraction
mkdir -p /tmp/docker-install
tar xzvf docker.tgz --strip 1 -C /tmp/docker-install

# Move the Docker binaries to /usr/local/bin
mv /tmp/docker-install/* /usr/local/bin/

# Clean up
rm -rf /tmp/docker-install
rm docker.tgz

# Step 3: Verify Docker Installation
echo "Verifying Docker installation..."
docker --version

# Step 4: Build and run the Docker container
echo "Building and running Docker container..."
docker build -t my-python-app .
docker run -d -p 4000:80 my-python-app

echo "Setup complete! Visit http://localhost:4000 in your browser."