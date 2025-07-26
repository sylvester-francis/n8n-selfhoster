# Troubleshooting Guide

This guide covers common issues and their solutions for the N8N self-hosted installation, including Proxmox VM-specific issues.

## Proxmox VM Issues

### Installation Timeout Errors

**Issue**: Nginx shows "504 Gateway Timeout" when accessing N8N  
**Cause**: N8N takes longer to start in VM environments  
**Solution**: The installer now automatically applies extended timeouts (300s vs 60s)

```bash
# Verify timeout settings are applied
grep "proxy_.*_timeout" /etc/nginx/sites-available/n8n

# Should show:
# proxy_connect_timeout 300s;
# proxy_send_timeout 300s;
# proxy_read_timeout 300s;
```

### Curl Installation Failures

**Issue**: One-line curl installation fails in Proxmox VMs  
**Cause**: Network restrictions or curl limitations in VMs  
**Solution**: Use local installation method

```bash
# Clone and install locally
git clone https://github.com/sylvester-francis/n8n-selfhoster.git
cd n8n-selfhoster
sudo ./install-proxmox.sh --yes
```

### Slow N8N Startup

**Issue**: N8N takes 5+ minutes to become available  
**Cause**: VM overhead and resource constraints  
**Solution**: This is normal for VMs, extended validation is automatic

```bash
# Monitor N8N startup progress
cd /opt/n8n && docker-compose logs -f n8n

# Check direct access (should work first)
curl -s http://localhost:5678

# Check proxy access (may take longer)
curl -k -s https://localhost
```

### VM Resource Issues

**Issue**: Installation fails due to insufficient resources  
**Cause**: VM allocated insufficient RAM/CPU/disk  
**Solution**: Increase VM resources

```bash
# Check current resources
free -h                    # Memory
df -h                      # Disk space
nproc                      # CPU cores
systemd-detect-virt        # Virtualization type

# Recommended minimums for Proxmox VMs:
# RAM: 2GB (4GB preferred)
# CPU: 1 core (2+ preferred)  
# Disk: 20GB (SSD preferred)
```

### Self-Signed Certificate Issues

**Issue**: Browser shows certificate warnings when accessing from host  
**Cause**: Self-signed certificates not trusted by host OS  
**Solutions**:

#### Option 1: Accept Warning (Simplest)
1. Click "Advanced" in browser
2. Click "Proceed to [VM_IP] (unsafe)"

#### Option 2: Trust Certificate (macOS)
```bash
# Download certificate from VM
scp root@VM_IP:/etc/ssl/certs/n8n-selfsigned.crt ./

# Add to macOS keychain
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain n8n-selfsigned.crt
```

#### Option 3: Use Let's Encrypt (Production)
```bash
# If you have a domain pointing to your VM
sudo certbot --nginx -d yourdomain.com
```

### VM Network Configuration

**Issue**: Cannot access N8N from outside the VM  
**Cause**: Network configuration issues  
**Solutions**:

```bash
# Check VM IP and network config
ip addr show
ip route show

# Check firewall status
sudo ufw status

# Check if ports are listening
sudo netstat -tlnp | grep -E ':(80|443|5678)'

# Test connectivity from VM to internet
curl -s https://google.com

# Verify Docker networking
docker network ls
cd /opt/n8n && docker-compose ps
```

### Performance Issues in VMs

**Issue**: N8N runs slowly in Proxmox VM  
**Cause**: VM overhead and resource constraints  
**Solutions**:

```bash
# Enable hardware virtualization in Proxmox VM settings
# Use VirtIO drivers for better performance
# Allocate more CPU cores and RAM

# Check current resource usage
htop
docker stats

# Monitor disk I/O
iostat -x 1

# Check VM-specific optimizations are applied
grep -r "PROXMOX\|proxmox" /opt/n8n/ || echo "Standard installation"
```

## SSH Connection Issues

### Permission Denied Errors

**Issue**: Cannot SSH to server  
**Solutions**:

#### Option 1: Use Password Authentication
```bash
# Force password authentication
ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no root@YOUR_SERVER_IP
```

