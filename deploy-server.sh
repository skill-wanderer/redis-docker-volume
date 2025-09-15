#!/bin/bash

# Redis Server Deployment Script for Ubuntu
# This script sets up secure Redis storage and deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}[SETUP]${NC} $1"
}

# Configuration
REDIS_DATA_DIR="/opt/redis/data"
REDIS_BACKUP_DIR="/opt/redis/backups"
REDIS_LOGS_DIR="/var/log/redis"
REDIS_USER="redis"
REDIS_GROUP="redis"

print_header "Redis Secure Server Setup for Ubuntu"
echo "=============================================="

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_warning "Running as root. This is normal for server setup."
else
    print_error "This script needs to be run with sudo privileges"
    echo "Usage: sudo ./deploy-server.sh"
    exit 1
fi

# Update system packages
print_status "Updating system packages..."
apt-get update -qq

# Install required packages
print_status "Installing required packages..."
apt-get install -y docker.io docker-compose-v2 ufw fail2ban

# Start Docker service
print_status "Starting Docker service..."
systemctl start docker
systemctl enable docker

# Create Redis system user and group
print_status "Creating Redis system user and group..."
if ! getent group $REDIS_GROUP > /dev/null 2>&1; then
    groupadd --system $REDIS_GROUP
fi

if ! getent passwd $REDIS_USER > /dev/null 2>&1; then
    useradd --system --gid $REDIS_GROUP --home-dir /opt/redis --shell /bin/false $REDIS_USER
fi

# Create secure directory structure
print_status "Creating secure directory structure..."
mkdir -p $REDIS_DATA_DIR
mkdir -p $REDIS_BACKUP_DIR  
mkdir -p $REDIS_LOGS_DIR
mkdir -p /opt/redis/config

# Set secure permissions
print_status "Setting secure permissions..."
chown -R $REDIS_USER:$REDIS_GROUP /opt/redis
chown -R $REDIS_USER:$REDIS_GROUP $REDIS_LOGS_DIR
chmod 750 /opt/redis
chmod 750 $REDIS_DATA_DIR
chmod 750 $REDIS_BACKUP_DIR
chmod 755 $REDIS_LOGS_DIR

# Configure firewall
print_status "Configuring firewall..."
ufw --force enable
ufw allow ssh

# Allow Redis only from home network (192.168.0.0/16)
ufw allow from 192.168.0.0/16 to any port 6379 comment 'Redis home network only'

# Explicitly deny Redis from other networks
ufw deny 6379 comment 'Block Redis from non-home networks'

# Configure fail2ban for additional security
print_status "Configuring fail2ban..."
cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
EOF

systemctl restart fail2ban

# Create backup script
print_status "Creating backup script..."
cat > /opt/redis/backup-redis.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="/opt/redis/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="redis_backup_${TIMESTAMP}"

# Create Redis backup
docker-compose exec -T redis redis-cli BGSAVE

# Wait for backup to complete
sleep 5

# Copy backup files
if [ -f "/opt/redis/data/dump.rdb" ]; then
    cp /opt/redis/data/dump.rdb "${BACKUP_DIR}/${BACKUP_FILE}.rdb"
    gzip "${BACKUP_DIR}/${BACKUP_FILE}.rdb"
    echo "Backup created: ${BACKUP_DIR}/${BACKUP_FILE}.rdb.gz"
fi

if [ -f "/opt/redis/data/appendonly.aof" ]; then
    cp /opt/redis/data/appendonly.aof "${BACKUP_DIR}/${BACKUP_FILE}.aof"
    gzip "${BACKUP_DIR}/${BACKUP_FILE}.aof"
    echo "AOF backup created: ${BACKUP_DIR}/${BACKUP_FILE}.aof.gz"
fi

# Clean old backups (keep 7 days)
find ${BACKUP_DIR} -name "redis_backup_*.gz" -mtime +7 -delete

# Set permissions
chown $REDIS_USER:$REDIS_GROUP ${BACKUP_DIR}/redis_backup_${TIMESTAMP}.*
EOF

chmod +x /opt/redis/backup-redis.sh
chown $REDIS_USER:$REDIS_GROUP /opt/redis/backup-redis.sh

# Create daily backup cron job
print_status "Setting up daily backups..."
cat > /etc/cron.d/redis-backup << EOF
# Daily Redis backup at 2 AM
0 2 * * * $REDIS_USER /opt/redis/backup-redis.sh >> $REDIS_LOGS_DIR/backup.log 2>&1
EOF

# Create log rotation configuration
print_status "Configuring log rotation..."
cat > /etc/logrotate.d/redis << EOF
$REDIS_LOGS_DIR/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
    su $REDIS_USER $REDIS_GROUP
}
EOF

# Copy Redis configuration if it exists
if [ -f "redis.conf" ]; then
    print_status "Copying Redis configuration..."
    cp redis.conf /opt/redis/config/
    chown $REDIS_USER:$REDIS_GROUP /opt/redis/config/redis.conf
    chmod 640 /opt/redis/config/redis.conf
fi

# Display security recommendations
print_header "Security Recommendations"
echo "=============================================="
echo "1. Change default Redis password in redis.conf"
echo "2. Configure SSL/TLS if needed"
echo "3. Regularly update Docker images"
echo "4. Monitor logs in $REDIS_LOGS_DIR"
echo "5. Test backups regularly"
echo

print_status "Server setup completed successfully!"
print_status "Redis data will be stored in: $REDIS_DATA_DIR"
print_status "Backups will be stored in: $REDIS_BACKUP_DIR"
print_status "Logs will be stored in: $REDIS_LOGS_DIR"

echo
print_header "Next Steps:"
echo "1. Deploy your Redis: docker-compose up -d"
echo "2. Test connection: docker-compose exec redis redis-cli ping"
echo "3. Check logs: tail -f $REDIS_LOGS_DIR/*.log"
echo "4. Run manual backup: /opt/redis/backup-redis.sh"
