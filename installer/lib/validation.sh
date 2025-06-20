#!/bin/bash

###################################################################################
#                                                                                 #
#                        N8N Self-Hosted Installer                               #
#                        Validation and Testing Module                            #
#                                                                                 #
###################################################################################

# Enhanced comprehensive tests with recovery
run_tests() {
    show_progress 14 15 "Running comprehensive tests"
    
    local test_failed=false
    local tests_passed=0
    local total_tests=10
    
    cd "$N8N_DIR" || exit
    
    # Test 1: Check if containers are running
    log "INFO" "Test 1: Checking container status..."
    if docker-compose ps | grep -q "Up.*Up"; then
        log "SUCCESS" "✓ Docker containers are running"
        ((tests_passed++))
    else
        log "ERROR" "✗ Some Docker containers are not running"
        docker-compose ps
        
        # Try to recover by restarting containers
        log "INFO" "Attempting to restart containers..."
        docker-compose restart
        sleep 10
        
        if docker-compose ps | grep -q "Up.*Up"; then
            log "SUCCESS" "✓ Containers recovered after restart"
            ((tests_passed++))
        else
            test_failed=true
        fi
    fi
    
    # Test 2: Check if N8N is responding locally with retry
    log "INFO" "Test 2: Checking N8N local response..."
    local n8n_ready=false
    for i in {1..5}; do
        if curl -s -m 10 http://localhost:5678 >/dev/null 2>&1; then
            log "SUCCESS" "✓ N8N is responding on localhost:5678"
            n8n_ready=true
            ((tests_passed++))
            break
        fi
        
        if [ $i -lt 5 ]; then
            log "INFO" "N8N not ready, waiting... (attempt $i/5)"
            sleep 10
        fi
    done
    
    if [ "$n8n_ready" = "false" ]; then
        log "ERROR" "✗ N8N is not responding on localhost:5678"
        log "INFO" "Checking N8N logs..."
        docker-compose logs --tail=10 n8n || true
        test_failed=true
    fi
    
    # Test 3: Check if Nginx is running
    log "INFO" "Test 3: Checking Nginx status..."
    if systemctl is-active --quiet nginx; then
        log "SUCCESS" "✓ Nginx is running"
    else
        log "ERROR" "✗ Nginx is not running"
        test_failed=true
    fi
    
    # Test 4: Check if HTTPS is working
    log "INFO" "Test 4: Checking HTTPS response..."
    if curl -s -k -o /dev/null -w "%{http_code}" https://localhost | grep -q "200\|401"; then
        log "SUCCESS" "✓ HTTPS is working"
    else
        log "ERROR" "✗ HTTPS is not working"
        test_failed=true
    fi
    
    # Test 5: Check if HTTP redirects to HTTPS
    log "INFO" "Test 5: Checking HTTP to HTTPS redirect..."
    if curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "301"; then
        log "SUCCESS" "✓ HTTP redirects to HTTPS"
    else
        log "WARNING" "⚠ HTTP to HTTPS redirect may not be working"
    fi
    
    # Test 6: Check firewall status
    log "INFO" "Test 6: Checking firewall status..."
    if ufw status | grep -q "Status: active"; then
        log "SUCCESS" "✓ Firewall is active"
    else
        log "WARNING" "⚠ Firewall is not active"
    fi
    
    # Test 7: Check if ports are accessible
    log "INFO" "Test 7: Checking port accessibility..."
    if check_port 443; then
        log "SUCCESS" "✓ Port 443 (HTTPS) is open"
    else
        log "ERROR" "✗ Port 443 (HTTPS) is not accessible"
        test_failed=true
    fi
    
    if check_port 80; then
        log "SUCCESS" "✓ Port 80 (HTTP) is open"
    else
        log "WARNING" "⚠ Port 80 (HTTP) is not accessible"
    fi
    
    # Test 8: Check backup script
    log "INFO" "Test 8: Checking backup script..."
    if [ -x "$N8N_DIR/backup.sh" ]; then
        log "SUCCESS" "✓ Backup script is executable"
    else
        log "ERROR" "✗ Backup script is not executable"
        test_failed=true
    fi
    
    # Test 9: Check cron job
    log "INFO" "Test 9: Checking backup cron job..."
    if crontab -l | grep -q "backup.sh"; then
        log "SUCCESS" "✓ Backup cron job is configured"
    else
        log "ERROR" "✗ Backup cron job is not configured"
        test_failed=true
    fi
    
    # Test 10: Check Fail2Ban
    log "INFO" "Test 10: Checking Fail2Ban status..."
    if systemctl is-active --quiet fail2ban; then
        log "SUCCESS" "✓ Fail2Ban is running"
    else
        log "WARNING" "⚠ Fail2Ban is not running"
    fi
    
    # Test summary
    log "INFO" "Test Results: $tests_passed/$total_tests tests passed"
    
    if [ "$test_failed" = true ]; then
        local failed_tests=$((total_tests - tests_passed))
        log "WARNING" "Some tests failed ($failed_tests failures). Installation completed with issues."
        
        # Offer recovery suggestions
        if [ "$tests_passed" -ge 7 ]; then
            log "INFO" "Most components are working. Issues may resolve automatically."
            log "INFO" "You can access N8N at: https://$DOMAIN_NAME"
            log "INFO" "Admin credentials are in: $N8N_DIR/credentials.txt"
        fi
        
        return 1
    else
        log "SUCCESS" "All tests passed! Installation completed successfully."
        return 0
    fi
}

