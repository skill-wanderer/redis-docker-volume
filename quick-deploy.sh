#!/bin/bash

# Redis Docker Volume - Quick Deploy from GitHub
# Usage: curl -sSL https://raw.githubusercontent.com/skill-wanderer/redis-docker-volume/main/quick-deploy.sh | bash

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_status "Redis Docker Volume - Quick Deploy"
print_status "=================================="

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    print_warning "This script should be run with sudo"
    echo "Usage: curl -sSL https://raw.githubusercontent.com/skill-wanderer/redis-docker-volume/main/quick-deploy.sh | sudo bash"
    exit 1
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd $TEMP_DIR

print_status "Downloading Redis Docker Volume from GitHub..."

# Download all necessary files
curl -sSL -o docker-compose.prod.yml https://raw.githubusercontent.com/skill-wanderer/redis-docker-volume/main/docker-compose.prod.yml
curl -sSL -o redis.prod.conf https://raw.githubusercontent.com/skill-wanderer/redis-docker-volume/main/redis.prod.conf
curl -sSL -o .env.production https://raw.githubusercontent.com/skill-wanderer/redis-docker-volume/main/.env.production
curl -sSL -o deploy-server.sh https://raw.githubusercontent.com/skill-wanderer/redis-docker-volume/main/deploy-server.sh

print_status "Setting up Redis server environment..."

# Make deploy script executable and run it
chmod +x deploy-server.sh
./deploy-server.sh

print_status "Configuring environment..."

# Copy environment file
cp .env.production .env

print_status "Redis server setup completed!"
print_status "Location: $(pwd)"

echo
print_status "Next steps:"
echo "1. Edit environment file: nano .env"
echo "2. Set secure password in .env file"
echo "3. Start Redis: docker-compose -f docker-compose.prod.yml up -d"
echo "4. Test connection: docker-compose -f docker-compose.prod.yml exec redis redis-cli -a YourPassword ping"
echo
print_warning "Don't forget to set a secure password in the .env file!"

# Copy files to /opt/redis for permanent installation
print_status "Installing to /opt/redis..."
mkdir -p /opt/redis/compose
cp *.yml *.conf .env* /opt/redis/compose/
cd /opt/redis/compose

print_status "Installation complete!"
print_status "Files installed to: /opt/redis/compose/"
