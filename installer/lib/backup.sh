#!/bin/bash

###################################################################################
#                                                                                 #
#                        N8N Self-Hosted Installer                               #
#                        Backup Configuration Module                              #
#                                                                                 #
###################################################################################

# Set up automated backups
setup_backups() {
    show_progress 10 15 "Setting up automated backups"
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    
    # Create backup script
    log "INFO" "Creating backup script..."
    
    cat > "$N8N_DIR/backup.sh" << 'EOF'
#!/bin/bash

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/opt/n8n/backups"
LOG_FILE="/var/log/n8n-backup.log"

echo "$(date): Starting N8N backup" >> $LOG_FILE

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Backup N8N data
echo "$(date): Backing up N8N data..." >> $LOG_FILE
docker run --rm -v n8n_n8n_data:/data -v $BACKUP_DIR:/backup alpine \
    tar czf /backup/n8n_data_$DATE.tar.gz -C /data . 2>> $LOG_FILE

# Backup PostgreSQL data
echo "$(date): Backing up PostgreSQL data..." >> $LOG_FILE
docker run --rm -v n8n_postgres_data:/data -v $BACKUP_DIR:/backup alpine \
    tar czf /backup/postgres_data_$DATE.tar.gz -C /data . 2>> $LOG_FILE

# Keep only last 7 days of backups
echo "$(date): Cleaning old backups..." >> $LOG_FILE
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete 2>> $LOG_FILE

echo "$(date): Backup completed successfully" >> $LOG_FILE

# Log backup sizes
ls -lh $BACKUP_DIR/*$DATE* >> $LOG_FILE 2>/dev/null || true
EOF
    
    chmod +x "$N8N_DIR/backup.sh"
    
    # Add cron job for daily backups
    log "INFO" "Setting up daily backup cron job..."
    # Get existing crontab or create empty if none exists
    crontab -l 2>/dev/null > /tmp/current_cron || echo "" > /tmp/current_cron
    # Add our backup job if it doesn't already exist
    if ! grep -q "$N8N_DIR/backup.sh" /tmp/current_cron 2>/dev/null; then
        echo "0 2 * * * $N8N_DIR/backup.sh" >> /tmp/current_cron
    fi
    # Install the updated crontab
    crontab /tmp/current_cron
    rm -f /tmp/current_cron
    
    # Create log rotation for backup logs
    cat > /etc/logrotate.d/n8n-backup << 'EOF'
/var/log/n8n-backup.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 root root
}
EOF
    
    log "SUCCESS" "Automated backups configured (daily at 2:00 AM)"
}