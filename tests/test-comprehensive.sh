#!/bin/bash

###################################################################################
#                     Comprehensive N8N Installer Test Suite                     #
###################################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test results
PASSED_TESTS=0
FAILED_TESTS=0
TOTAL_TESTS=0

# Helper functions
log() {
    local level=$1
    local message=$2
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        "SUCCESS")
            echo -e "${GREEN}[${timestamp}] ✅ $message${NC}"
            ;;
        "ERROR")
            echo -e "${RED}[${timestamp}] ❌ $message${NC}"
            ;;
        "WARNING")
            echo -e "${YELLOW}[${timestamp}] ⚠️ $message${NC}"
            ;;
        "INFO")
            echo -e "${BLUE}[${timestamp}] ℹ️ $message${NC}"
            ;;
        *)
            echo "[$timestamp] $message"
            ;;
    esac
}

cleanup_vm() {
    local vm_name=$1
    log "INFO" "Cleaning up VM: $vm_name"
    multipass delete "$vm_name" 2>/dev/null || true
    multipass purge 2>/dev/null || true
}

create_test_vm() {
    local vm_name=$1
    local ubuntu_version=${2:-22.04}
    
    log "INFO" "Creating Ubuntu $ubuntu_version VM: $vm_name"
    
    # Cleanup any existing VM with same name
    cleanup_vm "$vm_name"
    
    # Create fresh VM
    if multipass launch "$ubuntu_version" --name "$vm_name" --memory 4G --disk 20G --cpus 2; then
        log "SUCCESS" "VM $vm_name created successfully"
        
        # Wait for VM to be ready
        log "INFO" "Waiting for VM to initialize..."
        sleep 30
        
        # Basic setup
        multipass exec "$vm_name" -- bash -c "
            sudo apt update > /dev/null 2>&1 &&
            sudo apt install -y curl git lsb-release > /dev/null 2>&1
        "
        
        return 0
    else
        log "ERROR" "Failed to create VM $vm_name"
        return 1
    fi
}

transfer_installer() {
    local vm_name=$1
    
    log "INFO" "Transferring installer files to $vm_name"
    
    # Copy installer directory
    if multipass transfer --recursive installer/ "$vm_name":installer/; then
        log "SUCCESS" "Installer files transferred successfully"
        return 0
    else
        log "ERROR" "Failed to transfer installer files"
        return 1
    fi
}

run_test() {
    local test_name=$1
    local vm_name=$2
    local test_command=$3
    local expected_result=${4:-0}
    
    ((TOTAL_TESTS++))
    
    log "INFO" "Running test: $test_name"
    
    local start_time
    start_time=$(date +%s)
    
    if multipass exec "$vm_name" -- bash -c "$test_command"; then
        local exit_code=0
    else
        local exit_code=$?
    fi
    
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [ $exit_code -eq $expected_result ]; then
        log "SUCCESS" "Test '$test_name' PASSED (${duration}s)"
        ((PASSED_TESTS++))
        return 0
    else
        log "ERROR" "Test '$test_name' FAILED (${duration}s) - Expected: $expected_result, Got: $exit_code"
        ((FAILED_TESTS++))
        return 1
    fi
}

test_help_and_version() {
    local vm_name=$1
    
    log "INFO" "Testing help and version commands..."
    
    run_test "Help Command" "$vm_name" "cd installer && ./install.sh --help | grep -q 'USAGE'" 0
    run_test "Version Command" "$vm_name" "cd installer && ./install.sh --version | grep -q 'v1.2.0'" 0
}

test_non_interactive_installation() {
    local vm_name=$1
    
    log "INFO" "Testing non-interactive installation..."
    
    # Test with --yes flag
    run_test "Non-Interactive Installation" "$vm_name" "
        cd installer && 
        sudo ./install.sh --yes --domain test.example.com --timezone America/New_York --skip-backups
    " 0
    
    # Verify installation
    run_test "Docker Running" "$vm_name" "sudo docker info > /dev/null 2>&1" 0
    run_test "N8N Container Running" "$vm_name" "sudo docker ps | grep -q n8n" 0
    run_test "PostgreSQL Container Running" "$vm_name" "sudo docker ps | grep -q postgres" 0
    run_test "Nginx Running" "$vm_name" "sudo systemctl is-active nginx" 0
    run_test "N8N Web Interface" "$vm_name" "curl -k -s https://localhost | grep -q 'n8n'" 0
}

test_interactive_installation() {
    local vm_name=$1
    
    log "INFO" "Testing interactive installation with force-interactive flag..."
    
    # Create expect script for interactive testing
    multipass exec "$vm_name" -- bash -c "
        cat > /tmp/interactive_test.exp << 'EOF'
#!/usr/bin/expect -f
set timeout 1200
spawn sudo ./install.sh --force-interactive
expect \"Do you want to continue?\"
send \"y\r\"
expect \"Server IP address\"
send \"\r\"
expect \"Domain name\"
send \"\r\"
expect \"Timezone\"
send \"\r\"
expect \"Continue with this configuration?\"
send \"y\r\"
expect eof
EOF
        chmod +x /tmp/interactive_test.exp
    "
    
    # Install expect if not available
    multipass exec "$vm_name" -- sudo apt install -y expect > /dev/null 2>&1
    
    run_test "Interactive Installation" "$vm_name" "cd installer && /tmp/interactive_test.exp" 0
}

