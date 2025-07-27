#!/bin/bash

###################################################################################
#                                                                                 #
#                        N8N Self-Hosted Installer                               #
#                        Proxmox Detection & Configuration Module                 #
#                                                                                 #
###################################################################################

# Global Proxmox configuration variables
PROXMOX_DETECTED=false
PROXMOX_CONFIG_APPLIED=false
PROXMOX_NGINX_TIMEOUT=300
PROXMOX_VALIDATION_TIMEOUT=900  # 15 minutes
PROXMOX_VALIDATION_ATTEMPTS=30

###################################################################################
# Proxmox Environment Detection
###################################################################################

detect_proxmox_environment() {
    log "INFO" "Detecting virtualization environment..."
    
    # Check for Proxmox-specific indicators
    local proxmox_indicators=0
    
    # Check 1: systemd-detect-virt
    if command_exists systemd-detect-virt; then
        local virt_type
        virt_type=$(systemd-detect-virt 2>/dev/null || echo "none")
        log "DEBUG" "Virtualization type detected: $virt_type"
        
        if [[ "$virt_type" == "kvm" || "$virt_type" == "qemu" ]]; then
            ((proxmox_indicators++))
            log "INFO" "KVM/QEMU virtualization detected"
        fi
    fi
    
    # Check 2: DMI information for QEMU
    if [ -r "/sys/class/dmi/id/product_name" ]; then
        local product_name
        product_name=$(cat /sys/class/dmi/id/product_name 2>/dev/null || echo "")
        if [[ "$product_name" == *"QEMU"* ]]; then
            ((proxmox_indicators++))
            log "INFO" "QEMU product name detected in DMI"
        fi
    fi
    
    # Check 3: Proxmox guest agent
    if systemctl is-active qemu-guest-agent >/dev/null 2>&1; then
        ((proxmox_indicators++))
        log "INFO" "QEMU guest agent service detected"
    fi
    
    # Check 4: CPU model (common in Proxmox VMs)
    if [ -r "/proc/cpuinfo" ]; then
        if grep -q "QEMU\|KVM" /proc/cpuinfo 2>/dev/null; then
            ((proxmox_indicators++))
            log "INFO" "QEMU/KVM CPU model detected"
        fi
    fi
    
    # Check 5: Memory constraints typical of VMs
    local total_mem_gb
    total_mem_gb=$(free -g | awk 'NR==2{print $2}')
    if [ "$total_mem_gb" -le 4 ] && [ "$proxmox_indicators" -gt 0 ]; then
        ((proxmox_indicators++))
        log "INFO" "VM-typical memory constraints detected (${total_mem_gb}GB)"
    fi
    
    # Check 6: Network interface naming (Proxmox often uses specific patterns)
    if ip link show | grep -qE "(ens18|ens19|ens20|eth0.*qemu)"; then
        ((proxmox_indicators++))
        log "INFO" "Proxmox-typical network interface detected"
    fi
    
    # Determine if we're in a Proxmox environment
    if [ "$proxmox_indicators" -ge 2 ]; then
        PROXMOX_DETECTED=true
        log "SUCCESS" "Proxmox VM environment detected ($proxmox_indicators indicators)"
        return 0
    else
        log "INFO" "Standard/bare-metal environment detected ($proxmox_indicators indicators)"
        return 1
    fi
}

###################################################################################
# Proxmox-Specific Configuration Application
###################################################################################

apply_proxmox_optimizations() {
    if [ "$PROXMOX_DETECTED" != "true" ]; then
        log "DEBUG" "Skipping Proxmox optimizations (not detected)"
        return 0
    fi
    
    log "INFO" "Applying Proxmox VM optimizations..."
    
    # Set Proxmox-specific timeout values
    export NGINX_PROXY_TIMEOUT="$PROXMOX_NGINX_TIMEOUT"
    export VALIDATION_TIMEOUT="$PROXMOX_VALIDATION_TIMEOUT"
    export VALIDATION_ATTEMPTS="$PROXMOX_VALIDATION_ATTEMPTS"
    
    # Adjust Docker daemon settings for VM environment
    configure_docker_for_proxmox
    
    # Set kernel parameters for better VM performance
    configure_kernel_for_proxmox
    
    # Configure network optimizations
    configure_network_for_proxmox
    
    PROXMOX_CONFIG_APPLIED=true
    log "SUCCESS" "Proxmox optimizations applied"
    
    return 0
}

