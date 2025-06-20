#!/bin/bash


###################################################################################
#                                                                                 #
#                        N8N Self-Hosted Installer                                #
#                           Main Installation Script                              #
#                                                                                 #
###################################################################################
#                                                                                 #
# Description: Automated installer for N8N with HTTPS, PostgreSQL, and Nginx      #
# Author: Sylvester Francis                                                       #
# Version: 1.2.0 (Enhanced CLI Interface)                                        #
# GitHub: https://github.com/sylvester-francis/n8n-selfhoster                     #
#                                                                                 #
# Features:                                                                       #
# - Docker & Docker Compose installation                                         #
# - PostgreSQL database setup                                                    #
# - Nginx reverse proxy with HTTPS                                               #
# - Self-signed SSL certificates                                                 #
# - Firewall configuration                                                       #
# - Automated backups                                                            #
# - Security hardening                                                           #
# - Performance optimizations                                                    #
#                                                                                 #
###################################################################################

set -euo pipefail

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all library modules (including performance optimizations)
for lib in "$SCRIPT_DIR"/lib/*.sh; do
    if [ -f "$lib" ]; then
        # shellcheck source=/dev/null
        source "$lib"
    fi
done

###################################################################################
# Command Line Arguments and Help
###################################################################################

show_help() {
    cat << EOF
N8N Self-Hosted Installer v$SCRIPT_VERSION

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -h, --help              Show this help message
    -v, --version           Show version information
    -y, --yes               Skip all prompts (non-interactive mode)
    -d, --domain DOMAIN     Set domain name (e.g., example.com)
    -i, --ip IP             Set server IP address
    -t, --timezone TZ       Set timezone (e.g., America/New_York)
    --skip-firewall         Skip firewall configuration
    --skip-ssl              Skip SSL certificate generation
    --skip-backups          Skip backup configuration
    --quick                 Quick installation (skip optional features)
    --verbose               Enable verbose logging
    --dry-run               Show what would be done without executing

EXAMPLES:
    # Interactive installation
    sudo $0

    # Non-interactive with domain
    sudo $0 --yes --domain myserver.com

    # Quick installation with IP
    sudo $0 --quick --ip 192.168.1.100 --yes

    # Dry run to see what would happen
    sudo $0 --dry-run

For more information, visit: https://github.com/sylvester-francis/n8n-selfhoster

EOF
}

show_version() {
    echo "N8N Self-Hosted Installer v$SCRIPT_VERSION"
    echo "Author: Sylvester Francis"
    echo "GitHub: https://github.com/sylvester-francis/n8n-selfhoster"
}

parse_arguments() {
    # Default values
    export AUTO_CONFIRM=false
    export SKIP_FIREWALL=false
    export SKIP_SSL=false
    export SKIP_BACKUPS=false
    export QUICK_MODE=false
    export VERBOSE=false
    export DRY_RUN=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                show_version
                exit 0
                ;;
            -y|--yes)
                export AUTO_CONFIRM=true
                shift
                ;;
            -d|--domain)
                export DOMAIN_NAME="$2"
                export USE_DOMAIN=true
                shift 2
                ;;
            -i|--ip)
                export SERVER_IP="$2"
                shift 2
                ;;
            -t|--timezone)
                export TIMEZONE="$2"
                shift 2
                ;;
            --skip-firewall)
                export SKIP_FIREWALL=true
                shift
                ;;
            --skip-ssl)
                export SKIP_SSL=true
                shift
                ;;
            --skip-backups)
                export SKIP_BACKUPS=true
                shift
                ;;
            --quick)
                export QUICK_MODE=true
                export SKIP_BACKUPS=true
                shift
                ;;
            --verbose)
                export VERBOSE=true
                shift
                ;;
            --dry-run)
                export DRY_RUN=true
                shift
                ;;
            *)
                echo "Unknown option: $1" >&2
                echo "Use --help for usage information" >&2
                exit 1
                ;;
        esac
    done
}

###################################################################################
# Main Installation Flow
###################################################################################

main() {
    # Initialize logging
    init_logging
    
    local start_time
    start_time=$(date +%s)
    local failed_steps=()
    
    # Performance optimization setup
    log "INFO" "Applying performance optimizations..."
    optimize_system_performance 2>/dev/null || true
    
    # Helper function to run a step with performance tracking
    run_step_optimized() {
        local step_name="$1"
        local step_function="$2"
        local step_start
        step_start=$(date +%s)
        
        log "DEBUG" "Starting step: $step_name"
        if $step_function; then
            local step_end
            step_end=$(date +%s)
            local step_duration=$((step_end - step_start))
            log "DEBUG" "Step completed successfully: $step_name (${step_duration}s)"
            return 0
        else
            log "ERROR" "Step failed: $step_name"
            failed_steps+=("$step_name")
            return 1
        fi
    }
    
    # Parallel pre-checks for better performance
    log "INFO" "Running parallel pre-checks..."
    (
        fast_dependency_check 2>/dev/null || true
        setup_package_cache 2>/dev/null || true
    ) &
    local precheck_pid=$!
    
    # Run critical installation steps
    run_step_optimized "show_welcome" "show_welcome" || true
    run_step_optimized "check_requirements" "check_requirements" || exit 1
    run_step_optimized "get_configuration" "get_configuration" || exit 1
    
    # Wait for pre-checks to complete
    wait $precheck_pid 2>/dev/null || true
    
    # Optimized installation sequence
    run_step_optimized "update_system" "update_system" || exit 1
    run_step_optimized "install_docker" "install_docker" || exit 1
    
    # Parallel installation of nginx and SSL (independent tasks)
    log "INFO" "Running parallel nginx and SSL setup..."
    (
        install_nginx 2>/dev/null || log "WARNING" "Nginx installation had issues"
    ) &
    local nginx_pid=$!
    
    (
        generate_ssl_certificate 2>/dev/null || log "WARNING" "SSL generation had issues"
    ) &
    local ssl_pid=$!
    
    # Continue with N8N setup while others run in parallel
    run_step_optimized "setup_n8n" "setup_n8n" || exit 1
    
    # Wait for parallel tasks
    wait $nginx_pid 2>/dev/null || true
    wait $ssl_pid 2>/dev/null || true
    
    # Complete remaining configuration
    run_step_optimized "configure_nginx" "configure_nginx" || true
    
    # Parallel security and backup setup
    log "INFO" "Running parallel security configuration..."
    (
        configure_firewall 2>/dev/null || true
        setup_security 2>/dev/null || true
    ) &
    local security_pid=$!
    
    (
        setup_backups 2>/dev/null || true
        setup_environment 2>/dev/null || true
    ) &
    local backup_pid=$!
    
    # Start services
    run_step_optimized "start_docker_services" "start_docker_services" || exit 1
    run_step_optimized "start_nginx" "start_nginx" || true
    
    # Wait for parallel configurations
    wait $security_pid 2>/dev/null || true
    wait $backup_pid 2>/dev/null || true
    
    # Calculate total installation time
    local end_time
    end_time=$(date +%s)
    local total_duration=$((end_time - start_time))
    local minutes=$((total_duration / 60))
    local seconds=$((total_duration % 60))
    
    # Report performance metrics
    if [ ${#failed_steps[@]} -gt 0 ]; then
        log "WARNING" "Some installation steps failed: ${failed_steps[*]}"
    fi
    
    # Run final validation
    log "DEBUG" "Running final tests"
    if run_tests; then
        show_summary
        log "SUCCESS" "🚀 N8N installation completed successfully in ${minutes}m ${seconds}s!"
    else
        log "WARNING" "Installation completed with some issues (${minutes}m ${seconds}s total time)"
        print_color "$YELLOW" "\\n${WARNING} Installation completed but some tests failed."
        print_color "$WHITE" "Please check the issues above and refer to the troubleshooting guide."
        print_color "$WHITE" "Your N8N instance may still be functional."
    fi
}

###################################################################################
# Script Entry Point
###################################################################################

# Check if script is being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_arguments "$@"
    main
fi