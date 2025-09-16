# Redis Docker Setup with RedisInsight GUI

A comprehensive Docker Compose setup for Redis with RedisInsight GUI interface, featuring persistent data storage and password authentication.

## Features

- **Official Redis Image**: Uses `redis:8.2.1` (Alpine Linux base)
- **RedisInsight GUI**: Web-based Redis management interface
- **Persistent Storage**: Data persists across container restarts using Docker volumes
- **Password Authentication**: Secure Redis access with configurable password
- **Easy Management**: Simple commands for start, stop, and maintenance
- **Production Ready**: Configured with restart policies and proper security

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- Ports 6379 (Redis) and 5540 (RedisInsight) available

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/skill-wanderer/redis-docker-volume.git
   cd redis-docker-volume
   ```

2. **Configure environment (optional):**
   ```bash
   # Copy example environment file
   cp .env.example .env
   
   # Edit .env to set your preferred Redis password
   # Default password: nFanr9rLHPTbtRFk
   ```

3. **Start the services:**
   ```bash
   docker-compose up -d
   ```

4. **Verify Redis is running:**
   ```bash
   docker-compose exec redis redis-cli -a nFanr9rLHPTbtRFk ping
   # Should return: PONG
   ```

## Services

### Redis Server
- **Container**: `my-redis-with-gui`
- **Image**: `redis:8.2.1`
- **Port**: 6379
- **Authentication**: Password protected
- **Persistence**: Docker volume mounted to `/data`

### RedisInsight GUI
- **Container**: `my-redis-gui`
- **Image**: `redis/redisinsight:latest`
- **Port**: 5540
- **Access**: http://localhost:5540
- **Purpose**: Web-based Redis management and monitoring

## Usage

### Basic Commands

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# View logs for all services
docker-compose logs -f

# View logs for specific service
docker-compose logs -f redis
docker-compose logs -f redis-gui

# Access Redis CLI with authentication
docker-compose exec redis redis-cli -a ${REDIS_PASSWORD}

# Check container status
docker-compose ps

# Restart services
docker-compose restart
```

### Using RedisInsight GUI

1. **Access the web interface:**
   - Open http://localhost:5540 in your browser
   - Accept the terms and conditions

2. **Connect to Redis:**
   - Click "Add Redis Database"
   - Host: `redis` (container name)
   - Port: `6379`
   - Password: Use the password from your `.env` file
   - Click "Add Redis Database"

3. **Explore Redis:**
   - Browse keys and data structures
   - Execute Redis commands
   - Monitor performance metrics
   - View memory usage and statistics

### Redis CLI Examples

```bash
# Connect to Redis with authentication
docker-compose exec redis redis-cli -a nFanr9rLHPTbtRFk

# Basic operations
redis> PING
PONG
redis> SET mykey "Hello World"
OK
redis> GET mykey
"Hello World"
redis> KEYS *
1) "mykey"

# Working with different data types
redis> LPUSH mylist item1 item2 item3
(integer) 3
redis> LRANGE mylist 0 -1
1) "item3"
2) "item2" 
3) "item1"

redis> HSET myhash field1 "value1" field2 "value2"
(integer) 2
redis> HGETALL myhash
1) "field1"
2) "value1"
3) "field2"
4) "value2"
```

## Configuration

### Environment Variables

The project uses a `.env` file for configuration:

```env
# Redis authentication password
REDIS_PASSWORD=nFanr9rLHPTbtRFk
```

**To change the password:**
1. Edit the `.env` file
2. Restart the services: `docker-compose restart`

### Docker Compose Configuration

The `docker-compose.yml` includes:
- Redis server with password authentication
- RedisInsight GUI for web-based management
- Named volumes for data persistence
- Restart policies for reliability

## Data Persistence

Redis data is automatically persisted using Docker named volumes:

- **`redis-data` volume**: Stores Redis database files (RDB snapshots, AOF logs)
- **`redis-insight-data` volume**: Stores RedisInsight configuration and data
- **Automatic persistence**: Data survives container restarts and updates
- **RDB + AOF**: Redis uses both snapshot and append-only file persistence by default

### Volume Management

```bash
# List Docker volumes
docker volume ls

# Inspect volume details
docker volume inspect redis-docker-volume_redis-data

# Backup volume data
docker run --rm -v redis-docker-volume_redis-data:/data -v $(pwd):/backup alpine tar czf /backup/redis-backup-$(date +%Y%m%d).tar.gz -C /data .

# Remove volumes (WARNING: This deletes all data)
docker-compose down -v
```

