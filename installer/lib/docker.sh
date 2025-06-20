#!/bin/bash

###################################################################################
#                                                                                 #
#                        N8N Self-Hosted Installer                               #
#                        Docker Installation Module                               #
#                                                                                 #
###################################################################################

# Install Docker and Docker Compose (optimized)
install_docker() {
    show_progress 4 15 "Installing Docker and Docker Compose (optimized)"
    
    if command_exists docker; then
        log "INFO" "Docker already installed: $(docker --version)"
        
        # Even if Docker is installed, check if it's running
        if ! docker info > /dev/null 2>&1; then
            log "WARNING" "Docker is installed but not running, attempting to start..."
            # Try to start existing Docker installation
            if systemctl start docker 2>/dev/null || service docker start 2>/dev/null; then
                log "SUCCESS" "Existing Docker installation started"
            else
                log "WARNING" "Could not start existing Docker installation"
            fi
        fi
    else
        # Try fast installation method first
        log "INFO" "Attempting fast Docker installation..."
        if install_docker_fast; then
            log "SUCCESS" "Docker installed via fast method"
        else
            log "WARNING" "Fast installation failed, using manual method"
            if install_docker_manual; then
                log "SUCCESS" "Docker installed via manual method"
            else
                log "ERROR" "Both fast and manual Docker installation methods failed"
                return 1
            fi
        fi
    fi
    
    # Install Docker Compose
    install_docker_compose
    
    # Ensure Docker service is properly installed and running
    log "INFO" "Verifying Docker installation..."
    
    # Create docker group if it doesn't exist
    if ! getent group docker > /dev/null 2>&1; then
        log "INFO" "Creating docker group..."
        groupadd docker || log "WARNING" "Failed to create docker group"
    fi
    
    # Add user to docker group
    if [ -n "${SUDO_USER:-}" ]; then
        log "INFO" "Adding $SUDO_USER to docker group..."
        usermod -aG docker "$SUDO_USER" || log "WARNING" "Failed to add user to docker group"
    fi
    
    # Ensure Docker daemon is properly configured
    if [ ! -f /etc/docker/daemon.json ]; then
        log "INFO" "Creating Docker daemon configuration..."
        mkdir -p /etc/docker
        cat > /etc/docker/daemon.json << 'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
EOF
    fi
    
    # Wait for Docker to fully initialize
    log "INFO" "Waiting for Docker to initialize..."
    sleep 10
    
    # Restart Docker with new configuration
    log "INFO" "Restarting Docker with configuration..."
    systemctl daemon-reload
    systemctl restart docker || true
    sleep 5
    
    # Test Docker functionality with retries
    log "INFO" "Testing Docker installation..."
    local max_attempts=5
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker info > /dev/null 2>&1; then
            log "SUCCESS" "Docker is running properly"
            break
        else
            log "WARNING" "Docker not ready (attempt $attempt/$max_attempts), trying to start service..."
            
            # Try different approaches to start Docker
            if systemctl is-active docker >/dev/null 2>&1; then
                log "INFO" "Docker service is active, checking daemon..."
                systemctl restart docker
            elif systemctl start docker 2>/dev/null; then
                log "INFO" "Started Docker via systemctl"
            elif service docker start 2>/dev/null; then
                log "INFO" "Started Docker via service command"
            else
                log "WARNING" "Could not start Docker service"
            fi
            
            sleep 15
            ((attempt++))
        fi
    done
    
    # Final verification
    if ! docker info > /dev/null 2>&1; then
        log "ERROR" "Docker installation verification failed after $max_attempts attempts"
        log "INFO" "Checking Docker status and logs..."
        systemctl status docker --no-pager || service docker status || true
        journalctl -u docker --no-pager -n 20 || true
        return 1
    fi
    
    # Test basic Docker functionality
    log "INFO" "Testing Docker functionality..."
    if docker run --rm hello-world >/dev/null 2>&1; then
        log "SUCCESS" "Docker functionality test passed"
    else
        log "WARNING" "Docker functionality test failed, but Docker is running"
    fi
    
    # Verify Docker Compose (check for both v1 and v2)
    if command_exists docker-compose || docker compose version > /dev/null 2>&1; then
        log "SUCCESS" "Docker and Docker Compose installed successfully"
        return 0
    else
        log "ERROR" "Docker Compose installation verification failed"
        return 1
    fi
}

# Fast Docker installation using convenience script
install_docker_fast() {
    if curl -fsSL https://get.docker.com -o /tmp/get-docker.sh 2>/dev/null; then
        log "INFO" "Running Docker convenience script..."
        
        # Run the script and capture both success and any issues
        if timeout 300 sh /tmp/get-docker.sh 2>&1 | tee /tmp/docker-install.log; then
            rm -f /tmp/get-docker.sh
            
            # Check if Docker binary is installed
            if ! command_exists docker; then
                log "ERROR" "Docker binary not found after convenience script"
                return 1
            fi
            
            # Check if Docker daemon is running
            if docker info > /dev/null 2>&1; then
                log "SUCCESS" "Docker is already running"
                return 0
            fi
            
            # Try to start Docker service using multiple methods
            log "INFO" "Docker not running, attempting to start service..."
            
            # Method 1: systemctl (most modern systems)
            if systemctl list-unit-files | grep -q docker.service; then
                log "INFO" "Found docker.service, attempting to start with systemctl..."
                if systemctl enable docker --now 2>/dev/null; then
                    log "SUCCESS" "Docker service started with systemctl"
                    sleep 3
                    if docker info > /dev/null 2>&1; then
                        return 0
                    fi
                fi
            fi
            
            # Method 2: service command (older systems)
            if command_exists service; then
                log "INFO" "Attempting to start with service command..."
                if service docker start 2>/dev/null; then
                    log "SUCCESS" "Docker service started with service command"
                    sleep 3
                    if docker info > /dev/null 2>&1; then
                        return 0
                    fi
                fi
            fi
            
            # Method 3: Try to start dockerd directly
            if command_exists dockerd; then
                log "INFO" "Attempting to start dockerd directly..."
                if dockerd > /dev/null 2>&1 & then
                    sleep 5
                    if docker info > /dev/null 2>&1; then
                        log "SUCCESS" "Docker daemon started directly"
                        return 0
                    fi
                fi
            fi
            
            # If we get here, Docker installed but won't start
            log "ERROR" "Docker installed but failed to start. Check /tmp/docker-install.log"
            return 1
        else
            rm -f /tmp/get-docker.sh
            log "ERROR" "Docker convenience script failed. Check /tmp/docker-install.log"
            return 1
        fi
    else
        log "ERROR" "Failed to download Docker convenience script"
        return 1
    fi
}

