#!/bin/bash

###################################################################################
#                                                                                 #
#                        N8N Self-Hosted Installer                               #
#                           Common Utilities Library                              #
#                                                                                 #
###################################################################################

set -euo pipefail

###################################################################################
# Global Configuration Variables
###################################################################################

SCRIPT_VERSION="1.3.1"
LOG_FILE="/tmp/n8n-installer.log"
export N8N_DIR="/opt/n8n"
export BACKUP_DIR="/opt/n8n/backups"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
# PURPLE='\033[0;35m'  # Reserved for future use
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Emojis for better UX
SUCCESS="✅"
ERROR="❌"
WARNING="⚠️"
INFO="ℹ️"
# ROCKET="🚀"  # Reserved for future use
# LOCK="🔒" # Reserved for future use
GEAR="⚙️"

###################################################################################
# Utility Functions
###################################################################################

# Print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Log function
log() {
    local level=$1
    local message=$2
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    case $level in
        "ERROR")
            print_color "$RED" "${ERROR} $message"
            ;;
        "SUCCESS")
            print_color "$GREEN" "${SUCCESS} $message"
            ;;
        "WARNING")
            print_color "$YELLOW" "${WARNING} $message"
            ;;
        "INFO")
            print_color "$BLUE" "${INFO} $message"
            ;;
        *)
            echo "$message"
            ;;
    esac
}

# Enhanced error handler with recovery suggestions
error_exit() {
    local line_number=$1
    local exit_code=${2:-1}
    
    log "ERROR" "Script failed at line $line_number"
    print_color "$RED" "\n${ERROR} Installation failed! Check $LOG_FILE for details."
    
    # Common error recovery suggestions
    print_color "$YELLOW" "\n${INFO} Troubleshooting suggestions:"
    print_color "$WHITE" "1. Check internet connectivity: ping -c 3 google.com"
    print_color "$WHITE" "2. Ensure you have sudo privileges"
    print_color "$WHITE" "3. Check available disk space: df -h"
    print_color "$WHITE" "4. Check the log file for specific errors: tail -20 $LOG_FILE"
    
    # Suggest cleanup if partially installed
    if [ -d "$N8N_DIR" ] || command_exists docker; then
        print_color "$YELLOW" "\n${WARNING} Partial installation detected. You may want to clean up:"
        print_color "$WHITE" "- Remove N8N directory: sudo rm -rf $N8N_DIR"
        print_color "$WHITE" "- Stop any running containers: docker stop \$(docker ps -q)"
    fi
    
    print_color "$YELLOW" "\n${INFO} To retry the installation:"
    print_color "$WHITE" "sudo bash $0"
    
    # Offer to create a bug report only in interactive mode
    if is_interactive; then
        echo
        read -rp "Would you like to create a bug report? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            create_bug_report "$line_number"
        fi
    else
        # In non-interactive mode, always create bug report
        create_bug_report "$line_number"
    fi
    
    exit "$exit_code"
}

# Create a bug report for troubleshooting
create_bug_report() {
    local line_number=$1
    local bug_report_file="/tmp/n8n-installer-bug-report.txt"
    
    print_color "$BLUE" "\n${INFO} Creating bug report..."
    
    cat > "$bug_report_file" << EOF
N8N Installer Bug Report
========================
Date: $(date)
Script Version: $SCRIPT_VERSION
Failed at Line: $line_number

System Information:
- OS: $(lsb_release -d 2>/dev/null | cut -f2 || echo "Unknown")
- Kernel: $(uname -r)
- Architecture: $(uname -m)
- Available RAM: $(free -h | grep '^Mem:' | awk '{print $2}')
- Available Disk: $(df -h / | tail -1 | awk '{print $4}')

Network Information:
- Public IP: ${SERVER_IP:-"Not determined"}
- Internet Connectivity: $(ping -c 1 8.8.8.8 >/dev/null 2>&1 && echo "OK" || echo "FAILED")

Docker Status:
- Docker Installed: $(command_exists docker && echo "YES" || echo "NO")
- Docker Version: $(docker --version 2>/dev/null || echo "Not installed")

Last 20 lines of installer log:
$(tail -20 "$LOG_FILE" 2>/dev/null || echo "Log file not available")

EOF

    print_color "$GREEN" "${SUCCESS} Bug report created: $bug_report_file"
    print_color "$WHITE" "Please share this file when reporting issues on GitHub:"
    print_color "$CYAN" "https://github.com/sylvester-francis/n8n-selfhoster/issues"
}