## Monitoring and Management

### Using RedisInsight (Recommended)

RedisInsight provides a comprehensive web-based interface:

- **Real-time metrics**: CPU, memory, commands per second
- **Key browser**: Explore and edit data structures visually
- **CLI interface**: Built-in Redis CLI with syntax highlighting
- **Performance analysis**: Slow log, memory analysis, profiler
- **Configuration management**: View and modify Redis settings

Access at: http://localhost:5540

### Command Line Monitoring

```bash
# Redis server information
docker-compose exec redis redis-cli -a nFanr9rLHPTbtRFk INFO

# Memory usage statistics
docker-compose exec redis redis-cli -a nFanr9rLHPTbtRFk INFO memory

# Connected clients
docker-compose exec redis redis-cli -a nFanr9rLHPTbtRFk INFO clients

# Monitor commands in real-time
docker-compose exec redis redis-cli -a nFanr9rLHPTbtRFk MONITOR

# Check slow queries
docker-compose exec redis redis-cli -a nFanr9rLHPTbtRFk SLOWLOG GET 10
```

### Container Health Monitoring

```bash
# Check container status
docker-compose ps

# View detailed container information
docker inspect my-redis-with-gui
docker inspect my-redis-gui

# Monitor resource usage
docker stats my-redis-with-gui my-redis-gui
```

## Backup and Restore

### Manual Backup

```bash
# Create RDB snapshot
docker-compose exec redis redis-cli -a nFanr9rLHPTbtRFk BGSAVE

# Create backup from volume
docker run --rm -v redis-docker-volume_redis-data:/data -v $(pwd):/backup alpine \
  tar czf /backup/redis-backup-$(date +%Y%m%d-%H%M%S).tar.gz -C /data .
```

### Automated Backup Script

Create a backup script (`backup.sh`):
```bash
#!/bin/bash
BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="redis-backup-$DATE.tar.gz"

mkdir -p $BACKUP_DIR

# Trigger Redis save
docker-compose exec -T redis redis-cli -a $REDIS_PASSWORD BGSAVE

# Wait for save to complete
sleep 5

# Create backup
docker run --rm \
  -v redis-docker-volume_redis-data:/data \
  -v $(pwd)/$BACKUP_DIR:/backup \
  alpine tar czf /backup/$BACKUP_FILE -C /data .

echo "Backup created: $BACKUP_DIR/$BACKUP_FILE"
```

### Restore from Backup

1. **Stop Redis services:**
   ```bash
   docker-compose down
   ```

2. **Remove existing data volume:**
   ```bash
   docker volume rm redis-docker-volume_redis-data
   ```

3. **Restore from backup:**
   ```bash
   docker run --rm \
     -v redis-docker-volume_redis-data:/data \
     -v $(pwd)/backups:/backup \
     alpine tar xzf /backup/redis-backup-YYYYMMDD-HHMMSS.tar.gz -C /data
   ```

4. **Start services:**
   ```bash
   docker-compose up -d
   ```

## Security

### Current Security Features

- **Password Authentication**: Redis requires password for all connections
- **Container Isolation**: Services run in isolated Docker containers
- **No External Network**: Redis only accessible via localhost or Docker network

### Additional Security Recommendations

1. **Change Default Password**: 
   ```bash
   # Edit .env file
   REDIS_PASSWORD=your_strong_password_here
   
   # Restart services
   docker-compose restart
   ```

2. **Restrict Network Access**: 
   - Keep Redis port (6379) closed to external access
   - Use Docker networks for inter-container communication
   - Consider using a reverse proxy for RedisInsight

3. **Regular Updates**:
   ```bash
   # Update to latest images
   docker-compose pull
   docker-compose up -d
   ```

4. **Enable Redis Security Features** (optional):
   Add a custom redis.conf to enable additional security settings

## Connecting External Applications

### From Other Docker Containers

Create a docker-compose.yml for your application:

```yaml
version: '3.8'

services:
  your-app:
    image: your-app:latest
    environment:
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - REDIS_PASSWORD=nFanr9rLHPTbtRFk
    depends_on:
      - redis
    networks:
      - redis-network

  redis:
    image: redis:8.2.1
    container_name: my-redis-with-gui
    command: redis-server --requirepass ${REDIS_PASSWORD}
    ports:
      - '6379:6379'
    volumes:
      - redis-data:/data
    networks:
      - redis-network

networks:
  redis-network:
    driver: bridge

volumes:
  redis-data:
```

### From Host Applications