configure_docker_for_proxmox() {
    log "INFO" "Configuring Docker for Proxmox environment..."
    
    # Create Proxmox-optimized Docker daemon configuration
    local docker_config="/etc/docker/daemon.json"
    
    if [ -f "$docker_config" ]; then
        # Backup existing config
        cp "$docker_config" "${docker_config}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    cat > "$docker_config" << 'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ],
  "live-restore": true,
  "userland-proxy": false,
  "experimental": false,
  "metrics-addr": "127.0.0.1:9323",
  "default-runtime": "runc",
  "runtimes": {
    "runc": {
      "path": "runc"
    }
  },
  "exec-opts": ["native.cgroupdriver=systemd"],
  "bridge": "docker0",
  "fixed-cidr": "172.17.0.0/16",
  "default-address-pools": [
    {
      "base": "172.20.0.0/16",
      "size": 24
    }
  ]
}
EOF
    
    log "SUCCESS" "Docker configuration optimized for Proxmox"
}

configure_kernel_for_proxmox() {
    log "INFO" "Configuring kernel parameters for Proxmox VM..."
    
    # Create sysctl configuration for Proxmox VMs
    cat > /etc/sysctl.d/99-n8n-proxmox.conf << 'EOF'
# N8N Proxmox VM Optimizations

# Network optimizations
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq

# VM memory optimizations
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5

# File system optimizations
fs.file-max = 2097152
fs.inotify.max_user_watches = 524288

# Docker/container optimizations
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
    
    # Apply the settings
    sysctl -p /etc/sysctl.d/99-n8n-proxmox.conf >/dev/null 2>&1 || true
    
    log "SUCCESS" "Kernel parameters optimized for Proxmox"
}

configure_network_for_proxmox() {
    log "INFO" "Configuring network optimizations for Proxmox..."
    
    # Increase network buffer sizes for better performance in VMs
    if [ -f /proc/sys/net/core/netdev_max_backlog ]; then
        echo 5000 > /proc/sys/net/core/netdev_max_backlog 2>/dev/null || true
    fi
    
    # Optimize TCP settings for virtualized environment
    if [ -f /proc/sys/net/ipv4/tcp_window_scaling ]; then
        echo 1 > /proc/sys/net/ipv4/tcp_window_scaling 2>/dev/null || true
    fi
    
    log "SUCCESS" "Network optimizations applied"
}

###################################################################################
# Proxmox-Specific Installation Functions
###################################################################################

get_proxmox_configuration() {
    if [ "$PROXMOX_DETECTED" != "true" ]; then
        return 0
    fi
    
    log "INFO" "Gathering Proxmox-specific configuration..."
    
    # Auto-detect VM IP (more reliable in Proxmox)
    if [ -z "$DOMAIN_NAME" ] || [ "$DOMAIN_NAME" = "localhost" ]; then
        local vm_ip
        vm_ip=$(get_proxmox_vm_ip)
        if [ -n "$vm_ip" ]; then
            DOMAIN_NAME="$vm_ip"
            log "INFO" "Auto-detected Proxmox VM IP: $vm_ip"
        fi
    fi
    
    # Adjust memory settings based on VM allocation
    local total_mem_mb
    total_mem_mb=$(free -m | awk 'NR==2{print $2}')
    if [ "$total_mem_mb" -lt 4096 ]; then
        log "WARNING" "Low memory detected (${total_mem_mb}MB). Applying memory optimizations..."
        export N8N_MAX_EXECUTION_DATA_SIZE="5MB"
        export N8N_MAX_WORKFLOW_SIZE="5MB"
        export POSTGRES_SHARED_BUFFERS="128MB"
    fi
    
    # Set Proxmox-friendly defaults
    export INSTALLATION_TYPE="proxmox"
    export EXTENDED_TIMEOUTS="true"
    
    log "SUCCESS" "Proxmox configuration gathered"
}