# Set up error trap
trap 'error_exit $LINENO' ERR

# Enhanced progress indicator with visual progress bar
show_progress() {
    local step=$1
    local total=$2
    local description=$3
    local percentage=$((step * 100 / total))
    
    # Create visual progress bar
    local bar_length=50
    local filled_length=$((percentage * bar_length / 100))
    local bar=""
    
    # Build progress bar
    for ((i=0; i<filled_length; i++)); do
        bar+="█"
    done
    for ((i=filled_length; i<bar_length; i++)); do
        bar+="░"
    done
    
    print_color "$CYAN" "\n${GEAR} Step $step/$total ($percentage%): $description"
    print_color "$WHITE" "[$bar] $percentage%"
    echo "=================================================================================="
}

# Simple progress dots for long operations
show_progress_dots() {
    local message="$1"
    local pid="$2"
    local delay=1
    
    printf "%s" "$message"
    
    while ps -p "$pid" > /dev/null 2>&1; do
        printf "."
        sleep $delay
    done
    
    printf " ✓\n"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1 || \
    [ -x "/usr/sbin/$1" ] || \
    [ -x "/usr/bin/$1" ] || \
    [ -x "/sbin/$1" ] || \
    [ -x "/bin/$1" ]
}

# Check if port is open
check_port() {
    local port=$1
    if ss -tuln | grep -q ":$port "; then
        return 0
    else
        return 1
    fi
}

# Generate secure password
generate_password() {
    # Try multiple methods for generating secure passwords
    if command_exists openssl; then
        openssl rand -base64 32 | tr -d "=+/" | cut -c1-25
    elif [ -c /dev/urandom ]; then
        # Use /dev/urandom with base64 encoding
        head -c 32 /dev/urandom | base64 | tr -d "=+/" | cut -c1-25
    elif command_exists python3; then
        python3 -c "import secrets, string; print(''.join(secrets.choice(string.ascii_letters + string.digits) for _ in range(25)))"
    elif command_exists python; then
        python -c "import random, string; print(''.join(random.choice(string.ascii_letters + string.digits) for _ in range(25)))"
    else
        # Fallback to date-based password (less secure but functional)
        echo "n8n$(date +%s)$(echo $RANDOM | md5sum | head -c 10)" | cut -c1-25
    fi
}

# Check if we should run in interactive mode
is_interactive() {
    # Force interactive mode if requested
    if [ "${FORCE_INTERACTIVE:-}" = "true" ]; then
        return 0
    fi
    
    # Skip interactive if auto-confirm is set
    if [ "${AUTO_CONFIRM:-}" = "true" ]; then
        return 1
    fi
    
    # Check for real terminal
    if [ -t 0 ] && [ -t 1 ]; then
        return 0
    fi
    
    return 1
}

# Spinner function for long-running operations with timeout
spinner() {
    local pid=$1
    local timeout=${2:-300}  # Default 5 minute timeout
    local delay=0.1
    local spinstr="|/-\\"
    local elapsed=0
    
    while ps a | awk '{print $1}' | grep -q "$pid"; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
        
        elapsed=$((elapsed + 1))
        if [ $elapsed -gt $((timeout * 10)) ]; then
            printf "    \b\b\b\b"
            log "WARNING" "Operation timed out after ${timeout} seconds"
            kill "$pid" 2>/dev/null || true
            return 1
        fi
    done
    printf "    \b\b\b\b"
    return 0
}

# Initialize logging
init_logging() {
    touch "$LOG_FILE"
    log "INFO" "Starting N8N Self-Hosted Installer v$SCRIPT_VERSION"
}

