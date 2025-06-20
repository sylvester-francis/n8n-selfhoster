# Security Guide

This guide covers security considerations and best practices for your N8N self-hosted installation.

## Built-in Security Features

The installer automatically configures several security measures:

### Firewall Protection (UFW)

```bash
# View current firewall status
sudo ufw status

# Default configuration allows only:
# - Port 22 (SSH)
# - Port 80 (HTTP - redirects to HTTPS)
# - Port 443 (HTTPS)
```

### Fail2Ban Intrusion Prevention

```bash
# Check Fail2Ban status
sudo fail2ban-client status

# View banned IPs
sudo fail2ban-client status nginx-n8n

# Unban an IP (if needed)
sudo fail2ban-client set nginx-n8n unbanip YOUR_IP
```

### Nginx Security Headers

The installer configures these security headers:

```nginx
# Security Headers
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
```

### Rate Limiting

```nginx
# Rate limiting configuration
limit_req_zone $binary_remote_addr zone=n8n:10m rate=10r/s;
limit_req zone=n8n burst=20 nodelay;
```

## Additional Security Recommendations

### 1. SSH Key Authentication

Replace password authentication with SSH keys:

```bash
# Generate SSH key pair (on your local machine)
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"

# Copy public key to server
ssh-copy-id root@YOUR_SERVER_IP

# Disable password authentication
sudo nano /etc/ssh/sshd_config
# Set: PasswordAuthentication no
# Set: PermitRootLogin prohibit-password

# Restart SSH
sudo systemctl restart sshd
```

### 2. Create Non-Root User

```bash
# Create a new user
adduser n8nadmin

# Add to sudo group
usermod -aG sudo n8nadmin

# Copy SSH keys
rsync --archive --chown=n8nadmin:n8nadmin ~/.ssh /home/n8nadmin

# Disable root login
sudo nano /etc/ssh/sshd_config
# Set: PermitRootLogin no
```

### 3. Update N8N Authentication

Replace basic auth with stronger authentication:

```bash
cd /opt/n8n
# Edit docker-compose.yml
nano docker-compose.yml

# Add stronger password or disable basic auth and use N8N's built-in auth
# Remove these lines:
# - N8N_BASIC_AUTH_ACTIVE=true
# - N8N_BASIC_AUTH_USER=admin
# - N8N_BASIC_AUTH_PASSWORD=...

# Restart N8N
docker-compose up -d
```

### 4. Database Security

Secure PostgreSQL database:

```bash
# Connect to database
docker-compose exec postgres psql -U n8n

# Change default passwords
ALTER USER n8n WITH PASSWORD 'your-new-strong-password';

# Update docker-compose.yml with new password
nano docker-compose.yml
# Update DB_POSTGRESDB_PASSWORD

# Restart services
docker-compose up -d
```

### 5. SSL/TLS Hardening

#### Upgrade to Let's Encrypt

```bash
# Install certbot (if not already installed)
sudo apt install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d your-domain.com

# Test auto-renewal
sudo certbot renew --dry-run
```

#### SSL Configuration Hardening

```bash
# Edit Nginx configuration
sudo nano /etc/nginx/sites-available/n8n

# Add stronger SSL configuration:
ssl_protocols TLSv1.3;
ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384;
ssl_prefer_server_ciphers off;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;

# Add OCSP stapling
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;

# Test and reload
sudo nginx -t && sudo systemctl reload nginx
```

## Network Security

### 1. VPN Access (Recommended)

For additional security, consider VPN-only access:

```bash
# Install WireGuard
sudo apt install wireguard

# Generate server keys
wg genkey | tee server-private.key | wg pubkey > server-public.key

# Configure WireGuard (example)
sudo nano /etc/wireguard/wg0.conf
```

### 2. IP Whitelisting

Restrict access to specific IPs:

```bash
# UFW: Allow only specific IPs
sudo ufw delete allow 443
sudo ufw allow from YOUR_IP_ADDRESS to any port 443

# Nginx: IP-based restrictions
sudo nano /etc/nginx/sites-available/n8n
# Add in server block:
# allow YOUR_IP_ADDRESS;
# deny all;
```

### 3. Cloudflare Protection

Use Cloudflare for additional protection:

1. Add your domain to Cloudflare
2. Enable "Under Attack" mode when needed
3. Configure Page Rules for rate limiting
4. Use Cloudflare Access for authentication

## Monitoring and Alerting

### 1. Log Monitoring

```bash
# Install log monitoring
sudo apt install logwatch

# Configure logwatch
sudo nano /etc/logwatch/conf/logwatch.conf
# Set your email address

# Set up daily reports
echo "0 6 * * * /usr/sbin/logwatch --output mail --mailto your-email@example.com" | sudo crontab -
```

### 2. Intrusion Detection

```bash
# Install AIDE (Advanced Intrusion Detection Environment)
sudo apt install aide

# Initialize database
sudo aideinit

# Set up daily checks
echo "0 3 * * * /usr/bin/aide --check" | sudo crontab -
```

