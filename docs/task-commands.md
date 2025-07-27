# Task Commands Reference

Complete reference for all Task-based commands in the N8N Self-Hosted Installer. The Task system provides a modular, organized approach to managing your N8N installation.

## 🎯 Quick Reference

```bash
# Discovery
task --list                    # Show all available tasks
task help                      # Show help system
task --summary <task-name>     # Show task details

# Installation
task install                   # Smart installation with auto-detection
task quick                     # Quick installation for testing
task dry-run                   # Preview installation

# Status & Monitoring
task status                    # Overall system status
task test:health-check         # Health check validation

# Service Management
task n8n:restart              # Restart N8N services
task nginx:restart            # Restart Nginx
task docker:restart           # Restart Docker services

# Backup & Restore
task backup                   # Create backup
task backup:restore           # Restore from backup
```

## 📁 Command Categories

## 🏗️ Installation Commands

### Main Installation
| Command | Description | Usage |
|---------|-------------|--------|
| `task install` | Smart installation with environment auto-detection | `sudo task install` |
| `task quick` | Quick installation for testing/development | `sudo task quick` |
| `task standard` | Standard production installation | `sudo task standard` |
| `task proxmox` | Proxmox-optimized installation | `sudo task proxmox` |
| `task dry-run` | Preview installation without changes | `task dry-run` |
| `task help` | Show installation help and examples | `task help` |

### Installation Options
```bash
# Non-interactive installation
sudo task install -- --yes --domain example.com --email admin@example.com

# Quick testing setup
sudo task quick -- --ip 192.168.1.100 --yes

# Proxmox environment
sudo task proxmox -- --yes --domain n8n.local
```

## 🖥️ System Management

### System Module (`tasks/system.yml`)
| Command | Description | Requirements |
|---------|-------------|--------------|
| `task system:check-requirements` | Validate system prerequisites | None |
| `task system:update` | Update system packages | sudo |
| `task system:optimize-performance` | Apply performance optimizations | sudo |
| `task system:uninstall` | Complete N8N removal | sudo |

### Examples
```bash
# Check if system meets requirements
task system:check-requirements

# Update system packages
sudo task system:update

# Apply performance optimizations
sudo task system:optimize-performance

# Complete uninstall (WARNING: Removes all data)
sudo task system:uninstall
```

## 🐳 Docker Management

### Docker Module (`tasks/docker.yml`)
| Command | Description | Requirements |
|---------|-------------|--------------|
| `task docker:install` | Install Docker and Docker Compose | sudo |
| `task docker:start` | Start Docker services | sudo |
| `task docker:stop` | Stop Docker services | sudo |
| `task docker:restart` | Restart Docker services | sudo |
| `task docker:status` | Check Docker status | None |
| `task docker:clean` | Clean unused Docker resources | sudo |
| `task docker:logs` | Show Docker system logs | None |

### Examples
```bash
# Check Docker status
task docker:status

# Restart Docker services
sudo task docker:restart

# Clean up unused resources
sudo task docker:clean

# View Docker logs
task docker:logs
```

## 🎯 N8N Service Management

### N8N Module (`tasks/n8n.yml`)
| Command | Description | Requirements |
|---------|-------------|--------------|
| `task n8n:setup` | Setup N8N with PostgreSQL | sudo |
| `task n8n:start` | Start N8N services | sudo |
| `task n8n:stop` | Stop N8N services | sudo |
| `task n8n:restart` | Restart N8N services | sudo |
| `task n8n:status` | Check N8N service status | None |
| `task n8n:update` | Update N8N to latest version | sudo |
| `task n8n:logs` | Show N8N application logs | None |
| `task n8n:shell` | Access N8N container shell | sudo |
| `task n8n:db-shell` | Access PostgreSQL shell | sudo |
| `task n8n:reset` | Reset N8N installation (⚠️ WARNING) | sudo |

### Examples
```bash
# Check N8N status
task n8n:status

# Restart N8N
sudo task n8n:restart

# View N8N logs
task n8n:logs

# Access N8N container for debugging
sudo task n8n:shell

# Access PostgreSQL database
sudo task n8n:db-shell

# Update N8N to latest version
sudo task n8n:update
```

## 🌐 Nginx Web Server

### Nginx Module (`tasks/nginx.yml`)
| Command | Description | Requirements |
|---------|-------------|--------------|
| `task nginx:install` | Install and configure Nginx | sudo |
| `task nginx:configure` | Configure Nginx for N8N | sudo |
| `task nginx:ssl` | Configure SSL certificates | sudo |
| `task nginx:start` | Start Nginx service | sudo |
| `task nginx:stop` | Stop Nginx service | sudo |
| `task nginx:restart` | Restart Nginx service | sudo |
| `task nginx:reload` | Reload Nginx configuration | sudo |
| `task nginx:status` | Check Nginx status | None |
| `task nginx:logs` | Show Nginx access/error logs | None |

### Examples
```bash
# Check Nginx status
task nginx:status

# Restart Nginx
sudo task nginx:restart

# Reload configuration without restart
sudo task nginx:reload

# View Nginx logs
task nginx:logs

# Reconfigure SSL certificates
sudo task nginx:ssl
```

## 🔒 Security Management

### Security Module (`tasks/security.yml`)
| Command | Description | Requirements |
|---------|-------------|--------------|
| `task security:configure` | Configure system security | sudo |
| `task security:firewall` | Configure UFW firewall | sudo |
| `task security:fail2ban` | Configure Fail2Ban | sudo |
| `task security:ssh` | Secure SSH configuration | sudo |
| `task security:audit` | Run comprehensive security audit | sudo |
| `task security:status` | Show security status overview | None |
| `task security:logs` | Show security-related logs | None |

