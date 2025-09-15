# Redis Docker Volume

A simple Docker Compose setup for Redis using the official Redis image with persistent data storage.

## Features

- **Official Redis Image**: Uses `redis:8.2.1` (latest stable)
- **Persistent Storage**: Data persists across container restarts
- **Custom Configuration**: Configurable Redis settings
- **Health Checks**: Built-in container health monitoring
- **Network Isolation**: Dedicated Docker network

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- Port 6379 available (or modify in docker-compose.yml)

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd redis-docker-volume
   ```

2. **Start Redis:**
   ```bash
   docker-compose up -d
   ```

3. **Verify Redis is running:**
   ```bash
   docker-compose exec redis redis-cli ping
   # Should return: PONG
   ```

## Usage

### Basic Commands

```bash
# Start Redis
docker-compose up -d

# Stop Redis
docker-compose down

# View logs
docker-compose logs -f redis

# Access Redis CLI
docker-compose exec redis redis-cli

# Check container status
docker-compose ps

# Restart Redis
docker-compose restart redis
```

### Redis CLI Examples

```bash
# Connect to Redis
docker-compose exec redis redis-cli

# Basic operations
redis> PING
PONG
redis> SET mykey "Hello World"
OK
redis> GET mykey
"Hello World"
redis> KEYS *
1) "mykey"
```

## Configuration

### Environment Variables

Create a `.env` file from `.env.example`:

```bash
cp .env.example .env
```

Edit `.env` to customize:
```env
REDIS_PASSWORD=your_secure_password
COMPOSE_PROJECT_NAME=redis-docker-volume
```

### Redis Configuration

Modify `redis.conf` to customize Redis settings:
- Memory limits (`maxmemory`)
- Persistence settings
- Security options (`requirepass`)
- Performance tuning

## Data Persistence

Redis data is automatically persisted using Docker volumes:

- **RDB Snapshots**: Point-in-time data snapshots
- **AOF Logging**: Append-only transaction log
- **Docker Volume**: `redis_data` volume stores all persistent data

## Monitoring

### Health Check

The container includes health checks:

```bash
# Check health status
docker-compose ps

# View detailed container info
docker inspect redis-server
```

### Performance Monitoring

```bash
# Redis statistics
docker-compose exec redis redis-cli INFO

# Memory usage
docker-compose exec redis redis-cli INFO memory

# Connected clients
docker-compose exec redis redis-cli INFO clients

# Monitor commands in real-time
docker-compose exec redis redis-cli MONITOR
```

## Backup and Restore

### Create Backup

```bash
# Create RDB snapshot
docker-compose exec redis redis-cli BGSAVE

# Copy backup file
docker cp redis-server:/data/dump.rdb ./backup-$(date +%Y%m%d).rdb
```

### Restore from Backup

1. Stop Redis: `docker-compose down`
2. Replace volume data with backup
3. Start Redis: `docker-compose up -d`

## Security

### Enable Password Authentication

1. Edit `redis.conf`:
   ```
   requirepass your_secure_password
   ```

2. Restart Redis:
   ```bash
   docker-compose restart redis
   ```

3. Connect with password:
   ```bash
   docker-compose exec redis redis-cli -a your_secure_password
   ```

## Advanced Usage

### Connecting External Applications

Other Docker containers can connect to Redis:

```yaml
services:
  app:
    image: your-app:latest
    networks:
      - redis_network
    environment:
      - REDIS_HOST=redis
      - REDIS_PORT=6379
    depends_on:
      - redis

networks:
  redis_network:
    external: true
```

### Production Considerations

1. **Security**: Enable password authentication
2. **Memory**: Set appropriate `maxmemory` limits
3. **Persistence**: Choose between RDB, AOF, or both
4. **Monitoring**: Implement proper monitoring and alerting
5. **Backup**: Regular automated backups
6. **Network**: Use Docker networks for isolation

## Troubleshooting

### Common Issues

1. **Port 6379 in use**:
   ```bash
   # Find what's using the port
   netstat -tlnp | grep :6379
   # Change port in docker-compose.yml if needed
   ```

2. **Permission errors**:
   ```bash
   # Check Docker daemon is running
   docker info
   ```

3. **Container won't start**:
   ```bash
   # Check logs for errors
   docker-compose logs redis
   ```

### Performance Issues

- Monitor memory usage with `INFO memory`
- Adjust `maxmemory-policy` based on use case
- Tune persistence settings for performance vs durability
- Use `SLOWLOG` to identify slow queries

## Versions

- **Redis**: 8.2.1 (Alpine Linux base)
- **Docker Compose**: 3.8+

## License

This project is licensed under the terms in the LICENSE file.

---

For production deployments, consider Redis clustering, monitoring tools like RedisInsight, and proper backup strategies.