### 3. Security Updates

```bash
# Install unattended upgrades
sudo apt install unattended-upgrades

# Configure automatic security updates
sudo dpkg-reconfigure -plow unattended-upgrades

# Edit configuration
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades
```

## N8N-Specific Security

### 1. Workflow Security

- Never store sensitive data directly in workflows
- Use environment variables or credentials store
- Regular audit of workflow permissions
- Implement workflow versioning

### 2. Credential Management

```bash
# N8N credentials are encrypted and stored in database
# Ensure database backups are encrypted
# Rotate credentials regularly
# Use minimal required permissions for each service
```

### 3. Webhook Security

```bash
# Use authentication for webhooks
# Implement request validation
# Consider IP whitelisting for webhook sources
# Use HTTPS-only for webhook URLs
```

## Backup Security

### 1. Encrypt Backups

```bash
# Create encrypted backup script
cat > /opt/n8n/secure-backup.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/opt/n8n/backups"
ENCRYPT_PASSWORD="your-encryption-password"

# Create regular backup
/opt/n8n/backup.sh

# Encrypt backup files
for file in $BACKUP_DIR/*$DATE*; do
    gpg --cipher-algo AES256 --compress-algo 1 --s2k-mode 3 \
        --s2k-digest-algo SHA256 --s2k-count 65536 --force-mdc \
        --symmetric --output "$file.gpg" --passphrase "$ENCRYPT_PASSWORD" "$file"
    rm "$file"  # Remove unencrypted backup
done
EOF

chmod +x /opt/n8n/secure-backup.sh
```

### 2. Offsite Backup Storage

```bash
# Install rclone for cloud storage
curl https://rclone.org/install.sh | sudo bash

# Configure cloud storage (example: AWS S3)
rclone config

# Add to backup script
rclone copy /opt/n8n/backups/ s3:your-bucket/n8n-backups/
```

## Incident Response

### 1. Security Incident Checklist

1. **Immediate Response**
   - Isolate affected systems
   - Document everything
   - Preserve evidence

2. **Investigation**
   - Check logs for suspicious activity
   - Identify attack vectors
   - Assess damage

3. **Recovery**
   - Remove threats
   - Restore from clean backups
   - Update security measures

### 2. Emergency Contacts

Prepare emergency response information:

```bash
# Create incident response guide
cat > /opt/n8n/incident-response.md << 'EOF'
# Emergency Response Guide

## Immediate Actions
1. Stop all services: `cd /opt/n8n && docker-compose down`
2. Backup current state: `/opt/n8n/backup.sh`
3. Check logs: `tail -100 /var/log/nginx/access.log`

## Key Log Locations
- Nginx: /var/log/nginx/
- N8N: docker-compose logs n8n
- System: journalctl -f

## Emergency Contacts
- System Admin: [Your Contact]
- Security Team: [Security Contact]
- Hosting Provider: [Provider Support]
EOF
```

## Security Auditing

### 1. Regular Security Checks

```bash
# Create security audit script
cat > /opt/n8n/security-audit.sh << 'EOF'
#!/bin/bash
echo "=== Security Audit Report $(date) ==="

echo "1. System Updates:"
apt list --upgradable

echo "2. Firewall Status:"
ufw status

echo "3. Fail2Ban Status:"
fail2ban-client status

echo "4. SSL Certificate Status:"
certbot certificates

echo "5. Open Ports:"
ss -tuln

echo "6. Recent SSH Logins:"
last -n 10

echo "7. N8N Service Status:"
cd /opt/n8n && docker-compose ps
EOF

chmod +x /opt/n8n/security-audit.sh

# Run weekly
(crontab -l 2>/dev/null; echo "0 9 * * 1 /opt/n8n/security-audit.sh | mail -s 'N8N Security Audit' your-email@example.com") | crontab -
```

### 2. Penetration Testing

Consider regular penetration testing:

- Use tools like Nmap, Nikto, OWASP ZAP
- Test from external networks
- Document and fix vulnerabilities
- Retest after fixes

## Compliance Considerations

### GDPR Compliance

- Implement data retention policies
- Ensure secure data processing
- Document data flows
- Implement right to erasure

### SOC 2 Considerations

- Access controls and monitoring
- Logical and physical access restrictions
- System operations monitoring
- Change management procedures

## Resources and Tools

### Security Testing Tools

```bash
# Install security testing tools
sudo apt install nmap nikto sqlmap

# Basic security scan
nmap -sS -O YOUR_SERVER_IP
nikto -h https://YOUR_DOMAIN
```

### Security Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CIS Controls](https://www.cisecurity.org/controls/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [Ubuntu Security Guide](https://ubuntu.com/security)

Remember: Security is an ongoing process, not a one-time setup. Regularly review and update your security measures based on new threats and best practices.