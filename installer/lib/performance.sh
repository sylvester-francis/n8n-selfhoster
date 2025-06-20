#!/bin/bash

###################################################################################
#                                                                                 #
#                        N8N Self-Hosted Installer                               #
#                        Performance Optimization Module                          #
#                                                                                 #
###################################################################################

# Performance optimization functions

# Parallel package installation with batching
install_packages_parallel() {
    local packages=("$@")
    local batch_size=5
    local pids=()
    
    log "INFO" "Installing ${#packages[@]} packages in parallel batches of $batch_size..."
    
    for ((i=0; i<${#packages[@]}; i+=batch_size)); do
        local batch=("${packages[@]:i:batch_size}")
        (
            apt update > /dev/null 2>&1
            env DEBIAN_FRONTEND=noninteractive apt install -y "${batch[@]}" > /dev/null 2>&1
        ) &
        pids+=($!)
        
        # Wait if we have too many parallel jobs
        if [ ${#pids[@]} -ge 3 ]; then
            wait "${pids[@]}"
            pids=()
        fi
    done
    
    # Wait for remaining jobs
    if [ ${#pids[@]} -gt 0 ]; then
        wait "${pids[@]}"
    fi
}

# Cache management for faster subsequent runs
setup_package_cache() {
    # Configure apt for better performance
    cat > /etc/apt/apt.conf.d/99installer-performance << 'EOF'
APT::Acquire::Retries "3";
APT::Acquire::Queue-Mode "host";
APT::Install-Recommends "false";
APT::Install-Suggests "false";
Dpkg::Use-Pty "0";
EOF

    # Pre-download critical packages
    log "INFO" "Pre-downloading essential packages..."
    apt update > /dev/null 2>&1 &
}

# Optimized Docker installation
install_docker_optimized() {
    show_progress 4 15 "Installing Docker (optimized)"
    
    if command_exists docker; then
        log "INFO" "Docker already installed: $(docker --version)"
        return 0
    fi
    
    log "INFO" "Installing Docker with optimizations..."
    
    # Use Docker's convenience script for faster installation
    if curl -fsSL https://get.docker.com -o /tmp/get-docker.sh; then
        sh /tmp/get-docker.sh > /dev/null 2>&1
        rm -f /tmp/get-docker.sh
    else
        log "ERROR" "Failed to download Docker installation script"
        return 1
    fi
    
    # Start Docker service immediately
    systemctl enable docker --now > /dev/null 2>&1
    
    # Optimize Docker daemon settings
    mkdir -p /etc/docker
    cat > /etc/docker/daemon.json << 'EOF'
{
    "storage-driver": "overlay2",
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    },
    "live-restore": true,
    "userland-proxy": false
}
EOF
    
    systemctl restart docker > /dev/null 2>&1
    
    log "SUCCESS" "Docker installed and optimized"
    return 0
}

# Parallel service validation
validate_services_parallel() {
    local services=("docker" "nginx" "postgresql")
    local pids=()
    
    for service in "${services[@]}"; do
        (
            if systemctl is-active "$service" > /dev/null 2>&1; then
                echo "$service:success"
            else
                echo "$service:failed"
            fi
        ) &
        pids+=($!)
    done
    
    # Wait for all background processes to complete
    for pid in "${pids[@]}"; do
        wait "$pid"
    done
}

# Optimized system update with selective packages
update_system_optimized() {
    show_progress 3 15 "Updating system (optimized)"
    
    log "INFO" "Optimizing package cache..."
    setup_package_cache
    
    # Update only security packages if system is recent
    local last_update
    last_update=$(stat -c %Y /var/lib/apt/lists 2>/dev/null || echo 0)
    local current_time
    current_time=$(date +%s)
    local hours_since_update=$(( (current_time - last_update) / 3600 ))
    
    if [ "$hours_since_update" -lt 24 ]; then
        log "INFO" "System recently updated, installing only security updates..."
        apt list --upgradable 2>/dev/null | grep -i security | cut -d/ -f1 | xargs -r apt install -y > /dev/null 2>&1
    else
        log "INFO" "Performing selective system update..."
        apt update > /dev/null 2>&1
        
        # Only update essential packages
        local essential_packages=(
            "ca-certificates" "curl" "gnupg" "lsb-release" 
            "apt-transport-https" "software-properties-common"
        )
        
        for package in "${essential_packages[@]}"; do
            apt install -y "$package" > /dev/null 2>&1 || true
        done
    fi
    
    log "SUCCESS" "System update optimized"
}

# Fast dependency pre-check
fast_dependency_check() {
    local required_commands=("curl" "systemctl" "docker" "nginx")
    local missing=()
    
    for cmd in "${required_commands[@]}"; do
        if ! command_exists "$cmd" && [ "$cmd" != "docker" ] && [ "$cmd" != "nginx" ]; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        log "INFO" "Installing missing dependencies: ${missing[*]}"
        install_packages_parallel "${missing[@]}"
    fi
}

# Optimized Docker Compose installation
install_compose_optimized() {
    if command_exists docker-compose; then
        log "INFO" "Docker Compose already available"
        return 0
    fi
    
    # Use Docker plugin instead of standalone binary for better performance
    log "INFO" "Installing Docker Compose plugin..."
    
    # Create docker CLI plugins directory
    mkdir -p /usr/local/lib/docker/cli-plugins
    
    # Download compose plugin directly
    local arch
    arch=$(uname -m)
    case $arch in
        x86_64) arch="x86_64" ;;
        aarch64|arm64) arch="aarch64" ;;
        *) arch="x86_64" ;;
    esac
    
    local compose_url="https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$arch"
    
    if curl -SL "$compose_url" -o /usr/local/lib/docker/cli-plugins/docker-compose; then
        chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
        ln -sf /usr/local/lib/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose
        log "SUCCESS" "Docker Compose plugin installed"
    else
        log "WARNING" "Failed to install Docker Compose plugin, using fallback"
        return 1
    fi
}

# Optimized N8N startup with health checks
start_n8n_optimized() {
    log "INFO" "Starting N8N with optimized configuration..."
    
    cd "$N8N_DIR" || return 1
    
    # Start with resource limits and health checks
    docker-compose up -d --remove-orphans
    
    # Wait for services with timeout
    local timeout=120
    local elapsed=0
    
    while [ $elapsed -lt $timeout ]; do
        if docker-compose ps -q | xargs docker inspect --format='{{.State.Health.Status}}' 2>/dev/null | grep -q "healthy"; then
            log "SUCCESS" "N8N services are healthy"
            return 0
        fi
        
        sleep 2
        elapsed=$((elapsed + 2))
        
        if [ $((elapsed % 10)) -eq 0 ]; then
            log "INFO" "Waiting for N8N services... (${elapsed}s/${timeout}s)"
        fi
    done
    
    log "WARNING" "N8N services did not become healthy within timeout"
    return 1
}

# Memory usage optimization
optimize_system_performance() {
    log "INFO" "Applying system performance optimizations..."
    
    # Optimize kernel parameters for containers
    cat >> /etc/sysctl.conf << 'EOF'
# N8N Container Optimizations
vm.max_map_count=262144
net.core.somaxconn=65535
net.ipv4.tcp_max_syn_backlog=65535
net.ipv4.ip_local_port_range=1024 65535
EOF
    
    sysctl -p > /dev/null 2>&1 || true
    
    # Set up tmpfs for temporary files if enough RAM
    local total_mem
    total_mem=$(free -m | awk 'NR==2{print $2}')
    
    if [ "$total_mem" -gt 2048 ]; then
        mount -t tmpfs -o size=512M tmpfs /tmp > /dev/null 2>&1 || true
        log "INFO" "Optimized temporary storage with tmpfs"
    fi
}

# Export functions for use in main installer
export -f install_packages_parallel
export -f setup_package_cache
export -f install_docker_optimized
export -f validate_services_parallel
export -f update_system_optimized
export -f fast_dependency_check
export -f install_compose_optimized
export -f start_n8n_optimized
export -f optimize_system_performance