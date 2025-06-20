#!/bin/bash

###################################################################################
#                                                                                 #
#                        N8N Self-Hosted Installer                               #
#                        Nginx Configuration Module                               #
#                                                                                 #
###################################################################################

# Install Nginx and SSL tools
install_nginx() {
    show_progress 5 15 "Installing Nginx and SSL tools"
    
    if command_exists nginx; then
        log "INFO" "Nginx already installed: $(nginx -v 2>&1)"
    else
        log "INFO" "Installing Nginx..."
        
        # Update package cache first
        if ! apt update; then
            log "ERROR" "Failed to update package cache for Nginx installation"
            return 1
        fi
        
        # Install Nginx with verbose output for debugging
        log "INFO" "Installing nginx package..."
        if ! timeout 300 env DEBIAN_FRONTEND=noninteractive apt install -y nginx; then
            log "ERROR" "Failed to install Nginx package"
            return 1
        fi
        
        # Force refresh of command cache and PATH
        hash -r
        export PATH="/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
        sleep 5
        
        # Wait for package installation to complete fully
        log "INFO" "Waiting for nginx package installation to complete..."
        local attempts=0
        while [ $attempts -lt 30 ]; do
            if [ -f "/usr/sbin/nginx" ] || [ -f "/usr/bin/nginx" ]; then
                break
            fi
            sleep 2
            attempts=$((attempts + 1))
        done
        
        # Check if nginx binary exists
        if [ -f "/usr/sbin/nginx" ]; then
            log "INFO" "Found nginx binary at /usr/sbin/nginx"
            NGINX_BINARY="/usr/sbin/nginx"
        elif [ -f "/usr/bin/nginx" ]; then
            log "INFO" "Found nginx binary at /usr/bin/nginx"
            NGINX_BINARY="/usr/bin/nginx"
        else
            log "ERROR" "Nginx binary not found after installation"
            # List installed nginx files for debugging
            log "DEBUG" "Checking installed nginx files:"
            dpkg -L nginx-core 2>/dev/null | grep -E "(nginx|sbin)" | head -10 || true
            dpkg -L nginx 2>/dev/null | grep -E "(nginx|sbin)" | head -10 || true
            return 1
        fi
        
        # Test nginx command directly
        if $NGINX_BINARY -v 2>/dev/null; then
            log "SUCCESS" "Nginx installed successfully: $($NGINX_BINARY -v 2>&1)"
        else
            log "ERROR" "Nginx installation verification failed"
            return 1
        fi
    fi
    
    if command_exists certbot; then
        log "INFO" "Certbot already installed"
    else
        log "INFO" "Installing Certbot..."
        if ! timeout 300 env DEBIAN_FRONTEND=noninteractive apt install -y certbot python3-certbot-nginx; then
            log "ERROR" "Failed to install Certbot"
            return 1
        fi
        
        # Verify Certbot installation
        if command_exists certbot; then
            log "SUCCESS" "Certbot installed"
        else
            log "ERROR" "Certbot installation verification failed"
            return 1
        fi
    fi
    
    # Stop nginx for configuration
    log "INFO" "Stopping Nginx for configuration..."
    systemctl stop nginx || true
    
    # Enable Nginx service
    systemctl enable nginx || log "WARNING" "Failed to enable Nginx service"
}

# Configure Nginx reverse proxy
configure_nginx() {
    show_progress 8 15 "Configuring Nginx reverse proxy"
    
    # Create Nginx configuration
    log "INFO" "Creating Nginx configuration for N8N..."
    
    # Ensure nginx directories exist
    mkdir -p /etc/nginx/sites-available
    mkdir -p /etc/nginx/sites-enabled
    
    # Create nginx configuration file
    log "INFO" "Creating nginx configuration file..."
    cat > /etc/nginx/sites-available/n8n << EOF
# Rate limiting for security
limit_req_zone \\\$binary_remote_addr zone=n8n:10m rate=10r/s;

server {
    listen 80;
    server_name $DOMAIN_NAME;
    
    # Redirect HTTP to HTTPS
    return 301 https://\\\$server_name\\\$request_uri;
}

server {
    listen 443 ssl;
    server_name $DOMAIN_NAME;

    # SSL Configuration
    ssl_certificate /etc/ssl/certs/n8n-selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/n8n-selfsigned.key;
    
    # Modern SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Rate limiting
    limit_req zone=n8n burst=20 nodelay;

    # Increase client body size for file uploads
    client_max_body_size 50M;

    # Proxy to N8N
    location / {
        proxy_pass http://127.0.0.1:5678;
        proxy_set_header Host \\\$host;
        proxy_set_header X-Real-IP \\\$remote_addr;
        proxy_set_header X-Forwarded-For \\\$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \\\$scheme;
        
        # WebSocket support for N8N
        proxy_http_version 1.1;
        proxy_set_header Upgrade \\\$http_upgrade;
        proxy_set_header Connection "upgrade";
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # Disable buffering for real-time features
        proxy_buffering off;
        proxy_request_buffering off;
    }
}
EOF
    
    # Remove default site and enable N8N site
    rm -f /etc/nginx/sites-enabled/default
    ln -sf /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
    
    # Test Nginx configuration
    log "INFO" "Testing Nginx configuration..."
    local nginx_cmd=""
    
    # Find nginx command
    if command_exists nginx; then
        nginx_cmd="nginx"
    elif [ -f "/usr/sbin/nginx" ]; then
        nginx_cmd="/usr/sbin/nginx"
    elif [ -f "/usr/bin/nginx" ]; then
        nginx_cmd="/usr/bin/nginx"
    else
        log "ERROR" "Nginx binary not found, cannot test configuration"
        # Try to find the binary anyway
        find /usr -name "nginx" -type f -executable 2>/dev/null || true
        return 1
    fi
    
    # Test configuration
    log "INFO" "Testing nginx configuration with: $nginx_cmd"
    if $nginx_cmd -t; then
        log "SUCCESS" "Nginx configuration is valid"
    else
        log "ERROR" "Nginx configuration test failed"
        # Show nginx configuration errors
        $nginx_cmd -t 2>&1 || true
        return 1
    fi
}

# Start Nginx service
start_nginx() {
    show_progress 14 15 "Starting Nginx service"
    
    # Check if Nginx is installed
    if ! command_exists nginx && [ ! -f "/usr/sbin/nginx" ] && [ ! -f "/usr/bin/nginx" ]; then
        log "ERROR" "Nginx is not installed, cannot start service"
        return 1
    fi
    
    # Start Nginx
    log "INFO" "Starting Nginx..."
    if systemctl start nginx; then
        log "SUCCESS" "Nginx service started"
    else
        log "ERROR" "Failed to start Nginx service"
        return 1
    fi
    
    # Enable Nginx at boot
    if systemctl enable nginx; then
        log "INFO" "Nginx service enabled at boot"
    else
        log "WARNING" "Failed to enable Nginx service at boot"
    fi
}