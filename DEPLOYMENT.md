# Ubuntu Server Deployment Guide

This guide will help you deploy Redis securely on your Ubuntu server with proper data storage and security configurations.

## Secure Storage Location

Redis data will be stored in `/opt/redis/data/` which provides:

✅ **Security**: Proper file permissions and ownership  
✅ **Persistence**: Data survives system reboots  
✅ **Backup**: Easy to backup and restore  
✅ **Monitoring**: Centralized logging  
✅ **Scalability**: Can be mounted on separate disk  

## Directory Structure on Ubuntu Server

```
/opt/redis/
├── data/              # Redis data files (RDB, AOF)
├── backups/           # Automated backups
├── config/            # Configuration files
└── backup-redis.sh    # Backup script

/var/log/redis/        # Redis logs
├── redis-server.log   # Main Redis log
└── backup.log         # Backup operation log
```

## Deployment Steps

### 1. Upload Files to Server

```bash
# Copy project to server
scp -r redis-docker-volume/ user@your-server:/home/user/

# Connect to server
ssh user@your-server
cd redis-docker-volume
```

### 2. Run Server Setup Script

```bash
# Make script executable and run
chmod +x deploy-server.sh
sudo ./deploy-server.sh
```

This script will:
- Install Docker and Docker Compose
- Create secure directories with proper permissions
- Set up firewall rules
- Configure automated backups
- Create Redis system user
- Set up log rotation

### 3. Configure Production Settings

```bash
# Copy production environment file
cp .env.production .env

# Edit with your secure password
nano .env
```

**Important**: Change the default password in `.env`:
```env
REDIS_PASSWORD=YourVerySecurePassword123!
```

### 4. Update Redis Configuration

```bash
# Edit production Redis config
nano redis.prod.conf
```

Uncomment and set password:
```conf
requirepass YourVerySecurePassword123!
```

### 5. Deploy Redis

```bash
# Start Redis in production mode
docker-compose -f docker-compose.prod.yml up -d

# Verify deployment
docker-compose -f docker-compose.prod.yml ps
```

### 6. Test Connection

```bash
# Test Redis connection locally
docker-compose -f docker-compose.prod.yml exec redis redis-cli -a YourVerySecurePassword123! ping

# Should return: PONG
```

### 7. Connect from Other Devices on Home Network

```bash
# From another device on your home network (192.168.x.x)
redis-cli -h YOUR_SERVER_IP -p 6379 -a YourVerySecurePassword123!

# Example: if your server IP is 192.168.1.100
redis-cli -h 192.168.1.100 -p 6379 -a YourVerySecurePassword123! ping
```

**Find your server IP (should be 192.168.x.x):**
```bash
ip addr show | grep "192.168"
# or
hostname -I | grep -o "192\.168\.[0-9]*\.[0-9]*"
```

**Note**: Only devices with IP addresses in the range 192.168.0.0 to 192.168.255.255 can connect.

## Security Features

### 1. **Network Security**
- Redis accessible only from home network (192.168.0.0/16)
- Firewall blocks access from other networks
- Fail2ban protection against brute force
- Strong password authentication required

### 2. **File System Security**
- Dedicated Redis user with minimal privileges
- Secure directory permissions (750)
- Read-only container filesystem

### 3. **Redis Security**
- Password authentication required
- Dangerous commands disabled/renamed
- Protected mode enabled
- Connection limits enforced

### 4. **Data Protection**
- Both RDB and AOF persistence enabled
- Daily automated backups
- Log rotation configured
- Backup retention policy (7 days)

## Monitoring and Maintenance

### Check Redis Status
```bash
# Container status
docker-compose -f docker-compose.prod.yml ps

# Redis info
docker-compose -f docker-compose.prod.yml exec redis redis-cli -a PASSWORD info server
```

### View Logs
```bash
# Redis logs
sudo tail -f /var/log/redis/redis-server.log

# Docker container logs
docker-compose -f docker-compose.prod.yml logs -f redis
```

### Manual Backup
```bash
# Run backup script
sudo -u redis /opt/redis/backup-redis.sh

# List backups
sudo ls -la /opt/redis/backups/
```

### Performance Monitoring
```bash
# Memory usage
docker-compose -f docker-compose.prod.yml exec redis redis-cli -a PASSWORD info memory

# Client connections
docker-compose -f docker-compose.prod.yml exec redis redis-cli -a PASSWORD client list

# Slow queries
docker-compose -f docker-compose.prod.yml exec redis redis-cli -a PASSWORD slowlog get 10
```

## Backup and Recovery

### Automated Backups
- Daily backups at 2 AM
- Stored in `/opt/redis/backups/`
- Compressed with gzip
- 7-day retention policy

### Manual Restore
```bash
# Stop Redis
docker-compose -f docker-compose.prod.yml down

# Restore backup
sudo gunzip /opt/redis/backups/redis_backup_YYYYMMDD_HHMMSS.rdb.gz
sudo cp /opt/redis/backups/redis_backup_YYYYMMDD_HHMMSS.rdb /opt/redis/data/dump.rdb
sudo chown redis:redis /opt/redis/data/dump.rdb

# Start Redis
docker-compose -f docker-compose.prod.yml up -d
```

## Production Recommendations

1. **Resource Allocation**: Adjust `maxmemory` in redis.prod.conf based on your server RAM
2. **SSL/TLS**: Consider setting up Redis with SSL for encrypted connections
3. **Monitoring**: Set up monitoring with tools like Prometheus + Grafana
4. **Alerts**: Configure alerts for memory usage, connection limits, and backup failures
5. **Updates**: Regularly update Redis Docker image for security patches

## Troubleshooting

### Common Issues

1. **Permission Denied**:
   ```bash
   sudo chown -R redis:redis /opt/redis
   ```

2. **Connection Refused**:
   - Check if Docker is running: `sudo systemctl status docker`
   - Check firewall: `sudo ufw status`

3. **Connection Refused from Home Network**:
   - Check if device IP is in 192.168.x.x range: `ip addr`
   - Test firewall rules: `sudo ufw status numbered`
   - Check if Redis is listening: `netstat -tlnp | grep :6379`
   - Test with telnet: `telnet YOUR_SERVER_IP 6379`

4. **Out of Memory**:
   - Adjust `maxmemory` in redis.prod.conf
   - Check memory usage: `docker stats`

### Support Commands
```bash
# System resources
free -h
df -h /opt/redis
docker system df

# Network check
netstat -tlnp | grep :6379
sudo ufw status numbered
```

This setup provides enterprise-grade security and reliability for your Redis deployment on Ubuntu server.