# Show welcome message with environment detection and installation type selection
show_welcome() {
    # Only clear screen in truly interactive mode
    if [ -t 0 ] && [ -t 1 ] && [ -t 2 ] && [ -z "${SSH_CONNECTION:-}" ]; then
        clear 2>/dev/null || true
    fi
    
    print_color "$CYAN" "╔══════════════════════════════════════════════════════════════════════════════╗"
    print_color "$CYAN" "║                                                                              ║"
    print_color "$CYAN" "║                    🚀 N8N Self-Hosted Installer 🚀                          ║"
    print_color "$CYAN" "║                                                                              ║"
    print_color "$CYAN" "║                    Production-Ready Ubuntu Installation                      ║"
    print_color "$CYAN" "║                            Version $SCRIPT_VERSION                                        ║"
    print_color "$CYAN" "║                                                                              ║"
    print_color "$CYAN" "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo
    
    # Detect environment
    local environment_type="unknown"
    local environment_info=""
    
    if command -v systemd-detect-virt >/dev/null 2>&1; then
        local virt_type
        virt_type=$(systemd-detect-virt 2>/dev/null || echo "none")
        if [[ "$virt_type" != "none" ]]; then
            environment_type="virtual"
            environment_info="$virt_type"
            
            # Check if it's likely Proxmox
            if [[ "$virt_type" == "kvm" ]] && detect_proxmox_environment >/dev/null 2>&1; then
                environment_type="proxmox"
                environment_info="Proxmox VM"
            fi
        else
            environment_type="physical"
            environment_info="Physical/Bare Metal"
        fi
    fi
    
    print_color "$BLUE" "${INFO} Environment Detection:"
    print_color "$WHITE" "  System Type: $environment_info"
    
    if [ "$environment_type" = "proxmox" ]; then
        print_color "$GREEN" "  ${SUCCESS} Proxmox VM detected - optimizations available!"
    elif [ "$environment_type" = "virtual" ]; then
        print_color "$YELLOW" "  ${WARNING} Virtual machine detected - some optimizations available"
    fi
    
    echo
    print_color "$YELLOW" "📋 What this installer includes:"
    print_color "$WHITE" "  • Docker & Docker Compose installation"
    print_color "$WHITE" "  • N8N with PostgreSQL database"
    print_color "$WHITE" "  • Nginx reverse proxy with HTTPS"
    print_color "$WHITE" "  • Self-signed SSL certificates"
    print_color "$WHITE" "  • Firewall and security configuration"
    print_color "$WHITE" "  • Automated backups"
    print_color "$WHITE" "  • Comprehensive testing"
    
    if [ "$environment_type" = "proxmox" ]; then
        echo
        print_color "$GREEN" "${SUCCESS} Proxmox VM Optimizations:"
        print_color "$WHITE" "  • Extended timeouts (nginx: 300s, validation: 15min)"
        print_color "$WHITE" "  • VM-optimized Docker configuration"
        print_color "$WHITE" "  • Memory-conscious N8N settings"
        print_color "$WHITE" "  • Kernel parameter tuning for VMs"
        print_color "$WHITE" "  • Automatic VM IP detection"
        export PROXMOX_OPTIMIZATIONS=true
    fi
    
    echo
    local estimated_time="10-15 minutes"
    if [ "$environment_type" = "proxmox" ] || [ "$environment_type" = "virtual" ]; then
        estimated_time="15-25 minutes"
    fi
    
    print_color "$BLUE" "${INFO} Installation Info:"
    print_color "$WHITE" "  Estimated time: $estimated_time"
    print_color "$WHITE" "  Log file: $LOG_FILE"
    echo
    
    # Handle installation type selection based on command line argument or user interaction
    if [ "${INSTALLATION_TYPE:-auto}" = "auto" ]; then
        if is_interactive; then
            # In interactive mode, offer installation type selection
            if [ "$environment_type" = "proxmox" ]; then
                print_color "$YELLOW" "🖥️ Installation Options:"
                print_color "$WHITE" "  1) Proxmox-optimized installation (Recommended)"
                print_color "$WHITE" "  2) Standard installation"
                print_color "$WHITE" "  3) Cancel"
                echo
                
                while true; do
                    read -rp "Select installation type (1-3): " choice
                    case $choice in
                        1)
                            export INSTALLATION_TYPE="proxmox"
                            print_color "$GREEN" "${SUCCESS} Proxmox-optimized installation selected"
                            break
                            ;;
                        2)
                            export INSTALLATION_TYPE="standard"
                            export PROXMOX_OPTIMIZATIONS=false
                            print_color "$BLUE" "${INFO} Standard installation selected"
                            break
                            ;;
                        3)
                            log "INFO" "Installation cancelled by user"
                            exit 0
                            ;;
                        *)
                            print_color "$RED" "Invalid choice. Please select 1, 2, or 3."
                            ;;
                    esac
                done
            else
                print_color "$YELLOW" "Continue with installation? (y/N): "
                read -rp "" -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    log "INFO" "Installation cancelled by user"
                    exit 0
                fi
                export INSTALLATION_TYPE="standard"
            fi
        else
            # Non-interactive mode - auto-select based on environment
            if [ "$environment_type" = "proxmox" ]; then
                export INSTALLATION_TYPE="proxmox"
                log "INFO" "Auto-detection: selected Proxmox-optimized installation"
                print_color "$GREEN" "${SUCCESS} Auto-selected: Proxmox-optimized installation"
            else
                export INSTALLATION_TYPE="standard"
                log "INFO" "Auto-detection: proceeding with standard installation"
                print_color "$BLUE" "${INFO} Auto-selected: Standard installation"
            fi
        fi
    else
        # Installation type was specified via command line
        case "${INSTALLATION_TYPE}" in
            "proxmox")
                export PROXMOX_OPTIMIZATIONS=true
                print_color "$GREEN" "${SUCCESS} Using Proxmox-optimized installation (specified via --type)"
                log "INFO" "Installation type forced to Proxmox via command line"
                ;;
            "standard")
                export PROXMOX_OPTIMIZATIONS=false
                print_color "$BLUE" "${INFO} Using standard installation (specified via --type)"
                log "INFO" "Installation type forced to standard via command line"
                ;;
        esac
        
        if is_interactive; then
            print_color "$YELLOW" "Continue with installation? (y/N): "
            read -rp "" -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                log "INFO" "Installation cancelled by user"
                exit 0
            fi
        fi
    fi
    
    echo
    print_color "$GREEN" "${SUCCESS} Starting installation..."
    sleep 2
}