# Show final summary and instructions
show_summary() {
    show_progress 15 15 "Installation completed"
    
    # Only clear screen in truly interactive mode
    if [ -t 0 ] && [ -t 1 ] && [ -t 2 ] && [ -z "${SSH_CONNECTION:-}" ]; then
        clear 2>/dev/null || true
    fi
    print_color "$GREEN" "
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║                     ${SUCCESS} N8N INSTALLATION COMPLETED! ${SUCCESS}                      ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
"

    print_color "$WHITE" "\n📋 INSTALLATION SUMMARY"
    print_color "$WHITE" "=========================="
    print_color "$GREEN" "✓ N8N with PostgreSQL database"
    print_color "$GREEN" "✓ Nginx reverse proxy with HTTPS"
    print_color "$GREEN" "✓ Self-signed SSL certificate"
    print_color "$GREEN" "✓ Firewall protection (UFW)"
    print_color "$GREEN" "✓ Automated daily backups"
    print_color "$GREEN" "✓ Security hardening (Fail2Ban)"
    print_color "$GREEN" "✓ Log rotation configured"
    
    print_color "$WHITE" "\n🔗 ACCESS INFORMATION"
    print_color "$WHITE" "======================"
    print_color "$CYAN" "URL:      https://$DOMAIN_NAME"
    print_color "$CYAN" "Username: admin"
    print_color "$CYAN" "Password: $ADMIN_PASSWORD"
    
    print_color "$WHITE" "\n${LOCK} IMPORTANT SECURITY NOTES"
    print_color "$WHITE" "========================="
    if [ "$USE_DOMAIN" = false ]; then
        print_color "$YELLOW" "⚠️  You're using a self-signed certificate"
        print_color "$WHITE" "   Your browser will show a security warning"
        print_color "$WHITE" "   Click 'Advanced' → 'Proceed to $DOMAIN_NAME (unsafe)'"
    else
        print_color "$YELLOW" "🔧 Next: Set up Let's Encrypt for trusted certificates"
        print_color "$WHITE" "   Run: sudo certbot --nginx -d $DOMAIN_NAME"
    fi
    
    print_color "$WHITE" "\n📁 IMPORTANT FILES"
    print_color "$WHITE" "=================="
    print_color "$CYAN" "Credentials:     $N8N_DIR/credentials.txt"
    print_color "$CYAN" "Configuration:   $N8N_DIR/docker-compose.yml"
    print_color "$CYAN" "Backup Script:   $N8N_DIR/backup.sh"
    print_color "$CYAN" "Nginx Config:    /etc/nginx/sites-available/n8n"
    print_color "$CYAN" "Install Log:     $LOG_FILE"
    
    print_color "$WHITE" "\n🔧 USEFUL COMMANDS"
    print_color "$WHITE" "=================="
    print_color "$CYAN" "Check status:    cd $N8N_DIR && docker-compose ps"
    print_color "$CYAN" "View logs:       cd $N8N_DIR && docker-compose logs n8n"
    print_color "$CYAN" "Restart N8N:     cd $N8N_DIR && docker-compose restart n8n"
    print_color "$CYAN" "Update N8N:      cd $N8N_DIR && docker-compose pull && docker-compose up -d"
    print_color "$CYAN" "Manual backup:   $N8N_DIR/backup.sh"
    print_color "$CYAN" "Check firewall:  sudo ufw status"
    print_color "$CYAN" "Check fail2ban:  sudo fail2ban-client status"
    
    print_color "$WHITE" "\n📚 NEXT STEPS"
    print_color "$WHITE" "=============="
    print_color "$WHITE" "1. ${SUCCESS} Access your N8N instance at https://$DOMAIN_NAME"
    print_color "$WHITE" "2. ${INFO} Complete the initial setup wizard"
    print_color "$WHITE" "3. ${GEAR} Add your service credentials (GitHub, Gmail, etc.)"
    print_color "$WHITE" "4. ${ROCKET} Create your first automation workflow"
    
    if [ "$USE_DOMAIN" = true ]; then
        print_color "$WHITE" "5. ${LOCK} Set up Let's Encrypt: sudo certbot --nginx -d $DOMAIN_NAME"
    fi
    
    print_color "$WHITE" "\n🆘 GETTING HELP"
    print_color "$WHITE" "==============="
    print_color "$WHITE" "Documentation: https://docs.n8n.io"
    print_color "$WHITE" "Community:     https://community.n8n.io"
    print_color "$WHITE" "GitHub:        https://github.com/n8n-io/n8n"
    
    print_color "$YELLOW" "\n${WARNING} Remember to:"
    print_color "$WHITE" "• Save your credentials securely"
    print_color "$WHITE" "• Remove $N8N_DIR/credentials.txt after copying"
    print_color "$WHITE" "• Set up monitoring for production use"
    print_color "$WHITE" "• Regularly update your system and N8N"
    
    print_color "$GREEN" "\n${ROCKET} Happy automating with N8N! ${ROCKET}"
    
    # Save summary to file
    cat > "$N8N_DIR/installation-summary.txt" << EOF
N8N Installation Summary
=======================
Date: $(date)
Server: $DOMAIN_NAME
Version: N8N Self-Hosted Installer v$SCRIPT_VERSION

Access Information:
- URL: https://$DOMAIN_NAME
- Username: admin
- Password: $ADMIN_PASSWORD

Important Files:
- Configuration: $N8N_DIR/docker-compose.yml
- Backup Script: $N8N_DIR/backup.sh
- Nginx Config: /etc/nginx/sites-available/n8n
- Install Log: $LOG_FILE

Services Installed:
- N8N (latest)
- PostgreSQL 13
- Nginx (reverse proxy)
- Docker & Docker Compose
- UFW Firewall
- Fail2Ban
- Automated Backups

Next Steps:
1. Access N8N at https://$DOMAIN_NAME
2. Complete setup wizard
3. Add service credentials
4. Create workflows
$([ "$USE_DOMAIN" = true ] && echo "5. Set up Let's Encrypt: sudo certbot --nginx -d $DOMAIN_NAME")

Generated by N8N Self-Hosted Installer v$SCRIPT_VERSION
EOF
    
    log "SUCCESS" "Installation summary saved to $N8N_DIR/installation-summary.txt"
}