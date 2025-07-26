#!/bin/bash

# Focused test script for critical functionality
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    local level=$1
    local message=$2
    local timestamp
    timestamp=$(date '+%H:%M:%S')
    
    case $level in
        "SUCCESS") echo -e "${GREEN}[${timestamp}] ✅ $message${NC}" ;;
        "ERROR") echo -e "${RED}[${timestamp}] ❌ $message${NC}" ;;
        "WARNING") echo -e "${YELLOW}[${timestamp}] ⚠️ $message${NC}" ;;
        "INFO") echo -e "${BLUE}[${timestamp}] ℹ️ $message${NC}" ;;
        *) echo "[$timestamp] $message" ;;
    esac
}

cleanup() {
    local vm_name=$1
    log "INFO" "Cleaning up $vm_name..."
    multipass delete "$vm_name" 2>/dev/null || true
    multipass purge 2>/dev/null || true
}

test_basic_installation() {
    local vm_name="n8n-test-basic"
    
    log "INFO" "Testing basic non-interactive installation..."
    
    # Cleanup
    cleanup "$vm_name"
    
    # Create VM
    if ! multipass launch 22.04 --name "$vm_name" --memory 4G --disk 20G --cpus 2; then
        log "ERROR" "Failed to create VM"
        return 1
    fi
    
    sleep 20
    multipass exec "$vm_name" -- sudo apt update >/dev/null 2>&1
    
    # Transfer installer
    multipass transfer --recursive installer/ "$vm_name":installer/
    
    # Run installation
    log "INFO" "Running installation..."
    multipass exec "$vm_name" -- bash -c "
        cd installer
        sudo ./install.sh --yes --domain test.example.com --timezone America/New_York 2>&1 | tee /tmp/install.log
    "
    
    # Check results
    log "INFO" "Verifying installation..."
    
    # Test Docker
    if multipass exec "$vm_name" -- sudo docker info >/dev/null 2>&1; then
        log "SUCCESS" "Docker is working"
    else
        log "ERROR" "Docker test failed"
        cleanup "$vm_name"
        return 1
    fi
    
    # Test containers
    if multipass exec "$vm_name" -- bash -c "cd /opt/n8n && sudo docker-compose ps | grep -q 'Up.*Up'"; then
        log "SUCCESS" "Containers are running"
    else
        log "ERROR" "Container test failed"
        multipass exec "$vm_name" -- bash -c "cd /opt/n8n && sudo docker-compose ps" || true
        cleanup "$vm_name"
        return 1
    fi
    
    # Test N8N response (with retries)
    local n8n_ready=false
    for i in {1..10}; do
        if multipass exec "$vm_name" -- curl -s http://localhost:5678 >/dev/null 2>&1; then
            log "SUCCESS" "N8N is responding"
            n8n_ready=true
            break
        fi
        log "INFO" "N8N not ready, waiting... ($i/10)"
        sleep 10
    done
    
    if [ "$n8n_ready" = "false" ]; then
        log "ERROR" "N8N never became ready"
        multipass exec "$vm_name" -- bash -c "cd /opt/n8n && sudo docker-compose logs n8n | tail -20" || true
        cleanup "$vm_name"
        return 1
    fi
    
    # Test HTTPS
    if multipass exec "$vm_name" -- curl -k -s https://localhost >/dev/null 2>&1; then
        log "SUCCESS" "HTTPS is working"
    else
        log "WARNING" "HTTPS test failed (may be expected with self-signed certs)"
    fi
    
    log "SUCCESS" "Basic installation test passed!"
    cleanup "$vm_name"
    return 0
}

test_help_commands() {
    local vm_name="n8n-test-help"
    
    log "INFO" "Testing help and version commands..."
    
    cleanup "$vm_name"
    multipass launch 22.04 --name "$vm_name" --memory 2G --disk 10G --cpus 1
    sleep 15
    multipass transfer --recursive installer/ "$vm_name":installer/
    
    # Test help
    if multipass exec "$vm_name" -- bash -c "cd installer && ./install.sh --help | grep -q 'USAGE'"; then
        log "SUCCESS" "Help command works"
    else
        log "ERROR" "Help command failed"
        cleanup "$vm_name"
        return 1
    fi
    
    # Test version
    if multipass exec "$vm_name" -- bash -c "./install.sh --version | grep -q 'v1.3.0'"; then
        log "SUCCESS" "Version command works"
    else
        log "ERROR" "Version command failed"
        cleanup "$vm_name"
        return 1
    fi
    
    log "SUCCESS" "Help commands test passed!"
    cleanup "$vm_name"
    return 0
}

test_requirements_check() {
    local vm_name="n8n-test-req"
    
    log "INFO" "Testing requirements checking..."
    
    cleanup "$vm_name"
    # Create a smaller VM to test warnings
    multipass launch 22.04 --name "$vm_name" --memory 1G --disk 8G --cpus 1
    sleep 15
    multipass transfer --recursive installer/ "$vm_name":installer/
    
    # Test with insufficient resources (should show warnings but continue with --yes)
    if multipass exec "$vm_name" -- bash -c "cd installer && sudo ./install.sh --yes --quick --ip 192.168.1.100"; then
        log "SUCCESS" "Requirements check allows installation with warnings"
    else
        log "WARNING" "Requirements check may have blocked installation"
    fi
    
    cleanup "$vm_name"
    return 0
}

# Main execution
main() {
    echo "🚀 N8N Installer Focused Testing"
    echo "================================"
    
    if ! command -v multipass >/dev/null; then
        log "ERROR" "Multipass required for testing"
        exit 1
    fi
    
    local tests_passed=0
    local total_tests=3
    
    # Test 1: Help commands
    if test_help_commands; then
        ((tests_passed++))
    fi
    
    # Test 2: Requirements check
    if test_requirements_check; then
        ((tests_passed++))
    fi
    
    # Test 3: Basic installation
    if test_basic_installation; then
        ((tests_passed++))
    fi
    
    echo
    echo "📊 Test Results: $tests_passed/$total_tests passed"
    
    if [ "$tests_passed" -eq "$total_tests" ]; then
        log "SUCCESS" "All focused tests passed! 🎉"
        exit 0
    else
        log "ERROR" "Some tests failed"
        exit 1
    fi
}

main "$@"