# Enhanced input validation
validate_input() {
    local input_type="$1"
    local value="$2"
    
    case "$input_type" in
        "ip")
            if [[ $value =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                IFS='.' read -ra ADDR <<< "$value"
                for i in "${ADDR[@]}"; do
                    if [[ $i -gt 255 ]]; then
                        return 1
                    fi
                done
                return 0
            else
                return 1
            fi
            ;;
        "domain")
            if [[ $value =~ ^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]?\.[a-zA-Z]{2,}$ ]]; then
                return 0
            else
                return 1
            fi
            ;;
        "timezone")
            if timedatectl list-timezones | grep -q "^$value$"; then
                return 0
            else
                return 1
            fi
            ;;
        *)
            return 1
            ;;
    esac
}

# Enhanced prompt with validation and defaults
prompt_with_validation() {
    local prompt_text="$1"
    local validation_type="$2"
    local default_value="$3"
    local allow_empty="${4:-false}"
    local result=""
    
    while true; do
        if [ -n "$default_value" ]; then
            read -rp "$prompt_text [$default_value]: " result
            if [ -z "$result" ]; then
                result="$default_value"
            fi
        else
            read -rp "$prompt_text: " result
        fi
        
        if [ -z "$result" ] && [ "$allow_empty" = "true" ]; then
            break
        elif [ -z "$result" ] && [ "$allow_empty" = "false" ]; then
            print_color "$RED" "This field is required. Please enter a value."
            continue
        fi
        
        if [ -n "$validation_type" ] && ! validate_input "$validation_type" "$result"; then
            case "$validation_type" in
                "ip")
                    print_color "$RED" "Invalid IP address format. Please enter a valid IP (e.g., 192.168.1.100)"
                    ;;
                "domain")
                    print_color "$RED" "Invalid domain format. Please enter a valid domain (e.g., example.com)"
                    ;;
                "timezone")
                    print_color "$RED" "Invalid timezone. Use 'timedatectl list-timezones' to see available options"
                    ;;
                *)
                    print_color "$RED" "Invalid input format."
                    ;;
            esac
            continue
        fi
        
        break
    done
    
    echo "$result"
}