Connection parameters:
- **Host**: `localhost`
- **Port**: `6379`
- **Password**: Value from `.env` file
- **Connection String**: `redis://:nFanr9rLHPTbtRFk@localhost:6379`

### Language-Specific Examples

**Python (redis-py):**
```python
import redis

r = redis.Redis(host='localhost', port=6379, password='nFanr9rLHPTbtRFk', decode_responses=True)
r.set('key', 'value')
print(r.get('key'))
```

**Node.js (ioredis):**
```javascript
const Redis = require('ioredis');
const redis = new Redis({
  host: 'localhost',
  port: 6379,
  password: 'nFanr9rLHPTbtRFk'
});

redis.set('key', 'value');
redis.get('key').then(result => console.log(result));
```

## Troubleshooting

### Common Issues

1. **Port already in use**:
   ```bash
   # Check what's using port 6379
   netstat -ano | findstr :6379
   
   # Or check port 5540 for RedisInsight
   netstat -ano | findstr :5540
   
   # Kill the process or change ports in docker-compose.yml
   ```

2. **Permission denied errors**:
   ```bash
   # Ensure Docker Desktop is running
   docker info
   
   # On Windows, ensure you're running PowerShell as Administrator if needed
   ```

3. **Container won't start**:
   ```bash
   # Check logs for specific error messages
   docker-compose logs redis
   docker-compose logs redis-gui
   
   # Common fixes:
   # - Ensure .env file exists with REDIS_PASSWORD
   # - Check ports are not occupied
   # - Verify Docker has enough resources allocated
   ```

4. **RedisInsight connection issues**:
   - Verify Redis container is running: `docker-compose ps`
   - Use container name `redis` as hostname in RedisInsight
   - Ensure correct password from `.env` file
   - Try connecting via `localhost` instead of `redis` if outside Docker

5. **Data not persisting**:
   ```bash
   # Verify volumes exist
   docker volume ls | grep redis
   
   # Check volume mount points
   docker inspect my-redis-with-gui | grep Mounts -A 10
   ```

### Performance Optimization

```bash
# Monitor memory usage
docker-compose exec redis redis-cli -a nFanr9rLHPTbtRFk INFO memory

# Check slow queries
docker-compose exec redis redis-cli -a nFanr9rLHPTbtRFk SLOWLOG GET 10

# Monitor key expiration
docker-compose exec redis redis-cli -a nFanr9rLHPTbtRFk INFO keyspace
```

### Log Analysis

```bash
# View recent logs
docker-compose logs --tail=50 redis

# Follow logs in real-time
docker-compose logs -f redis

# Check container resource usage
docker stats my-redis-with-gui my-redis-gui
```

## Project Structure

```
redis-docker-volume/
├── .env                    # Environment variables (Redis password)
├── .env.example           # Example environment file
├── .gitignore            # Git ignore rules
├── docker-compose.yml    # Docker Compose configuration
├── LICENSE              # Project license
├── README.md           # This file
├── data/               # Directory for additional data (currently empty)
├── logs/               # Directory for logs (currently empty)
└── scripts/            # Directory for utility scripts (currently empty)
```

## Useful Commands Reference

```bash
# Service Management
docker-compose up -d                    # Start services in background
docker-compose down                     # Stop and remove containers
docker-compose restart                  # Restart all services
docker-compose pull                     # Pull latest images

# Monitoring
docker-compose ps                       # Show running containers
docker-compose logs -f redis           # Follow Redis logs
docker-compose logs -f redis-gui       # Follow RedisInsight logs
docker stats my-redis-with-gui         # Show resource usage

# Redis Operations
docker-compose exec redis redis-cli -a $REDIS_PASSWORD        # Access Redis CLI
docker-compose exec redis redis-cli -a $REDIS_PASSWORD INFO   # Redis info
docker-compose exec redis redis-cli -a $REDIS_PASSWORD PING   # Test connection

# Volume Management
docker volume ls                                              # List volumes
docker volume inspect redis-docker-volume_redis-data         # Inspect volume
docker-compose down -v                                        # Remove with volumes
```

## Version Information

- **Redis**: 8.2.1 (Alpine Linux base)
- **RedisInsight**: Latest stable release
- **Docker Compose**: 3.8+
- **Supported Platforms**: Windows, macOS, Linux

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the terms in the LICENSE file.

---

**Quick Links:**
- [Redis Documentation](https://redis.io/docs/)
- [RedisInsight Documentation](https://redis.io/docs/stack/insight/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

For production deployments, consider Redis clustering, advanced monitoring solutions, and comprehensive backup strategies.