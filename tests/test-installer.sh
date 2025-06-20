#!/bin/bash
set -e

echo "🚀 Testing N8N Installer..."

# Cleanup any existing VM
multipass delete n8n-test 2>/dev/null || true
multipass purge 2>/dev/null || true

# Create fresh VM
echo "📦 Creating Ubuntu VM..."
multipass launch 22.04 --name n8n-test --memory 4G --disk 30G --cpus 2

# Wait for VM to be ready
echo "⏳ Waiting for VM to initialize..."
sleep 30

# Get VM IP
echo "🔍 Getting VM IP address..."
if ! multipass info n8n-test > /tmp/vm_info.txt; then
    echo "❌ Failed to get VM information"
    exit 1
fi

if ! grep IPv4 /tmp/vm_info.txt > /tmp/vm_ip_line.txt; then
    echo "❌ Failed to find IPv4 information in VM info"
    exit 1
fi

VM_IP=$(awk '{print $2}' /tmp/vm_ip_line.txt) || {
    echo "❌ Failed to extract IP address"
    exit 1
}

if [[ -z "${VM_IP}" ]]; then
    echo "❌ VM IP address is empty"
    exit 1
fi

echo "🌐 VM IP: ${VM_IP}"
rm -f /tmp/vm_info.txt /tmp/vm_ip_line.txt

# Clone the repo inside the VM and copy our files
echo "📁 Setting up installation environment..."
multipass exec n8n-test -- bash -c "
    sudo apt update > /dev/null 2>&1 &&
    sudo apt install -y git > /dev/null 2>&1 &&
    git clone https://github.com/sylvester-francis/n8n-selfhoster.git
"

# Install Docker using the official convenience script
echo "🐳 Installing Docker using official convenience script..."
multipass exec n8n-test -- bash -c "
    # Remove any existing Docker installations
    sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
    
    # Install prerequisites
    sudo apt-get update
    sudo apt-get install -y curl
    
    # Download and run the Docker convenience script
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    
    # Add current user to docker group to run without sudo
    sudo usermod -aG docker $USER
    
    # Verify Docker installation
    sudo docker --version || echo "Docker installation failed"
    
    # Test Docker with a simple container
    sudo docker run --rm hello-world || echo "Docker test failed"
"

# Copy installer files
echo "📝 Copying installer files..."
multipass transfer installer/lib/backup.sh n8n-test:n8n-selfhoster/installer/lib/backup.sh
multipass transfer installer/lib/common.sh n8n-test:n8n-selfhoster/installer/lib/common.sh  
multipass transfer installer/lib/docker.sh n8n-test:n8n-selfhoster/installer/lib/docker.sh
multipass transfer installer/lib/nginx.sh n8n-test:n8n-selfhoster/installer/lib/nginx.sh
multipass transfer installer/lib/ssl.sh n8n-test:n8n-selfhoster/installer/lib/ssl.sh
multipass transfer installer/lib/system.sh n8n-test:n8n-selfhoster/installer/lib/system.sh
multipass transfer installer/lib/validation.sh n8n-test:n8n-selfhoster/installer/lib/validation.sh
multipass transfer installer/lib/performance.sh n8n-test:n8n-selfhoster/installer/lib/performance.sh
multipass transfer installer/install.sh n8n-test:n8n-selfhoster/installer/install.sh

# Record start time for performance measurement
START_TIME=$(date +%s)

# Run installer
echo "⚙️ Running N8N installer..."
multipass exec n8n-test -- bash -c "
    cd n8n-selfhoster && 
    sudo chmod +x installer/install.sh && 
    sudo ./installer/install.sh --yes --ip ${VM_IP}
"

# Calculate installation time
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

echo "✅ Installation complete in ${MINUTES}m ${SECONDS}s!"
echo "🌐 Access N8N at: https://${VM_IP}"
echo "🔑 Get credentials: multipass exec n8n-test -- sudo cat /opt/n8n/credentials.txt"
echo "🗑️  Cleanup when done: multipass delete n8n-test && multipass purge"