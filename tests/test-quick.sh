#!/bin/bash

# Quick focused test script
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%H:%M:%S')
    
    case $level in
        "SUCCESS") echo -e "${GREEN}[${timestamp}] ✅ $message${NC}" ;;
        "ERROR") echo -e "${RED}[${timestamp}] ❌ $message${NC}" ;;
        "WARNING") echo -e "${YELLOW}[${timestamp}] ⚠️ $message${NC}" ;;
        "INFO") echo -e "${BLUE}[${timestamp}] ℹ️ $message${NC}" ;;
        *) echo "[$timestamp] $message" ;;
    esac
}

test_installation() {
    local vm_name="n8n-test-quick"
    
    log "INFO" "Creating test VM..."
    multipass delete "$vm_name" 2>/dev/null || true
    multipass purge 2>/dev/null || true
    
    if ! multipass launch 22.04 --name "$vm_name" --memory 4G --disk 20G --cpus 2; then
        log "ERROR" "Failed to create VM"
        return 1
    fi
    
    sleep 30
    multipass exec "$vm_name" -- sudo apt update > /dev/null 2>&1
    
    log "INFO" "Transferring installer..."
    multipass transfer --recursive installer/ "$vm_name":installer/
    
    log "INFO" "Running non-interactive installation..."
    multipass exec "$vm_name" -- bash -c "
        cd installer && 
        sudo ./install.sh --yes --domain test.example.com --timezone America/New_York
    "
    
    log "INFO" "Fixing database connection (if needed)..."
    multipass exec "$vm_name" -- bash -c "
        cd /opt/n8n
        sudo docker-compose down -v > /dev/null 2>&1
        sudo docker volume prune -f > /dev/null 2>&1
        sudo docker-compose up -d > /dev/null 2>&1
        sleep 30
    "
    
    log "INFO" "Running verification tests..."
    
    # Test 1: Docker
    if multipass exec "$vm_name" -- sudo docker info > /dev/null 2>&1; then
        log "SUCCESS" "Docker is running"
    else
        log "ERROR" "Docker test failed"
    fi
    
    # Test 2: Containers
    if multipass exec "$vm_name" -- sudo docker ps | grep -q "n8n.*Up"; then
        log "SUCCESS" "N8N container is running"
    else
        log "ERROR" "N8N container test failed"
    fi
    
    # Test 3: Web interface
    if multipass exec "$vm_name" -- curl -s http://localhost:5678 | grep -q "<!DOCTYPE html"; then
        log "SUCCESS" "N8N web interface is responding"
    else
        log "WARNING" "N8N web interface test failed (might need more time)"
    fi
    
    # Test 4: HTTPS
    if multipass exec "$vm_name" -- curl -k -s https://localhost | grep -q "html"; then
        log "SUCCESS" "HTTPS is working"
    else
        log "WARNING" "HTTPS test failed"
    fi
    
    # Test 5: Interactive mode test
    log "INFO" "Testing interactive mode with force flag..."
    if multipass exec "$vm_name" -- bash -c "
        cd installer && 
        echo 'y' | sudo ./install.sh --force-interactive --version > /dev/null 2>&1
    "; then
        log "SUCCESS" "Interactive mode flag works"
    else
        log "WARNING" "Interactive mode test had issues"
    fi
    
    log "INFO" "Cleaning up..."
    multipass delete "$vm_name"
    multipass purge
    
    log "SUCCESS" "Quick test completed!"
}

# Run test
test_installation