get_proxmox_vm_ip() {
    # Try multiple methods to get the VM IP
    local vm_ip=""
    
    # Method 1: hostname -I (most reliable)
    vm_ip=$(hostname -I 2>/dev/null | awk '{print $1}' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$')
    if [ -n "$vm_ip" ] && [ "$vm_ip" != "127.0.0.1" ]; then
        echo "$vm_ip"
        return 0
    fi
    
    # Method 2: ip route
    vm_ip=$(ip route get 8.8.8.8 2>/dev/null | grep -oP 'src \K\S+' | head -1)
    if [ -n "$vm_ip" ] && [ "$vm_ip" != "127.0.0.1" ]; then
        echo "$vm_ip"
        return 0
    fi
    
    # Method 3: ip addr
    vm_ip=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | head -1 | awk '{print $2}' | cut -d'/' -f1)
    if [ -n "$vm_ip" ]; then
        echo "$vm_ip"
        return 0
    fi
    
    return 1
}

###################################################################################
# Proxmox-Specific Validation Functions
###################################################################################

run_proxmox_validation() {
    if [ "$PROXMOX_DETECTED" != "true" ]; then
        return 0
    fi
    
    log "INFO" "Running Proxmox-specific validation..."
    
    # Extended N8N startup validation for VMs
    validate_n8n_startup_proxmox
    
    # Validate VM-specific networking
    validate_proxmox_networking
    
    # Performance validation
    validate_proxmox_performance
    
    log "SUCCESS" "Proxmox validation completed"
}

validate_n8n_startup_proxmox() {
    log "INFO" "Validating N8N startup (extended timeout for Proxmox VM)..."
    
    local max_attempts=${PROXMOX_VALIDATION_ATTEMPTS:-30}
    local timeout_per_attempt=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s -m $timeout_per_attempt http://localhost:5678 >/dev/null 2>&1; then
            log "SUCCESS" "✓ N8N is responding (attempt $attempt/$max_attempts)"
            return 0
        fi
        
        local elapsed=$((attempt * timeout_per_attempt))
        log "INFO" "N8N not ready, waiting... (${elapsed}s/${PROXMOX_VALIDATION_TIMEOUT}s)"
        
        # Show container status every 5 attempts
        if [ $((attempt % 5)) -eq 0 ]; then
            log "DEBUG" "Container status check:"
            docker-compose ps 2>/dev/null || true
        fi
        
        sleep $timeout_per_attempt
        ((attempt++))
    done
    
    log "ERROR" "N8N did not start within timeout period"
    return 1
}

validate_proxmox_networking() {
    log "INFO" "Validating Proxmox VM networking..."
    
    # Check if VM can reach external networks
    if curl -s --connect-timeout 10 https://google.com >/dev/null 2>&1; then
        log "SUCCESS" "✓ External network connectivity verified"
    else
        log "WARNING" "⚠ External network connectivity issues detected"
    fi
    
    # Validate internal container networking
    if docker network ls | grep -q n8n; then
        log "SUCCESS" "✓ Docker network configuration verified"
    else
        log "WARNING" "⚠ Docker network issues detected"
    fi
    
    return 0
}

validate_proxmox_performance() {
    log "INFO" "Validating Proxmox VM performance..."
    
    # Check memory usage
    local mem_usage
    mem_usage=$(free | awk 'NR==2{printf "%.1f", $3*100/$2}')
    log "INFO" "Memory usage: ${mem_usage}%"
    
    # Check disk I/O
    local disk_usage
    disk_usage=$(df /opt/n8n 2>/dev/null | awk 'NR==2{print $5}' | sed 's/%//')
    log "INFO" "Disk usage: ${disk_usage}%"
    
    # Check if containers are resource-constrained
    if command_exists docker; then
        docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" 2>/dev/null | head -5 || true
    fi
    
    return 0
}

###################################################################################
# Proxmox Information Display
###################################################################################

show_proxmox_info() {
    if [ "$PROXMOX_DETECTED" != "true" ]; then
        return 0
    fi
    
    echo ""
    log "INFO" "🖥️  Proxmox VM Environment Detected"
    echo ""
    
    if [ "$PROXMOX_CONFIG_APPLIED" = "true" ]; then
        cat << EOF
[32m✅ Proxmox Optimizations Applied:[0m
  • Extended nginx timeouts (300s vs 60s)
  • Extended startup validation (15 minutes)
  • VM-optimized Docker configuration
  • Kernel parameter tuning
  • Network buffer optimizations
  • Memory-conscious N8N settings

[33m⚠️  Proxmox VM Notes:[0m
  • N8N startup may take 2-5 minutes
  • Initial nginx proxy access may be slower
  • Direct access (localhost:5678) should be immediate
  • Certificate warnings are normal with self-signed certs

EOF
    fi
    
    echo ""
}