test_quick_mode() {
    local vm_name=$1
    
    log "INFO" "Testing quick mode installation..."
    
    run_test "Quick Mode Installation" "$vm_name" "
        cd installer && 
        sudo ./install.sh --quick --yes --ip 192.168.1.100
    " 0
}

test_dry_run() {
    local vm_name=$1
    
    log "INFO" "Testing dry-run mode..."
    
    run_test "Dry Run Mode" "$vm_name" "
        cd installer && 
        sudo ./install.sh --dry-run --domain test.com
    " 0
}

test_docker_installation() {
    local vm_name=$1
    
    log "INFO" "Testing Docker installation specifically..."
    
    # Test Docker functionality
    run_test "Docker Version" "$vm_name" "sudo docker --version" 0
    run_test "Docker Info" "$vm_name" "sudo docker info" 0
    run_test "Docker Compose Version" "$vm_name" "sudo docker-compose --version || sudo docker compose version" 0
}

test_security_features() {
    local vm_name=$1
    
    log "INFO" "Testing security features..."
    
    run_test "UFW Firewall Active" "$vm_name" "sudo ufw status | grep -q 'Status: active'" 0
    run_test "Fail2Ban Running" "$vm_name" "sudo systemctl is-active fail2ban" 0
    run_test "SSL Certificate Exists" "$vm_name" "sudo test -f /etc/ssl/certs/n8n-selfsigned.crt" 0
}

test_backup_system() {
    local vm_name=$1
    
    log "INFO" "Testing backup system..."
    
    run_test "Backup Script Exists" "$vm_name" "sudo test -f /opt/n8n/backup.sh" 0
    run_test "Backup Directory Exists" "$vm_name" "sudo test -d /opt/n8n/backups" 0
}

run_comprehensive_tests() {
    local vm_name="n8n-test"
    
    log "INFO" "Starting comprehensive N8N installer tests..."
    log "INFO" "VM Name: $vm_name"
    
    # Create test VM
    if ! create_test_vm "$vm_name"; then
        log "ERROR" "Failed to create test VM"
        return 1
    fi
    
    # Transfer installer
    if ! transfer_installer "$vm_name"; then
        log "ERROR" "Failed to transfer installer"
        cleanup_vm "$vm_name"
        return 1
    fi
    
    # Run tests
    test_help_and_version "$vm_name"
    test_dry_run "$vm_name"
    test_non_interactive_installation "$vm_name"
    test_docker_installation "$vm_name"
    test_security_features "$vm_name"
    test_backup_system "$vm_name"
    
    # Cleanup for next test
    cleanup_vm "$vm_name"
    
    # Test interactive mode on fresh VM
    log "INFO" "Creating fresh VM for interactive testing..."
    if create_test_vm "$vm_name-interactive"; then
        transfer_installer "$vm_name-interactive"
        test_interactive_installation "$vm_name-interactive"
        cleanup_vm "$vm_name-interactive"
    fi
    
    # Test quick mode on fresh VM
    log "INFO" "Creating fresh VM for quick mode testing..."
    if create_test_vm "$vm_name-quick"; then
        transfer_installer "$vm_name-quick"
        test_quick_mode "$vm_name-quick"
        cleanup_vm "$vm_name-quick"
    fi
}

# Test different Ubuntu versions
test_multiple_ubuntu_versions() {
    log "INFO" "Testing on multiple Ubuntu versions..."
    
    for version in "20.04" "22.04"; do
        log "INFO" "Testing on Ubuntu $version"
        local vm_name="n8n-test-ubuntu-${version//./-}"
        
        if create_test_vm "$vm_name" "$version"; then
            transfer_installer "$vm_name"
            
            # Quick test on each version
            run_test "Ubuntu $version Installation" "$vm_name" "
                cd installer && 
                sudo ./install.sh --yes --quick --ip 192.168.1.100
            " 0
            
            cleanup_vm "$vm_name"
        fi
    done
}

# Main execution
main() {
    echo "🚀 N8N Installer Comprehensive Test Suite"
    echo "=========================================="
    echo
    
    # Check prerequisites
    if ! command -v multipass > /dev/null; then
        log "ERROR" "Multipass is required for testing. Please install it first."
        exit 1
    fi
    
    # Run tests
    run_comprehensive_tests
    
    # Test multiple Ubuntu versions
    test_multiple_ubuntu_versions
    
    # Results summary
    echo
    echo "📊 Test Results Summary"
    echo "======================="
    echo "Total Tests: $TOTAL_TESTS"
    echo "Passed: $PASSED_TESTS"
    echo "Failed: $FAILED_TESTS"
    echo
    
    if [ $FAILED_TESTS -eq 0 ]; then
        log "SUCCESS" "All tests passed! 🎉"
        exit 0
    else
        log "ERROR" "$FAILED_TESTS tests failed"
        exit 1
    fi
}

# Run main function
main "$@"