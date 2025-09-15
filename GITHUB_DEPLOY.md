# 🚀 Quick Deployment from GitHub

Deploy Redis directly from this GitHub repository to your Ubuntu server.

## One-Command Deployment

```bash
# Quick deploy (downloads and sets up everything)
curl -sSL https://raw.githubusercontent.com/skill-wanderer/redis-docker-volume/main/quick-deploy.sh | sudo bash
```

## Manual Deployment

### Option 1: Clone Repository
```bash
# Clone and deploy
git clone https://github.com/skill-wanderer/redis-docker-volume.git
cd redis-docker-volume

# Run setup
sudo ./deploy-server.sh

# Configure
cp .env.production .env
nano .env  # Set your password

# Start Redis
docker-compose -f docker-compose.prod.yml up -d
```

### Option 2: Direct Docker Compose
```bash
# Create directory
mkdir -p ~/redis-deploy && cd ~/redis-deploy

# Download files
curl -O https://raw.githubusercontent.com/skill-wanderer/redis-docker-volume/main/docker-compose.prod.yml
curl -O https://raw.githubusercontent.com/skill-wanderer/redis-docker-volume/main/redis.prod.conf
curl -O https://raw.githubusercontent.com/skill-wanderer/redis-docker-volume/main/.env.production

# Copy and edit environment
cp .env.production .env
nano .env

# Start Redis
docker-compose -f docker-compose.prod.yml up -d
```

## Verification

```bash
# Check status
docker-compose -f docker-compose.prod.yml ps

# Test connection
docker-compose -f docker-compose.prod.yml exec redis redis-cli -a YourPassword ping
```

## Files You Need

From this repository, you need:
- `docker-compose.prod.yml` - Production Docker Compose
- `redis.prod.conf` - Redis configuration
- `.env.production` - Environment template
- `deploy-server.sh` - Server setup script (optional)

## Security Notes

⚠️ **Important**: Always set a strong password in the `.env` file!

```env
REDIS_PASSWORD=YourVerySecurePassword123!
```

## Network Access

This configuration allows access from home network devices (192.168.x.x) only.

## Support

For issues, check the [full deployment guide](DEPLOYMENT.md).