# Get user configuration with enhanced prompts
get_configuration() {
    show_progress 2 15 "Gathering configuration"
    
    # Skip configuration if already set via command line arguments
    if [ -n "${SERVER_IP:-}" ] && [ -n "${DOMAIN_NAME:-}" ] && [ -n "${TIMEZONE:-}" ]; then
        log "INFO" "Using configuration from command line arguments"
        return 0
    fi
    
    # Get server IP if not already set
    if [ -z "${SERVER_IP:-}" ]; then
        detected_ip=$(curl -s ifconfig.me || curl -s ipinfo.io/ip || curl -s icanhazip.com)
        if is_interactive; then
            if [ -n "$detected_ip" ]; then
                SERVER_IP=$(prompt_with_validation "Server IP address" "ip" "$detected_ip" false)
            else
                SERVER_IP=$(prompt_with_validation "Server IP address (could not auto-detect)" "ip" "" false)
            fi
        else
            if [ -n "$detected_ip" ]; then
                SERVER_IP="$detected_ip"
                log "INFO" "Auto-detected IP: $SERVER_IP"
            else
                log "ERROR" "Cannot determine IP address in non-interactive mode"
                exit 1
            fi
        fi
        export SERVER_IP
    fi
    
    # Ask for domain if not already set
    if [ -z "${DOMAIN_NAME:-}" ] && [ -z "${USE_DOMAIN:-}" ]; then
        print_color "$YELLOW" "\n${INFO} Domain Configuration"
        print_color "$WHITE" "You can use either a domain name or IP address for this installation."
        print_color "$WHITE" "Domain names allow for proper SSL certificates with Let's Encrypt."
        
        if is_interactive; then
            DOMAIN_NAME=$(prompt_with_validation "Domain name (or press Enter to use IP $SERVER_IP)" "domain" "" true)
        else
            DOMAIN_NAME=""  # Use IP address in non-interactive mode
            log "INFO" "Non-interactive mode: using IP address"
        fi
        
        if [ -z "$DOMAIN_NAME" ]; then
            export DOMAIN_NAME="$SERVER_IP"
            export USE_DOMAIN=false
            log "INFO" "Using IP address: $SERVER_IP"
        else
            export USE_DOMAIN=true
            export DOMAIN_NAME="$DOMAIN_NAME"
            log "INFO" "Using domain: $DOMAIN_NAME"
        fi
    fi
    
    # Generate secure passwords
    DB_PASSWORD=$(generate_password)
    export DB_PASSWORD
    ADMIN_PASSWORD=$(generate_password)
    export ADMIN_PASSWORD
    
    # Ask for timezone if not already set
    if [ -z "${TIMEZONE:-}" ]; then
        current_tz=$(timedatectl show --property=Timezone --value)
        print_color "$YELLOW" "\n${INFO} Timezone Configuration"
        
        if is_interactive; then
            TIMEZONE=$(prompt_with_validation "Timezone" "timezone" "$current_tz" true)
        else
            TIMEZONE="$current_tz"  # Use current timezone in non-interactive mode
            log "INFO" "Non-interactive mode: using current timezone"
        fi
        
        if [ -z "$TIMEZONE" ]; then
            TIMEZONE="$current_tz"
        fi
        export TIMEZONE
    fi
    
    # Configuration summary
    print_color "$GREEN" "\n${SUCCESS} Configuration Summary:"
    print_color "$WHITE" "  Domain/IP: $DOMAIN_NAME"
    print_color "$WHITE" "  Timezone: $TIMEZONE"
    print_color "$WHITE" "  Database Password: [Generated securely]"
    print_color "$WHITE" "  Admin Password: [Generated securely]"
    
    if is_interactive; then
        echo
        read -rp "Continue with this configuration? (Y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            log "INFO" "Configuration cancelled by user"
            exit 0
        fi
    else
        log "INFO" "Non-interactive mode: automatically continuing with configuration"
    fi
    
    log "INFO" "Configuration completed"
    log "INFO" "Domain/IP: $DOMAIN_NAME"
    log "INFO" "Timezone: $TIMEZONE"
}