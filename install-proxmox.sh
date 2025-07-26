#!/bin/bash

###################################################################################
#                                                                                 #
#                   N8N Self-Hosted Installer - Proxmox Edition                  #
#                                                                                 #
###################################################################################
#                                                                                 #
# Description: Specialized installer for Proxmox Ubuntu VMs                      #
# Author: Sylvester Francis                                                      #
# Version: 1.3.0 (Proxmox Edition)                                              #
# GitHub: https://github.com/sylvester-francis/n8n-selfhoster                    #
#                                                                                 #
# Proxmox-specific optimizations:                                                #
# - Extended timeouts for VM environments                                        #
# - VM-optimized Docker configuration                                           #
# - Automatic VM IP detection                                                   #
# - Memory-conscious settings                                                   #
# - Kernel parameter tuning for VMs                                            #
#                                                                                 #
###################################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║           🖥️  N8N Self-Hosted Installer - Proxmox Edition 🖥️                 ║
║                                                                              ║
║           Optimized for Proxmox Ubuntu Virtual Machines                     ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

show_proxmox_info() {
    echo -e "${YELLOW}📋 Proxmox VM Optimizations Included:${NC}"
    echo ""
    echo "  🔧 Extended nginx timeouts (300s vs 60s)"
    echo "  ⏱️  Extended startup validation (15 minutes)"
    echo "  🐳 VM-optimized Docker configuration"
    echo "  🧠 Memory-conscious N8N settings"
    echo "  ⚡ Kernel parameter tuning for VMs"
    echo "  🌐 Automatic VM IP detection"
    echo "  📊 VM performance monitoring"
    echo ""
    echo -e "${BLUE}ℹ️  Expected behavior in Proxmox VMs:${NC}"
    echo "  • Installation: 10-20 minutes (longer than bare metal)"
    echo "  • N8N startup: 2-5 minutes after containers start"
    echo "  • Direct access test: curl http://localhost:5678 (immediate)"
    echo "  • Proxy access: https://VM_IP (may take a few minutes initially)"
    echo ""
}

check_proxmox_requirements() {
    echo -e "${CYAN}🔍 Checking Proxmox VM requirements...${NC}"
    
    local errors=0
    local warnings=0
    
    # Check if we're in a virtualized environment
    if command -v systemd-detect-virt >/dev/null 2>&1; then
        local virt_type=$(systemd-detect-virt 2>/dev/null || echo "none")
        if [[ "$virt_type" == "none" ]]; then
            echo -e "${YELLOW}⚠️  Warning: Not detected as a virtual machine${NC}"
            echo "   This installer is optimized for Proxmox VMs"
            ((warnings++))
        else
            echo -e "${GREEN}✅ Virtual machine detected: $virt_type${NC}"
        fi
    fi
    
    # Check memory (minimum 2GB for VMs)
    local total_mem_gb=$(free -g | awk 'NR==2{print $2}')
    if [ "$total_mem_gb" -lt 2 ]; then
        echo -e "${RED}❌ Insufficient memory: ${total_mem_gb}GB (minimum 2GB required)${NC}"
        ((errors++))
    elif [ "$total_mem_gb" -lt 4 ]; then
        echo -e "${YELLOW}⚠️  Low memory: ${total_mem_gb}GB (4GB recommended for production)${NC}"
        ((warnings++))
    else
        echo -e "${GREEN}✅ Memory check passed: ${total_mem_gb}GB available${NC}"
    fi
    
    # Check disk space (minimum 20GB)
    local disk_space_gb=$(df / | awk 'NR==2{print int($4/1024/1024)}')
    if [ "$disk_space_gb" -lt 20 ]; then
        echo -e "${RED}❌ Insufficient disk space: ${disk_space_gb}GB (minimum 20GB required)${NC}"
        ((errors++))
    else
        echo -e "${GREEN}✅ Disk space check passed: ${disk_space_gb}GB available${NC}"
    fi
    
    # Check Ubuntu version
    if [ -f /etc/os-release ]; then
        local ubuntu_version=$(grep VERSION_ID /etc/os-release | cut -d'"' -f2)
        if [[ "$ubuntu_version" < "20.04" ]]; then
            echo -e "${RED}❌ Ubuntu version too old: $ubuntu_version (minimum 20.04 required)${NC}"
            ((errors++))
        else
            echo -e "${GREEN}✅ Ubuntu version check passed: $ubuntu_version${NC}"
        fi
    fi
    
    # Check internet connectivity
    if curl -s --connect-timeout 10 https://google.com >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Internet connectivity verified${NC}"
    else
        echo -e "${RED}❌ No internet connectivity${NC}"
        ((errors++))
    fi
    
    echo ""
    
    if [ $errors -gt 0 ]; then
        echo -e "${RED}❌ $errors critical error(s) detected. Please resolve them before continuing.${NC}"
        return 1
    elif [ $warnings -gt 0 ]; then
        echo -e "${YELLOW}⚠️  $warnings warning(s) detected. Installation can continue but may not be optimal.${NC}"
        if [ "${AUTO_CONFIRM:-false}" != "true" ]; then
            echo ""
            read -p "Continue anyway? (y/N): " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "Installation cancelled."
                exit 1
            fi
        fi
    else
        echo -e "${GREEN}✅ All checks passed!${NC}"
    fi
    
    echo ""
}

