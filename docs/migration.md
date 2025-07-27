# Migration Guide: Shell Scripts to Task Architecture (v1.3.0 → v1.3.1)

This document provides comprehensive guidance for migrating from the shell script-based architecture (v1.3.0) to the new Task-based architecture (v1.3.1).

## 📋 Overview

Version 1.3.1 introduces a major architectural change from shell scripts to a modular Task-based system using [Taskfile](https://taskfile.dev). This migration provides:

- **Better Organization**: Commands are organized into logical modules
- **Improved Maintainability**: YAML-based configuration is easier to read and modify
- **Enhanced Testing**: Unified testing approach with task commands
- **Cleaner Interface**: Discoverable commands with built-in help
- **Streamlined CI/CD**: Simplified continuous integration with task-based validation

## 🚀 Quick Migration

### For End Users

No action required! The installation process remains the same:

```bash
# This still works exactly the same
curl -fsSL https://raw.githubusercontent.com/sylvester-francis/n8n-selfhoster/main/install.sh | sudo bash
```

### For Developers and Power Users

Install Task to access the new command interface:

```bash
# Install Task
curl -sL https://taskfile.dev/install.sh | sudo sh -s -- -b /usr/local/bin

# Clone/update repository
git clone https://github.com/sylvester-francis/n8n-selfhoster.git
cd n8n-selfhoster

# Explore new commands
task --list
task help
```

## 🔄 Command Migration Reference

### Installation Commands

| v1.3.0 (Shell) | v1.3.1 (Task) | Description |
|---|---|---|
| `sudo ./install.sh` | `task install` | Smart installation with auto-detection |
| `sudo ./install.sh --type proxmox` | `task proxmox` | Proxmox-optimized installation |
| `sudo ./install.sh --type standard` | `task standard` | Standard installation |
| `sudo ./install.sh --quick` | `task quick` | Quick installation for testing |
| `sudo ./install.sh --dry-run` | `task dry-run` | Preview installation |
| `sudo ./install.sh --help` | `task help` | Show help and examples |

### Management Commands

| v1.3.0 (Shell) | v1.3.1 (Task) | Description |
|---|---|---|
| `cd /opt/n8n && docker-compose ps` | `task status` | System status overview |
| `cd /opt/n8n && docker-compose ps` | `task n8n:status` | N8N-specific status |
| `cd /opt/n8n && docker-compose logs n8n` | `task logs` | N8N logs |
| `cd /opt/n8n && docker-compose logs n8n` | `task n8n:logs` | N8N logs (specific) |
| `cd /opt/n8n && docker-compose restart n8n` | `task n8n:restart` | Restart N8N services |
| `systemctl status nginx` | `task nginx:status` | Nginx status |
| `systemctl restart nginx` | `task nginx:restart` | Restart Nginx |

### Backup Commands

| v1.3.0 (Shell) | v1.3.1 (Task) | Description |
|---|---|---|
| `/opt/n8n/backup.sh` | `task backup` | Create manual backup |
| `ls -la /opt/n8n/backups/` | `task backup:list` | List available backups |
| *Manual process* | `task backup:restore` | Interactive restore |
| *Manual cron setup* | `task backup:schedule` | Setup automatic backups |
| *Manual verification* | `task backup:verify` | Verify backup integrity |

### Testing Commands

| v1.3.0 (Shell) | v1.3.1 (Task) | Description |
|---|---|---|
| `./tests/test-quick.sh` | `task test:quick` | Quick validation tests |
| `./tests/test-comprehensive.sh` | `task test:comprehensive` | Full test suite |
| `./tests/test-installer.sh` | `task test:functions` | Basic functionality tests |
| *Manual shellcheck* | `task test:lint` | Code quality checks |
| *Manual validation* | `task test:syntax` | Configuration syntax validation |
| *Manual health checks* | `task test:health-check` | System health validation |

### Security Commands

| v1.3.0 (Shell) | v1.3.1 (Task) | Description |
|---|---|---|
| `sudo ufw status` | `task security:status` | Security status overview |
| *Manual audit* | `task security:audit` | Comprehensive security audit |
| `sudo fail2ban-client status` | `task security:status` | Included in security status |
| *Manual log review* | `task security:logs` | Security-related logs |

## 📁 New Task Module Structure

The new architecture organizes functionality into 8 specialized modules:

### 1. **System Module** (`tasks/system.yml`)
```bash
task system:check-requirements    # Check system requirements
task system:update               # Update system packages
task system:optimize-performance # Apply performance optimizations
task system:uninstall           # Uninstall N8N completely
```

### 2. **Docker Module** (`tasks/docker.yml`)
```bash
task docker:install             # Install Docker and Docker Compose
task docker:start               # Start Docker services
task docker:stop                # Stop Docker services
task docker:status              # Check Docker status
task docker:clean               # Clean up Docker resources
task docker:logs                # Show Docker logs
```

### 3. **N8N Module** (`tasks/n8n.yml`)
```bash
task n8n:setup                  # Setup N8N with PostgreSQL
task n8n:start                  # Start N8N services
task n8n:stop                   # Stop N8N services
task n8n:restart                # Restart N8N services
task n8n:status                 # Check N8N status
task n8n:update                 # Update N8N to latest version
task n8n:logs                   # Show N8N logs
task n8n:shell                  # Access N8N container shell
task n8n:db-shell               # Access PostgreSQL shell
task n8n:reset                  # Reset N8N installation (WARNING)
```

### 4. **Nginx Module** (`tasks/nginx.yml`)
```bash
task nginx:install              # Install and configure Nginx
task nginx:configure            # Configure Nginx for N8N
task nginx:ssl                  # Configure SSL certificates
task nginx:start                # Start Nginx service
task nginx:stop                 # Stop Nginx service
task nginx:restart              # Restart Nginx service
task nginx:reload               # Reload Nginx configuration
task nginx:status               # Check Nginx status
task nginx:logs                 # Show Nginx logs
```

### 5. **Security Module** (`tasks/security.yml`)
```bash
task security:configure         # Configure system security
task security:firewall          # Configure UFW firewall
task security:fail2ban          # Configure Fail2Ban
task security:ssh               # Secure SSH configuration
task security:audit             # Run security audit
task security:status            # Show security status
task security:logs              # Show security-related logs
```

### 6. **Backup Module** (`tasks/backup.yml`)
```bash
task backup:setup               # Setup backup system
task backup:create-backup       # Create manual backup
task backup:restore             # Restore from backup
task backup:schedule            # Setup automatic backups
task backup:list                # List available backups
task backup:cleanup             # Clean up old backups
task backup:verify              # Verify backup integrity
task backup:status              # Show backup status
```

### 7. **Proxmox Module** (`tasks/proxmox.yml`)
```bash
task proxmox:detect             # Detect if running in Proxmox environment
task proxmox:optimize           # Apply Proxmox-specific optimizations
task proxmox:install-guest-agent # Install QEMU guest agent
task proxmox:configure-vm       # Configure VM-specific settings
task proxmox:performance-tweaks # Apply Proxmox-specific performance tweaks
task proxmox:monitoring         # Configure Proxmox VM monitoring
task proxmox:status             # Show Proxmox VM status
task proxmox:logs               # Show Proxmox-related logs
task proxmox:reset-optimizations # Reset Proxmox optimizations
```

### 8. **Test Module** (`tasks/test.yml`)
```bash
task test:lint                  # Run shellcheck on task scripts
task test:syntax                # Check syntax of task definitions
task test:functions             # Test task functionality
task test:health-check          # Health check for N8N installation
task test:connectivity          # Test N8N connectivity
task test:performance           # Run performance tests
task test:security              # Run security tests
task test:quick                 # Run quick validation tests
task test:comprehensive         # Run comprehensive test suite
task test:status                # Show overall system status
```

## 🔧 Development Workflow Migration

### Before (v1.3.0)
```bash
# Development workflow with shell scripts
git clone repo
chmod +x tests/*.sh
./tests/test-quick.sh
sudo ./install.sh --dry-run
sudo shellcheck installer/lib/*.sh
```

### After (v1.3.1)
```bash
# Development workflow with Task
git clone repo
curl -sL https://taskfile.dev/install.sh | sudo sh -s -- -b /usr/local/bin
task test:syntax
task test:lint
task dry-run
task test:quick
```

## 🧪 CI/CD Migration

### GitHub Actions Workflow Changes

**Before (v1.3.0):**
```yaml
- name: Run tests
  run: |
    ./tests/test-quick.sh
    shellcheck installer/lib/*.sh
```

**After (v1.3.1):**
```yaml
- name: Install Task
  run: |
    sudo sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin
    
- name: Run tests
  run: |
    task test:quick
    task test:lint
```

### Key CI/CD Improvements

1. **Unified Testing**: Single `task test:*` commands replace multiple script calls
2. **Better Validation**: `task test:syntax` validates all configurations
3. **Consistent Interface**: Same commands work in CI and local development
4. **Enhanced Reporting**: Task provides better error reporting and status

## 📚 Learning the New System

### Discovery Commands
```bash
# Show all available tasks
task --list

# Show detailed help
task help

# Get help for specific task
task --help <task-name>

# Show task dependencies
task --summary <task-name>
```

### Common Patterns
```bash
# Check status of all components
task status

# Restart all services
task n8n:restart
task nginx:restart

# Run comprehensive tests
task test:comprehensive

# Create and verify backup
task backup
task backup:verify
```

## 🔍 Troubleshooting Migration Issues

### Task Installation Issues

**Problem**: Task command not found
```bash
# Solution: Install Task
curl -sL https://taskfile.dev/install.sh | sudo sh -s -- -b /usr/local/bin
```

**Problem**: Permission denied
```bash
# Solution: Ensure proper installation path
which task
ls -la /usr/local/bin/task
```

### Task Execution Issues

**Problem**: Task fails with missing dependencies
```bash
# Solution: Check task requirements
task test:syntax
task --summary install
```

**Problem**: Task shows unexpected output
```bash
# Solution: Check if silent mode is working
grep "silent:" Taskfile.yml
```

### Legacy Command Compatibility

**Problem**: Old commands don't work
```bash
# Remember: Legacy commands still work!
sudo ./install.sh --help
cd /opt/n8n && docker-compose ps

# But new Task commands are preferred
task help
task status
```

## 📋 Migration Checklist

### For End Users
- [ ] ✅ No action required - installation process unchanged
- [ ] 📖 Review new Task commands for better management experience
- [ ] 🔧 Consider installing Task for enhanced local management

### For Developers
- [ ] 📦 Install Task on development machine
- [ ] 🔄 Update local scripts to use Task commands
- [ ] 🧪 Migrate testing workflows to use `task test:*`
- [ ] 📚 Update documentation with Task examples
- [ ] 🚀 Update deployment scripts to use Task

### For CI/CD Pipelines
- [ ] 📦 Add Task installation to CI/CD workflows
- [ ] 🔄 Replace shell script calls with Task commands
- [ ] 🧪 Update test execution to use `task test:*`
- [ ] ✅ Verify all workflows pass with new Task system
- [ ] 🧹 Remove references to old shell script paths

## 🎯 Best Practices

### 1. Use Namespaced Commands
```bash
# Good: Specific and clear
task n8n:restart
task security:audit
task backup:verify

# Avoid: Too generic
task restart  # Which service?
task check    # Check what?
```

### 2. Leverage Task Discovery
```bash
# Explore before executing
task --list | grep backup
task --summary backup:restore
```

### 3. Combine Related Tasks
```bash
# Create comprehensive workflows
task backup && task test:health-check
task security:audit && task test:security
```

### 4. Use Status Commands
```bash
# Check before acting
task status                    # Overall system status
task n8n:status               # Before restarting N8N
task security:status          # Before security changes
```

## 🆘 Getting Help

### Built-in Help
```bash
task help                     # Main help system
task --list                   # All available commands
task --summary <task>         # Task details
```

### Community Support
- **GitHub Issues**: https://github.com/sylvester-francis/n8n-selfhoster/issues
- **Discussions**: https://github.com/sylvester-francis/n8n-selfhoster/discussions
- **Migration Questions**: Tag issues with `migration` label

### Documentation
- **README.md**: Updated with Task examples
- **CHANGELOG.md**: Detailed migration information
- **Task Documentation**: https://taskfile.dev/

## 🔮 Future Considerations

### Planned Enhancements
- Additional task modules for extended functionality
- Integration with external monitoring systems
- Enhanced development workflows
- Automated migration detection and suggestions

### Deprecation Timeline
- **v1.3.1**: Task system introduced, shell scripts still supported
- **v1.4.x**: Task system mature, shell scripts deprecated
- **v2.0.x**: Potential removal of legacy shell script support

---

**Need help with migration?** Create an issue with the `migration` label and we'll help you transition to the new Task-based architecture!