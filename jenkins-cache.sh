#!/bin/bash

# Jenkins Cache Management Script
# Optimizes build performance by managing Docker and pip caches

set -e

CACHE_DIR="/var/jenkins_home/cache"
PIP_CACHE_DIR="$CACHE_DIR/pip"
DOCKER_CACHE_DIR="$CACHE_DIR/docker"
WORKSPACE_CACHE_DIR="$CACHE_DIR/workspace"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to setup cache directories
setup_cache_dirs() {
    log "Setting up cache directories..."
    
    mkdir -p "$PIP_CACHE_DIR"
    mkdir -p "$DOCKER_CACHE_DIR"
    mkdir -p "$WORKSPACE_CACHE_DIR"
    
    # Set proper permissions
    chmod -R 755 "$CACHE_DIR"
    
    success "Cache directories created"
}

# Function to setup pip cache
setup_pip_cache() {
    log "Setting up pip cache..."
    
    export PIP_CACHE_DIR="$PIP_CACHE_DIR"
    
    # Create pip.conf for persistent cache configuration
    mkdir -p ~/.pip
    cat > ~/.pip/pip.conf << EOF
[global]
cache-dir = $PIP_CACHE_DIR
trusted-host = pypi.org
               pypi.python.org
               files.pythonhosted.org
EOF
    
    success "Pip cache configured"
}

# Function to setup Docker cache
setup_docker_cache() {
    log "Setting up Docker cache..."
    
    # Enable BuildKit for better caching
    export DOCKER_BUILDKIT=1
    export COMPOSE_DOCKER_CLI_BUILD=1
    
    # Configure Docker daemon for better caching
    if [ -f /etc/docker/daemon.json ]; then
        cp /etc/docker/daemon.json /etc/docker/daemon.json.backup
    fi
    
    cat > /tmp/daemon.json << EOF
{
    "storage-driver": "overlay2",
    "storage-opts": [
        "overlay2.override_kernel_check=true"
    ],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    },
    "max-concurrent-downloads": 10,
    "max-concurrent-uploads": 10,
    "builder": {
        "gc": {
            "enabled": true,
            "defaultKeepStorage": "20GB"
        }
    }
}
EOF
    
    success "Docker cache configured"
}

# Function to warm up caches
warm_up_caches() {
    log "Warming up caches..."
    
    # Pull commonly used base images
    docker pull python:3.9-slim &
    docker pull postgres:13-alpine &
    docker pull jenkins/jenkins:lts-alpine &
    
    wait
    
    success "Base images cached"
}

# Function to clean old cache
clean_old_cache() {
    log "Cleaning old cache entries..."
    
    # Clean pip cache older than 7 days
    find "$PIP_CACHE_DIR" -type f -mtime +7 -delete 2>/dev/null || true
    
    # Clean Docker system
    docker system prune -f --filter "until=168h" || true
    
    # Clean workspace cache older than 3 days
    find "$WORKSPACE_CACHE_DIR" -type f -mtime +3 -delete 2>/dev/null || true
    
    success "Old cache cleaned"
}

# Function to show cache statistics
show_cache_stats() {
    log "Cache Statistics:"
    
    if [ -d "$PIP_CACHE_DIR" ]; then
        PIP_SIZE=$(du -sh "$PIP_CACHE_DIR" 2>/dev/null | cut -f1 || echo "0")
        echo "  Pip Cache: $PIP_SIZE"
    fi
    
    if [ -d "$DOCKER_CACHE_DIR" ]; then
        DOCKER_SIZE=$(du -sh "$DOCKER_CACHE_DIR" 2>/dev/null | cut -f1 || echo "0")
        echo "  Docker Cache: $DOCKER_SIZE"
    fi
    
    if [ -d "$WORKSPACE_CACHE_DIR" ]; then
        WORKSPACE_SIZE=$(du -sh "$WORKSPACE_CACHE_DIR" 2>/dev/null | cut -f1 || echo "0")
        echo "  Workspace Cache: $WORKSPACE_SIZE"
    fi
    
    # Docker system info
    echo "  Docker Images: $(docker images -q | wc -l)"
    echo "  Docker Containers: $(docker ps -aq | wc -l)"
}

# Function to optimize build environment
optimize_build_env() {
    log "Optimizing build environment..."
    
    # Set environment variables for faster builds
    export MAKEFLAGS="-j$(nproc)"
    export PYTHONDONTWRITEBYTECODE=1
    export PYTHONUNBUFFERED=1
    export PIP_NO_CACHE_DIR=0
    export PIP_DISABLE_PIP_VERSION_CHECK=1
    
    # Configure Git for faster operations
    git config --global core.preloadindex true
    git config --global core.fscache true
    git config --global gc.auto 256
    
    success "Build environment optimized"
}

# Function to backup cache
backup_cache() {
    log "Creating cache backup..."
    
    BACKUP_DIR="/var/jenkins_home/cache_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # Backup pip cache
    if [ -d "$PIP_CACHE_DIR" ]; then
        cp -r "$PIP_CACHE_DIR" "$BACKUP_DIR/pip" || warning "Failed to backup pip cache"
    fi
    
    # Export Docker images
    docker save $(docker images -q) | gzip > "$BACKUP_DIR/docker_images.tar.gz" || warning "Failed to backup Docker images"
    
    success "Cache backup created at $BACKUP_DIR"
}

# Function to restore cache
restore_cache() {
    if [ -z "$1" ]; then
        error "Please provide backup directory path"
        exit 1
    fi
    
    BACKUP_DIR="$1"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        error "Backup directory not found: $BACKUP_DIR"
        exit 1
    fi
    
    log "Restoring cache from $BACKUP_DIR..."
    
    # Restore pip cache
    if [ -d "$BACKUP_DIR/pip" ]; then
        cp -r "$BACKUP_DIR/pip" "$PIP_CACHE_DIR" || warning "Failed to restore pip cache"
    fi
    
    # Restore Docker images
    if [ -f "$BACKUP_DIR/docker_images.tar.gz" ]; then
        gunzip -c "$BACKUP_DIR/docker_images.tar.gz" | docker load || warning "Failed to restore Docker images"
    fi
    
    success "Cache restored"
}

# Main execution
case "${1:-setup}" in
    "setup")
        setup_cache_dirs
        setup_pip_cache
        setup_docker_cache
        optimize_build_env
        ;;
    "warm")
        warm_up_caches
        ;;
    "clean")
        clean_old_cache
        ;;
    "stats")
        show_cache_stats
        ;;
    "backup")
        backup_cache
        ;;
    "restore")
        restore_cache "$2"
        ;;
    "optimize")
        setup_cache_dirs
        setup_pip_cache
        setup_docker_cache
        optimize_build_env
        warm_up_caches
        clean_old_cache
        ;;
    *)
        echo "Usage: $0 {setup|warm|clean|stats|backup|restore|optimize}"
        echo ""
        echo "Commands:"
        echo "  setup    - Setup cache directories and configuration"
        echo "  warm     - Warm up caches with common images"
        echo "  clean    - Clean old cache entries"
        echo "  stats    - Show cache statistics"
        echo "  backup   - Create cache backup"
        echo "  restore  - Restore cache from backup (requires backup path)"
        echo "  optimize - Run full optimization (setup + warm + clean)"
        exit 1
        ;;
esac

success "Cache management completed!"