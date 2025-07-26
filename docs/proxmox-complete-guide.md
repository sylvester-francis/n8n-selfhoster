# Complete Proxmox VM Guide for N8N Installation

## Overview

This comprehensive guide covers everything you need to know about installing N8N on Proxmox Virtual Environment (VE), including VM setup, installation, optimization, and troubleshooting.

## Table of Contents

1. [Proxmox VM Setup](#proxmox-vm-setup)
2. [Automated Installation](#automated-installation)
3. [VM-Specific Optimizations](#vm-specific-optimizations)
4. [Performance Tuning](#performance-tuning)
5. [Troubleshooting](#troubleshooting)
6. [Best Practices](#best-practices)

## Proxmox VM Setup

### Creating the Ubuntu VM

1. **Download Ubuntu Server ISO**:
   - Ubuntu 20.04 LTS or 22.04 LTS (recommended)
   - Upload to Proxmox storage

2. **Create VM with Optimal Settings**:
   ```bash
   # Recommended VM configuration:
   # General:
   #   - VM ID: Your choice
   #   - Name: n8n-server
   #   - Resource Pool: Optional
   
   # OS:
   #   - Use CD/DVD disc image file (ISO)
   #   - Storage: local
   #   - ISO image: ubuntu-22.04-server-amd64.iso
   
   # System:
   #   - Graphic card: Default
   #   - Machine: Default (i440fx)
   #   - BIOS: Default (SeaBIOS)
   #   - SCSI Controller: VirtIO SCSI
   #   - Qemu Agent: ENABLED ✓
   
   # Hard Disk:
   #   - Bus/Device: VirtIO Block (virtio0)
   #   - Storage: local-lvm (or SSD storage if available)
   #   - Disk size: 25 GB minimum (50 GB recommended)
   #   - Cache: Write back (unsafe) for better performance
   #   - Discard: ENABLED ✓ (for SSD)
   
   # CPU:
   #   - Sockets: 1
   #   - Cores: 2 minimum (4 recommended)
   #   - Type: host (or kvm64 for compatibility)
   
   # Memory:
   #   - Memory: 4096 MB (4 GB) recommended
   #   - Minimum: 2048 MB (2 GB)
   #   - Ballooning: ENABLED ✓
   
   # Network:
   #   - Bridge: vmbr0 (or your bridge)
   #   - Model: VirtIO (paravirtualized)
   #   - Firewall: Optional
   ```

3. **Install Ubuntu**:
   - Boot from ISO
   - Follow standard Ubuntu server installation
   - Enable OpenSSH server during installation
   - Create user account
   - Install security updates

### Post-Installation VM Configuration

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install QEMU guest agent (if not already installed)
sudo apt install qemu-guest-agent -y
sudo systemctl enable qemu-guest-agent
sudo systemctl start qemu-guest-agent

# Install useful tools
sudo apt install curl wget git htop net-tools -y

# Verify virtualization detection
systemd-detect-virt
# Should output: kvm

# Check available resources
free -h    # Memory
df -h      # Disk space
nproc      # CPU cores
```

## Automated Installation

### Method 1: Proxmox-Optimized Installer (Recommended)

```bash
# Download and run the Proxmox-specific installer
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install-proxmox.sh | sudo bash

# Or for non-interactive installation
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install-proxmox.sh | sudo bash -s -- --yes
```

### Method 2: Local Installation (If curl fails)

```bash
# Clone repository
git clone https://github.com/sylvester-francis/n8n-selfhoster.git
cd n8n-selfhoster

# Run Proxmox installer
sudo ./install-proxmox.sh

# Or non-interactive
sudo ./install-proxmox.sh --yes
```

### Method 3: Standard Installer with Auto-Detection

```bash
# The standard installer will auto-detect Proxmox and apply optimizations
git clone https://github.com/sylvester-francis/n8n-selfhoster.git
cd n8n-selfhoster
sudo ./installer/install.sh --yes --domain $(hostname -I | awk '{print $1}')
```

### What Happens During Installation

1. **Environment Detection**:
   - Detects KVM/QEMU virtualization
   - Identifies Proxmox-specific indicators
   - Applies VM-specific optimizations automatically

2. **VM Optimizations Applied**:
   - Nginx timeouts: 60s → 300s
   - Validation timeout: 5 minutes → 15 minutes
   - Docker configuration optimized for VMs
   - Kernel parameters tuned for virtualization
   - Memory settings adjusted for VM constraints

3. **Installation Process**:
   - Takes 15-25 minutes (vs 10-15 on bare metal)
   - Extended validation periods for VM startup delays
   - Automatic IP detection for VM environment

## VM-Specific Optimizations

### Automatic Optimizations Applied

#### Nginx Configuration
```nginx
# Extended timeouts for VM environments
proxy_connect_timeout 300s;
proxy_send_timeout 300s;
proxy_read_timeout 300s;
```

#### Docker Configuration
```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ],
  "live-restore": true,
  "userland-proxy": false,
  "exec-opts": ["native.cgroupdriver=systemd"]
}
```

#### Kernel Parameters
```bash
# /etc/sysctl.d/99-n8n-proxmox.conf
# Network optimizations
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_congestion_control = bbr

# VM memory optimizations
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5

# File system optimizations
fs.file-max = 2097152
fs.inotify.max_user_watches = 524288
```

#### N8N Memory Settings (for constrained VMs)
```bash
# Applied automatically if VM has < 4GB RAM
N8N_MAX_EXECUTION_DATA_SIZE=5MB
N8N_MAX_WORKFLOW_SIZE=5MB
POSTGRES_SHARED_BUFFERS=128MB
```

## Performance Tuning

### Proxmox Host Settings

1. **Enable Hardware Virtualization**:
   ```bash
   # On Proxmox host, verify CPU features
   grep -E "(vmx|svm)" /proc/cpuinfo
   
   # Enable in VM options:
   # Options → CPU → Type: host
   # Hardware → Processors → Advanced → Enable CPU flags
   ```

2. **Storage Optimization**:
   ```bash
   # Use local SSD storage if available
   # Enable discard for SSD trimming
   # Set cache to "Write back" for better performance
   ```

3. **Network Optimization**:
   ```bash
   # Use VirtIO network adapter
   # Enable multiqueue if supported
   # Consider bridged networking for external access
   ```

### VM-Level Performance

```bash
# Monitor resource usage
htop                    # CPU and memory
iotop                   # Disk I/O
nethogs                 # Network usage

# Docker performance monitoring
docker stats
cd /opt/n8n && docker-compose top

# Check VM-specific settings
cat /proc/version
systemd-detect-virt
lscpu | grep Virtualization
```

### N8N Performance Tuning

```bash
# Increase worker processes for high-traffic workflows
sudo sed -i 's/worker_processes auto;/worker_processes 4;/' /etc/nginx/nginx.conf

# Optimize PostgreSQL for VM environment
cd /opt/n8n
docker-compose exec postgres psql -U n8n -d n8n -c "
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '1GB';
SELECT pg_reload_conf();
"

# Restart services to apply changes
sudo systemctl reload nginx
docker-compose restart postgres n8n
```

## Troubleshooting

### Common Issues and Solutions

#### Installation Timeouts
```bash
# Issue: 504 Gateway Timeout
# Solution: Extended timeouts are automatically applied

# Verify timeout settings
grep "proxy_.*_timeout" /etc/nginx/sites-available/n8n

# Manual timeout adjustment if needed
sudo sed -i 's/proxy_read_timeout [0-9]*s;/proxy_read_timeout 600s;/' /etc/nginx/sites-available/n8n
sudo systemctl reload nginx
```

#### Slow Startup
```bash
# Issue: N8N takes 5+ minutes to start
# Solution: This is normal for VMs, monitor progress

# Watch N8N startup
cd /opt/n8n && docker-compose logs -f n8n

# Check container health
docker-compose ps
docker-compose exec n8n wget -q --spider http://localhost:5678 && echo "N8N ready"
```

#### Resource Constraints
```bash
# Issue: Performance problems
# Solution: Check and adjust VM resources

# Check current allocation
free -h
df -h
nproc

# Monitor resource usage during operation
watch -n 2 'free -h && echo "---" && docker stats --no-stream'
```

#### Network Access Issues
```bash
# Issue: Cannot access N8N from outside VM
# Solution: Check network configuration

# Verify VM IP and routing
ip addr show
ip route show

# Check Proxmox firewall settings
# Check VM firewall settings
sudo ufw status

# Test connectivity
curl -s http://localhost:5678        # Direct access
curl -k -s https://$(hostname -I | awk '{print $1}')  # Proxy access
```

### Debug Commands

```bash
# Comprehensive system check
echo "=== System Information ==="
hostnamectl
systemd-detect-virt
free -h
df -h
nproc

echo "=== Network Configuration ==="
ip addr show
ip route show

echo "=== Docker Status ==="
systemctl status docker
cd /opt/n8n && docker-compose ps
docker-compose logs --tail=20 n8n

echo "=== Nginx Status ==="
systemctl status nginx
sudo nginx -t
curl -I http://localhost

echo "=== N8N Health Check ==="
curl -s http://localhost:5678 > /dev/null && echo "N8N: OK" || echo "N8N: FAIL"
curl -k -s https://localhost > /dev/null && echo "HTTPS: OK" || echo "HTTPS: FAIL"
```

## Best Practices

### VM Configuration
- **RAM**: Allocate 4GB for optimal performance (2GB minimum)
- **CPU**: Use 2+ cores with "host" CPU type for best performance
- **Storage**: Use SSD storage with VirtIO SCSI controller
- **Network**: Use VirtIO network adapter with bridged networking
- **QEMU Agent**: Always enable for better VM management

### Security
- Keep Proxmox host and VM updated
- Use firewall rules appropriately
- Consider VPN access for administrative tasks
- Regular backup testing
- Monitor resource usage and logs

### Monitoring
```bash
# Set up basic monitoring
# Monitor disk space
df -h | grep -E "(/$|/opt)" | awk '{print $5}' | sed 's/%//' | while read usage; do
    if [ "$usage" -gt 80 ]; then
        echo "WARNING: High disk usage: ${usage}%"
    fi
done

# Monitor memory usage
free | awk 'NR==2{printf "Memory Usage: %.1f%%\n", $3*100/$2}'

# Monitor N8N health
curl -s http://localhost:5678 > /dev/null || echo "N8N health check failed"
```

### Backup Strategy
```bash
# VM-level backups (recommended)
# Use Proxmox backup functionality
# Schedule regular VM snapshots

# Application-level backups
cd /opt/n8n
./backup.sh

# Verify backups
ls -la /opt/n8n/backups/
```

### Performance Optimization Checklist
- ✅ Hardware virtualization enabled
- ✅ VirtIO drivers used for disk and network
- ✅ Adequate resources allocated (4GB RAM, 2+ CPU)
- ✅ SSD storage with discard enabled
- ✅ QEMU guest agent installed and running
- ✅ Proxmox optimizations auto-detected and applied
- ✅ Regular monitoring and maintenance

This completes the comprehensive Proxmox guide for N8N installation. The automated installer handles most optimizations, but this guide provides the knowledge needed for advanced configuration and troubleshooting.