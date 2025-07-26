# N8N Installation Guide

This guide provides step-by-step instructions for installing N8N on Ubuntu using our automated installer, including specialized support for Proxmox VMs.

## Prerequisites

### General Requirements
- Ubuntu 20.04+ server with root access
- 2GB+ RAM (4GB recommended)
- 20GB+ free disk space
- Internet connection

### Proxmox VM Requirements
- Ubuntu 20.04+ VM
- 2GB+ RAM (4GB recommended for VMs)
- 20GB+ disk space (SSD preferred)
- 1+ vCPU (2+ recommended)
- Bridged networking recommended

## Quick Install

### Standard Installation

```bash
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/n8n_installer_script.sh | sudo bash
```

### Proxmox VM Installation (Recommended for VMs)

```bash
# Proxmox-optimized installer with VM-specific settings
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install-proxmox.sh | sudo bash

# Alternative: Clone and run locally (if curl fails in VMs)
git clone https://github.com/sylvester-francis/n8n-selfhoster.git
cd n8n-selfhoster
sudo ./install-proxmox.sh
```

### Manual Installation

```bash
# Download the installer
wget https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/n8n_installer_script.sh

# Make it executable
chmod +x n8n_installer_script.sh

# Run the installer
sudo ./n8n_installer_script.sh
```

## Installation Process

The installer will automatically:

1. **Update System** - Update package lists and upgrade system
2. **Install Docker** - Install Docker and Docker Compose
3. **Configure Firewall** - Set up UFW with secure rules
4. **Create N8N Directory** - Set up `/opt/n8n` with configuration
5. **Install PostgreSQL** - Database setup with Docker
6. **Configure Nginx** - Reverse proxy with HTTPS
7. **Generate SSL Certificate** - Self-signed certificate for immediate use
8. **Set Up Backups** - Automated daily backups
9. **Security Hardening** - Fail2Ban and security headers
10. **Start Services** - Launch all services
11. **Run Tests** - Comprehensive validation

## Post-Installation

### Access Your N8N Instance

1. Open your browser
2. Navigate to `https://YOUR_SERVER_IP`
3. Accept the self-signed certificate warning
4. Login with the generated credentials

### Initial Configuration

1. Complete the N8N setup wizard
2. Add your service credentials (GitHub, Gmail, OpenAI, etc.)
3. Create your first workflow
4. (Optional) Set up Let's Encrypt for trusted certificates

## Proxmox VM Installation

### Automatic Detection and Optimization

The installer automatically detects Proxmox VE environments and applies VM-specific optimizations:

- **Extended timeouts**: Nginx timeouts increased from 60s to 300s
- **VM-optimized Docker**: Specialized daemon configuration for virtual environments
- **Memory management**: Automatic resource-conscious settings for constrained VMs
- **Kernel tuning**: VM-specific kernel parameters for better performance
- **Network optimization**: Enhanced buffer settings for virtualized networking
- **Extended validation**: 15-minute timeout for N8N startup validation

### Proxmox Installation Steps

1. **Create Ubuntu VM in Proxmox**:
   ```bash
   # Recommended VM settings:
   # - 2+ GB RAM (4GB preferred)
   # - 2+ CPU cores
   # - 20+ GB disk (SSD preferred)
   # - VirtIO network adapter
   # - Enable QEMU guest agent
   ```

2. **Install Ubuntu and Update**:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

3. **Run Proxmox Installer**:
   ```bash
   # Option 1: Direct download
   curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install-proxmox.sh | sudo bash
   
   # Option 2: Clone repository (recommended for curl issues)
   git clone https://github.com/sylvester-francis/n8n-selfhoster.git
   cd n8n-selfhoster
   sudo ./install-proxmox.sh --yes
   ```

4. **Wait for Installation** (15-25 minutes for VMs):
   - The installer will detect the Proxmox environment
   - Extended timeouts will be automatically applied
   - VM-specific Docker configuration will be used
   - Network and memory optimizations will be applied

5. **Verify Installation**:
   ```bash
   # Test direct N8N access (should be immediate)
   curl -s http://localhost:5678
   
   # Test nginx proxy (may take a few minutes initially)
   curl -k -s https://localhost
   
   # Check container status
   cd /opt/n8n && docker-compose ps
   ```

### Proxmox VM Best Practices

- **Enable hardware virtualization** in VM CPU settings
- **Use VirtIO drivers** for better I/O performance
- **Allocate adequate resources** (2+ GB RAM, 2+ CPU cores)
- **Use SSD storage** for better Docker performance
- **Configure bridged networking** for external access
- **Enable QEMU guest agent** for better VM management

### Expected Behavior in Proxmox VMs

- **Installation time**: 15-25 minutes (vs 10-15 on bare metal)
- **N8N startup**: 2-5 minutes after containers start
- **Direct access**: `curl http://localhost:5678` responds immediately
- **Proxy access**: `https://VM_IP` may take time during initial startup
- **Resource usage**: Higher memory/CPU usage than bare metal

## Configuration Details

### System Update and Package Installation

```bash
# Update package lists and upgrade system
apt update && apt upgrade -y

# Install essential packages
apt install -y curl wget git unzip software-properties-common apt-transport-https ca-certificates gnupg lsb-release
```

### Docker Installation

```bash
# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
apt update
apt install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Start Docker service
systemctl start docker
systemctl enable docker
```

### Firewall Configuration

```bash
# Install and configure UFW firewall
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw --force enable

# Check firewall status
ufw status
```

### N8N and PostgreSQL Setup

The installer creates a complete Docker Compose configuration with:

- **N8N** (latest version) on port 5678 (internal)
- **PostgreSQL 13** with dedicated database
- **Persistent volumes** for data storage
- **Health checks** for service monitoring
- **Environment variables** for secure configuration

### Nginx Reverse Proxy

Nginx is configured with:

- **HTTPS redirect** from HTTP
- **Security headers** for protection
- **Rate limiting** to prevent abuse
- **WebSocket support** for N8N real-time features
- **Optimized timeouts** and buffering

### Automated Backups

Daily backups are configured at 2:00 AM including:

- **N8N data** (workflows, credentials, settings)
- **PostgreSQL database** (complete database dump)
- **7-day retention** (automatic cleanup)
- **Backup logging** for monitoring

## File Locations

- **N8N Configuration**: `/opt/n8n/docker-compose.yml`
- **Credentials**: `/opt/n8n/credentials.txt`
- **Backup Script**: `/opt/n8n/backup.sh`
- **Nginx Config**: `/etc/nginx/sites-available/n8n`
- **Installation Log**: `/tmp/n8n-installer.log`
- **Backups**: `/opt/n8n/backups/`

## Next Steps

1. [Set up HTTPS with Let's Encrypt](https.md)
2. [Configure your first workflows](../README.md#usage)
3. [Add service credentials](../README.md#credentials)
4. [Set up monitoring](monitoring.md)