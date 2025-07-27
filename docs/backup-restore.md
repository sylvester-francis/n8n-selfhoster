# Backup & Restore Guide

Comprehensive data protection strategies for your N8N self-hosted installation using the Task-based backup system.

## 🎯 Overview

The N8N backup system protects your critical data:
- **N8N workflows and configurations**
- **PostgreSQL database**
- **User credentials and settings**
- **SSL certificates**
- **Custom configurations**

## 🚀 Quick Backup

### Create Immediate Backup

```bash
# Create manual backup
sudo task backup

# Create backup with custom name
sudo task backup -- --name "pre-update-backup"
```

This creates a timestamped backup in `/opt/n8n/backups/`:
```
/opt/n8n/backups/
├── n8n-backup-2024-07-27-14-30-00.tar.gz
├── n8n-backup-2024-07-26-14-30-00.tar.gz
└── ...
```

### Backup Status

```bash
# Check backup system status
task backup:status

# List all available backups
task backup:list

# Verify backup integrity
task backup:verify
```

## ⚙️ Backup System Setup

### Initial Setup

```bash
# Setup backup system
sudo task backup:setup
```

This configures:
- Backup directory structure
- Backup scripts and utilities
- Default retention policies
- Verification mechanisms

### Automatic Backup Scheduling

```bash
# Setup automatic daily backups
sudo task backup:schedule
```

This creates a cron job for:
- **Daily backups** at 2:00 AM
- **7-day retention** (configurable)
- **Automatic cleanup** of old backups
- **Email notifications** (optional)

### Custom Backup Schedule

Edit the cron schedule manually:
```bash
sudo crontab -e

# Add custom schedule (e.g., every 6 hours)
0 */6 * * * /usr/local/bin/task -d /opt/n8n-selfhoster backup:create-backup
```

## 💾 Backup Operations

### Manual Backup Creation

```bash
# Standard backup
sudo task backup:create-backup

# Backup with verification
sudo task backup:create-backup && task backup:verify

# Backup with custom compression
sudo task backup:create-backup -- --compression=xz
```

### Backup Verification

```bash
# Verify latest backup
task backup:verify

# Verify specific backup
task backup:verify -- --file="n8n-backup-2024-07-27-14-30-00.tar.gz"

# Comprehensive verification
task backup:verify -- --full-check
```

### Backup Management

```bash
# List all backups with details
task backup:list

# Cleanup old backups (keeps last 7)
sudo task backup:cleanup

# Force cleanup (keeps last 3)
sudo task backup:cleanup -- --keep=3

# Delete specific backup
sudo rm /opt/n8n/backups/n8n-backup-YYYY-MM-DD-HH-MM-SS.tar.gz
```

## 🔄 Restore Operations

### Interactive Restore

```bash
# Start interactive restore process
sudo task backup:restore
```

This provides a menu-driven interface:
1. **Select backup** from available backups
2. **Choose components** to restore (full/partial)
3. **Confirm restoration** with safety checks
4. **Automatic service restart** after restore

### Restore Specific Components

```bash
# Restore only N8N data
sudo task backup:restore -- --component=n8n-data

# Restore only database
sudo task backup:restore -- --component=database

# Restore only configurations
sudo task backup:restore -- --component=config
```

### Emergency Restore

```bash
# Quick restore from latest backup
sudo task backup:restore -- --latest --auto-confirm

# Restore from specific backup
sudo task backup:restore -- --file="backup-name.tar.gz" --auto-confirm
```

## 📁 Backup Contents

### What's Included

The backup system captures:

```
/opt/n8n/backups/n8n-backup-TIMESTAMP.tar.gz
├── n8n-data/                    # N8N user data
│   ├── workflows/               # Workflow definitions
│   ├── credentials/             # Encrypted credentials
│   └── settings/                # User settings
├── postgres-dump.sql            # Database dump
├── docker-compose.yml           # Service configuration
├── .env                         # Environment variables
├── nginx-config/                # Nginx configuration
│   └── sites-available/n8n      # N8N site config
├── ssl-certificates/            # SSL certificates
│   ├── n8n-selfsigned.crt
│   └── n8n-selfsigned.key
└── metadata.json               # Backup metadata
```

### Backup Metadata

Each backup includes metadata:
```json
{
  "timestamp": "2024-07-27T14:30:00Z",
  "version": "1.3.1",
  "n8n_version": "1.0.5",
  "components": ["n8n-data", "database", "config", "ssl"],
  "size": "45.2MB",
  "checksum": "sha256:abc123..."
}
```

## 🛡️ Backup Security

### Encryption

Enable backup encryption:
```bash
# Setup encrypted backups
sudo task backup:setup -- --encrypt --password="your-secure-password"
```

Encrypted backups:
- Use **AES-256** encryption
- Require **password** for restoration
- Store **encrypted metadata**

### Secure Storage

Backup to external locations:

```bash
# Configure remote backup location
sudo nano /opt/n8n/backup-config.yml

remote_backup:
  enabled: true
  type: "s3"  # or "rsync", "scp"
  destination: "s3://your-bucket/n8n-backups/"
  retention: 30  # days
```

### Access Control

Secure backup files:
```bash
# Set secure permissions
sudo chmod 600 /opt/n8n/backups/*.tar.gz
sudo chown root:root /opt/n8n/backups/*.tar.gz

# Restrict backup directory
sudo chmod 700 /opt/n8n/backups/
```

## 🧪 Testing Backups

### Backup Validation

```bash
# Test backup integrity
task backup:verify

# Test restore process (dry run)
sudo task backup:restore -- --dry-run

# Full restore test on test system
sudo task backup:restore -- --test-mode
```

### Disaster Recovery Testing

1. **Create test environment**:
   ```bash
   # On test server
   curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash
   ```

2. **Transfer backup**:
   ```bash
   scp backup-file.tar.gz test-server:/opt/n8n/backups/
   ```

3. **Test restore**:
   ```bash
   # On test server
   sudo task backup:restore
   ```

4. **Verify functionality**:
   ```bash
   task test:health-check
   task test:connectivity
   ```

## 📊 Monitoring Backups

### Backup Health Monitoring

```bash
# Check backup system health
task backup:status

# Monitor backup size trends
ls -lah /opt/n8n/backups/

# Check last backup time
stat /opt/n8n/backups/ | grep Modify
```

### Automated Notifications

Setup backup notifications:

```bash
# Configure email notifications
sudo nano /opt/n8n/backup-config.yml

notifications:
  email:
    enabled: true
    smtp_server: "smtp.gmail.com"
    smtp_port: 587
    username: "your-email@gmail.com"
    password: "app-password"
    to: "admin@yourdomain.com"
    on_success: true
    on_failure: true
```

### Backup Monitoring Script

Create monitoring script:
```bash
#!/bin/bash
# /opt/n8n/monitor-backup.sh

BACKUP_DIR="/opt/n8n/backups"
LATEST_BACKUP=$(ls -t $BACKUP_DIR/*.tar.gz | head -1)
BACKUP_AGE=$(find $BACKUP_DIR -name "*.tar.gz" -mtime -1 | wc -l)

if [ $BACKUP_AGE -eq 0 ]; then
    echo "WARNING: No recent backups found!"
    # Send alert
fi
```

## 🚨 Disaster Recovery

### Complete System Recovery

1. **Fresh Installation**:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash
   ```

2. **Stop Services**:
   ```bash
   sudo task n8n:stop
   sudo task nginx:stop
   ```

3. **Restore Data**:
   ```bash
   sudo task backup:restore
   ```

4. **Verify and Start**:
   ```bash
   sudo task n8n:start
   sudo task nginx:start
   task test:health-check
   ```

### Partial Recovery

Restore specific components:

```bash
# Database only
sudo task backup:restore -- --component=database

# Workflows only
sudo task backup:restore -- --component=n8n-data

# Configuration only
sudo task backup:restore -- --component=config
```

## 🔧 Advanced Backup Configuration

### Custom Backup Scripts

Create custom backup hooks:
```bash
# Pre-backup script
sudo nano /opt/n8n/pre-backup.sh

#!/bin/bash
# Custom pre-backup operations
echo "Starting custom backup procedures..."
# Add your custom logic here

# Post-backup script
sudo nano /opt/n8n/post-backup.sh

#!/bin/bash
# Custom post-backup operations
echo "Backup completed, running cleanup..."
# Add your custom logic here
```

### Backup Configuration File

```yaml
# /opt/n8n/backup-config.yml
backup:
  retention_days: 7
  compression: "gzip"  # gzip, xz, lz4
  verify_after_backup: true
  include_logs: false
  
  components:
    n8n_data: true
    database: true
    config: true
    ssl_certificates: true
    nginx_config: true
    
  remote:
    enabled: false
    type: "s3"
    bucket: "n8n-backups"
    region: "us-east-1"
    
  notifications:
    enabled: false
    email: "admin@example.com"
    
  schedule:
    enabled: true
    time: "02:00"
    timezone: "UTC"
```

## 📋 Backup Best Practices

### Regular Backup Schedule
- **Daily backups** for production systems
- **Weekly backups** for development systems
- **Pre-update backups** before any changes

### Storage Strategy
- **Local backups** for quick recovery
- **Remote backups** for disaster recovery
- **Multiple backup locations** for redundancy

### Testing Protocol
- **Monthly restore tests** on test environment
- **Quarterly disaster recovery drills**
- **Annual backup strategy review**

### Security Considerations
- **Encrypt sensitive backups**
- **Secure backup storage locations**
- **Regular backup integrity verification**
- **Access control for backup files**

---

**Next Steps**:
- Configure [Security](security.md) for backup protection
- Set up [Monitoring](troubleshooting.md) for backup health
- Review [Performance Tuning](performance.md) for backup optimization