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
    else
        # Try fast installation method first
        log "INFO" "Attempting fast Docker installation..."
        if install_docker_fast; then
            log "SUCCESS" "Docker installed via fast method"
        else
            log "WARNING" "Fast installation failed, using manual method"
            install_docker_manual
        fi
    fi
    
    # Install Docker Compose
    install_docker_compose
    
    # Verify installation
    if command_exists docker && command_exists docker-compose; then
        log "SUCCESS" "Docker and Docker Compose installed successfully"
        return 0
    else
        log "ERROR" "Docker installation verification failed"
        return 1
    fi
}

# Fast Docker installation using convenience script
install_docker_fast() {
    if curl -fsSL https://get.docker.com -o /tmp/get-docker.sh 2>/dev/null; then
        log "INFO" "Running Docker convenience script..."
        if timeout 300 sh /tmp/get-docker.sh > /dev/null 2>&1; then
            rm -f /tmp/get-docker.sh
            systemctl enable docker --now > /dev/null 2>&1
            return 0
        else
            rm -f /tmp/get-docker.sh
            return 1
        fi
    else
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
    
    # Add current user to docker group if not root
    if [ "$SUDO_USER" ]; then
        usermod -aG docker "$SUDO_USER"
        log "INFO" "Added $SUDO_USER to docker group"
    fi
    
    # Wait a moment for Docker to fully initialize
    log "INFO" "Waiting for Docker to initialize..."
    sleep 5
    
    # Test Docker functionality
    log "INFO" "Testing Docker installation..."
    if docker info > /dev/null 2>&1; then
        log "SUCCESS" "Docker is running properly"
    else
        log "WARNING" "Docker may not be fully ready yet"
    fi
}

# Start Docker services
start_docker_services() {
    show_progress 13 15 "Starting N8N services"
    
    cd "$N8N_DIR" || exit
    
    # Start N8N services
    log "INFO" "Starting N8N and PostgreSQL containers..."
    log "INFO" "This may take several minutes to download images..."
    
    # Use timeout command available in Ubuntu to prevent hanging
    if timeout 600 docker-compose up -d; then
        log "SUCCESS" "Docker containers started successfully"
    else
        log "ERROR" "Docker containers failed to start within 10 minutes"
        log "INFO" "Checking container status..."
        docker-compose ps || true
        log "INFO" "Checking logs..."
        docker-compose logs --tail=20 || true
        return 1
    fi
    
    # Wait for services to be ready with health checks
    log "INFO" "Waiting for services to initialize..."
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        log "INFO" "Health check attempt $attempt/$max_attempts..."
        
        # Check if containers are running
        if docker-compose ps | grep -q "Up"; then
            # Check if PostgreSQL is ready
            if docker-compose exec -T postgres pg_isready -U n8n >/dev/null 2>&1; then
                log "SUCCESS" "PostgreSQL is ready"
                break
            fi
        fi
        
        sleep 10
        ((attempt++))
    done
    
    if [ $attempt -gt $max_attempts ]; then
        log "WARNING" "Services may not be fully initialized yet"
        log "INFO" "Container status:"
        docker-compose ps || true
    fi
    
    log "SUCCESS" "Docker services startup completed"
}