# Service Management

Comprehensive guide for managing your N8N self-hosted installation using the Task-based architecture.

## 🎯 Overview

Your N8N installation consists of several interconnected services:
- **N8N**: Core workflow automation engine
- **PostgreSQL**: Database for workflow data
- **Nginx**: Web server and reverse proxy
- **Docker**: Container orchestration
- **UFW/Fail2Ban**: Security services

## 📊 System Status

### Quick Status Check

```bash
# Overall system status
task status
```

This shows:
- ✅ Service health (running/stopped)
- 📊 Resource usage (CPU, memory, disk)
- 🌐 Network connectivity
- 🔒 Security status
- 💾 Backup status

### Detailed Status Checks

```bash
# Individual service status
task n8n:status              # N8N application status
task docker:status           # Docker service status
task nginx:status            # Nginx web server status
task security:status         # Security configuration status
task backup:status           # Backup system status
```

### Service Health Validation

```bash
# Comprehensive health check
task test:health-check

# Quick connectivity test
task test:connectivity

# Performance check
task test:performance
```

## 🔄 Service Control

### N8N Service Management

```bash
# Start N8N services
sudo task n8n:start

# Stop N8N services
sudo task n8n:stop

# Restart N8N services
sudo task n8n:restart

# Check N8N status
task n8n:status

# View N8N logs
task n8n:logs

# Follow N8N logs in real-time
task n8n:logs -- --follow
```

### Docker Container Management

```bash
# Start Docker services
sudo task docker:start

# Stop Docker services
sudo task docker:stop

# Restart Docker daemon
sudo task docker:restart

# Check Docker status
task docker:status

# View Docker logs
task docker:logs

# Clean up unused Docker resources
sudo task docker:clean
```

### Nginx Web Server Management

```bash
# Start Nginx
sudo task nginx:start

# Stop Nginx
sudo task nginx:stop

# Restart Nginx
sudo task nginx:restart

# Reload configuration (no downtime)
sudo task nginx:reload

# Check Nginx status
task nginx:status

# View Nginx logs
task nginx:logs

# Test Nginx configuration
sudo nginx -t
```

## 📝 Log Management

### Viewing Logs

```bash
# Main N8N application logs
task n8n:logs

# Nginx access and error logs
task nginx:logs

# Docker system logs
task docker:logs

# System logs related to N8N
sudo journalctl -u docker -f
```

### Log Analysis

```bash
# View last 50 lines
task n8n:logs -- --tail=50

# Follow logs in real-time
task n8n:logs -- --follow

# Filter logs by time
task n8n:logs -- --since="1h"

# Show logs with timestamps
task n8n:logs -- --timestamps
```

### Log Rotation

Logs are automatically rotated by Docker and systemd:
- **N8N logs**: Managed by Docker (max 10MB, 3 files)
- **Nginx logs**: Managed by logrotate (daily rotation)
- **System logs**: Managed by journald

Manual log cleanup:
```bash
# Clean Docker logs
sudo task docker:clean

# Truncate specific container logs
sudo truncate -s 0 /var/lib/docker/containers/*/∗-json.log
```

## 🔧 Configuration Management

### Environment Variables

Configuration is stored in `/opt/n8n/.env`:

```bash
# View current configuration
sudo cat /opt/n8n/.env

# Edit configuration
sudo nano /opt/n8n/.env

# Apply changes
sudo task n8n:restart
```

### Docker Compose Configuration

Main service configuration in `/opt/n8n/docker-compose.yml`:

```bash
# View docker-compose configuration
sudo cat /opt/n8n/docker-compose.yml

# Validate configuration
sudo docker-compose -f /opt/n8n/docker-compose.yml config

# Apply configuration changes
cd /opt/n8n && sudo docker-compose up -d
```

### Nginx Configuration

Nginx configuration in `/etc/nginx/sites-available/n8n`:

```bash
# View Nginx configuration
sudo cat /etc/nginx/sites-available/n8n

# Test configuration syntax
sudo nginx -t

# Reload configuration
sudo task nginx:reload

# Edit configuration
sudo nano /etc/nginx/sites-available/n8n
```

## 🚀 Performance Management

### Resource Monitoring

```bash
# Current resource usage
task status

# Detailed performance metrics
task test:performance

# Docker container resource usage
sudo docker stats

# System resource usage
htop
```

### Performance Optimization

```bash
# Apply system optimizations
sudo task system:optimize-performance

# Proxmox-specific optimizations (if applicable)
sudo task proxmox:optimize

# Clean up unused resources
sudo task docker:clean
```

### Scaling Considerations

For high-load environments:

