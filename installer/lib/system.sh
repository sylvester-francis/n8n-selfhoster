#!/bin/bash

###################################################################################
#                                                                                 #
#                        N8N Self-Hosted Installer                               #
#                        System Requirements Module                               #
#                                                                                 #
###################################################################################

# Enhanced system requirements check
check_requirements() {
    show_progress 1 15 "Checking system requirements"
    
    local errors=0
    local warnings=0
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        log "ERROR" "This script must be run as root (use sudo)"
        exit 1
    fi
    
    # Check available memory
    local memory_gb=$(awk '/MemTotal/ {print int($2/1024/1024)}' /proc/meminfo)
    if [ "$memory_gb" -lt 2 ]; then
        log "ERROR" "Insufficient memory: ${memory_gb}GB detected, minimum 2GB required"
        ((errors++))
    elif [ "$memory_gb" -lt 4 ]; then
        log "WARNING" "Low memory: ${memory_gb}GB detected, 4GB recommended for production"
        ((warnings++))
    else
        log "SUCCESS" "Memory check passed: ${memory_gb}GB available"
    fi
    
    # Check available disk space
    local disk_gb=$(df / | awk 'NR==2 {print int($4/1024/1024)}')
    if [ "$disk_gb" -lt 20 ]; then
        log "ERROR" "Insufficient disk space: ${disk_gb}GB available, minimum 20GB required"
        ((errors++))
    elif [ "$disk_gb" -lt 50 ]; then
        log "WARNING" "Low disk space: ${disk_gb}GB available, 50GB recommended for production"
        ((warnings++))
    else
        log "SUCCESS" "Disk space check passed: ${disk_gb}GB available"
    fi
    
    # Check CPU cores
    local cpu_cores=$(nproc)
    if [ "$cpu_cores" -lt 1 ]; then
        log "ERROR" "Insufficient CPU cores: ${cpu_cores} detected"
        ((errors++))
    elif [ "$cpu_cores" -eq 1 ]; then
        log "WARNING" "Single CPU core detected, 2+ cores recommended for production"
        ((warnings++))
    else
        log "SUCCESS" "CPU check passed: ${cpu_cores} cores available"
    fi
    
    # Check internet connectivity
    if ! curl -s --connect-timeout 10 https://google.com >/dev/null 2>&1; then
        log "ERROR" "No internet connectivity detected"
        ((errors++))
    else
        log "SUCCESS" "Internet connectivity verified"
    fi
    
    # Check Ubuntu version with fallback methods
    if ! grep -q "Ubuntu" /etc/os-release; then
        log "ERROR" "This script is designed for Ubuntu. Detected: $(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)"
        exit 1
    fi
    
    local ubuntu_version
    # Try multiple methods to get Ubuntu version
    if command -v lsb_release > /dev/null 2>&1; then
        ubuntu_version=$(lsb_release -rs)
    elif grep -q "VERSION_ID" /etc/os-release; then
        ubuntu_version=$(grep VERSION_ID /etc/os-release | cut -d'"' -f2)
    elif [ -f /etc/lsb-release ]; then
        ubuntu_version=$(grep DISTRIB_RELEASE /etc/lsb-release | cut -d'=' -f2)
    else
        # Final fallback - install lsb-release first
        log "INFO" "Installing lsb-release for system detection..."
        apt update > /dev/null 2>&1
        apt install -y lsb-release > /dev/null 2>&1
        ubuntu_version=$(lsb_release -rs)
    fi
    
    if ! dpkg --compare-versions "$ubuntu_version" "ge" "20.04"; then
        log "ERROR" "Ubuntu 20.04 or later required. Current version: $ubuntu_version"
        ((errors++))
    else
        log "SUCCESS" "Ubuntu version check passed: $ubuntu_version"
    fi
    
    # Summary of checks
    if [ "$errors" -gt 0 ]; then
        log "ERROR" "System requirements check failed with $errors critical errors"
        log "ERROR" "Please resolve the above issues before continuing"
        exit 1
    fi
    
    if [ "$warnings" -gt 0 ]; then
        log "WARNING" "System requirements check completed with $warnings warnings"
        if is_interactive; then
            echo
            read -rp "Continue despite warnings? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                log "INFO" "Installation cancelled by user"
                exit 0
            fi
        else
            log "INFO" "Non-interactive mode: proceeding despite warnings"
        fi
    else
        log "SUCCESS" "System requirements check passed"
    fi
    
    log "INFO" "Ubuntu $ubuntu_version detected with ${memory_gb}GB RAM and ${disk_gb}GB free disk space"
}

# Update system packages (optimized)
update_system() {
    show_progress 3 15 "Updating system packages (optimized)"
    
    # Use optimized update if available
    if declare -f update_system_optimized > /dev/null; then
        update_system_optimized
        return $?
    fi
    
    log "INFO" "Updating package lists..."
    if ! timeout 120 apt update; then
        log "ERROR" "Failed to update package lists"
        return 1
    fi
    
    log "INFO" "Upgrading system packages..."
    if ! timeout 600 env DEBIAN_FRONTEND=noninteractive apt upgrade -y; then
        log "ERROR" "Failed to upgrade system packages"
        return 1
    fi
    
    log "INFO" "Installing essential packages..."
    if ! timeout 300 env DEBIAN_FRONTEND=noninteractive apt install -y \
        curl \
        wget \
        git \
        unzip \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release \
        ufw \
        fail2ban \
        htop \
        nano \
        openssl; then
        log "ERROR" "Failed to install essential packages"
        return 1
    fi
    
    log "SUCCESS" "System update completed"
}

# Set up environment variables
setup_environment() {
    show_progress 12 15 "Setting up environment variables"
    
    # Add environment variables to root's bash profile
    log "INFO" "Adding environment variables to bash profile..."
    
    cat >> /root/.bashrc << EOF

# N8N Environment Variables
export DB_PASSWORD="$DB_PASSWORD"
export ADMIN_PASSWORD="$ADMIN_PASSWORD"
export N8N_DIR="$N8N_DIR"
export DOMAIN_NAME="$DOMAIN_NAME"
EOF
    
    # Also add to .profile for non-interactive sessions
    cat >> /root/.profile << EOF

# N8N Environment Variables
export DB_PASSWORD="$DB_PASSWORD"
export ADMIN_PASSWORD="$ADMIN_PASSWORD"
export N8N_DIR="$N8N_DIR"
export DOMAIN_NAME="$DOMAIN_NAME"
EOF
    
    log "SUCCESS" "Environment variables configured"
}