#### Option 2: Use DigitalOcean Console
1. Go to [DigitalOcean Dashboard](https://cloud.digitalocean.com)
2. Click your droplet name
3. Click **"Access"** tab
4. Click **"Launch Droplet Console"**
5. Login as `root` with your password

#### Option 3: Enable Password Authentication
```bash
# In the console, edit SSH config
nano /etc/ssh/sshd_config

# Change this line:
PasswordAuthentication yes

# Restart SSH
systemctl restart sshd
```

### Connection Refused

**Issue**: SSH connection refused  
**Solutions**:

```bash
# Check if droplet is running
# Verify correct IP address
# Try from different network

# Check SSH service status (in console)
systemctl status ssh
systemctl start ssh
```

## Installation Issues

### Script Fails During Installation

**Issue**: Installer script fails  
**Solutions**:

```bash
# Check installation log
tail -f /tmp/n8n-installer.log

# Check system resources
free -h
df -h

# Retry installation
sudo ./n8n_installer_script.sh
```

### Docker Installation Fails

**Issue**: Docker installation errors  
**Solutions**:

```bash
# Remove partial Docker installation
apt remove docker docker-engine docker.io containerd runc

# Clean up
apt autoremove
apt autoclean

# Retry installation
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### Port Already in Use

**Issue**: Port 80/443 already in use  
**Solutions**:

```bash
# Check what's using the ports
netstat -tlnp | grep :80
netstat -tlnp | grep :443

# Stop conflicting services
systemctl stop apache2  # if Apache is installed
systemctl stop nginx    # if Nginx is already running

# Disable conflicting services
systemctl disable apache2
```

## Service Issues

### N8N Not Starting

**Issue**: N8N containers not starting  
**Solutions**:

```bash
# Check container status
cd /opt/n8n
docker-compose ps

# Check logs
docker-compose logs n8n
docker-compose logs postgres

# Restart services
docker-compose down
docker-compose up -d

# Check system resources
htop
df -h
```

### Database Connection Issues

**Issue**: N8N cannot connect to PostgreSQL  
**Solutions**:

```bash
# Check PostgreSQL container
docker-compose logs postgres

# Check database health
docker-compose exec postgres pg_isready -U n8n

# Reset database (WARNING: loses data)
docker-compose down -v
docker-compose up -d
```

### Nginx Issues

**Issue**: Nginx not starting or serving errors  
**Solutions**:

```bash
# Test Nginx configuration
nginx -t

# Check Nginx logs
tail -f /var/log/nginx/error.log
tail -f /var/log/nginx/access.log

# Restart Nginx
systemctl restart nginx

# Check if Nginx is running
systemctl status nginx
```

## Access Issues

### Cannot Access N8N Web Interface

**Issue**: Browser cannot reach N8N  
**Solutions**:

```bash
# Check if N8N is responding locally
curl -I http://localhost:5678

# Check if HTTPS is working
curl -k -I https://localhost

# Check firewall
ufw status

# Check if ports are open
netstat -tlnp | grep :443
netstat -tlnp | grep :80
```

### SSL Certificate Issues

**Issue**: Browser shows SSL warnings  
**Solutions**:

For self-signed certificates (development):
- Click "Advanced" in browser
- Click "Proceed to site (unsafe)"
- This is normal for self-signed certificates

For Let's Encrypt issues:
```bash
# Check certificate status
certbot certificates

# Renew certificate
certbot renew

# Check Nginx SSL configuration
nginx -t
```

### Authentication Issues

**Issue**: Cannot login to N8N  
**Solutions**:

```bash
# Check credentials file
cat /opt/n8n/credentials.txt

# Reset admin password
cd /opt/n8n
docker-compose down
# Edit docker-compose.yml to change N8N_BASIC_AUTH_PASSWORD
docker-compose up -d
```

## Performance Issues

### N8N Running Slowly

**Issue**: N8N is slow or unresponsive  
**Solutions**:

```bash
# Check system resources
htop
free -m
df -h

# Check N8N logs for errors
docker-compose logs n8n | tail -100

# Restart N8N
docker-compose restart n8n

# Check for memory issues
dmesg | grep -i "killed process"
```

### Database Performance Issues

**Issue**: Database queries are slow  
**Solutions**:

```bash
# Check PostgreSQL performance
docker-compose exec postgres psql -U n8n -d n8n -c "SELECT pg_stat_database.datname, pg_size_pretty(pg_database_size(pg_database.datname)) AS size FROM pg_database JOIN pg_stat_database ON pg_database.datname = pg_stat_database.datname;"

# Analyze slow queries
docker-compose exec postgres psql -U n8n -d n8n -c "SELECT query, calls, total_time, mean_time FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;"

# Restart PostgreSQL
docker-compose restart postgres
```

## Backup and Recovery Issues

### Backup Script Fails

**Issue**: Automated backups not working  
**Solutions**:

```bash
# Check backup script permissions
ls -la /opt/n8n/backup.sh

# Test backup script manually
/opt/n8n/backup.sh

# Check backup logs
tail -f /var/log/n8n-backup.log

# Check cron job
crontab -l | grep backup
```

### Restore from Backup

**Issue**: Need to restore N8N from backup  
**Solutions**:

```bash
# Stop N8N
cd /opt/n8n
docker-compose down

# List available backups
ls -la /opt/n8n/backups/

# Restore N8N data
docker run --rm -v n8n_n8n_data:/data -v /opt/n8n/backups:/backup alpine \
    sh -c "cd /data && rm -rf * && tar xzf /backup/n8n_data_YYYYMMDD_HHMMSS.tar.gz"

# Restore PostgreSQL data
docker run --rm -v n8n_postgres_data:/data -v /opt/n8n/backups:/backup alpine \
    sh -c "cd /data && rm -rf * && tar xzf /backup/postgres_data_YYYYMMDD_HHMMSS.tar.gz"

# Start N8N
docker-compose up -d
```

## Network Issues

### Firewall Blocking Access

**Issue**: UFW blocking legitimate traffic  
**Solutions**:

```bash
# Check firewall rules
ufw status numbered

# Allow specific IP
ufw allow from YOUR_IP_ADDRESS

# Temporarily disable firewall (for testing)
ufw disable
# Remember to re-enable: ufw enable
```

### DNS Issues

**Issue**: Domain not resolving correctly  
**Solutions**:

```bash
# Check DNS resolution
nslookup your-domain.com
dig your-domain.com

# Check if DNS has propagated
# Use online tools like whatsmydns.net

# Flush DNS cache (on client)
# Windows: ipconfig /flushdns
# Mac: sudo dscacheutil -flushcache
# Linux: sudo systemctl restart systemd-resolved
```

## Update Issues

### N8N Update Fails

**Issue**: Cannot update N8N to latest version  
**Solutions**:

```bash
# Check current version
cd /opt/n8n
docker-compose exec n8n n8n --version

# Pull latest images
docker-compose pull

# Restart with new images
docker-compose down
docker-compose up -d

# Check for breaking changes in N8N release notes
```

### System Update Issues

**Issue**: Ubuntu system updates fail  
**Solutions**:

```bash
# Fix broken packages
apt --fix-broken install

# Clean package cache
apt clean
apt autoclean

# Update package lists
apt update

# Retry upgrade
apt upgrade
```

## Log Files and Debugging

### Important Log Locations

```bash
# N8N logs
docker-compose logs n8n

# PostgreSQL logs
docker-compose logs postgres

# Nginx logs
tail -f /var/log/nginx/error.log
tail -f /var/log/nginx/access.log

# Installation log
tail -f /tmp/n8n-installer.log

# Backup logs
tail -f /var/log/n8n-backup.log

# System logs
journalctl -u docker
journalctl -u nginx
dmesg | tail -50
```

### Enable Debug Logging

```bash
# Enable N8N debug logging
cd /opt/n8n
# Edit docker-compose.yml
# Change: N8N_LOG_LEVEL=info
# To: N8N_LOG_LEVEL=debug

docker-compose up -d
```

## Emergency Recovery

### Complete System Recovery

If everything fails, here's how to completely reinstall:

```bash
# Stop all services
cd /opt/n8n
docker-compose down -v

# Remove N8N installation
rm -rf /opt/n8n

# Remove Docker containers and images
docker system prune -a --volumes

# Remove Nginx configuration
rm -f /etc/nginx/sites-enabled/n8n
rm -f /etc/nginx/sites-available/n8n

# Reinstall N8N
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/n8n_installer_script.sh | sudo bash
```

## Getting Additional Help

### Community Resources

- [N8N Community Forum](https://community.n8n.io)
- [N8N Documentation](https://docs.n8n.io)
- [Docker Documentation](https://docs.docker.com)
- [Nginx Documentation](https://nginx.org/en/docs/)

### Collecting Debug Information

When asking for help, include:

```bash
# System information
uname -a
lsb_release -a
free -h
df -h

# Service status
systemctl status docker
systemctl status nginx
cd /opt/n8n && docker-compose ps

# Recent logs
tail -50 /tmp/n8n-installer.log
docker-compose logs n8n | tail -50
tail -50 /var/log/nginx/error.log
```

### Filing Bug Reports

When reporting issues:

1. Include system information (above)
2. Describe steps to reproduce
3. Include relevant log files
4. Mention any customizations made
5. Specify expected vs. actual behavior