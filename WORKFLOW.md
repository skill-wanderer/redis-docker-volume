# 🚀 Redis Ubuntu Server Deployment Workflow

Complete step-by-step guide to deploy Redis on Ubuntu server from GitHub.

## 📋 Prerequisites

- Ubuntu Server 20.04+ (fresh or existing)
- SSH access to the server
- Internet connection on server
- Basic command line knowledge

## 🔧 Method 1: One-Command Quick Deploy (Recommended)

### Step 1: Connect to Server
```bash
ssh user@your-server-ip
```

### Step 2: Run Quick Deploy
```bash
curl -sSL https://raw.githubusercontent.com/skill-wanderer/redis-docker-volume/main/quick-deploy.sh | sudo bash
```

### Step 3: Configure Password
```bash
cd /opt/redis/compose
sudo nano .env
```
**Change this line:**
```env
REDIS_PASSWORD=YourVerySecurePassword123!
```

### Step 4: Start Redis
```bash
sudo docker-compose -f docker-compose.prod.yml up -d
```

### Step 5: Test Connection
```bash
sudo docker-compose -f docker-compose.prod.yml exec redis redis-cli -a YourVerySecurePassword123! ping
```

**Expected output:** `PONG`

---

## 🔧 Method 2: Manual Step-by-Step

### Step 1: Connect to Server
```bash
ssh user@your-server-ip
```

### Step 2: Update System
```bash
sudo apt update
sudo apt upgrade -y
```

### Step 3: Install Docker
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt install -y docker-compose

# Add user to docker group (optional)
sudo usermod -aG docker $USER
```

### Step 4: Download Redis Files
```bash
# Create deployment directory
mkdir -p ~/redis-deploy
cd ~/redis-deploy

# Download necessary files
curl -O https://raw.githubusercontent.com/skill-wanderer/redis-docker-volume/main/docker-compose.prod.yml
curl -O https://raw.githubusercontent.com/skill-wanderer/redis-docker-volume/main/redis.prod.conf
curl -O https://raw.githubusercontent.com/skill-wanderer/redis-docker-volume/main/.env.production
curl -O https://raw.githubusercontent.com/skill-wanderer/redis-docker-volume/main/deploy-server.sh
```

### Step 5: Run Server Setup
```bash
chmod +x deploy-server.sh
sudo ./deploy-server.sh
```

### Step 6: Configure Environment
```bash
cp .env.production .env
nano .env
```
**Set secure password:**
```env
REDIS_PASSWORD=YourVerySecurePassword123!
```

### Step 7: Start Redis
```bash
sudo docker-compose -f docker-compose.prod.yml up -d
```

### Step 8: Verify Installation
```bash
# Check container status
sudo docker-compose -f docker-compose.prod.yml ps

# Test Redis connection
sudo docker-compose -f docker-compose.prod.yml exec redis redis-cli -a YourVerySecurePassword123! ping
```

---

## 🔧 Method 3: Git Clone (Full Development Setup)

### Step 1: Install Git and Clone
```bash
sudo apt install -y git
git clone https://github.com/skill-wanderer/redis-docker-volume.git
cd redis-docker-volume
```

### Step 2: Run Setup
```bash
sudo ./deploy-server.sh
```

### Step 3: Configure
```bash
cp .env.production .env
nano .env
```

### Step 4: Deploy
```bash
sudo docker-compose -f docker-compose.prod.yml up -d
```

---

## 🧪 Testing and Verification

### 1. Check Container Health
```bash
# Container status
sudo docker-compose -f docker-compose.prod.yml ps

# Container logs
sudo docker-compose -f docker-compose.prod.yml logs redis

# Health check
sudo docker inspect redis-production | grep -A 5 Health
```

### 2. Test Redis Operations
```bash
# Connect to Redis CLI
sudo docker-compose -f docker-compose.prod.yml exec redis redis-cli -a YourPassword

# Inside Redis CLI, test commands:
redis> PING
redis> SET test "Hello Redis"
redis> GET test
redis> INFO server
redis> EXIT
```

### 3. Test Network Access
```bash
# Find server IP
ip addr show | grep "192.168"

