# Pull Request

## 📋 Description

<!-- Provide a brief description of the changes in this PR -->

## 🎯 Type of Change

<!-- Mark the relevant option with an "x" -->

- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📚 Documentation update
- [ ] 🔧 Refactoring (no functional changes)
- [ ] ⚡ Performance improvement
- [ ] 🧪 Test updates
- [ ] 🛠️ Infrastructure/tooling changes
- [ ] 📋 Task architecture changes

## 🔗 Related Issues

<!-- Link to any related issues -->
Fixes #(issue number)
Relates to #(issue number)

## 📝 Changes Made

<!-- Describe the changes in detail -->

### Core Changes
- [ ] Modified installation process
- [ ] Updated Task commands
- [ ] Changed CI/CD workflows
- [ ] Updated documentation
- [ ] Modified security configuration
- [ ] Updated backup system
- [ ] Changed Proxmox optimizations

### Task Architecture Changes (if applicable)
- [ ] Added new task modules
- [ ] Modified existing tasks
- [ ] Updated task dependencies
- [ ] Changed task structure

## 🧪 Testing

<!-- Describe how you tested your changes -->

### Testing Performed
- [ ] Task syntax validation (`task test:syntax`)
- [ ] Code quality checks (`task test:lint`)
- [ ] Health checks (`task test:health-check`)
- [ ] Quick validation (`task test:quick`)
- [ ] Comprehensive tests (`task test:comprehensive`)
- [ ] Manual installation testing
- [ ] Proxmox VM testing
- [ ] Security audit (`task test:security`)

### Test Environment
- [ ] Ubuntu 20.04
- [ ] Ubuntu 22.04
- [ ] Proxmox VM
- [ ] DigitalOcean Droplet
- [ ] Local development
- [ ] Other: _____________

### Test Commands Run
```bash
# List the specific task commands you tested
task test:syntax
task test:lint
# ... add others
```

## 📊 Impact Assessment

### Compatibility
- [ ] ✅ Backward compatible
- [ ] ⚠️ Requires migration steps
- [ ] 💥 Breaking changes

### Performance Impact
- [ ] ➕ Improves performance
- [ ] ➖ May impact performance
- [ ] 🔄 No performance impact

### Security Impact
- [ ] 🔒 Improves security
- [ ] ⚠️ Potential security implications
- [ ] 🔄 No security impact

## 📋 Migration Guide (if applicable)

<!-- If this introduces breaking changes, provide migration instructions -->

### For Users Upgrading from Previous Version

```bash
# Example migration steps
task --version  # Check if Task is installed
# ... other steps
```

### For Developers

```bash
# Example developer migration steps
git pull origin main
task test:syntax
# ... other steps
```

## 📸 Screenshots (if applicable)

<!-- Add screenshots for UI changes or visual improvements -->

## ✅ Checklist

### Code Quality
- [ ] Code follows project style guidelines
- [ ] Self-review of the code has been performed
- [ ] Code is properly commented
- [ ] No hardcoded secrets or sensitive information
- [ ] Task commands follow naming conventions

### Testing
- [ ] All existing tests pass
- [ ] New tests added for new functionality
- [ ] Task syntax validation passes (`task test:syntax`)
- [ ] Code quality checks pass (`task test:lint`)
- [ ] Manual testing performed

### Documentation
- [ ] README.md updated (if needed)
- [ ] CHANGELOG.md updated
- [ ] Task help text updated
- [ ] Command examples are correct
- [ ] Migration guide provided (if breaking changes)

### CI/CD
- [ ] All GitHub Actions workflows pass
- [ ] Task-based CI/CD validation successful
- [ ] No workflow syntax errors

## 📋 Task Architecture Compliance

<!-- For Task-related changes -->

- [ ] New tasks follow the established module structure
- [ ] Task descriptions are clear and helpful
- [ ] Tasks have proper dependencies defined
- [ ] No duplicate functionality across tasks
- [ ] Commands are organized in logical namespaces
- [ ] Silent mode respected where appropriate

## 🔍 Review Checklist for Maintainers

- [ ] PR title follows conventional commit format
- [ ] Changes align with project goals
- [ ] Code quality meets standards
- [ ] Tests are comprehensive
- [ ] Documentation is complete
- [ ] No security vulnerabilities introduced
- [ ] Task architecture is consistent

## 📝 Additional Notes

<!-- Any additional information that reviewers should know -->

---

## 🎯 Special Instructions for Shell-to-Task Migration PRs

If this PR is part of the shell-to-task migration effort:

### Shell Script Migration Checklist
- [ ] Identified all shell script functionality
- [ ] Created equivalent task commands
- [ ] Updated CI/CD to use task commands
- [ ] Maintained backward compatibility
- [ ] Updated documentation examples
- [ ] Added migration guide

### Task Implementation Checklist
- [ ] Task modules follow established patterns
- [ ] Commands are discoverable via `task --list`
- [ ] Help text is informative (`task help`)
- [ ] Error handling is consistent
- [ ] Logging follows project standards

## 🚀 Post-Merge Actions

<!-- Actions to take after this PR is merged -->

- [ ] Update version tags
- [ ] Update release notes
- [ ] Notify community of changes
- [ ] Update deployment scripts
- [ ] Archive deprecated workflows

---

Thank you for contributing to the N8N Self-Hosted Installer! 🙏