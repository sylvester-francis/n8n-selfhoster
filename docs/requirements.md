# System Requirements

Complete system requirements and compatibility information for the N8N Self-Hosted Installer.

## 📋 Minimum Requirements

### Operating System
- **Ubuntu 20.04 LTS** or newer
- **Debian 11** or newer
- **CentOS 8** or newer (experimental)
- **RHEL 8** or newer (experimental)

**Recommended**: Ubuntu 22.04 LTS for best compatibility and support.

### Hardware Requirements

#### Minimum Configuration
- **CPU**: 1 vCore
- **RAM**: 2GB
- **Storage**: 10GB free disk space
- **Network**: Stable internet connection

#### Recommended Configuration
- **CPU**: 2+ vCores
- **RAM**: 4GB+
- **Storage**: 20GB+ SSD storage
- **Network**: Broadband internet connection

#### Production Configuration
- **CPU**: 4+ vCores
- **RAM**: 8GB+
- **Storage**: 50GB+ SSD storage
- **Network**: High-speed internet with low latency

### Network Requirements

#### Required Ports
| Port | Service | Direction | Purpose |
|------|---------|-----------|---------|
| 22 | SSH | Inbound | Remote administration |
| 80 | HTTP | Inbound | HTTP redirect to HTTPS |
| 443 | HTTPS | Inbound | N8N web interface |
| 53 | DNS | Outbound | Domain resolution |
| 80/443 | HTTP/HTTPS | Outbound | Package downloads, webhooks |

#### Optional Ports
| Port | Service | Purpose |
|------|---------|---------|
| 5432 | PostgreSQL | Database access (if external) |
| 25/587/465 | SMTP | Email notifications |

## 🌐 Software Dependencies

### Automatically Installed
The installer automatically handles these dependencies:
- **Docker Engine** (latest stable)
- **Docker Compose** (v2.x)
- **Nginx** (latest stable)
- **UFW Firewall**
- **Fail2Ban**
- **curl, wget, git**
- **OpenSSL**

### Pre-installed Requirements
- **sudo privileges** for the installing user
- **systemd** (standard on supported distributions)
- **bash** shell (version 4.0+)

