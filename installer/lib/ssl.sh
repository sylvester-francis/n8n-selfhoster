#!/bin/bash

###################################################################################
#                                                                                 #
#                        N8N Self-Hosted Installer                               #
#                        SSL Certificate Module                                   #
#                                                                                 #
###################################################################################

# Generate SSL certificate
generate_ssl_certificate() {
    show_progress 6 15 "Generating SSL certificate"
    
    if [ "$USE_DOMAIN" = true ]; then
        log "INFO" "Domain detected. You can set up Let's Encrypt later."
        log "INFO" "For now, generating self-signed certificate for testing..."
    fi
    
    # Create SSL directories
    mkdir -p /etc/ssl/private
    mkdir -p /etc/ssl/certs
    
    # Generate self-signed certificate
    log "INFO" "Generating self-signed SSL certificate..."
    if ! timeout 60 openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/private/n8n-selfsigned.key \
        -out /etc/ssl/certs/n8n-selfsigned.crt \
        -subj "/C=US/ST=State/L=City/O=N8N-Server/OU=IT/CN=$DOMAIN_NAME"; then
        log "ERROR" "Failed to generate SSL certificate"
        return 1
    fi
    
    # Verify certificates were created
    if [ ! -f "/etc/ssl/private/n8n-selfsigned.key" ] || [ ! -f "/etc/ssl/certs/n8n-selfsigned.crt" ]; then
        log "ERROR" "SSL certificate files were not created"
        return 1
    fi
    
    # Set proper permissions
    chmod 600 /etc/ssl/private/n8n-selfsigned.key
    chmod 644 /etc/ssl/certs/n8n-selfsigned.crt
    
    log "SUCCESS" "SSL certificate generated for $DOMAIN_NAME"
}