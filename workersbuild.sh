#!/bin/bash
set -e  # Exit on error

# 1. Verify essential dependencies (pre-installed in Workers Builds)
check_dependency() {
    if ! command -v $1 &> /dev/null; then
        echo "WARNING: Required command '$1' not found. Skipping Docker setup."
        return 1
    fi
    return 0
}

echo "Checking system dependencies..."
check_dependency curl
check_dependency wget
check_dependency newuidmap
check_dependency newgidmap

# 2. Install Docker binaries if newuidmap is available
if command -v newuidmap &> /dev/null; then
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
    export XDG_RUNTIME_DIR="/run/user/$(id -u)"
    export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/docker.sock"
    echo "Docker Host: $DOCKER_HOST"

    # 5. Start Docker daemon directly (no systemd)
    echo "Starting Docker service..."
    $DOCKER_DIR/dockerd/dockerd-rootless.sh > /tmp/docker.log 2>&1 &

    # Wait for Docker daemon to be ready
    echo "Waiting for Docker to start..."
    timeout=30
    while [ ! -S "$XDG_RUNTIME_DIR/docker.sock" ]; do
        if [ "$timeout" -le 0 ]; then
            echo "Timeout waiting for Docker daemon"
            exit 1
        fi
        sleep 1
        ((timeout--))
    done

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
else
    echo "Skipping Docker setup due to missing 'newuidmap'."
    echo "You may need to run your application using a different method."
fi