### Optional Components
- **Task runner** (installed separately for advanced management)
- **certbot** (for Let's Encrypt certificates)
- **htop** (for system monitoring)

## 🖥️ Virtualization Support

### Supported Platforms

#### Cloud Providers
- ✅ **AWS EC2** (all instance types)
- ✅ **Google Cloud Platform** (all machine types)
- ✅ **Microsoft Azure** (all VM sizes)
- ✅ **DigitalOcean Droplets**
- ✅ **Linode**
- ✅ **Vultr**
- ✅ **Hetzner Cloud**

#### Virtualization Platforms
- ✅ **Proxmox VE** (with optimizations)
- ✅ **VMware vSphere/ESXi**
- ✅ **VirtualBox**
- ✅ **QEMU/KVM**
- ✅ **Hyper-V**
- ✅ **Docker** (using Docker-in-Docker)

#### Container Platforms
- ✅ **LXC/LXD containers**
- ⚠️ **Docker containers** (requires privileged mode)
- ❌ **Kubernetes pods** (not supported)

### Proxmox-Specific Requirements

For Proxmox installations:
- **Container Type**: VM (not LXC container)
- **CPU Type**: host or kvm64
- **Memory**: Minimum 2GB, no ballooning
- **Storage**: VirtIO SCSI controller recommended
- **Network**: VirtIO network adapter

## 🔒 Security Requirements

### User Permissions
- User must have **sudo privileges**
- Root access **not required** (installer uses sudo)
- SSH access with **key-based authentication** recommended

### Network Security
- **Firewall-friendly** installation (uses standard ports)
- **No special network configuration** required
- **Behind NAT/proxy** supported
- **CloudFlare proxy** compatible

### SSL/TLS Requirements
- **Automatic certificate generation** (self-signed or Let's Encrypt)
- **Domain name** required for Let's Encrypt certificates
- **DNS control** needed for domain validation

## 📊 Performance Considerations

### Resource Usage

#### Idle System
- **CPU**: 5-10% average usage
- **RAM**: 1.5-2GB used
- **Disk I/O**: Minimal
- **Network**: <1MB/hour

#### Active Workflows
- **CPU**: Varies by workflow complexity
- **RAM**: +500MB per concurrent workflow
- **Disk I/O**: Database writes, log files
- **Network**: Depends on external API calls

#### Scaling Guidelines
| Concurrent Workflows | CPU | RAM | Storage |
|---------------------|-----|-----|---------|
| 1-5 | 1 vCore | 2GB | 10GB |
| 5-20 | 2 vCores | 4GB | 20GB |
| 20-50 | 4 vCores | 8GB | 50GB |
| 50+ | 8+ vCores | 16GB+ | 100GB+ |

## 🧪 Compatibility Testing

### Pre-Installation Check

Run compatibility check:
```bash
# Download and run compatibility checker
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/check-compatibility.sh | bash
```

This checks:
- ✅ Operating system compatibility
- ✅ Hardware resources
- ✅ Network connectivity
- ✅ Required ports availability
- ✅ Sudo privileges
- ✅ Disk space

### Manual Verification

```bash
# Check OS version
lsb_release -a

# Check available memory
free -h

# Check disk space
df -h

# Check network connectivity
ping -c 4 google.com

# Check if ports are available
sudo netstat -tlnp | grep -E ':(80|443|22)\s'

# Check sudo privileges
sudo echo "Sudo access confirmed"
```

## 🌍 Geographic Considerations

### Supported Regions
The installer works globally but performance may vary:

#### Optimal Performance
- **North America** (US, Canada)
- **Europe** (EU countries)
- **Asia-Pacific** (Singapore, Japan, Australia)

#### Good Performance
- **South America** (Brazil, Argentina)
- **Middle East** (UAE, Israel)
- **Asia** (India, Hong Kong)

#### Limited Performance
- **Africa** (limited infrastructure)
- **Remote regions** (satellite internet)

### Download Sources
- **Primary**: GitHub (global CDN)
- **Docker Images**: Docker Hub (global mirrors)
- **System Packages**: Regional Ubuntu/Debian mirrors

## 📱 Device Compatibility

### Management Access
N8N web interface supports:
- ✅ **Desktop browsers** (Chrome, Firefox, Safari, Edge)
- ✅ **Mobile browsers** (responsive design)
- ✅ **Tablet browsers** (iPad, Android tablets)

### Minimum Browser Requirements
- **Chrome**: Version 90+
- **Firefox**: Version 88+
- **Safari**: Version 14+
- **Edge**: Version 90+

## 🚨 Known Limitations

### Not Supported
- ❌ **Windows** (use WSL2 instead)
- ❌ **macOS** (development only with Docker Desktop)
- ❌ **ARM32** architectures (Raspberry Pi 3 and older)
- ❌ **OpenVZ** containers
- ❌ **Very restrictive networks** (corporate firewalls blocking Docker)

### Partial Support
- ⚠️ **ARM64** (Apple Silicon, Raspberry Pi 4) - experimental
- ⚠️ **CentOS/RHEL** - limited testing
- ⚠️ **Behind corporate proxy** - may require configuration

## 🔧 Resource Optimization

### For Low-Resource Systems

```bash
# Install with resource optimizations
sudo ./install.sh --quick --optimize-resources

# Or using Task
sudo task install -- --optimize-resources
```

This applies:
- Reduced Docker memory limits
- Optimized PostgreSQL configuration
- Disabled unnecessary services
- Compressed logging

### For High-Performance Systems

```bash
# Install with performance optimizations
sudo ./install.sh --optimize-performance

# Or using Task
sudo task system:optimize-performance
```

This applies:
- Increased worker processes
- Optimized database settings
- SSD-specific optimizations
- Enhanced caching

## 📋 Pre-Installation Checklist

Before installing, verify:

- [ ] ✅ Supported operating system
- [ ] ✅ Minimum hardware requirements met
- [ ] ✅ Sudo privileges available
- [ ] ✅ Internet connectivity working
- [ ] ✅ Required ports available (80, 443, 22)
- [ ] ✅ Sufficient disk space (10GB minimum)
- [ ] ✅ Domain name configured (for production)
- [ ] ✅ DNS pointing to server (for Let's Encrypt)
- [ ] ✅ Firewall allowing required ports
- [ ] ✅ No conflicting services on ports 80/443

## 🆘 Compatibility Issues

### Common Problems

**Insufficient Memory**:
```bash
# Check available memory
free -h
# Solution: Add swap or upgrade RAM
```

**Port Conflicts**:
```bash
# Check what's using port 80/443
sudo lsof -i :80
sudo lsof -i :443
# Solution: Stop conflicting services
```

**Docker Installation Issues**:
```bash
# Check if Docker can be installed
curl -fsSL https://get.docker.com | sudo sh --dry-run
```

**Network Restrictions**:
```bash
# Test Docker Hub connectivity
docker pull hello-world
```

### Getting Help

If compatibility issues persist:
1. Run the compatibility checker
2. Check the [Troubleshooting Guide](troubleshooting.md)
3. Create an issue on [GitHub](https://github.com/sylvester-francis/n8n-selfhoster/issues)

---

**Next Steps**:
- Review [Installation Guide](installation.md) for setup instructions
- Check [Quick Start](quick-start.md) for rapid deployment
- See [Troubleshooting](troubleshooting.md) for common issues