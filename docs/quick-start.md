# Quick Start Guide

Get your N8N self-hosted instance up and running in minutes with this streamlined guide.

## 🚀 One-Line Installation

```bash
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash
```

This command will:
1. ✅ Install all dependencies (Docker, Nginx, PostgreSQL)
2. ✅ Configure N8N with secure defaults
3. ✅ Set up SSL certificates
4. ✅ Configure firewall and security
5. ✅ Start all services

**Installation time**: 5-10 minutes on most systems.

## 🎯 What Happens During Installation

### Automatic Detection
The installer automatically detects:
- Your server's IP address
- Operating system version
- Available resources
- Network configuration
- Virtualization environment (Proxmox, VMware, etc.)

### Components Installed
- **Docker & Docker Compose**: Container orchestration
- **PostgreSQL**: Database for N8N data
- **Nginx**: Reverse proxy with SSL termination
- **N8N**: Workflow automation platform
- **UFW Firewall**: Security protection
- **Fail2Ban**: Intrusion prevention
- **Backup System**: Automated data protection

## 🌐 First Access

### 1. Find Your N8N URL

After installation completes, you'll see:
```
🎉 Installation completed successfully!

📍 N8N is accessible at:
   • https://your-server-ip
   • https://your-domain.com (if configured)

🔐 Security Information:
   • Firewall: Enabled (UFW)
   • SSL: Self-signed certificate installed
   • Admin: Create admin user on first login
```

### 2. Access N8N Web Interface

Open your browser and navigate to the provided URL:
- **Local/Testing**: `https://your-server-ip`
- **Production**: `https://your-domain.com`

**Note**: You may see a security warning due to self-signed certificates. This is normal for initial setup.

### 3. Create Admin Account

On first access, N8N will prompt you to:
1. **Create Owner Account**: Set username and password
2. **Configure Basic Settings**: Workspace name, preferences
3. **Explore Interface**: Take the optional tour

## ⚙️ Post-Installation Configuration

### 1. Install Task Runner (Recommended)

```bash
curl -sL https://taskfile.dev/install.sh | sudo sh -s -- -b /usr/local/bin
```

This enables advanced management commands:

```bash
# Check system status
task status

# View logs
task logs

# Create backup
task backup

# Show all available commands
task --list
```

### 2. Configure Domain (Production)

If you have a domain name, update the configuration:

```bash
# Set domain and get real SSL certificates
sudo task nginx:ssl
```

Or manually edit `/opt/n8n/.env`:
```env
DOMAIN=your-domain.com
SUBDOMAIN=n8n
```

Then restart services:
```bash
sudo task n8n:restart
sudo task nginx:restart
```

### 3. Set Up Automatic Backups

```bash
sudo task backup:schedule
```

This configures:
- Daily automated backups
- Backup retention (7 days)
- Backup verification
- Email notifications (optional)

## 🎯 Quick Management Tasks

### Service Status
```bash
# Overall status
task status

# Individual services
task n8n:status
task docker:status
task nginx:status
```

### Service Control
```bash
# Restart services
sudo task n8n:restart
sudo task nginx:restart

# View logs
task n8n:logs
task nginx:logs
```

### Backup Operations
```bash
# Create backup
sudo task backup

# List backups
task backup:list

# Restore backup
sudo task backup:restore
```

### Security Check
```bash
# Security status
task security:status

# Run security audit
sudo task security:audit
```

## 🔧 Common First Steps

### 1. Create Your First Workflow

1. **Log into N8N** at your server URL
2. **Click "New Workflow"** in the interface
3. **Add nodes** by clicking the "+" button
4. **Connect nodes** by dragging between connection points
5. **Test execution** using the "Execute Workflow" button
6. **Save workflow** when satisfied

### 2. Explore Templates

N8N includes workflow templates:
1. Click **"Templates"** in the main menu
2. Browse **pre-built workflows**
3. **Import template** and customize for your needs

### 3. Configure Credentials

For external services:
1. Go to **"Credentials"** in the main menu
2. **Add credential** for your service (Gmail, Slack, etc.)
3. **Test connection** to verify setup
4. **Use credential** in your workflows

## 📊 Health Check

Verify everything is working correctly:

```bash
task test:health-check
```

This validates:
- ✅ All containers running
- ✅ Database connectivity
- ✅ Web interface accessible
- ✅ SSL certificates valid
- ✅ Backup system functional

## 🚨 Troubleshooting Quick Issues

### Can't Access Web Interface

```bash
# Check service status
task status

# Check specific issues
task test:connectivity
task nginx:status
```

### Services Not Starting

```bash
# Check Docker status
task docker:status

# Restart all services
sudo task docker:restart
sudo task n8n:restart
sudo task nginx:restart
```

### SSL Certificate Issues

```bash
# Check certificate status
task security:status

# Regenerate certificates
sudo task nginx:ssl
```

### Permission Issues

```bash
# Check file permissions
sudo chown -R 1000:1000 /opt/n8n/n8n-data
sudo task n8n:restart
```

## 🎛️ Next Steps

### Learning N8N
- **Official Documentation**: [docs.n8n.io](https://docs.n8n.io)
- **Community Forum**: [community.n8n.io](https://community.n8n.io)
- **Workflow Templates**: Available in the N8N interface

### Advanced Configuration
- **[Service Management](service-management.md)**: Day-to-day operations
- **[Security Configuration](security.md)**: Hardening your installation
- **[Backup & Restore](backup-restore.md)**: Data protection strategies
- **[Performance Tuning](performance.md)**: Optimization strategies

### Development
- **[Task Commands](task-commands.md)**: Complete command reference
- **[Development Workflow](development.md)**: Contributing to the project

## 📞 Getting Help

### Quick Help
```bash
task help                    # Main help system
task --list                  # All available commands
```

### Community Support
- **GitHub Issues**: [Report issues](https://github.com/sylvester-francis/n8n-selfhoster/issues)
- **Discussions**: [Community discussions](https://github.com/sylvester-francis/n8n-selfhoster/discussions)
- **Documentation**: This docs folder

### Emergency Recovery
If something goes wrong:
```bash
# Check all services
task status

# Run comprehensive diagnostics
task test:comprehensive

# Get detailed logs
task n8n:logs
task nginx:logs
task docker:logs
```

---

**🎉 Congratulations!** You now have a fully functional N8N self-hosted instance. Start building your first workflow automation and explore the powerful capabilities of N8N!