# From another device on home network (192.168.x.x):
redis-cli -h YOUR_SERVER_IP -p 6379 -a YourPassword ping
```

### 4. Check Security
```bash
# Verify firewall rules
sudo ufw status

# Check listening ports
sudo netstat -tlnp | grep :6379

# Verify Redis security
sudo docker-compose -f docker-compose.prod.yml exec redis redis-cli -a YourPassword CONFIG GET "*password*"
```

---

## 📊 Monitoring and Maintenance

### Daily Operations
```bash
# Check status
sudo docker-compose -f docker-compose.prod.yml ps

# View logs
sudo docker-compose -f docker-compose.prod.yml logs -f redis

# Check Redis memory usage
sudo docker-compose -f docker-compose.prod.yml exec redis redis-cli -a YourPassword INFO memory
```

### Backup Operations
```bash
# Manual backup
sudo /opt/redis/backup-redis.sh

# Check backups
sudo ls -la /opt/redis/backups/

# View backup logs
sudo tail -f /var/log/redis/backup.log
```

### Updates
```bash
# Update Redis image
sudo docker-compose -f docker-compose.prod.yml pull
sudo docker-compose -f docker-compose.prod.yml up -d

# Check system updates
sudo apt update && sudo apt upgrade -y
```

---

## 🛠️ Troubleshooting

### Common Issues and Solutions

**1. Permission Denied:**
```bash
sudo chown -R redis:redis /opt/redis
sudo chmod 750 /opt/redis/data
```

**2. Port Already in Use:**
```bash
sudo netstat -tlnp | grep :6379
# Kill process using port or change port in docker-compose.prod.yml
```

**3. Can't Connect from Home Network:**
```bash
# Check your device IP is 192.168.x.x
ip addr

# Test firewall
sudo ufw status numbered

# Test connectivity
telnet YOUR_SERVER_IP 6379
```

**4. Container Won't Start:**
```bash
# Check logs for errors
sudo docker-compose -f docker-compose.prod.yml logs redis

# Check disk space
df -h

# Check memory
free -h
```

**5. Redis Authentication Issues:**
```bash
# Verify password in environment
cat .env | grep REDIS_PASSWORD

# Check Redis config
sudo docker-compose -f docker-compose.prod.yml exec redis redis-cli -a YourPassword CONFIG GET requirepass
```

---

## 🔒 Security Checklist

After deployment, verify:

- [ ] Strong password set in `.env` file
- [ ] Firewall allows only 192.168.x.x networks
- [ ] Redis protected mode is enabled
- [ ] Dangerous commands are disabled/renamed
- [ ] Backups are working (check `/opt/redis/backups/`)
- [ ] Log rotation is configured
- [ ] Container has security restrictions (read-only, no-new-privileges)

---

## 🌐 Connecting Applications

### From Python:
```python
import redis
r = redis.Redis(
    host='YOUR_SERVER_IP',  # e.g., '192.168.1.100'
    port=6379,
    password='YourVerySecurePassword123!'
)
print(r.ping())  # Should return True
```

### From Node.js:
```javascript
const redis = require('redis');
const client = redis.createClient({
    host: 'YOUR_SERVER_IP',
    port: 6379,
    password: 'YourVerySecurePassword123!'
});
client.ping(console.log);
```

### From Command Line (any device on home network):
```bash
redis-cli -h YOUR_SERVER_IP -p 6379 -a YourVerySecurePassword123!
```

---

## 📞 Getting Help

If you encounter issues:

1. Check the logs: `sudo docker-compose -f docker-compose.prod.yml logs redis`
2. Review [DEPLOYMENT.md](DEPLOYMENT.md) for detailed troubleshooting
3. Verify your network setup matches 192.168.x.x range
4. Ensure password is correctly set in `.env` file

---

## 🎉 Success!

If everything works correctly, you now have:

- ✅ Redis 8.2.1 running in Docker
- ✅ Data stored securely in `/opt/redis/data/`
- ✅ Accessible from all home network devices (192.168.x.x)
- ✅ Automatic backups every day at 2 AM
- ✅ Security hardened with firewall rules
- ✅ Production-ready monitoring and logging

**Your Redis server is ready for production use!** 🚀