get_vm_configuration() {
    echo -e "${CYAN}⚙️  Gathering VM configuration...${NC}"
    
    # Auto-detect VM IP
    local vm_ip=""
    vm_ip=$(hostname -I 2>/dev/null | awk '{print $1}' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' || true)
    
    if [ -z "$vm_ip" ]; then
        vm_ip=$(ip route get 8.8.8.8 2>/dev/null | grep -oP 'src \K\S+' | head -1 || true)
    fi
    
    if [ -z "$vm_ip" ]; then
        echo -e "${YELLOW}⚠️  Could not auto-detect VM IP${NC}"
        if [ "${AUTO_CONFIRM:-false}" != "true" ]; then
            read -p "Enter your VM's IP address: " vm_ip
        else
            vm_ip="localhost"
        fi
    else
        echo -e "${GREEN}✅ Auto-detected VM IP: $vm_ip${NC}"
    fi
    
    # Auto-detect timezone
    local timezone=""
    if command -v timedatectl >/dev/null 2>&1; then
        timezone=$(timedatectl show -p Timezone --value 2>/dev/null || echo "UTC")
    else
        timezone="UTC"
    fi
    
    echo -e "${GREEN}✅ Detected timezone: $timezone${NC}"
    
    # Export configuration for main installer
    export DOMAIN_NAME="$vm_ip"
    export TIMEZONE="$timezone"
    export PROXMOX_MODE="true"
    export AUTO_CONFIRM="${AUTO_CONFIRM:-false}"
    
    echo ""
    echo -e "${WHITE}📋 Configuration Summary:${NC}"
    echo "  Domain/IP: $vm_ip"
    echo "  Timezone: $timezone"
    echo "  Installation type: Proxmox VM Optimized"
    echo ""
}

main() {
    print_banner
    show_proxmox_info
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -y|--yes)
                export AUTO_CONFIRM=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            --domain)
                export DOMAIN_NAME="$2"
                shift 2
                ;;
            --ip)
                export DOMAIN_NAME="$2"
                shift 2
                ;;
            *)
                echo "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    # Check requirements
    check_proxmox_requirements
    
    # Get configuration
    get_vm_configuration
    
    # Confirm installation
    if [ "${AUTO_CONFIRM:-false}" != "true" ]; then
        echo -e "${CYAN}🚀 Ready to install N8N with Proxmox optimizations${NC}"
        echo ""
        read -p "Continue with installation? (Y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            echo "Installation cancelled."
            exit 0
        fi
    fi
    
    echo ""
    echo -e "${GREEN}🚀 Starting Proxmox-optimized N8N installation...${NC}"
    echo ""
    
    # Force Proxmox optimizations
    export PROXMOX_DETECTED=true
    export NGINX_PROXY_TIMEOUT=300
    export VALIDATION_ATTEMPTS=30
    export VALIDATION_TIMEOUT_PER_CHECK=30
    
    # Run the main installer with Proxmox optimizations
    if [ -f "$SCRIPT_DIR/installer/install.sh" ]; then
        exec "$SCRIPT_DIR/installer/install.sh" --yes --domain "$DOMAIN_NAME" --timezone "$TIMEZONE"
    else
        echo -e "${RED}❌ Main installer not found at $SCRIPT_DIR/installer/install.sh${NC}"
        echo "Please make sure you're running this script from the project root directory."
        exit 1
    fi
}

show_help() {
    cat << EOF
N8N Self-Hosted Installer - Proxmox Edition

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -h, --help          Show this help message
    -y, --yes           Skip all prompts (non-interactive mode)
    --domain DOMAIN     Set domain name (e.g., example.com)
    --ip IP             Set server IP address

EXAMPLES:
    # Interactive installation
    sudo $0

    # Non-interactive installation
    sudo $0 --yes

    # Installation with specific IP
    sudo $0 --yes --ip 192.168.1.100

PROXMOX OPTIMIZATIONS:
    • Extended nginx timeouts (300s vs 60s)
    • Extended startup validation (15 minutes vs 5 minutes)
    • VM-optimized Docker configuration
    • Automatic VM IP detection
    • Memory-conscious N8N settings
    • Kernel parameter tuning for VMs

For more information, visit: https://github.com/sylvester-francis/n8n-selfhoster

EOF
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}❌ This script must be run as root (use sudo)${NC}"
    exit 1
fi

# Run main function
main "$@"