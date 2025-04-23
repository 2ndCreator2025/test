#!/bin/bash
set -e  # Exit on error

# Step 3: Install Docker
echo "Setting up Docker..."
sudo apt install -y -qq apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update -qq
sudo apt install -y -qq docker-ce

# Step 4: Verify Docker Installation
echo "Verifying Docker installation..."
sudo docker --version


# Build and run the Docker container
echo "Building and running Docker container..."
sudo docker build -t my-python-app .
sudo docker run -d -p 4000:80 my-python-app

echo "Setup complete! Visit http://localhost:4000 in your browser."