1. **Increase N8N Workers**:
   ```bash
   # Edit /opt/n8n/.env
   N8N_CONCURRENCY_PRODUCTION=10
   ```

2. **Optimize Database**:
   ```bash
   # Edit PostgreSQL configuration
   sudo nano /opt/n8n/postgres.conf
   ```

3. **Resource Limits**:
   ```bash
   # Edit docker-compose.yml
   deploy:
     resources:
       limits:
         memory: 2G
         cpus: '1.0'
   ```

## 🔄 Updates and Maintenance

### N8N Updates

```bash
# Update N8N to latest version
sudo task n8n:update

# Check current version
task n8n:status

# View update logs
task n8n:logs
```

### System Updates

```bash
# Update system packages
sudo task system:update

# Update Docker
sudo apt update && sudo apt upgrade docker-ce docker-compose-plugin

# Update Nginx
sudo apt update && sudo apt upgrade nginx
```

### Maintenance Tasks

```bash
# Weekly maintenance routine
sudo task backup                    # Create backup
sudo task system:update            # Update system
task test:health-check             # Verify health
sudo task docker:clean             # Clean up resources
task security:audit               # Security check
```

## 🔒 Security Management

### Security Status

```bash
# Overall security status
task security:status

# Detailed security audit
sudo task security:audit

# Check security logs
task security:logs
```

### Firewall Management

```bash
# Configure firewall
sudo task security:firewall

# Check firewall status
sudo ufw status verbose

# View firewall logs
sudo tail -f /var/log/ufw.log
```

### Fail2Ban Management

```bash
# Configure Fail2Ban
sudo task security:fail2ban

# Check Fail2Ban status
sudo fail2ban-client status

# Check banned IPs
sudo fail2ban-client status sshd
```

## 🛠️ Troubleshooting

### Common Issues

**N8N not accessible**:
```bash
# Check all services
task status
task test:connectivity

# Check specific services
task n8n:status
task nginx:status
task docker:status
```

**Database connection issues**:
```bash
# Access database shell
sudo task n8n:db-shell

# Check database logs
task n8n:logs | grep -i postgres

# Restart database
cd /opt/n8n && sudo docker-compose restart postgres
```

**SSL certificate problems**:
```bash
# Check certificate status
task security:status

# Regenerate certificates
sudo task nginx:ssl

# Check Nginx configuration
sudo nginx -t
```

**High resource usage**:
```bash
# Check resource usage
task test:performance
sudo docker stats

# Optimize performance
sudo task system:optimize-performance
sudo task docker:clean
```

### Emergency Procedures

**Complete service restart**:
```bash
sudo task docker:restart
sudo task nginx:restart
sleep 30
task status
```

**Reset N8N data** (⚠️ **WARNING: Data loss**):
```bash
sudo task n8n:reset
```

**Restore from backup**:
```bash
task backup:list
sudo task backup:restore
```

## 📋 Maintenance Schedules

### Daily Tasks
- Monitor service status: `task status`
- Check logs for errors: `task n8n:logs`
- Verify connectivity: `task test:connectivity`

### Weekly Tasks
- Create manual backup: `sudo task backup`
- Update system packages: `sudo task system:update`
- Clean Docker resources: `sudo task docker:clean`
- Security audit: `sudo task security:audit`

### Monthly Tasks
- Update N8N: `sudo task n8n:update`
- Review and rotate logs
- Performance optimization: `sudo task system:optimize-performance`
- Backup verification: `task backup:verify`

## 🎛️ Advanced Management

### Container Shell Access

```bash
# Access N8N container shell
sudo task n8n:shell

# Access PostgreSQL shell
sudo task n8n:db-shell

# Direct Docker exec access
sudo docker exec -it n8n_n8n_1 /bin/sh
sudo docker exec -it n8n_postgres_1 psql -U n8n
```

### Configuration Templates

Create custom configurations:

```bash
# Custom N8N configuration
sudo cp /opt/n8n/.env /opt/n8n/.env.backup
sudo nano /opt/n8n/.env

# Custom Nginx configuration
sudo cp /etc/nginx/sites-available/n8n /etc/nginx/sites-available/n8n.backup
sudo nano /etc/nginx/sites-available/n8n
```

### Monitoring Integration

For external monitoring:

```bash
# Health check endpoint
curl -s https://your-domain/healthz

# Prometheus metrics (if enabled)
curl -s https://your-domain/metrics

# Custom monitoring script
sudo task test:health-check --format json
```

---

**Next Steps**:
- Set up [Backup & Restore](backup-restore.md) procedures
- Configure [Security](security.md) hardening
- Review [Performance Tuning](performance.md) options
- Explore [Task Commands](task-commands.md) reference