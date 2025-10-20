#!/bin/bash

# Optimized build script for faster builds
set -e

echo "🚀 Starting optimized build process..."

# Enable BuildKit for faster Docker builds
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to build with cache
build_with_cache() {
    echo "📦 Building Docker images with cache optimization..."
    
    # Pull base images for cache
    docker pull python:3.9-slim || echo "Failed to pull base image, continuing..."
    docker pull postgres:13-alpine || echo "Failed to pull postgres image, continuing..."
    
    # Build with parallel processing and cache
    docker-compose build --parallel --pull
}

# Function to run tests quickly
run_quick_tests() {
    echo "🧪 Running quick tests..."
    
    # Create virtual environment if it doesn't exist
    if [ ! -d ".venv" ]; then
        python3 -m venv .venv
    fi
    
    # Activate virtual environment
    source .venv/bin/activate
    
    # Install dependencies with cache
    pip install --upgrade pip --cache-dir ~/.cache/pip
    pip install -r requirements.txt --cache-dir ~/.cache/pip
    
    # Run syntax check
    python -m py_compile manage.py
    
    # Run Django system checks
    python manage.py check --deploy
    
    # Run tests with keepdb for speed
    python manage.py test --verbosity=1 --keepdb --parallel
    
    echo "✅ Tests completed successfully!"
}

# Function to collect static files
collect_static() {
    echo "📁 Collecting static files..."
    source .venv/bin/activate
    python manage.py collectstatic --noinput --clear
    echo "✅ Static files collected!"
}

# Function to start services
start_services() {
    echo "🔄 Starting services..."
    
    # Stop existing containers
    docker-compose down --timeout 30
    
    # Start services with health checks
    docker-compose up -d db
    
    # Wait for database to be ready
    echo "⏳ Waiting for database to be ready..."
    timeout 60 bash -c 'until docker-compose exec db pg_isready -U postgres; do sleep 2; done'
    
    # Start web service
    docker-compose up -d web
    
    # Wait for web service to be ready
    echo "⏳ Waiting for web service to be ready..."
    timeout 120 bash -c 'until curl -f http://localhost:8000/health/ 2>/dev/null; do sleep 5; done'
    
    echo "✅ Services started successfully!"
    echo "🌐 Application available at: http://localhost:8000"
}

# Main execution
case "${1:-all}" in
    "test")
        run_quick_tests
        ;;
    "build")
        build_with_cache
        ;;
    "static")
        collect_static
        ;;
    "start")
        start_services
        ;;
    "all")
        run_quick_tests
        collect_static
        build_with_cache
        start_services
        ;;
    "ci")
        # Optimized CI build
        echo "🔧 Running CI optimized build..."
        run_quick_tests
        collect_static
        build_with_cache
        echo "✅ CI build completed!"
        ;;
    *)
        echo "Usage: $0 {test|build|static|start|all|ci}"
        echo "  test   - Run tests only"
        echo "  build  - Build Docker images only"
        echo "  static - Collect static files only"
        echo "  start  - Start services only"
        echo "  all    - Run complete build process"
        echo "  ci     - Run CI optimized build"
        exit 1
        ;;
esac

echo "🎉 Build process completed successfully!"