### Examples
```bash
# Check security status
task security:status

# Run security audit
sudo task security:audit

# Configure firewall rules
sudo task security:firewall

# View security logs
task security:logs

# Configure Fail2Ban
sudo task security:fail2ban
```

## 💾 Backup & Restore

### Backup Module (`tasks/backup.yml`)
| Command | Description | Requirements |
|---------|-------------|--------------|
| `task backup:setup` | Setup backup system | sudo |
| `task backup` | Create manual backup | sudo |
| `task backup:create-backup` | Create backup (explicit) | sudo |
| `task backup:restore` | Interactive restore process | sudo |
| `task backup:schedule` | Setup automatic backups | sudo |
| `task backup:list` | List available backups | None |
| `task backup:cleanup` | Clean up old backups | sudo |
| `task backup:verify` | Verify backup integrity | None |
| `task backup:status` | Show backup system status | None |

### Examples
```bash
# Create manual backup
sudo task backup

# List available backups
task backup:list

# Restore from backup (interactive)
sudo task backup:restore

# Verify backup integrity
task backup:verify

# Setup automatic backups
sudo task backup:schedule

# Check backup status
task backup:status
```

## 🖥️ Proxmox Integration

### Proxmox Module (`tasks/proxmox.yml`)
| Command | Description | Requirements |
|---------|-------------|--------------|
| `task proxmox:detect` | Detect Proxmox environment | None |
| `task proxmox:optimize` | Apply Proxmox optimizations | sudo |
| `task proxmox:install-guest-agent` | Install QEMU guest agent | sudo |
| `task proxmox:configure-vm` | Configure VM settings | sudo |
| `task proxmox:performance-tweaks` | Apply performance tweaks | sudo |
| `task proxmox:monitoring` | Configure VM monitoring | sudo |
| `task proxmox:status` | Show Proxmox VM status | None |
| `task proxmox:logs` | Show Proxmox-related logs | None |
| `task proxmox:reset-optimizations` | Reset Proxmox optimizations | sudo |

### Examples
```bash
# Detect if running in Proxmox
task proxmox:detect

# Apply Proxmox optimizations
sudo task proxmox:optimize

# Install QEMU guest agent
sudo task proxmox:install-guest-agent

# Check Proxmox VM status
task proxmox:status

# Configure monitoring
sudo task proxmox:monitoring
```

## 🧪 Testing & Validation

### Test Module (`tasks/test.yml`)
| Command | Description | Requirements |
|---------|-------------|--------------|
| `task test:lint` | Run shellcheck on scripts | None |
| `task test:syntax` | Check task definition syntax | None |
| `task test:functions` | Test task functionality | None |
| `task test:health-check` | N8N installation health check | None |
| `task test:connectivity` | Test N8N connectivity | None |
| `task test:performance` | Run performance tests | None |
| `task test:security` | Run security validation tests | None |
| `task test:quick` | Quick validation tests | None |
| `task test:comprehensive` | Full comprehensive test suite | None |
| `task test:status` | Overall system status | None |

### Examples
```bash
# Quick health check
task test:health-check

# Run quick validation
task test:quick

# Comprehensive testing
task test:comprehensive

# Check connectivity
task test:connectivity

# Security testing
task test:security

# Performance testing
task test:performance
```

## 🔄 Combined Workflows

### Common Task Combinations

```bash
# Complete status check
task status && task test:health-check

# Backup and verify
sudo task backup && task backup:verify

# Security audit and status
sudo task security:audit && task security:status

# Update and restart services
sudo task n8n:update && sudo task n8n:restart

# Performance optimization
sudo task system:optimize-performance && sudo task proxmox:optimize

# Complete system restart
sudo task docker:restart && sudo task nginx:restart
```

### Development Workflow

```bash
# Development testing workflow
task test:syntax          # Check task definitions
task test:lint            # Check code quality
task dry-run              # Preview changes
task test:quick           # Quick validation
```

### Maintenance Workflow

```bash
# Regular maintenance workflow
task status               # Check system status
sudo task backup          # Create backup
sudo task system:update   # Update packages
task test:health-check    # Verify health
task security:status      # Check security
```

## 🎛️ Advanced Usage

### Task Dependencies
Tasks automatically handle dependencies. For example:
- `task n8n:setup` automatically runs `docker:install` first
- `task nginx:configure` runs `nginx:install` if needed

### Silent Mode
All tasks run in silent mode by default for clean output. Override with:
```bash
task --verbose n8n:status
```

### Task Summaries
Get detailed information about any task:
```bash
task --summary n8n:setup
task --summary backup:restore
```

### Environment Variables
Tasks respect environment variables:
```bash
DOMAIN=example.com task install
IP_ADDRESS=192.168.1.100 task quick
```

## 🆘 Help & Troubleshooting

### Getting Help
```bash
task help                    # Main help system
task --list                  # All available tasks
task --summary <task>        # Detailed task info
```

### Common Issues

**Task not found error**
```bash
# Ensure you're in the project directory
pwd
ls Taskfile.yml

# Check available tasks
task --list
```

**Permission denied**
```bash
# Most management tasks require sudo
sudo task <command>
```

**Task fails with dependencies**
```bash
# Check task dependencies
task --summary <task-name>

# Run dependencies manually
task system:check-requirements
```

---

**Next Steps**: 
- Review [Service Management](service-management.md) for operational procedures
- Check [Troubleshooting](troubleshooting.md) for common issues
- See [Development Workflow](development.md) for contribution guidelines