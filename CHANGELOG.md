# Changelog

All notable changes to the N8N Self-Hosted Installer project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2024-07-26

### 🎯 Major Features

#### Unified Entry Point Implementation

- **Added** single `install.sh` entry point that automatically detects environment
- **Added** smart environment detection with 6-point Proxmox identification system
- **Added** interactive installation type selection for Proxmox users
- **Added** `--type` parameter with options: `auto`, `standard`, `proxmox`
- **Removed** separate `install-proxmox.sh` script (functionality integrated)

#### Enhanced User Experience

- **Added** intelligent auto-detection that suggests optimal configurations
- **Added** interactive prompts explaining optimization choices
- **Added** visual installation menu with clear option descriptions
- **Added** smart defaults for non-interactive deployments
- **Improved** error handling with environment-specific troubleshooting

### 🖥️ Proxmox VM Support

- **Added** automatic Proxmox VE environment detection
- **Added** extended timeouts (Nginx: 60s → 300s, Validation: 5min → 15min)
- **Added** VM-optimized Docker configuration with specialized daemon.json
- **Added** memory-conscious N8N settings for constrained environments
- **Added** kernel parameter tuning for virtualized environments
- **Added** enhanced network buffer settings for VM networking
- **Added** automatic VM IP detection with multiple fallback methods

### 📖 Documentation Overhaul
- **Added** comprehensive command reference with 40+ practical commands
- **Restructured** README.md with enhanced Quick Start section
- **Added** detailed installation methods for different environments
- **Enhanced** Proxmox VM installation guide with unified approach
- **Added** troubleshooting section with unified installer guidance
- **Consolidated** all documentation into single source of truth
- **Removed** redundant documentation files (`docs/` directory)
- **Removed** `COMPLETE_DOCUMENTATION.md` (merged into README.md)

### 🔧 Technical Improvements
- **Enhanced** argument parsing with new `--type` parameter
- **Improved** installation flow with conditional optimization application
- **Added** environment-specific configuration logic
- **Maintained** modular architecture while improving entry point
- **Preserved** all existing functionality with better UX
- **Added** comprehensive function validation in CI/CD

### 🧪 Testing & CI/CD Updates
- **Updated** GitHub Actions workflows for unified installer structure
- **Added** `install.sh` to CI/CD trigger paths
- **Updated** all test scripts to use unified installer path
- **Fixed** script references throughout test suite
- **Enhanced** validation checks for new installer structure
- **Added** ShellCheck validation for main installer
- **Updated** VM integration tests with correct file transfers

### 🎛️ Command-Line Interface
```bash
# New installation types
--type auto      # Auto-detect environment (default)
--type standard  # Standard installation (no VM optimizations)  
--type proxmox   # Force Proxmox VM optimizations

# Usage examples
curl -fsSL URL | sudo bash                                    # Smart auto-detection
curl -fsSL URL | sudo bash -s -- --type proxmox --yes        # Force Proxmox
curl -fsSL URL | sudo bash -s -- --type standard --ip IP     # Standard mode
```

### 📁 File Structure Changes
```diff
+ install.sh                 # New unified entry point
- install-proxmox.sh         # Removed (integrated into main installer)
- docs/                      # Removed (consolidated into README.md)
- COMPLETE_DOCUMENTATION.md  # Removed (merged into README.md)
~ installer/lib/common.sh    # Enhanced with environment detection
~ installer/config/defaults.conf # Updated version to 1.3.0
~ tests/*.sh                 # Updated for unified installer paths
~ .github/workflows/*.yml    # Updated for new structure
```

### 🔄 Migration Guide
- **For basic users**: No changes needed - same command works with better detection
- **For Proxmox users**: Can continue using same command or add `--type proxmox` for explicit control
- **For automation**: Add `--type` parameter if specific installation type required
- **For CI/CD**: Update any direct file path references from `installer/install.sh` to `install.sh`

### 🐛 Bug Fixes
- **Fixed** CI/CD file transfer paths for VM testing
- **Fixed** script permission issues in GitHub Actions
- **Fixed** documentation references to old installer paths
- **Fixed** test script execution paths

### 🔒 Security
- **Maintained** all existing security features and hardening
- **Preserved** proper error handling with `set -euo pipefail`
- **Kept** all security validation in CI/CD pipeline

---

## [1.2.1] - 2024-01-15

### 🔧 Reliability & Quality Assurance Release
- **Enhanced** error handling with comprehensive recovery suggestions
- **Improved** installation validation with extended timeout support
- **Added** automated bug report generation for failed installations
- **Optimized** package installation with better dependency management
- **Strengthened** Docker installation reliability
- **Enhanced** SSL certificate generation with better error detection

### 🧪 Testing Infrastructure
- **Added** comprehensive testing suite with multiple environment support
- **Implemented** automated CI/CD pipeline with GitHub Actions
- **Added** performance benchmarking capabilities
- **Enhanced** security validation checks
- **Improved** installation verification with health checks

---

## [1.2.0] - 2023-12-10

### 🎯 Enhanced CLI Interface Release
- **Added** comprehensive command-line argument support
- **Implemented** non-interactive installation mode
- **Added** custom domain and IP configuration options
- **Enhanced** timezone configuration with validation
- **Added** quick installation mode for development
- **Implemented** dry-run capability for installation preview

### ⚡ Performance Optimizations
- **Optimized** Docker installation with fast convenience scripts
- **Implemented** parallel processing for independent tasks
- **Added** smart package management with caching
- **Enhanced** system update process with selective updating
- **Improved** overall installation speed by 30-50%

---

## [1.1.0] - 2023-11-20

### 🚀 Performance Optimization Release
- **Implemented** modular architecture with library separation
- **Added** performance monitoring and optimization functions
- **Enhanced** Docker configuration with production-ready settings
- **Improved** database performance with optimized PostgreSQL settings
- **Added** system resource optimization
- **Implemented** advanced caching strategies

### 🔒 Security Enhancements
- **Strengthened** firewall configuration with UFW
- **Enhanced** Fail2Ban integration for intrusion prevention
- **Improved** SSL/TLS configuration with modern ciphers
- **Added** security headers for Nginx
- **Implemented** automated security hardening

---

## [1.0.0] - 2023-10-15

### 🎉 Initial Release
- **Implemented** core N8N installation with Docker and Docker Compose
- **Added** PostgreSQL 13 database setup and configuration
- **Implemented** Nginx reverse proxy with HTTPS support
- **Added** self-signed SSL certificate generation
- **Implemented** automated backup system
- **Added** UFW firewall configuration
- **Implemented** basic system requirements checking
- **Added** installation validation and health checks

### 🐳 Core Components
- **N8N** (latest version) - Workflow automation tool
- **PostgreSQL 13** - Reliable database backend  
- **Nginx** - Reverse proxy with HTTPS
- **Docker & Docker Compose** - Container management
- **UFW Firewall** - Network protection
- **SSL/TLS encryption** - Secure connections
- **Automated backups** - Daily database and data backups

---

## References

- **Issue Tracker**: https://github.com/sylvester-francis/n8n-selfhoster/issues
- **Repository**: https://github.com/sylvester-francis/n8n-selfhoster
- **Documentation**: https://github.com/sylvester-francis/n8n-selfhoster/blob/main/README.md

---

*For upgrade instructions and breaking changes, please refer to the [Migration Guide](README.md#migration-guide) in the main documentation.*