# Manual Docker installation (fallback method)
install_docker_manual() {
    log "INFO" "Installing Docker using manual method..."
    
    # Create keyring directory if it doesn't exist
    mkdir -p /usr/share/keyrings
    
    # Add Docker's official GPG key with error handling
    log "INFO" "Adding Docker GPG key..."
    if ! curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg; then
        log "ERROR" "Failed to add Docker GPG key"
        return 1
    fi
    
    # Add Docker repository
    log "INFO" "Adding Docker repository..."
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update package lists
    log "INFO" "Updating package lists with Docker repository..."
    if ! apt update; then
        log "ERROR" "Failed to update package lists"
        return 1
    fi
    
    # Install Docker with timeout and error handling
    log "INFO" "Installing Docker packages (this may take several minutes)..."
    if ! timeout 600 apt install -y docker-ce docker-ce-cli containerd.io; then
        log "ERROR" "Docker installation failed or timed out"
        return 1
    fi
    
    # Start and enable Docker with error handling
    log "INFO" "Starting Docker service..."
    if ! systemctl start docker; then
        log "ERROR" "Failed to start Docker service"
        return 1
    fi
    
    if ! systemctl enable docker; then
        log "WARNING" "Failed to enable Docker service at boot"
    fi
    
    # Verify Docker installation
    if ! docker --version; then
        log "ERROR" "Docker installation verification failed"
        return 1
    fi
    
    log "SUCCESS" "Docker installed: $(docker --version)"
    return 0
}

# Install Docker Compose
install_docker_compose() {
    if command_exists docker-compose; then
        log "INFO" "Docker Compose already installed: $(docker-compose --version)"
    else
        log "INFO" "Installing Docker Compose..."
        
        # Download Docker Compose with error handling and timeout
        local compose_url
        compose_url="https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)"
        log "INFO" "Downloading Docker Compose from: $compose_url"
        
        if ! timeout 300 curl -L "$compose_url" -o /usr/local/bin/docker-compose; then
            log "ERROR" "Failed to download Docker Compose"
            return 1
        fi
        
        chmod +x /usr/local/bin/docker-compose
        
        # Verify Docker Compose installation
        if ! docker-compose --version; then
            log "ERROR" "Docker Compose installation verification failed"
            return 1
        fi
        
        log "SUCCESS" "Docker Compose installed: $(docker-compose --version)"
    fi
    
    # Note: User addition to docker group is handled in main install_docker function
}

# Start Docker services
start_docker_services() {
    show_progress 13 15 "Starting N8N services"
    
    cd "$N8N_DIR" || exit
    
    # Ensure clean state
    log "INFO" "Ensuring clean Docker state..."
    docker-compose down -v >/dev/null 2>&1 || true
    docker system prune -f >/dev/null 2>&1 || true
    
    # Start N8N services
    log "INFO" "Starting N8N and PostgreSQL containers..."
    log "INFO" "This may take several minutes to download images..."
    
    # Start PostgreSQL first and wait for it
    log "INFO" "Starting PostgreSQL container..."
    if ! timeout 300 docker-compose up -d postgres; then
        log "ERROR" "Failed to start PostgreSQL container"
        return 1
    fi
    
    # Wait for PostgreSQL to be healthy
    log "INFO" "Waiting for PostgreSQL to be ready..."
    local max_attempts=60
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker-compose exec -T postgres pg_isready -U n8n >/dev/null 2>&1; then
            log "SUCCESS" "PostgreSQL is ready"
            break
        fi
        
        log "INFO" "PostgreSQL health check $attempt/$max_attempts..."
        sleep 5
        ((attempt++))
    done
    
    if [ $attempt -gt $max_attempts ]; then
        log "ERROR" "PostgreSQL failed to become ready"
        docker-compose logs postgres
        return 1
    fi
    
    # Now start N8N
    log "INFO" "Starting N8N container..."
    if ! timeout 300 docker-compose up -d n8n; then
        log "ERROR" "Failed to start N8N container"
        return 1
    fi
    
    # Wait for N8N to be ready
    log "INFO" "Waiting for N8N to be ready..."
    attempt=1
    max_attempts=30
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s http://localhost:5678 >/dev/null 2>&1; then
            log "SUCCESS" "N8N is ready"
            break
        fi
        
        log "INFO" "N8N health check $attempt/$max_attempts..."
        sleep 5
        ((attempt++))
    done
    
    if [ $attempt -gt $max_attempts ]; then
        log "WARNING" "N8N may still be starting up"
        log "INFO" "Checking N8N logs..."
        docker-compose logs --tail=10 n8n || true
    fi
    
    # Final status check
    log "INFO" "Final container status:"
    docker-compose ps
    
    log "SUCCESS" "Docker services startup completed"
}