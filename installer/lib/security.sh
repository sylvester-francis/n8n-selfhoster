#!/bin/bash

###################################################################################
#                                                                                 #
#                        N8N Self-Hosted Installer                               #
#                        Security and Firewall Module                             #
#                                                                                 #
###################################################################################

# Configure firewall
configure_firewall() {
    show_progress 9 15 "Configuring firewall"
    
    log "INFO" "Setting up UFW firewall..."
    
    # Reset UFW to defaults
    ufw --force reset
    
    # Set default policies
    ufw default deny incoming
    ufw default allow outgoing
    
    # Allow SSH (be careful not to lock yourself out!)
    ufw allow 22/tcp comment 'SSH'
    
    # Allow HTTP and HTTPS
    ufw allow 80/tcp comment 'HTTP'
    ufw allow 443/tcp comment 'HTTPS'
    
    # Enable firewall
    ufw --force enable
    
    log "SUCCESS" "Firewall configured and enabled"
    ufw status numbered
}

# Set up security hardening
setup_security() {
    show_progress 11 15 "Configuring security settings"
    
    # Configure Fail2Ban for Nginx
    log "INFO" "Setting up Fail2Ban for additional security..."
    
    cat > /etc/fail2ban/jail.d/nginx-n8n.conf << 'EOF'
[nginx-n8n]
enabled = true
port = 80,443
filter = nginx-n8n
logpath = /var/log/nginx/access.log
maxretry = 5
bantime = 3600
findtime = 600

[nginx-n8n-auth]
enabled = true
port = 80,443
filter = nginx-n8n-auth
logpath = /var/log/nginx/error.log
maxretry = 3
bantime = 7200
findtime = 600
EOF
    
    # Create Fail2Ban filters
    cat > /etc/fail2ban/filter.d/nginx-n8n.conf << 'EOF'
[Definition]
failregex = ^<HOST> -.*"(GET|POST).*" (404|403|401) .*$
            ^<HOST> -.*"(GET|POST) /(\.env|wp-admin|admin|login\.php|phpmyadmin).*" .*$
ignoreregex =
EOF
    
    cat > /etc/fail2ban/filter.d/nginx-n8n-auth.conf << 'EOF'
[Definition]
failregex = \[error\] \d+#\d+: \*\d+ user "\S+":? (password mismatch|was not found), client: <HOST>, server: \S+, request: "\S+ \S+ HTTP/\d+\.\d+", host: "\S+"
            \[error\] \d+#\d+: \*\d+ no user/password was provided for basic authentication, client: <HOST>, server: \S+, request: "\S+ \S+ HTTP/\d+\.\d+", host: "\S+"
ignoreregex =
EOF
    
    # Restart Fail2Ban
    systemctl restart fail2ban
    systemctl enable fail2ban
    
    # Set up log rotation for Nginx
    cat > /etc/logrotate.d/nginx-n8n << 'EOF'
/var/log/nginx/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 644 www-data adm
    sharedscripts
    prerotate
        if [ -d /etc/logrotate.d/httpd-prerotate ]; then \
            run-parts /etc/logrotate.d/httpd-prerotate; \
        fi \
    endscript
    postrotate
        invoke-rc.d nginx rotate >/dev/null 2>&1
    endpostrotate
}
EOF
    
    log "SUCCESS" "Security hardening completed"
}