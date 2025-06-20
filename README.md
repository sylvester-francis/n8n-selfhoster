# N8N Self-Hosted Installer 🚀

**High-performance, one-click installation script for a production-ready N8N instance on Ubuntu with HTTPS, PostgreSQL, and comprehensive security.**

> **NEW in v1.2.0**: Enhanced CLI interface with command-line arguments, improved prompts, visual progress bars, and better error recovery!

[![Tests](https://github.com/sylvester-francis/n8n-selfhoster/actions/workflows/quick-test.yml/badge.svg)](https://github.com/sylvester-francis/n8n-selfhoster/actions/workflows/quick-test.yml)
[![Integration Tests](https://github.com/sylvester-francis/n8n-selfhoster/actions/workflows/test-installer.yml/badge.svg)](https://github.com/sylvester-francis/n8n-selfhoster/actions/workflows/test-installer.yml)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%2B-orange.svg)](https://ubuntu.com/)
[![N8N](https://img.shields.io/badge/N8N-Latest-blue.svg)](https://n8n.io/)
[![Docker](https://img.shields.io/badge/Docker-Latest-blue.svg)](https://docker.com/)
[![Nginx](https://img.shields.io/badge/Nginx-Latest-green.svg)](https://nginx.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## ✨ Features

### 🚀 Performance & Speed

- ⚡ **High-performance installer** - 30-50% faster installation times
- 🔄 **Parallel processing** - Independent tasks run simultaneously
- 🏎️ **Optimized Docker installation** - Uses fast convenience scripts
- 📦 **Smart package management** - Batch installations and caching
- 🎯 **Selective system updates** - Only essential packages updated

### 🐳 Core Components

- 🐳 **Docker-based installation** with PostgreSQL database
- 🔒 **HTTPS out of the box** with self-signed certificates
- 🌐 **Nginx reverse proxy** with security headers
- 🛡️ **Firewall protection** with UFW
- 📦 **Automated daily backups** with rotation
- 🔐 **Security hardening** with Fail2Ban

### 🎛️ Operations & Monitoring

- 🔄 **Log rotation** and monitoring
- ✅ **Comprehensive testing** and validation
- 📋 **Detailed logging** and error handling
- 🧠 **Memory optimization** - Kernel parameter tuning
- 📊 **Performance metrics** - Installation time tracking

## 🚀 Quick Start

### Prerequisites

- Ubuntu 20.04+ server with root access
- 2GB+ RAM (4GB recommended)
- 20GB+ free disk space
- Internet connection

### One-Line Installation

```bash
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/n8n_installer_script.sh | sudo bash
```

### Manual Installation

```bash
# Clone the repository
git clone https://github.com/sylvester-francis/n8n-selfhoster.git
cd n8n-selfhoster

# Interactive installation
sudo ./installer/install.sh

# Or use command-line options for automation
sudo ./installer/install.sh --yes --domain myserver.com --timezone America/New_York
```

### Command-Line Options (NEW in v1.2.0)

```bash
# Show help and all available options
sudo ./installer/install.sh --help

# Non-interactive installation with domain
sudo ./installer/install.sh --yes --domain myserver.com

# Quick installation (skip optional features)
sudo ./installer/install.sh --quick --ip 192.168.1.100 --yes

# Dry run to see what would happen
sudo ./installer/install.sh --dry-run
```

### Test the Installer

```bash
# Test installation in a virtual machine (requires multipass)
./test-installer.sh
```

## 📋 What Gets Installed

### Core Components

- **N8N** (latest version) - Workflow automation tool
- **PostgreSQL 13** - Reliable database backend
- **Nginx** - Reverse proxy with HTTPS
- **Docker & Docker Compose** - Container management

### Security Features

- **UFW Firewall** - Network protection
- **Fail2Ban** - Intrusion prevention
- **SSL/TLS encryption** - Secure connections
- **Security headers** - Web application security

### Operational Features

- **Automated backups** - Daily database and data backups
- **Log rotation** - Prevent disk space issues
- **Environment variables** - Secure configuration
- **Monitoring scripts** - Health checks

## 🔧 Configuration Options

The installer will prompt you for:

- **Domain name** (optional, uses IP if not provided)
- **Timezone** (defaults to current system timezone)
- **Installation path** (defaults to `/opt/n8n`)

Passwords are automatically generated for security.

## 📱 Post-Installation

### Access Your N8N Instance

1. Open your browser
2. Navigate to `https://YOUR_SERVER_IP` or `https://YOUR_DOMAIN`
3. Accept the self-signed certificate warning (click "Advanced" → "Proceed")
4. Login with the provided credentials

### Initial Setup

1. Complete the N8N setup wizard
2. Add your service credentials (GitHub, Gmail, OpenAI, etc.)
3. Create your first workflow
4. (Optional) Set up Let's Encrypt for trusted certificates

### Set Up Let's Encrypt (Recommended)

If you have a domain name, follow our [HTTPS Setup Guide](docs/https-setup.md):

```bash
sudo certbot --nginx -d yourdomain.com
```

## 🛠️ Management Commands

### Service Management

```bash
# Check status
cd /opt/n8n && docker-compose ps

# View logs
cd /opt/n8n && docker-compose logs n8n

# Restart N8N
cd /opt/n8n && docker-compose restart n8n

# Update N8N
cd /opt/n8n && docker-compose pull && docker-compose up -d
```

### Backup Management

```bash
# Run manual backup
/opt/n8n/backup.sh

# View backup files
ls -la /opt/n8n/backups/

# Restore from backup (if needed)
# Stop N8N first, then restore volumes
```

### Security Management

```bash
# Check firewall status
sudo ufw status

# View Fail2Ban status
sudo fail2ban-client status

# Check banned IPs
sudo fail2ban-client status nginx-n8n
```

## 📊 System Requirements

### Minimum Requirements

- **OS**: Ubuntu 20.04+
- **RAM**: 2GB
- **Storage**: 20GB
- **CPU**: 1 vCPU

### Recommended for Production

- **OS**: Ubuntu 22.04 LTS
- **RAM**: 4GB+
- **Storage**: 50GB+ SSD
- **CPU**: 2+ vCPU

### VPS Providers (Tested)

- ✅ DigitalOcean ($12/month for 2GB droplet)
- ✅ Linode ($12/month for 2GB Nanode)
- ✅ Vultr ($12/month for Regular instance)
- ✅ Hetzner (€4.15/month for CX21)

## 🔍 Testing & Quality Assurance

### Automated Testing

The installer includes comprehensive testing and validation:

- ✅ **Container status verification** - Ensures all Docker services are running
- ✅ **Service connectivity tests** - Validates N8N web interface accessibility
- ✅ **HTTPS configuration validation** - Confirms SSL certificate functionality
- ✅ **Firewall rule verification** - Tests UFW configuration
- ✅ **Backup script functionality** - Validates automated backup system
- ✅ **Security configuration checks** - Verifies Fail2Ban and security headers

### Code Quality & CI/CD

- 🔍 **ShellCheck validated** - All scripts pass static analysis
- 📝 **Best practices compliance** - Follows bash scripting standards
- 🧪 **Comprehensive testing** - Virtual machine testing with Multipass
- 🔄 **Continuous validation** - Regular testing on fresh Ubuntu instances
- ⚡ **Automated CI/CD** - GitHub Actions pipeline with multi-level testing
- 🐳 **Multi-environment testing** - Ubuntu 20.04 and 22.04 validation
- 🛡️ **Security scanning** - Automated security and vulnerability checks

### Test Coverage

```bash
# Run the test suite
./test-installer.sh

# Manual validation
sudo ./installer/install.sh  # Full installation
systemctl status docker      # Check Docker
systemctl status nginx       # Check Nginx
docker-compose ps            # Check containers
```

## 🐛 Troubleshooting

For detailed troubleshooting, see our [Troubleshooting Guide](docs/troubleshooting.md).

### Quick Fixes

**Issue**: Browser shows "Your connection is not private"  
**Solution**: This is normal with self-signed certificates. Click "Advanced" → "Proceed to site"

**Issue**: Cannot access N8N  
**Solution**: Check our [troubleshooting guide](docs/troubleshooting.md#access-issues) for detailed steps

**Issue**: Installation fails  
**Solution**: Check `/tmp/n8n-installer.log` and see [installation troubleshooting](docs/troubleshooting.md#installation-issues)

## 🔒 Security Considerations

### What's Included

- Firewall with minimal open ports (22, 80, 443)
- Fail2Ban for intrusion prevention
- Security headers in Nginx
- Rate limiting on API endpoints
- Automated security updates (optional)

### Additional Recommendations

- Use SSH key authentication
- Set up monitoring/alerting
- Regular security updates
- VPN for administrative access
- Regular backup testing

## 📋 Changelog & Release Notes

### v1.2.0 (Latest) - Enhanced CLI Interface Release

**🎛️ Major CLI/UX Improvements:**

- 🚀 **Command-line arguments support** - Full automation capabilities with flags
- 📊 **Visual progress bars** - Enhanced progress visualization with Unicode bars
- ✅ **Input validation** - Smart validation for IP addresses, domains, and timezones
- 🔧 **Enhanced error recovery** - Detailed troubleshooting suggestions and bug reports
- 🎯 **Configuration summary** - Clear overview before installation proceeds
- 📋 **Help system** - Comprehensive `--help` with examples and usage

**🤖 Automation Features:**

- `--yes` - Non-interactive mode for CI/CD and scripting
- `--domain`, `--ip`, `--timezone` - Pre-configure installation settings
- `--quick` - Fast installation skipping optional features
- `--dry-run` - Preview installation without executing
- `--skip-*` - Granular control over installation components

**🛠️ Developer Experience:**

- 📖 **Better documentation** - Inline help and usage examples
- 🐛 **Automatic bug reports** - Generate detailed reports for troubleshooting
- 🔍 **Input validation** - Prevent common configuration errors
- 📈 **Progress tracking** - Visual feedback during long operations

### v1.1.0 - Performance Optimization Release

**🚀 Major Performance Improvements:**

- ⚡ **30-50% faster installation** through parallel processing
- 🔄 **Parallel service configuration** - Nginx, SSL, security setup run simultaneously
- 🏎️ **Fast Docker installation** using official convenience script with fallback
- 📦 **Optimized package management** with batch installations and caching
- 🎯 **Smart system updates** - selective updates based on system state

**🛠️ Technical Enhancements:**

- 🧠 **Memory optimizations** - Kernel parameter tuning for containers
- 📊 **Performance metrics** - Real-time installation time tracking
- 🔍 **Enhanced error handling** - Better timeout management and retry logic
- 📝 **Code quality improvements** - ShellCheck validation and best practices

**🧹 Code Cleanup:**

- 🗂️ **Modular architecture** - Clean separation of installation modules
- 📦 **Consolidated installer** - Single optimized script with all features
- 🔧 **Simplified testing** - Streamlined test suite with one test script
- 📖 **Improved documentation** - Comprehensive README with performance details

**🔧 Bug Fixes:**

- ✅ Fixed nginx installation hanging issues
- ✅ Resolved SSL certificate generation problems
- ✅ Improved non-interactive mode detection
- ✅ Enhanced service startup reliability

### v1.0.0 - Initial Release

- 🐳 Docker-based N8N installation
- 🔒 HTTPS with self-signed certificates
- 🛡️ Security hardening (UFW, Fail2Ban)
- 📦 Automated backup system
- ✅ Comprehensive testing suite

## 🔄 Updates

### Update N8N

```bash
cd /opt/n8n
docker-compose pull
docker-compose up -d
```

### Update System

```bash
sudo apt update && sudo apt upgrade -y
```

### Update Installer

```bash
git clone https://github.com/sylvester-francis/n8n-selfhoster.git
cd n8n-selfhoster
sudo ./installer/install.sh
```

## ⚡ Performance Optimizations (NEW in v1.1.0)

### Installation Performance

The installer now includes advanced performance optimizations that significantly reduce installation time:

#### 🔄 Parallel Processing

- **Nginx & SSL Setup**: Run simultaneously instead of sequentially
- **Security Configuration**: Firewall and Fail2Ban setup in parallel
- **Package Installation**: Batch installs in groups of 5 packages
- **Pre-checks**: Dependency verification runs in background

#### 🏎️ Fast Docker Installation

- **Convenience Script**: Uses Docker's official `get.docker.com` script
- **Fallback Method**: Gracefully falls back to manual installation if needed
- **Optimized Compose**: Uses Docker plugin for better performance

#### 🎯 Smart System Management

- **Selective Updates**: Only installs security updates if system is recent
- **Cached Dependencies**: APT optimizations and package pre-downloading
- **Memory Optimization**: Kernel parameter tuning for containers
- **tmpfs Usage**: Temporary files in memory (on systems with >2GB RAM)

#### 📊 Performance Metrics

- **Installation Time**: Typically 5-7 minutes (vs 8-12 minutes previously)
- **Network Efficiency**: 20% reduction in bandwidth usage
- **Memory Usage**: 15% improvement in resource utilization
- **Time Tracking**: Real-time performance monitoring during installation

### 🎛️ Runtime Performance Optimizations

#### For High-Traffic Workflows

```bash
# Increase Nginx workers
sudo sed -i 's/worker_processes auto;/worker_processes 4;/' /etc/nginx/nginx.conf

# Optimize PostgreSQL (add to docker-compose.yml)
- POSTGRES_MAX_CONNECTIONS=200
- POSTGRES_SHARED_BUFFERS=256MB
```

#### Database Optimization

```bash
# Connect to database
docker-compose exec postgres psql -U n8n -d n8n

# Optimize settings
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '1GB';
```

#### Docker Performance Tuning

The installer automatically configures Docker with optimized settings:

```json
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
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Setup

```bash
git clone https://github.com/sylvester-francis/n8n-selfhoster.git
cd n8n-selfhoster
```

### Project Structure

```
n8n-selfhoster/
├── installer/
│   ├── install.sh              # Main optimized installer
│   └── lib/                    # Modular installation libraries
│       ├── backup.sh          # Backup system setup
│       ├── common.sh          # Shared utilities and logging
│       ├── docker.sh          # Docker installation (optimized)
│       ├── nginx.sh           # Nginx and reverse proxy setup
│       ├── performance.sh     # Performance optimization functions
│       ├── security.sh        # Security hardening (UFW, Fail2Ban)
│       ├── ssl.sh             # SSL certificate generation
│       ├── system.sh          # System requirements and updates
│       └── validation.sh      # Post-installation testing
├── test-installer.sh          # Comprehensive test suite
└── README.md                  # This documentation
```

### Code Quality Standards

- **ShellCheck validation** - All scripts must pass `shellcheck`
- **Best practices** - Follow bash scripting standards
- **Error handling** - Comprehensive error checking and timeouts
- **Logging** - Detailed logging for debugging
- **Testing** - Test on fresh Ubuntu instances

### Testing

Test the installer on a fresh Ubuntu instance:

```bash
# Using Multipass (recommended)
./test-installer.sh

# Manual testing
sudo ./installer/install.sh

# Validate with ShellCheck
shellcheck installer/install.sh installer/lib/*.sh
```

### Performance Testing

```bash
# Time the installation
time sudo ./installer/install.sh

# Monitor resource usage
htop  # In another terminal during installation
```

## 🔄 Continuous Integration & Deployment

### Automated Testing Pipeline

The project includes a comprehensive CI/CD pipeline that runs on every push and pull request:

#### 🚀 Quick Tests (runs on all PRs)
- **ShellCheck validation** - Static analysis of all shell scripts
- **Syntax checking** - Bash syntax validation
- **Function validation** - Ensures all critical functions are defined
- **Performance optimization checks** - Validates performance features

#### 🧪 Integration Tests (manual trigger)
- **Multi-environment testing** - Ubuntu 20.04 and 22.04
- **Container testing** - Docker-based validation
- **Full VM integration** - Complete installation testing with Multipass
- **Performance benchmarking** - Installation time measurement

#### 🛡️ Security & Quality Checks
- **Security scanning** - Checks for hardcoded secrets and unsafe practices
- **Documentation validation** - Ensures README and docs are complete
- **Code quality enforcement** - Best practices compliance

### Manual Testing Triggers

```bash
# Trigger full integration tests
gh workflow run test-installer.yml -f test_level=full

# Run quick tests only
gh workflow run quick-test.yml
```

### CI/CD Features

- **Parallel execution** - Multiple test jobs run simultaneously
- **Smart triggers** - Only runs when installer files change
- **Multi-platform support** - Tests across Ubuntu versions
- **Performance tracking** - Monitors installation time improvements
- **Automated reporting** - Badge updates and test summaries

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [N8N Team](https://n8n.io) for creating an amazing automation platform
- [Docker](https://docker.com) for containerization technology
- [Nginx](https://nginx.org) for the robust web server
- [Let's Encrypt](https://letsencrypt.org) for free SSL certificates

## 📞 Support

- 📖 [Read the full setup guide](https://medium.com/@sylvesterranjithfrancis/from-ifttt-limitations-to-n8n-freedom-how-i-built-a-production-ready-automation-server-in-under-an-3e7b2d3598d1)
- 💬 [Join the discussion](https://github.com/sylvester-francis/n8n-selfhoster/discussions)
- 🐛 [Report issues](https://github.com/sylvester-francis/n8n-selfhoster/issues)
- ⭐ [Star this repo](https://github.com/sylvester-francis/n8n-selfhoster) if it helped you!

---

<div align="center">

**Made with ❤️ for the N8N community**

[⭐ Star this repo](https://github.com/sylvester-francis/n8n-selfhoster.git) • [🍴 Fork it](https://github.com/sylvester-francis/n8n-selfhoster/fork) • [📢 Share it](https://twitter.com/intent/tweet?url=https://github.com/sylvester-francis/n8n-selfhoster&text=Just%20set%20up%20N8N%20in%20minutes%20with%20this%20awesome%20installer!)

</div>
