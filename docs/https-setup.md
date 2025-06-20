# HTTPS Setup Guide

This guide covers setting up proper HTTPS certificates for your N8N installation.

## Option 1: Let's Encrypt (Recommended for Production)

### Prerequisites

- A domain name pointing to your server
- DNS propagation completed (usually 5-10 minutes)

### Step 1: Verify DNS

```bash
# Test DNS propagation
nslookup your-domain.com
# Should return your server IP
```

### Step 2: Install Certbot

```bash
# Install certbot (if not already installed by the main installer)
apt update
apt install -y certbot python3-certbot-nginx
```

### Step 3: Get SSL Certificate

```bash
# Get SSL certificate with Let's Encrypt
certbot --nginx -d your-domain.com

# Follow the prompts:
# - Enter your email address
# - Agree to terms of service
# - Choose whether to share email with EFF (optional)
# - Certbot will automatically configure SSL
```

### Step 4: Update N8N Configuration

```bash
# Navigate to N8N directory
cd /opt/n8n

# Stop N8N services
docker-compose down

# Update WEBHOOK_URL in docker-compose.yml
sed -i 's|WEBHOOK_URL=.*|WEBHOOK_URL=https://your-domain.com/|' docker-compose.yml
sed -i 's|N8N_HOST=.*|N8N_HOST=your-domain.com|' docker-compose.yml

# Restart N8N
docker-compose up -d
```

### Step 5: Test Auto-Renewal

```bash
# Test certificate renewal
certbot renew --dry-run

# Check auto-renewal timer
systemctl status certbot.timer
```

## Option 2: Cloudflare SSL (Advanced)

If you're using Cloudflare, you can use their SSL certificates:

### Step 1: Configure Cloudflare

1. Add your domain to Cloudflare
2. Set DNS records to point to your server
3. Enable "Full (strict)" SSL mode
4. Generate an Origin Certificate

### Step 2: Install Origin Certificate

```bash
# Create certificate files
nano /etc/ssl/certs/cloudflare-origin.crt
# Paste your Cloudflare origin certificate

nano /etc/ssl/private/cloudflare-origin.key
# Paste your private key

# Set proper permissions
chmod 644 /etc/ssl/certs/cloudflare-origin.crt
chmod 600 /etc/ssl/private/cloudflare-origin.key
```

### Step 3: Update Nginx Configuration

```bash
# Edit Nginx configuration
nano /etc/nginx/sites-available/n8n

# Update SSL certificate paths:
ssl_certificate /etc/ssl/certs/cloudflare-origin.crt;
ssl_certificate_key /etc/ssl/private/cloudflare-origin.key;

# Reload Nginx
nginx -t && systemctl reload nginx
```

## Option 3: Self-Signed Certificate (Development)

The installer creates a self-signed certificate by default. To regenerate:

```bash
# Generate new self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/n8n-selfsigned.key \
    -out /etc/ssl/certs/n8n-selfsigned.crt \
    -subj "/C=US/ST=State/L=City/O=N8N-Server/OU=IT/CN=$(curl -s ifconfig.me)"

# Set permissions
chmod 600 /etc/ssl/private/n8n-selfsigned.key
chmod 644 /etc/ssl/certs/n8n-selfsigned.crt

# Reload Nginx
systemctl reload nginx
```

## SSL Configuration Verification

### Test SSL Configuration

```bash
# Test SSL configuration
openssl s_client -servername your-domain.com -connect your-domain.com:443 -showcerts

# Check SSL rating (external)
# Visit: https://www.ssllabs.com/ssltest/
```

### Common SSL Issues

**Issue**: Certificate not trusted  
**Solution**: Make sure you're using Let's Encrypt or a proper CA certificate

**Issue**: Mixed content warnings  
**Solution**: Ensure all resources are loaded over HTTPS

**Issue**: Certificate expired  
**Solution**: 
```bash
# Check certificate expiry
openssl x509 -in /etc/letsencrypt/live/your-domain.com/fullchain.pem -text -noout | grep "Not After"

# Renew certificate
certbot renew
```

## Security Headers

The installer configures these security headers in Nginx:

```nginx
# Security Headers
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
```

## Monitoring SSL Certificates

### Check Certificate Status

```bash
# Check certificate expiry date
echo | openssl s_client -servername your-domain.com -connect your-domain.com:443 2>/dev/null | openssl x509 -noout -dates

# List all certificates
certbot certificates
```

### Set Up Expiry Alerts

```bash
# Create monitoring script
cat > /opt/n8n/check-ssl.sh << 'EOF'
#!/bin/bash
DOMAIN="your-domain.com"
DAYS_WARN=30

EXPIRY=$(echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:443 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2)
EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s)
NOW_EPOCH=$(date +%s)
DAYS_LEFT=$(( ($EXPIRY_EPOCH - $NOW_EPOCH) / 86400 ))

if [ $DAYS_LEFT -lt $DAYS_WARN ]; then
    echo "WARNING: SSL certificate for $DOMAIN expires in $DAYS_LEFT days"
    # Add notification logic here (email, webhook, etc.)
fi
EOF

chmod +x /opt/n8n/check-ssl.sh

# Add to crontab (weekly check)
(crontab -l 2>/dev/null; echo "0 8 * * 1 /opt/n8n/check-ssl.sh") | crontab -
```

## Next Steps

- [Troubleshooting Guide](troubleshooting.md)
- [Security Best Practices](security.md)
- [Performance Optimization](performance.md)