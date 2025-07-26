# Proxmox VM Installation Guide

This guide addresses specific issues when installing N8N on Proxmox Ubuntu VMs.

## Known Issues & Solutions

### 1. Curl Installation Link Not Working

**Problem:** The one-line curl installation may fail on Proxmox VMs due to networking restrictions.

**Solution:** Use local installation:
```bash
# Clone and install locally
git clone https://github.com/sylvester-francis/n8n-selfhoster.git
cd n8n-selfhoster
sudo ./installer/install.sh --yes --domain YOUR_VM_IP
```

### 2. Nginx Timeout Issues (Fixed in this version)

**Problem:** N8N takes longer to start in Proxmox VMs, causing 504 Gateway Timeout.

**Solution:** This version increases nginx timeouts from 60s to 300s:
- `proxy_connect_timeout 300s`
- `proxy_send_timeout 300s` 
- `proxy_read_timeout 300s`

### 3. Extended N8N Startup Time

**Problem:** N8N may take 2-5 minutes to fully initialize in Proxmox VMs.

**Solution:** The installer now waits up to 15 minutes for N8N to become responsive.

### 4. Self-Signed Certificate Issues on macOS

**Problem:** Accessing from macOS with self-signed certificates is cumbersome.

**Solutions:**
- **Option A:** Use HTTP for initial setup:
  ```bash
  # Temporarily disable HTTPS redirect for testing
  sudo sed -i 's/return 301 https/# return 301 https/' /etc/nginx/sites-available/n8n
  sudo systemctl reload nginx
  # Access via http://VM_IP
  ```

- **Option B:** Set up Let's Encrypt with a domain:
  ```bash
  # Install certbot and get real certificate
  sudo certbot --nginx -d yourdomain.com
  ```

- **Option C:** Trust the self-signed certificate:
  1. Download the certificate: `scp root@VM_IP:/etc/ssl/certs/n8n-selfsigned.crt ./`
  2. Add to macOS keychain and trust

### 5. Proxmox VM-Specific Optimizations

**Docker Network Settings:**
```bash
# Add to docker-compose.yml if you have networking issues:
networks:
  default:
    driver: bridge
    driver_opts:
      com.docker.network.bridge.host_binding_ipv4: "0.0.0.0"
```

**Memory Settings for Proxmox:**
```bash
# If you have memory constraints, reduce N8N memory usage:
echo "N8N_MAX_EXECUTION_DATA_SIZE=5MB" >> /opt/n8n/.env
echo "N8N_MAX_WORKFLOW_SIZE=5MB" >> /opt/n8n/.env
```

## Troubleshooting Commands

### Check Service Status
```bash
# Container status
cd /opt/n8n && docker-compose ps

# N8N logs
cd /opt/n8n && docker-compose logs n8n

# Nginx status
sudo systemctl status nginx

# Test N8N directly (should be immediate)
curl -v http://127.0.0.1:5678

# Test through nginx (may timeout during startup)
curl -v -k https://localhost
```

### Network Debugging
```bash
# Check port bindings
sudo netstat -tlnp | grep :5678
sudo netstat -tlnp | grep :443

# Test Docker network
docker network ls
docker network inspect n8n_default
```

### Performance Monitoring
```bash
# Monitor during startup
htop
docker stats
journalctl -f -u nginx
```

## Installation Script for Proxmox VMs

```bash
#!/bin/bash
# Proxmox-optimized installation

# Clone repository
git clone https://github.com/sylvester-francis/n8n-selfhoster.git
cd n8n-selfhoster

# Get VM IP
VM_IP=$(hostname -I | awk '{print $1}')

# Install with extended timeouts
sudo ./installer/install.sh \
  --yes \
  --domain "$VM_IP" \
  --timezone "$(timedatectl show -p Timezone --value)"

# Wait for N8N to fully start (important in Proxmox)
echo "Waiting for N8N to initialize (this may take 5-10 minutes on Proxmox)..."
timeout 900 bash -c 'until curl -s http://localhost:5678 > /dev/null; do sleep 10; done'

echo "Installation complete!"
echo "Access your N8N instance at: https://$VM_IP"
echo "Accept the self-signed certificate warning in your browser"
```

## Post-Installation Verification

```bash
# Complete verification script
cd /opt/n8n

# 1. Check containers
docker-compose ps

# 2. Check N8N response (should be immediate)
curl -s http://localhost:5678 && echo "N8N responding directly" || echo "N8N not responding"

# 3. Check nginx response (may take time during startup)
timeout 30 curl -s -k https://localhost && echo "Nginx proxying working" || echo "Nginx timeout"

# 4. Check logs for errors
docker-compose logs n8n | tail -20
```

## Common Error Messages

**"504 Gateway Timeout"**: N8N is still starting up. Wait 2-5 more minutes.

**"Connection refused"**: Check if containers are running with `docker-compose ps`

**"SSL Certificate Error"**: Either trust the self-signed cert or use HTTP temporarily.

## Performance Tips for Proxmox

1. **Allocate adequate resources:** Minimum 2GB RAM, 4GB recommended
2. **Use SSD storage** if possible for better Docker performance
3. **Enable hardware virtualization** in Proxmox VM settings
4. **Monitor resource usage** during installation and startup