# Installation Guide

This guide covers all installation methods for the N8N Self-Hosted Installer using the Task-based architecture.

## 📋 Prerequisites

### System Requirements
- **Operating System**: Ubuntu 20.04, 22.04, or compatible Linux distribution
- **Memory**: Minimum 2GB RAM (4GB recommended)
- **Storage**: Minimum 10GB free space (20GB recommended)
- **Network**: Internet connection for downloading packages
- **User Access**: sudo privileges required

### Port Requirements
- **80**: HTTP (redirects to HTTPS)
- **443**: HTTPS (N8N web interface)
- **22**: SSH (for remote access)

## 🚀 Installation Methods

### Method 1: One-Line Installation (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash
```

This method:
- Automatically detects your environment
- Handles all dependencies
- Configures secure defaults
- Sets up SSL certificates
- Configures firewall rules

### Method 2: Task-Based Installation

For users who want more control over the installation process:

```bash
# 1. Install Task runner
curl -sL https://taskfile.dev/install.sh | sudo sh -s -- -b /usr/local/bin

# 2. Clone repository
git clone https://github.com/sylvester-francis/n8n-selfhoster.git
cd n8n-selfhoster

# 3. View available commands
task --list

# 4. Run installation
sudo task install
```

### Method 3: Manual Download and Install

```bash
# Download and extract
wget https://github.com/sylvester-francis/n8n-selfhoster/archive/main.tar.gz
tar -xzf main.tar.gz
cd n8n-selfhoster-main

# Run installation
sudo bash install.sh
```

## ⚙️ Installation Options

### Interactive Installation

```bash
sudo ./install.sh --force-interactive
```

This will prompt you for:
- Server IP address
- Domain name
- Timezone
- Email for SSL certificates
- Backup preferences

### Non-Interactive Installation

```bash
sudo ./install.sh --yes \
  --domain your-domain.com \
  --email admin@your-domain.com \
  --timezone America/New_York
```

### Quick Installation (Testing)

```bash
sudo ./install.sh --quick --yes --ip $(hostname -I | awk '{print $1}')
```

**Warning**: Quick mode uses self-signed certificates and default passwords. Only use for testing.

### Proxmox Optimized Installation

```bash
sudo ./install.sh --type proxmox --yes
```

This applies Proxmox-specific optimizations:
- QEMU guest agent installation
- Optimized resource allocation
- VM-specific performance tuning

## 🎛️ Configuration Parameters

### Required Parameters
- `--domain`: Your domain name (e.g., n8n.example.com)
- `--email`: Email for Let's Encrypt certificates

### Optional Parameters
- `--ip`: Server IP address (auto-detected if not specified)
- `--timezone`: System timezone (default: UTC)
- `--yes`: Non-interactive mode
- `--quick`: Quick setup for testing
- `--dry-run`: Preview installation without making changes
- `--type`: Installation type (standard, proxmox)
- `--skip-backups`: Skip backup system setup
- `--force-interactive`: Force interactive mode even in automated environments

## 📁 Installation Locations

After installation, files are organized as follows:

```
/opt/n8n/
├── docker-compose.yml          # N8N services configuration
├── .env                        # Environment variables
├── postgres-data/              # PostgreSQL data
├── n8n-data/                   # N8N user data
├── backups/                    # Backup storage
└── backup.sh                   # Backup script

/etc/nginx/sites-available/
└── n8n                         # Nginx configuration

/etc/ssl/certs/
└── n8n-selfsigned.crt         # SSL certificate

/var/log/
└── n8n-installer.log          # Installation log
```

## 🔐 Post-Installation Security

### Default Credentials
- **N8N Admin**: Set during first access via web interface
- **PostgreSQL**: Auto-generated (stored in `/opt/n8n/.env`)

### SSL Certificates
- **Production**: Automatic Let's Encrypt certificates
- **Testing**: Self-signed certificates

### Firewall Configuration
- UFW enabled with necessary ports open
- Fail2Ban configured for SSH protection

## 🧪 Verification

### Quick Health Check

```bash
# Using Task commands
task status
task test:health-check

# Manual verification
sudo docker ps
sudo systemctl status nginx
curl -k https://localhost
```

### Comprehensive Testing

```bash
task test:comprehensive
```

## 🔧 Task-Based Management

After installation, use these Task commands for management:

```bash
# Service status
task status
task n8n:status
task docker:status
task nginx:status

# Service control
task n8n:restart
task nginx:restart
task docker:restart

# Logs
task logs
task n8n:logs
task nginx:logs

# Backup
task backup
task backup:list
task backup:restore
```

## 🚨 Troubleshooting

### Common Issues

**Docker installation fails**
```bash
# Check system compatibility
task system:check-requirements
task docker:install
```

**Nginx configuration errors**
```bash
# Verify configuration
sudo nginx -t
task nginx:restart
```

**SSL certificate issues**
```bash
# Check certificate status
task security:status
task nginx:ssl
```

**N8N not accessible**
```bash
# Check all services
task status
task test:connectivity
```

### Log Files
- Installation: `/var/log/n8n-installer.log`
- N8N: `task n8n:logs`
- Nginx: `task nginx:logs`
- Docker: `task docker:logs`

### Getting Help
- Check [Troubleshooting Guide](troubleshooting.md)
- Review [FAQ](troubleshooting.md#faq)
- Create issue on [GitHub](https://github.com/sylvester-francis/n8n-selfhoster/issues)

## 📊 Installation Validation

Run comprehensive validation after installation:

```bash
task test:comprehensive
```

This validates:
- ✅ All services running
- ✅ N8N web interface accessible
- ✅ SSL certificates valid
- ✅ Database connectivity
- ✅ Backup system functional
- ✅ Security configuration correct

---

**Next Steps**: After successful installation, see [Quick Start Guide](quick-start.md) for initial configuration and [Service Management](service-management.md) for ongoing operations.