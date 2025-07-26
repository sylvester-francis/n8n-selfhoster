# N8N Self-Hosted Installer 🚀

**High-performance, one-click installation script for a production-ready N8N instance on Ubuntu with HTTPS, PostgreSQL, comprehensive security, and Proxmox VM support.**

> **Latest: v1.3.0** - Proxmox VM support with automatic detection, extended timeouts, VM-specific optimizations, and unified installation entry point for simplified user experience!

[![Tests](https://github.com/sylvester-francis/n8n-selfhoster/actions/workflows/quick-test.yml/badge.svg)](https://github.com/sylvester-francis/n8n-selfhoster/actions/workflows/quick-test.yml)
[![Integration Tests](https://github.com/sylvester-francis/n8n-selfhoster/actions/workflows/test-installer.yml/badge.svg)](https://github.com/sylvester-francis/n8n-selfhoster/actions/workflows/test-installer.yml)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%2B-orange.svg)](https://ubuntu.com/)
[![N8N](https://img.shields.io/badge/N8N-Latest-blue.svg)](https://n8n.io/)
[![Docker](https://img.shields.io/badge/Docker-Latest-blue.svg)](https://docker.com/)
[![Nginx](https://img.shields.io/badge/Nginx-Latest-green.svg)](https://nginx.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Proxmox](https://img.shields.io/badge/Proxmox-VM%20Ready-green.svg)](https://www.proxmox.com/)

---

## Table of Contents

1. [🚀 Quick Start](#-quick-start)
2. [✨ Features](#-features)
3. [📋 System Requirements](#-system-requirements)
4. [🛠️ Installation Methods](#️-installation-methods)
5. [🖥️ Proxmox VM Installation](#️-proxmox-vm-installation)
6. [⚙️ Configuration Options](#️-configuration-options)
7. [🎯 Post-Installation Setup](#-post-installation-setup)
8. [🔧 Management & Operations](#-management--operations)
9. [🔒 Security Configuration](#-security-configuration)
10. [⚡ Performance Optimization](#-performance-optimization)
11. [🔍 Troubleshooting](#-troubleshooting)
12. [🏗️ Advanced Configuration](#️-advanced-configuration)
13. [💾 Backup & Recovery](#-backup--recovery)
14. [🧪 Testing & Validation](#-testing--validation)
15. [📋 Version History](#-version-history)
16. [📚 Reference](#-reference)

---

## 🚀 Quick Start

### 🎯 **Recommended: One-Line Smart Installation**

```bash
# 🔍 Automatically detects your environment and applies optimal settings
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash
```

**What happens automatically:**
- 🖥️ **Detects Proxmox VMs** → Applies VM-specific optimizations (extended timeouts, memory tuning)
- 🖥️ **Detects other VMs** → Applies general virtualization optimizations  
- 💻 **Detects bare metal** → Uses standard high-performance configuration
- 🤔 **Interactive prompts** → Asks Proxmox users to confirm optimization preferences
- ⚡ **Smart defaults** → Non-interactive mode auto-selects best options

### 🎛️ **Installation with Specific Options**

```bash
# 🖥️ Force Proxmox optimizations (extended timeouts, VM-specific settings)
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash -s -- --type proxmox

# 💻 Force standard installation (no VM optimizations)
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash -s -- --type standard

# 🤖 Non-interactive installation (auto-detects environment)
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash -s -- --yes

# 🌐 Install with custom domain
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash -s -- --domain myserver.com --yes

# ⚡ Quick installation (skips backups and optional features)
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash -s -- --quick --yes
```

### 📦 **Local Installation** (if curl fails or offline setup)

```bash
# Clone the repository
git clone https://github.com/sylvester-francis/n8n-selfhoster.git
cd n8n-selfhoster

# Interactive installation with auto-detection
sudo ./install.sh

# With specific options
sudo ./install.sh --type proxmox --domain myserver.com --yes

# Preview what will be installed (dry run)
sudo ./install.sh --dry-run
```

### What Gets Installed

- **N8N** (latest version) - Workflow automation tool
- **PostgreSQL 13** - Reliable database backend
- **Nginx** - Reverse proxy with HTTPS
- **Docker & Docker Compose** - Container management
- **UFW Firewall** - Network protection
- **Fail2Ban** - Intrusion prevention
- **SSL/TLS encryption** - Secure connections
- **Automated backups** - Daily database and data backups

**Installation time**: 10-15 minutes (bare metal), 15-25 minutes (VMs)

---

## ✨ Features

### 🚀 Performance & Speed

- ⚡ **High-performance installer** - 30-50% faster installation times
- 🔄 **Parallel processing** - Independent tasks run simultaneously
- 🏎️ **Optimized Docker installation** - Uses fast convenience scripts
- 📦 **Smart package management** - Batch installations and caching
- 🎯 **Selective system updates** - Only essential packages updated

### 🐳 Core Components

- 🐳 **Docker-based installation** with PostgreSQL database
- 🔒 **HTTPS out of the box** with self-signed certificates
- 🌐 **Nginx reverse proxy** with security headers
- 🛡️ **Firewall protection** with UFW
- 📦 **Automated daily backups** with rotation
- 🔐 **Security hardening** with Fail2Ban

### 🖥️ Virtualization Support

- 🔍 **Automatic Proxmox detection** - Smart environment detection
- ⏱️ **Extended VM timeouts** - 300s nginx timeouts vs 60s default
- 🚀 **VM-optimized Docker** - Specialized daemon configuration
- 🧠 **Memory management** - Automatic resource-conscious settings
- 🌐 **Network optimization** - Enhanced buffer settings for VMs
- 📊 **VM performance monitoring** - Real-time resource tracking

### 🎛️ Operations & Monitoring

- 🔄 **Log rotation** and monitoring
- ✅ **Comprehensive testing** and validation
- 📋 **Detailed logging** and error handling
- 🧠 **Memory optimization** - Kernel parameter tuning
- 📊 **Performance metrics** - Installation time tracking

---

## 📋 System Requirements

### General Requirements (Bare Metal/VPS)
- **OS**: Ubuntu 20.04+ server with root access
- **RAM**: 2GB minimum, 4GB recommended
- **Storage**: 20GB minimum, 50GB+ recommended (SSD preferred)
- **CPU**: 1 vCPU minimum, 2+ vCPU recommended
- **Network**: Internet connection required

### Proxmox VM Requirements
- **OS**: Ubuntu 20.04+ VM
- **RAM**: 2GB minimum, 4GB recommended for VMs
- **Storage**: 20GB minimum, 50GB+ recommended (SSD storage preferred)
- **CPU**: 1+ vCPU, 2+ vCPU recommended
- **Network**: Bridged networking recommended
- **Virtualization**: Hardware virtualization enabled
- **Drivers**: VirtIO drivers recommended for performance

### VPS Providers (Tested)
- ✅ DigitalOcean ($12/month for 2GB droplet)
- ✅ Linode ($12/month for 2GB Nanode)
- ✅ Vultr ($12/month for Regular instance)
- ✅ Hetzner (€4.15/month for CX21)
- ✅ Proxmox VE (local virtualization)

---

## 🛠️ Installation Methods

### 🎯 **Method 1: Smart Auto-Detection (Recommended)**

```bash
# 🧠 Intelligent installer that detects your environment automatically
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash
```

**🔍 Environment Detection:**
- **Proxmox VMs**: Detects KVM/QEMU + Proxmox indicators → Applies VM optimizations
- **Other VMs**: Detects VMware, VirtualBox, Hyper-V → Applies general VM settings  
- **Bare Metal**: Physical servers → Uses standard high-performance configuration
- **Cloud VPS**: DigitalOcean, Linode, AWS EC2, etc. → Optimizes for cloud environments

**💬 Interactive Experience:**
- Proxmox users get prompted: *"Detected Proxmox VM. Use optimizations? (Recommended/Standard/Cancel)"*
- Other environments proceed with auto-selected optimal settings
- All configurations are clearly explained before application

### 🎛️ **Method 2: Explicit Installation Types**

#### **For Proxmox VMs (Extended Timeouts & VM Optimizations)**
```bash
# 🖥️ Perfect for Proxmox VE virtual machines
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash -s -- --type proxmox --yes

# With custom domain
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash -s -- --type proxmox --domain n8n.example.com --yes
```

#### **For Bare Metal & High-Performance VPS**
```bash
# 💻 Optimized for physical servers and powerful VPS
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash -s -- --type standard --yes

# With IP address instead of domain
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash -s -- --type standard --ip 192.168.1.100 --yes
```

#### **For Quick Deployments & Testing**
```bash
# ⚡ Fast installation without backups and optional features
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash -s -- --quick --yes

# Quick + custom timezone
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash -s -- --quick --timezone Europe/London --yes
```

### 📦 **Method 3: Local Installation** (Offline or Network Issues)

```bash
# Clone repository for local installation
git clone https://github.com/sylvester-francis/n8n-selfhoster.git
cd n8n-selfhoster

# Interactive installation with environment auto-detection
sudo ./install.sh

# Specify exact configuration
sudo ./install.sh --type proxmox --domain myserver.local --timezone America/New_York --yes

# Preview installation without making changes
sudo ./install.sh --dry-run --verbose
```

### 🔧 **Method 4: Advanced Configurations**

```bash
# Skip specific components
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash -s -- --skip-ssl --skip-firewall --yes

# Development/testing setup
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash -s -- --skip-backups --verbose --yes

# Corporate environment (custom domain, specific timezone)
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash -s -- \
  --domain n8n.company.com \
  --timezone America/New_York \
  --type standard \
  --yes
```

### Command-Line Options

```bash
# Show help and all available options
sudo ./install.sh --help

# Available options:
-h, --help              Show help message
-v, --version           Show version information
-y, --yes               Skip all prompts (non-interactive mode)
-d, --domain DOMAIN     Set domain name (e.g., example.com)
-i, --ip IP             Set server IP address
-t, --timezone TZ       Set timezone (e.g., America/New_York)
--type TYPE             Installation type: auto, standard, proxmox (default: auto)
--skip-firewall         Skip firewall configuration
--skip-ssl              Skip SSL certificate generation
--skip-backups          Skip backup configuration
--quick                 Quick installation (skip optional features)
--verbose               Enable verbose logging
--dry-run               Show what would be done without executing
--force-interactive     Force interactive mode even without TTY
```

**Installation Types:**
- **auto** (default): Auto-detect environment and apply appropriate optimizations
- **standard**: Standard installation for physical/bare metal servers
- **proxmox**: Force Proxmox VM optimizations (extended timeouts, VM-specific settings)

---

## 🖥️ Proxmox VM Installation

### 🎯 **New: Seamless Proxmox Support**

The installer now **automatically detects** Proxmox VMs and offers intelligent optimization choices:

```bash
# ✨ Simply run the standard installer - it detects Proxmox automatically!
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash

# What you'll see on Proxmox VMs:
# 🔍 "Proxmox VM detected - optimizations available!"
# 🖥️ "1) Proxmox-optimized installation (Recommended)"
# 💻 "2) Standard installation" 
# 🚫 "3) Cancel"
```

**🚀 Benefits of Unified Approach:**
- **No separate script needed** - Same command works everywhere
- **Smart defaults** - Auto-selects best configuration for your environment  
- **Interactive guidance** - Clear explanations of what each option does
- **Proven reliability** - Same detection system as v1.3.0, better UX

### 🔍 **Automatic Detection and Optimization**

The installer automatically detects Proxmox VE environments using a 6-point detection system:

1. **systemd-detect-virt** - Detects KVM/QEMU virtualization
2. **DMI information** - Identifies QEMU product names
3. **QEMU guest agent** - Checks for running guest agent service
4. **CPU model detection** - Identifies virtualized CPU features
5. **Memory pattern analysis** - Detects VM-typical resource constraints
6. **Network interface patterns** - Recognizes Proxmox network naming

When detected, the following optimizations are automatically applied:
- **Extended timeouts**: Nginx timeouts increased from 60s to 300s
- **VM-optimized Docker**: Specialized daemon configuration
- **Memory management**: Resource-conscious settings for constrained VMs
- **Kernel tuning**: VM-specific parameters for better performance
- **Network optimization**: Enhanced buffer settings for virtualized networking
- **Extended validation**: 15-minute timeout for N8N startup validation

### Proxmox VM Setup Guide

#### 1. Create Ubuntu VM in Proxmox

**Recommended VM Configuration:**
```bash
# VM Settings:
General:
  - Name: n8n-server
  - Resource Pool: (optional)

OS:
  - Use CD/DVD disc image file (ISO)
  - ISO image: ubuntu-22.04-server-amd64.iso

System:
  - Machine: Default (i440fx)
  - BIOS: Default (SeaBIOS)
  - SCSI Controller: VirtIO SCSI
  - Qemu Agent: ENABLED ✓

Hard Disk:
  - Bus/Device: VirtIO Block (virtio0)
  - Storage: local-lvm (or SSD storage)
  - Disk size: 25 GB minimum (50 GB recommended)
  - Cache: Write back (unsafe) for better performance
  - Discard: ENABLED ✓ (for SSD)

CPU:
  - Sockets: 1
  - Cores: 2 minimum (4 recommended)
  - Type: host (or kvm64 for compatibility)

Memory:
  - Memory: 4096 MB (4 GB) recommended
  - Minimum: 2048 MB (2 GB)
  - Ballooning: ENABLED ✓

Network:
  - Bridge: vmbr0 (or your bridge)
  - Model: VirtIO (paravirtualized)
  - Firewall: Optional
```

#### 2. Install Ubuntu and Prepare System

```bash
# Install Ubuntu Server (follow standard installation)
# Enable OpenSSH server during installation
# Create user account and install security updates

# After installation, update system
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

#### 3. 🚀 **Run Installation** (Smart Auto-Detection)

```bash
# 🎯 RECOMMENDED: Smart installation with interactive prompts
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash

# Expected interaction on Proxmox VM:
# 🔍 "Proxmox VM detected - optimizations available!"
# 🖥️ "1) Proxmox-optimized installation (Recommended)"
# 💻 "2) Standard installation"
# 🚫 "3) Cancel"
# Select: 1
```

**🔧 Alternative Commands:**
```bash
# ⚡ Force Proxmox optimizations (skip prompts)
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash -s -- --type proxmox --yes

# 🌐 With custom domain for internal networks
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash -s -- --type proxmox --domain n8n.local --yes

# 📦 Local installation (if network issues in VM)
git clone https://github.com/sylvester-francis/n8n-selfhoster.git
cd n8n-selfhoster
sudo ./install.sh --type proxmox --yes
```

#### 4. 📊 **Installation Process** (15-25 minutes for VMs)

**🔍 What the installer detects and applies:**
- ✅ **KVM/QEMU virtualization** → Confirms VM environment
- ✅ **Proxmox indicators** → Applies Proxmox-specific optimizations
- ✅ **Resource constraints** → Adjusts memory and CPU settings
- ✅ **VM networking** → Optimizes network buffer settings

**⚙️ Proxmox-specific optimizations applied:**
- 🕐 **Extended timeouts**: Nginx 60s → 300s (prevents 504 errors)
- ⏱️ **Extended validation**: 5min → 15min (accommodates slow VM startup)
- 🐳 **VM-optimized Docker**: Specialized daemon.json configuration
- 🧠 **Memory management**: Resource-conscious N8N settings  
- ⚡ **Kernel tuning**: VM-specific network and I/O parameters

#### 5. Verify Installation

```bash
# Test direct N8N access (should be immediate)
curl -s http://localhost:5678

# Test nginx proxy (may take a few minutes initially)
curl -k -s https://localhost

# Check container status
cd /opt/n8n && docker-compose ps

# Verify Proxmox optimizations were applied
grep "proxy_.*_timeout" /etc/nginx/sites-available/n8n
# Should show 300s timeouts

# Check system status
systemctl status docker nginx
docker stats --no-stream
```

### Expected Behavior in Proxmox VMs

- **Installation time**: 15-25 minutes (vs 10-15 on bare metal)
- **N8N startup**: 2-5 minutes after containers start
- **Direct access**: `curl http://localhost:5678` responds immediately
- **Proxy access**: `https://VM_IP` may take time during initial startup
- **Resource usage**: Higher memory/CPU usage than bare metal
- **Network latency**: Slightly higher due to virtualization overhead

---

## ⚙️ Configuration Options

### System Configuration

The installer prompts for or auto-detects:

- **Domain name** (optional, uses IP if not provided)
- **Timezone** (defaults to current system timezone)
- **Installation path** (defaults to `/opt/n8n`)
- **VM optimizations** (auto-detected for Proxmox environments)

Passwords are automatically generated for security using multiple fallback methods:
1. OpenSSL random generation
2. /dev/urandom system randomness
3. Python secrets module
4. Date-based fallback

### Environment Variables

The installer sets up these environment variables:

```bash
# N8N Configuration
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=postgres
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=n8n
DB_POSTGRESDB_USER=n8n
DB_POSTGRESDB_PASSWORD=<generated>

# Authentication
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=<generated>

# Network Configuration
N8N_HOST=0.0.0.0
N8N_PORT=5678
N8N_PROTOCOL=https
WEBHOOK_URL=https://<domain>/

# Runtime Configuration
NODE_ENV=production
GENERIC_TIMEZONE=<detected/specified>
N8N_LOG_LEVEL=info
N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
N8N_RUNNERS_ENABLED=true

# VM-Specific (when Proxmox detected)
N8N_MAX_EXECUTION_DATA_SIZE=5MB
N8N_MAX_WORKFLOW_SIZE=5MB
POSTGRES_SHARED_BUFFERS=128MB
```

### Docker Compose Configuration

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:13
    container_name: n8n-postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: n8n
      POSTGRES_USER: n8n
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -h localhost -U n8n -d n8n"]
      interval: 5s
      timeout: 5s
      retries: 10

  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "127.0.0.1:5678:5678"
    environment:
      # [All environment variables listed above]
    volumes:
      - n8n_data:/home/node/.n8n
    depends_on:
      postgres:
        condition: service_healthy

volumes:
  postgres_data:
  n8n_data:
```

---

## 🎯 Post-Installation Setup

### Initial Access

1. **Open your browser**
2. **Navigate to your installation**:
   - `https://YOUR_SERVER_IP` or `https://YOUR_DOMAIN`
   - For Proxmox VMs: `https://VM_IP`
3. **Accept the self-signed certificate warning**:
   - Click "Advanced" → "Proceed to site (unsafe)"
4. **Login with provided credentials**:
   - Find credentials in `/opt/n8n/credentials.txt`
   - Username: `admin`
   - Password: (auto-generated, shown during installation)

### N8N Initial Setup

1. **Complete the N8N setup wizard**
2. **Configure your profile**:
   - Set up your admin account
   - Configure workspace settings
3. **Add service credentials**:
   - GitHub, Gmail, OpenAI, Slack, etc.
   - Configure API keys and authentication
4. **Create your first workflow**:
   - Start with a simple automation
   - Test webhook endpoints

### SSL Certificate Setup

#### Option 1: Use Self-Signed Certificates (Default)
- Already configured during installation
- Suitable for internal/testing use
- Browser warnings are normal

#### Option 2: Set Up Let's Encrypt (Recommended for Production)

```bash
# Prerequisites: Domain name pointing to your server
# Install certbot (if not already installed)
sudo apt install certbot python3-certbot-nginx -y

# Obtain and install certificate
sudo certbot --nginx -d yourdomain.com

# Test automatic renewal
sudo certbot renew --dry-run

# Set up automatic renewal (already configured by installer)
sudo crontab -l | grep certbot
```

#### Option 3: Use Custom SSL Certificates

```bash
# Replace self-signed certificates with your own
sudo cp your-certificate.crt /etc/ssl/certs/n8n-selfsigned.crt
sudo cp your-private-key.key /etc/ssl/private/n8n-selfsigned.key

# Set proper permissions
sudo chmod 644 /etc/ssl/certs/n8n-selfsigned.crt
sudo chmod 600 /etc/ssl/private/n8n-selfsigned.key

# Restart nginx
sudo systemctl restart nginx
```

---

## 🔧 Management & Operations

### Service Management

```bash
# Check status
cd /opt/n8n && docker-compose ps

# View logs
cd /opt/n8n && docker-compose logs n8n
cd /opt/n8n && docker-compose logs postgres

# Restart services
cd /opt/n8n && docker-compose restart n8n
cd /opt/n8n && docker-compose restart postgres

# Stop services
cd /opt/n8n && docker-compose stop

# Start services
cd /opt/n8n && docker-compose start

# Update N8N
cd /opt/n8n && docker-compose pull && docker-compose up -d
```

### System Service Management

```bash
# Nginx management
sudo systemctl status nginx
sudo systemctl restart nginx
sudo systemctl reload nginx
sudo nginx -t  # Test configuration

# Docker management
sudo systemctl status docker
sudo systemctl restart docker

# Firewall management
sudo ufw status
sudo ufw reload

# View system logs
sudo journalctl -u nginx -f
sudo journalctl -u docker -f
```

### Backup Management

```bash
# Run manual backup
/opt/n8n/backup.sh

# View backup files
ls -la /opt/n8n/backups/

# Check backup schedule
sudo crontab -l | grep backup

# Restore from backup (example)
cd /opt/n8n
docker-compose stop
# Restore volumes from backup
docker-compose start
```

### Monitoring and Health Checks

```bash
# Quick health check script
#!/bin/bash
echo "=== N8N Health Check ==="
echo "Containers:"
cd /opt/n8n && docker-compose ps

echo -e "\nDirect N8N access:"
curl -s http://localhost:5678 > /dev/null && echo "✅ OK" || echo "❌ FAIL"

echo -e "\nNginx proxy:"
curl -k -s https://localhost > /dev/null && echo "✅ OK" || echo "❌ FAIL"

echo -e "\nDisk usage:"
df -h /opt/n8n

echo -e "\nMemory usage:"
free -h

echo -e "\nDocker stats:"
docker stats --no-stream
```

---

## 🔒 Security Configuration

### Firewall Configuration (UFW)

The installer automatically configures UFW with these rules:

```bash
# View firewall status
sudo ufw status

# Default configuration:
To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere         # SSH
80/tcp                     ALLOW IN    Anywhere         # HTTP
443/tcp                    ALLOW IN    Anywhere         # HTTPS

# Modify firewall rules
sudo ufw allow from 192.168.1.0/24 to any port 22  # Restrict SSH
sudo ufw deny 22                                    # Disable SSH (careful!)
sudo ufw reload
```

### Fail2Ban Configuration

Fail2Ban is automatically configured to protect against brute force attacks:

```bash
# Check Fail2Ban status
sudo fail2ban-client status

# Check specific jail status
sudo fail2ban-client status nginx-n8n
sudo fail2ban-client status sshd

# View banned IPs
sudo fail2ban-client get nginx-n8n banip

# Unban an IP
sudo fail2ban-client set nginx-n8n unbanip IP_ADDRESS

# View Fail2Ban logs
sudo tail -f /var/log/fail2ban.log
```

### Security Headers

Nginx is configured with security headers:

```nginx
# Configured automatically in /etc/nginx/sites-available/n8n
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
```

### Rate Limiting

```nginx
# Rate limiting configuration (automatic)
limit_req_zone $binary_remote_addr zone=n8n:10m rate=10r/s;
limit_req zone=n8n burst=20 nodelay;
```

### Additional Security Recommendations

1. **SSH Key Authentication**:
   ```bash
   # Disable password authentication
   sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
   sudo systemctl restart sshd
   ```

2. **Automatic Security Updates**:
   ```bash
   # Enable unattended upgrades
   sudo apt install unattended-upgrades -y
   sudo dpkg-reconfigure -plow unattended-upgrades
   ```

3. **VPN Access** (recommended for production):
   - Set up WireGuard or OpenVPN
   - Restrict access to management ports
   - Use VPN for administrative access

4. **Regular Security Audits**:
   ```bash
   # Check for listening services
   sudo netstat -tlnp
   
   # Check user accounts
   cat /etc/passwd
   
   # Review sudo access
   sudo cat /etc/sudoers
   ```

---

## ⚡ Performance Optimization

### Installation Performance Optimizations

The installer includes advanced performance optimizations:

#### Parallel Processing
- **Nginx & SSL Setup**: Run simultaneously instead of sequentially
- **Security Configuration**: Firewall and Fail2Ban setup in parallel
- **Package Installation**: Batch installs in groups of 5 packages
- **Pre-checks**: Dependency verification runs in background

#### Fast Docker Installation
- **Convenience Script**: Uses Docker's official `get.docker.com` script
- **Fallback Method**: Gracefully falls back to manual installation if needed
- **Optimized Compose**: Uses Docker plugin for better performance

#### Smart System Management
- **Selective Updates**: Only installs security updates if system is recent
- **Cached Dependencies**: APT optimizations and package pre-downloading
- **Memory Optimization**: Kernel parameter tuning for containers
- **tmpfs Usage**: Temporary files in memory (on systems with >2GB RAM)

### Runtime Performance Optimizations

#### Docker Configuration

**Standard Configuration:**
```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
```

**Proxmox VM Configuration:**
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

#### Kernel Parameter Tuning

**VM-Specific Optimizations (`/etc/sysctl.d/99-n8n-proxmox.conf`):**
```bash
# Network optimizations
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq

# VM memory optimizations
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5

# File system optimizations
fs.file-max = 2097152
fs.inotify.max_user_watches = 524288

# Docker/container optimizations
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
```

#### High-Traffic Workflow Optimization

```bash
# Increase Nginx workers
sudo sed -i 's/worker_processes auto;/worker_processes 4;/' /etc/nginx/nginx.conf

# Optimize PostgreSQL
cd /opt/n8n
docker-compose exec postgres psql -U n8n -d n8n -c "
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '1GB';
ALTER SYSTEM SET max_connections = 200;
SELECT pg_reload_conf();
"

# Restart services
sudo systemctl reload nginx
docker-compose restart postgres
```

#### Performance Monitoring

```bash
# System performance
htop
iostat -x 1
nethogs

# Docker performance
docker stats
docker system df
docker system events

# N8N specific
cd /opt/n8n && docker-compose exec n8n n8n metrics
```

---

## 🔍 Troubleshooting

### 🆕 **New Unified Installer** - Troubleshooting Made Easier

The v1.3.0 unified installer automatically detects issues and suggests solutions:

```bash
# 🔍 Smart diagnosis - shows what's detected and why
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash --dry-run --verbose

# 🛠️ If installation fails, the installer automatically:
# - Creates detailed bug report at /tmp/n8n-installer-bug-report.txt
# - Suggests specific troubleshooting steps based on failure point
# - Offers cleanup commands for partial installations
```

**🎯 Quick Diagnosis Commands:**
```bash
# Check what installer detects about your environment
sudo ./install.sh --dry-run | grep -E "(detected|environment|type)"

# Show all available options for your situation
sudo ./install.sh --help

# Force specific installation type if auto-detection fails
sudo ./install.sh --type proxmox --verbose  # or --type standard
```

### 📋 **Common Issues and Solutions**

#### Installation Issues

**Issue**: Installation fails with "insufficient memory"  
**Solution**: Increase RAM allocation or use VM optimization
```bash
# Check memory
free -h
# Minimum 2GB required, 4GB recommended for VMs
```

**Issue**: Docker installation fails  
**Solution**: Clean previous installations and retry
```bash
# Remove old Docker
sudo apt remove docker docker-engine docker.io containerd runc
sudo apt autoremove
# Re-run installer
```

**Issue**: Permission denied errors  
**Solution**: Ensure running as root
```bash
sudo ./install.sh
# Or use sudo with curl method
curl -fsSL URL | sudo bash
```

**Issue**: Wrong installation type selected  
**Solution**: Use `--type` parameter to force specific type
```bash
# Force Proxmox optimizations
sudo ./install.sh --type proxmox --yes

# Force standard installation
sudo ./install.sh --type standard --yes

# Let installer auto-detect (default)
sudo ./install.sh --type auto
```

**Issue**: Environment detection not working  
**Solution**: Check detection manually
```bash
# Manual detection check
systemd-detect-virt
cat /proc/version
cat /sys/class/dmi/id/product_name

# Force specific type if detection fails
sudo ./install.sh --type proxmox  # or standard
```

#### Proxmox VM-Specific Issues

**Issue**: Nginx shows "504 Gateway Timeout"  
**Solution**: Extended timeouts are automatically applied
```bash
# Verify timeout settings
grep "proxy_.*_timeout" /etc/nginx/sites-available/n8n
# Should show 300s timeouts
```

**Issue**: Curl installation fails in VM  
**Solution**: Use local installation method
```bash
git clone https://github.com/sylvester-francis/n8n-selfhoster.git
cd n8n-selfhoster
sudo ./install.sh --type proxmox --yes
```

**Issue**: N8N takes 5+ minutes to start  
**Solution**: This is normal for VMs, monitor progress
```bash
# Monitor startup
cd /opt/n8n && docker-compose logs -f n8n

# Check direct access first
curl -s http://localhost:5678

# Then check proxy access
curl -k -s https://localhost
```

#### Access Issues

**Issue**: Cannot access N8N web interface  
**Solutions**:

1. **Check services are running**:
   ```bash
   cd /opt/n8n && docker-compose ps
   systemctl status nginx
   ```

2. **Check firewall**:
   ```bash
   sudo ufw status
   # Ensure ports 80 and 443 are allowed
   ```

3. **Check port binding**:
   ```bash
   sudo netstat -tlnp | grep -E ':(80|443|5678)'
   ```

4. **Test direct access**:
   ```bash
   curl -s http://localhost:5678
   ```

**Issue**: Browser shows "Your connection is not private"  
**Solution**: This is normal with self-signed certificates
- Click "Advanced" → "Proceed to site (unsafe)"
- Or set up Let's Encrypt for trusted certificates

#### Performance Issues

**Issue**: N8N is slow or unresponsive  
**Solutions**:

1. **Check resource usage**:
   ```bash
   htop
   docker stats
   df -h
   ```

2. **Restart services**:
   ```bash
   cd /opt/n8n && docker-compose restart
   sudo systemctl restart nginx
   ```

3. **Check logs for errors**:
   ```bash
   cd /opt/n8n && docker-compose logs n8n | tail -50
   sudo journalctl -u nginx -n 50
   ```

4. **Optimize for high traffic** (see Performance section)

#### Network Issues

**Issue**: Cannot access from external network  
**Solutions**:

1. **Check firewall on server**:
   ```bash
   sudo ufw status
   ```

2. **Check router/cloud firewall**:
   - Ensure ports 80, 443 are open
   - Check cloud provider security groups

3. **Verify IP binding**:
   ```bash
   sudo netstat -tlnp | grep nginx
   # Should show 0.0.0.0:80 and 0.0.0.0:443
   ```

#### Database Issues

**Issue**: Database connection errors  
**Solutions**:

1. **Check PostgreSQL container**:
   ```bash
   cd /opt/n8n && docker-compose logs postgres
   ```

2. **Check database connectivity**:
   ```bash
   cd /opt/n8n && docker-compose exec postgres pg_isready -U n8n
   ```

3. **Restart database**:
   ```bash
   cd /opt/n8n && docker-compose restart postgres
   ```

### Diagnostic Commands

```bash
#!/bin/bash
# Comprehensive diagnostic script

echo "=== System Information ==="
hostnamectl
systemd-detect-virt
free -h
df -h
nproc

echo -e "\n=== Network Configuration ==="
ip addr show
ip route show
sudo netstat -tlnp | grep -E ':(22|80|443|5678)'

echo -e "\n=== Service Status ==="
systemctl status docker --no-pager
systemctl status nginx --no-pager
sudo ufw status

echo -e "\n=== Docker Status ==="
docker --version
docker-compose --version
cd /opt/n8n && docker-compose ps
docker stats --no-stream

echo -e "\n=== N8N Specific ==="
curl -s http://localhost:5678 > /dev/null && echo "Direct access: OK" || echo "Direct access: FAIL"
curl -k -s https://localhost > /dev/null && echo "HTTPS proxy: OK" || echo "HTTPS proxy: FAIL"

echo -e "\n=== Recent Logs ==="
cd /opt/n8n && docker-compose logs --tail=10 n8n
sudo journalctl -u nginx --no-pager -n 5

echo -e "\n=== Configuration Files ==="
ls -la /opt/n8n/
sudo nginx -t
```

### Getting Help

1. **Check this documentation** for solutions
2. **Run diagnostic commands** to gather information
3. **Check log files** for specific error messages
4. **Create GitHub issue** with diagnostic output
5. **Join community discussions** for peer support

---

## 🏗️ Advanced Configuration

### Custom Domain Configuration

```bash
# Update domain after installation
cd /opt/n8n

# Update environment variables
sudo nano docker-compose.yml
# Change WEBHOOK_URL to your new domain

# Update Nginx configuration
sudo nano /etc/nginx/sites-available/n8n
# Change server_name to your domain

# Test and reload
sudo nginx -t
sudo systemctl reload nginx
docker-compose restart n8n
```

### Custom Port Configuration

```bash
# Change N8N port (example: 8080)
cd /opt/n8n

# Update docker-compose.yml
sudo nano docker-compose.yml
# Change ports: "127.0.0.1:8080:5678"

# Update Nginx configuration
sudo nano /etc/nginx/sites-available/n8n
# Change proxy_pass http://127.0.0.1:8080;

# Restart services
docker-compose restart n8n
sudo systemctl reload nginx
```

### Resource Limit Configuration

```bash
# Set memory limits for containers
cd /opt/n8n
sudo nano docker-compose.yml

# Add to n8n service:
deploy:
  resources:
    limits:
      memory: 2G
      cpus: '1.0'
    reservations:
      memory: 512M
      cpus: '0.25'

# Restart with new limits
docker-compose up -d
```

### Environment Variable Customization

```bash
# Add custom environment variables
cd /opt/n8n
sudo nano docker-compose.yml

# Add to n8n service environment:
- N8N_PERSONALIZATION_ENABLED=false
- N8N_VERSION_NOTIFICATIONS_ENABLED=false
- N8N_DIAGNOSTICS_ENABLED=false
- N8N_DEFAULT_LOCALE=en
- N8N_TEMPLATES_ENABLED=true
- EXECUTIONS_PROCESS=main
- EXECUTIONS_TIMEOUT=3600
- EXECUTIONS_TIMEOUT_MAX=14400

# Restart to apply changes
docker-compose restart n8n
```

### Database Optimization

```bash
# Advanced PostgreSQL configuration
cd /opt/n8n
docker-compose exec postgres psql -U n8n -d n8n

-- Performance tuning
ALTER SYSTEM SET max_connections = 200;
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '1GB';
ALTER SYSTEM SET maintenance_work_mem = '64MB';
ALTER SYSTEM SET checkpoint_completion_target = 0.9;
ALTER SYSTEM SET wal_buffers = '16MB';
ALTER SYSTEM SET default_statistics_target = 100;
ALTER SYSTEM SET random_page_cost = 1.1;
ALTER SYSTEM SET effective_io_concurrency = 200;

-- Apply changes
SELECT pg_reload_conf();
\q

# Restart PostgreSQL
docker-compose restart postgres
```

### SSL/TLS Advanced Configuration

```bash
# Modern SSL configuration
sudo nano /etc/nginx/sites-available/n8n

# Replace SSL section with:
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
ssl_prefer_server_ciphers off;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;
ssl_stapling on;
ssl_stapling_verify on;

# Test and reload
sudo nginx -t
sudo systemctl reload nginx
```

---

## 💾 Backup & Recovery

### Automated Backup System

The installer sets up automated daily backups:

```bash
# Backup script location
/opt/n8n/backup.sh

# Backup schedule (crontab)
sudo crontab -l | grep backup
# 0 2 * * * /opt/n8n/backup.sh

# Backup storage location
ls -la /opt/n8n/backups/
```

### Manual Backup Procedures

```bash
# Create immediate backup
/opt/n8n/backup.sh

# Manual database backup
cd /opt/n8n
docker-compose exec postgres pg_dump -U n8n -d n8n > backup-$(date +%Y%m%d_%H%M%S).sql

# Manual volume backup
docker run --rm -v n8n_n8n_data:/data -v $(pwd):/backup alpine tar czf /backup/n8n-data-$(date +%Y%m%d_%H%M%S).tar.gz -C /data .
docker run --rm -v n8n_postgres_data:/data -v $(pwd):/backup alpine tar czf /backup/postgres-data-$(date +%Y%m%d_%H%M%S).tar.gz -C /data .
```

### Backup Verification

```bash
# Verify backup integrity
cd /opt/n8n/backups
for backup in *.tar.gz; do
    echo "Checking $backup..."
    tar -tzf "$backup" >/dev/null && echo "✅ OK" || echo "❌ CORRUPTED"
done

# Test database backup
cd /opt/n8n
docker-compose exec postgres psql -U n8n -d n8n -c "\d" | head -10
```

### Recovery Procedures

#### Complete System Recovery

```bash
# Stop services
cd /opt/n8n
docker-compose down

# Remove existing volumes
docker volume rm n8n_n8n_data n8n_postgres_data

# Restore from backup
cd /opt/n8n/backups
# Extract latest backup (adjust filename)
docker run --rm -v n8n_n8n_data:/data -v $(pwd):/backup alpine tar xzf /backup/latest-n8n-data.tar.gz -C /data
docker run --rm -v n8n_postgres_data:/data -v $(pwd):/backup alpine tar xzf /backup/latest-postgres-data.tar.gz -C /data

# Start services
cd /opt/n8n
docker-compose up -d

# Verify recovery
curl -s http://localhost:5678
```

#### Database-Only Recovery

```bash
# Stop n8n (keep database running)
cd /opt/n8n
docker-compose stop n8n

# Drop and recreate database
docker-compose exec postgres psql -U n8n -c "DROP DATABASE n8n;"
docker-compose exec postgres psql -U n8n -c "CREATE DATABASE n8n;"

# Restore from SQL backup
docker-compose exec -T postgres psql -U n8n -d n8n < backup-YYYYMMDD_HHMMSS.sql

# Start n8n
docker-compose start n8n
```

### Backup Best Practices

1. **Regular Testing**: Test recovery procedures monthly
2. **Off-site Storage**: Copy backups to external storage
3. **Retention Policy**: Keep 7 daily, 4 weekly, 12 monthly backups
4. **Monitoring**: Set up alerts for backup failures
5. **Documentation**: Document recovery procedures

---

## 🧪 Testing & Validation

### Automated Testing Suite

The project includes comprehensive testing:

```bash
# Run basic installation test
./tests/test-installer.sh

# Run Proxmox-specific tests
./tests/test-proxmox-fixes.sh

# Run comprehensive multi-environment tests
./tests/test-comprehensive.sh

# Run quick validation tests
./tests/test-quick.sh

# Run focused component tests
./tests/test-focused.sh
```

### Manual Validation Checklist

#### Post-Installation Validation

```bash
# 1. Service Status
systemctl status docker nginx
cd /opt/n8n && docker-compose ps

# 2. Network Connectivity
curl -s http://localhost:5678
curl -k -s https://localhost
curl -s https://google.com

# 3. Security Configuration
sudo ufw status
sudo fail2ban-client status

# 4. SSL Certificate
openssl s_client -connect localhost:443 -servername localhost < /dev/null

# 5. Database Connectivity
cd /opt/n8n && docker-compose exec postgres pg_isready -U n8n

# 6. Backup System
/opt/n8n/backup.sh
ls -la /opt/n8n/backups/

# 7. Log Files
sudo journalctl -u nginx --no-pager -n 5
cd /opt/n8n && docker-compose logs --tail=5 n8n
```

#### Functional Testing

```bash
# Web Interface Test
# 1. Open browser to https://YOUR_SERVER_IP
# 2. Accept certificate warning
# 3. Login with credentials from /opt/n8n/credentials.txt
# 4. Create test workflow
# 5. Execute test workflow
# 6. Verify workflow execution logs

# API Testing
curl -u admin:YOUR_PASSWORD https://YOUR_SERVER_IP/rest/workflows

# Webhook Testing
curl -X POST https://YOUR_SERVER_IP/webhook-test/test
```

#### Performance Testing

```bash
# Load Testing (basic)
ab -n 100 -c 10 http://localhost:5678/

# Resource Monitoring During Load
watch -n 1 'docker stats --no-stream; echo "---"; free -h'

# Database Performance
cd /opt/n8n
docker-compose exec postgres psql -U n8n -d n8n -c "
SELECT schemaname,tablename,attname,n_distinct,correlation 
FROM pg_stats 
WHERE schemaname = 'public' 
ORDER BY n_distinct DESC;"
```

---

## 📋 Version History

### v1.3.0 (Latest) - Proxmox VM Support + Unified Entry Point Release

**🖥️ Major Virtualization Support:**
- 🔍 **Automatic Proxmox detection** - 6-point detection system
- ⏱️ **Extended VM timeouts** - Nginx timeouts 60s → 300s
- 🚀 **VM-optimized configurations** - Docker, kernel, network settings
- 📋 **Integrated Proxmox support** - Auto-detection with `--type proxmox` option
- 🌐 **Automatic VM IP detection** - Multiple fallback methods
- 📊 **Enhanced validation** - 15-minute startup timeout for VMs

**🎯 Unified Entry Point Improvements:**
- 🔄 **Single entry point** - `install.sh` now serves as the only installer needed
- 🔍 **Smart auto-detection** - Automatically detects environment and suggests optimizations
- 🖥️ **Interactive installation type selection** - Prompts for Proxmox users to choose installation type
- ⚙️ **Command-line installation types** - `--type auto|standard|proxmox` for scripting
- 📋 **Simplified documentation** - Single installation method with intelligent behavior
- 🧹 **Codebase cleanup** - Removed redundant `install-proxmox.sh` and duplicate documentation

**🔧 Technical Improvements:**
- 🏗️ **Modular architecture** - New `proxmox.sh` library module
- ⚙️ **Configurable timeouts** - Environment-aware settings
- 🧠 **Memory-conscious settings** - Resource optimization for VMs
- 🛠️ **Backward compatibility** - Zero breaking changes

**📖 Documentation & Usability:**
- 📋 **Comprehensive Proxmox guide** - Complete troubleshooting
- 🎯 **VM-specific best practices** - Resource and performance recommendations
- 🚀 **Multiple installation methods** - Auto-detection plus manual options
- 📊 **Real-time feedback** - User notification of optimizations

### v1.2.1 - Reliability & Quality Assurance Release

**🛠️ Major Reliability Improvements:**
- 🔐 **Enhanced password generation** - Multiple fallback methods
- 🤖 **Improved non-interactive mode** - Better automation support
- ✅ **ShellCheck compliance** - Zero warnings across all scripts
- 🧪 **Reorganized test suite** - Dedicated `tests/` directory
- 🐛 **Enhanced error handling** - Automatic bug report creation

### v1.2.0 - Enhanced CLI Interface Release

**🎛️ Major CLI/UX Improvements:**
- 🚀 **Command-line arguments support** - Full automation capabilities
- 📊 **Visual progress bars** - Enhanced progress visualization
- ✅ **Input validation** - Smart validation for IPs, domains, timezones
- 🔧 **Enhanced error recovery** - Detailed troubleshooting suggestions

### v1.1.0 - Performance Optimization Release

**🚀 Major Performance Improvements:**
- ⚡ **30-50% faster installation** through parallel processing
- 🔄 **Parallel service configuration** - Simultaneous setup
- 🏎️ **Fast Docker installation** using convenience script
- 📦 **Optimized package management** with batch installations

### v1.0.0 - Initial Release

- 🐳 Docker-based N8N installation
- 🔒 HTTPS with self-signed certificates
- 🛡️ Security hardening (UFW, Fail2Ban)
- 📦 Automated backup system
- ✅ Comprehensive testing suite

---

## 📚 Reference

### 🔧 **Complete Command Reference**

#### **Installation Commands**
```bash
# 🎯 Smart Installation (Recommended)
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash

# 🖥️ Proxmox VM Installation
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash -s -- --type proxmox --yes
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash -s -- --type proxmox --domain n8n.local --yes

# 💻 Standard Installation (No VM Optimizations)
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash -s -- --type standard --yes
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash -s -- --type standard --ip 192.168.1.100 --yes

# ⚡ Quick Installation
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash -s -- --quick --yes

# 🌐 Custom Domain Installation
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash -s -- --domain myserver.com --timezone America/New_York --yes

# 📦 Local Installation
git clone https://github.com/sylvester-francis/n8n-selfhoster.git
cd n8n-selfhoster
sudo ./install.sh                              # Interactive with auto-detection
sudo ./install.sh --type proxmox --yes         # Proxmox optimized
sudo ./install.sh --help                       # Show all options
sudo ./install.sh --dry-run --verbose          # Preview installation
```

#### **Service Management Commands**
```bash
# Docker Services
cd /opt/n8n
docker-compose ps                              # Show container status
docker-compose logs n8n                       # N8N logs
docker-compose logs postgres                  # Database logs
docker-compose logs -f n8n                    # Follow N8N logs
docker-compose restart n8n                    # Restart N8N
docker-compose restart postgres               # Restart database
docker-compose down                           # Stop all services
docker-compose up -d                          # Start all services

# System Services
sudo systemctl status nginx                   # Nginx status
sudo systemctl restart nginx                  # Restart Nginx
sudo systemctl reload nginx                   # Reload Nginx config
sudo systemctl status docker                  # Docker status
sudo systemctl restart docker                 # Restart Docker
```

#### **Maintenance Commands**
```bash
# Backups
cd /opt/n8n
./backup.sh                                   # Manual backup
ls -la backups/                               # List backups
./backup.sh restore backup_20240101_120000.tar.gz  # Restore backup

# Updates
cd /opt/n8n
docker-compose pull                           # Pull latest images
docker-compose up -d                          # Apply updates
docker system prune -f                        # Cleanup old images

# Monitoring
docker stats                                  # Container resource usage
docker system df                              # Docker disk usage
htop                                          # System resources
sudo nginx -t                                # Test Nginx config
curl -s http://localhost:5678                # Test N8N direct access
curl -k -s https://localhost                 # Test HTTPS proxy
```

#### **Troubleshooting Commands**
```bash
# Health Checks
sudo ./install.sh --dry-run                  # Check what installer detects
systemd-detect-virt                          # Check virtualization
free -h                                       # Memory usage
df -h                                         # Disk usage
ss -tuln | grep -E "(80|443|5678)"          # Check port listeners

# Log Analysis
tail -f /var/log/nginx/error.log            # Nginx errors
tail -f /tmp/n8n-installer.log              # Installation log
docker-compose logs --tail=50 n8n           # Recent N8N logs
journalctl -u docker --since "1 hour ago"   # Docker service logs

# Network Diagnostics
curl -I http://localhost                     # HTTP response headers
curl -I https://localhost                    # HTTPS response headers
ss -tuln                                     # All listening ports
ip addr show                                 # Network interfaces
```

#### **Security Commands**
```bash
# Firewall Management
sudo ufw status                              # Firewall status
sudo ufw app list                            # Available app profiles
sudo ufw allow from 192.168.1.0/24          # Allow local network

# SSL Certificate Management
sudo openssl x509 -in /etc/ssl/certs/n8n.crt -text -noout  # View certificate
sudo openssl s_client -connect localhost:443 -servername localhost  # Test SSL

# Security Monitoring
sudo fail2ban-client status                  # Fail2ban status
sudo fail2ban-client status nginx-http-auth  # Nginx protection status
sudo journalctl -u fail2ban --since "1 hour ago"  # Recent security events
```

### 📁 **File Structure**

```
n8n-selfhoster/
├── installer/
│   ├── install.sh              # Main installer
│   ├── config/
│   │   └── defaults.conf       # Default configuration
│   └── lib/                    # Modular libraries
│       ├── backup.sh          # Backup system
│       ├── common.sh          # Utilities and logging
│       ├── docker.sh          # Docker installation
│       ├── nginx.sh           # Nginx configuration
│       ├── n8n.sh             # N8N setup
│       ├── performance.sh     # Performance optimizations
│       ├── proxmox.sh         # Proxmox VM support
│       ├── security.sh        # Security hardening
│       ├── ssl.sh             # SSL certificates
│       ├── system.sh          # System requirements
│       └── validation.sh      # Testing and validation
├── tests/                      # Testing suite
│   ├── test-installer.sh      # Basic installation test
│   ├── test-comprehensive.sh  # Multi-environment testing
│   ├── test-proxmox-fixes.sh  # Proxmox VM testing
│   ├── test-quick.sh          # Quick validation
│   └── test-focused.sh        # Component testing
├── install.sh                 # Main installer (auto-detects environment)
├── README.md                  # This documentation
└── LICENSE                    # MIT License
```

### Important File Locations

```bash
# N8N Installation
/opt/n8n/                      # Main installation directory
/opt/n8n/docker-compose.yml    # Docker configuration
/opt/n8n/credentials.txt       # Login credentials
/opt/n8n/backup.sh            # Backup script
/opt/n8n/backups/             # Backup storage

# Nginx Configuration
/etc/nginx/sites-available/n8n # N8N site configuration
/etc/nginx/sites-enabled/n8n   # Enabled site link
/var/log/nginx/                # Nginx logs

# SSL Certificates
/etc/ssl/certs/n8n-selfsigned.crt     # SSL certificate
/etc/ssl/private/n8n-selfsigned.key   # SSL private key

# System Configuration
/etc/ufw/                      # Firewall rules
/etc/fail2ban/                 # Intrusion prevention
/etc/docker/daemon.json        # Docker configuration
/etc/sysctl.d/99-n8n-proxmox.conf # Kernel parameters (VMs)

# Logs
/tmp/n8n-installer.log         # Installation log
/var/log/nginx/access.log      # Nginx access log
/var/log/nginx/error.log       # Nginx error log
/var/log/fail2ban.log          # Fail2Ban log
```

### Environment Variables Reference

```bash
# N8N Core
N8N_HOST=0.0.0.0
N8N_PORT=5678
N8N_PROTOCOL=https
WEBHOOK_URL=https://domain/
NODE_ENV=production

# Database
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=postgres
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=n8n
DB_POSTGRESDB_USER=n8n
DB_POSTGRESDB_PASSWORD=<generated>

# Authentication
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=<generated>

# Runtime
GENERIC_TIMEZONE=<detected>
N8N_LOG_LEVEL=info
N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
N8N_RUNNERS_ENABLED=true

# VM-Specific (Proxmox)
N8N_MAX_EXECUTION_DATA_SIZE=5MB
N8N_MAX_WORKFLOW_SIZE=5MB
POSTGRES_SHARED_BUFFERS=128MB
NGINX_PROXY_TIMEOUT=300
VALIDATION_ATTEMPTS=30
```

### Network Ports

```bash
# Required Ports
22/tcp   # SSH (administration)
80/tcp   # HTTP (redirects to HTTPS)
443/tcp  # HTTPS (main access)

# Internal Ports
5678/tcp # N8N (bound to localhost only)
5432/tcp # PostgreSQL (container internal)
```

### Command Reference

```bash
# Installation
curl -fsSL URL | sudo bash                    # Standard installation
sudo ./install.sh --type proxmox             # Proxmox installation
sudo ./install.sh --help                     # Show all options

# Service Management
docker-compose ps                             # Container status
docker-compose logs n8n                      # N8N logs
docker-compose restart n8n                   # Restart N8N
systemctl status nginx                       # Nginx status

# Backup & Recovery
/opt/n8n/backup.sh                           # Manual backup
ls /opt/n8n/backups/                        # List backups

# Security
sudo ufw status                              # Firewall status
sudo fail2ban-client status                 # Intrusion prevention
sudo nginx -t                               # Test configuration

# Health Checks
curl -s http://localhost:5678                # Direct N8N access
curl -k -s https://localhost                 # HTTPS proxy
docker stats --no-stream                     # Resource usage

# Troubleshooting
systemd-detect-virt                          # Virtualization type
free -h && df -h                            # Resources
journalctl -u nginx -f                      # Live logs
```

### Support and Resources

- **GitHub Repository**: https://github.com/sylvester-francis/n8n-selfhoster
- **Issues & Bug Reports**: https://github.com/sylvester-francis/n8n-selfhoster/issues
- **Discussions**: https://github.com/sylvester-francis/n8n-selfhoster/discussions
- **N8N Documentation**: https://docs.n8n.io/
- **Docker Documentation**: https://docs.docker.com/
- **Nginx Documentation**: https://nginx.org/en/docs/

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [N8N Team](https://n8n.io) for creating an amazing automation platform
- [Docker](https://docker.com) for containerization technology
- [Nginx](https://nginx.org) for the robust web server
- [Let's Encrypt](https://letsencrypt.org) for free SSL certificates
- [Proxmox](https://www.proxmox.com/) for virtualization platform support

---

**Made with ❤️ for the N8N community**

[⭐ Star this repo](https://github.com/sylvester-francis/n8n-selfhoster) • [🍴 Fork it](https://github.com/sylvester-francis/n8n-selfhoster/fork) • [📢 Share it](https://twitter.com/intent/tweet?url=https://github.com/sylvester-francis/n8n-selfhoster&text=Just%20set%20up%20N8N%20in%20minutes%20with%20this%20awesome%20installer!)