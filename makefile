# Jersey Customizer Makefile
# Optimized build commands for faster development

.PHONY: help install test build start stop clean deploy health lint format

# Default target
help:
	@echo "Jersey Customizer - Available Commands:"
	@echo ""
	@echo "Development:"
	@echo "  make install    - Install dependencies with caching"
	@echo "  make test       - Run tests with optimizations"
	@echo "  make lint       - Run code linting"
	@echo "  make format     - Format code"
	@echo ""
	@echo "Build & Deploy:"
	@echo "  make build      - Build Docker images with cache"
	@echo "  make start      - Start all services"
	@echo "  make stop       - Stop all services"
	@echo "  make restart    - Restart services"
	@echo "  make deploy     - Deploy application"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean      - Clean up containers and cache"
	@echo "  make health     - Check service health"
	@echo "  make logs       - Show service logs"
	@echo ""
	@echo "CI/CD:"
	@echo "  make ci         - Run CI pipeline locally"
	@echo "  make quick      - Quick development build"

# Development commands
install:
	@echo "📦 Installing dependencies with cache..."
	@python -m pip install --upgrade pip --cache-dir ~/.cache/pip
	@pip install -r requirements.txt --cache-dir ~/.cache/pip
	@echo "✅ Dependencies installed!"

test:
	@echo "🧪 Running optimized tests..."
	@python manage.py check --deploy
	@python manage.py test --verbosity=1 --keepdb --parallel
	@echo "✅ Tests completed!"

lint:
	@echo "🔍 Running code linting..."
	@python -m flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
	@python -m flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics
	@echo "✅ Linting completed!"

format:
	@echo "🎨 Formatting code..."
	@python -m black . --line-length=127
	@python -m isort .
	@echo "✅ Code formatted!"

# Build & Deploy commands
build:
	@echo "🏗️ Building with optimizations..."
	@export DOCKER_BUILDKIT=1 && export COMPOSE_DOCKER_CLI_BUILD=1
	@docker-compose build --parallel --pull
	@echo "✅ Build completed!"

start:
	@echo "🚀 Starting services..."
	@export DOCKER_BUILDKIT=1 && export COMPOSE_DOCKER_CLI_BUILD=1
	@docker-compose up -d
	@echo "⏳ Waiting for services to be ready..."
	@sleep 10
	@make health
	@echo "✅ Services started! Available at http://localhost:8000"

stop:
	@echo "🛑 Stopping services..."
	@docker-compose down --timeout 30
	@echo "✅ Services stopped!"

restart: stop start

deploy:
	@echo "🚀 Deploying application..."
	@./build_files.sh ci
	@echo "✅ Deployment completed!"

# Maintenance commands
clean:
	@echo "🧹 Cleaning up..."
	@docker-compose down --volumes --remove-orphans
	@docker system prune -f
	@docker volume prune -f
	@rm -rf .pytest_cache/
	@rm -rf __pycache__/
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -name "*.pyc" -delete
	@echo "✅ Cleanup completed!"

health:
	@echo "🏥 Checking service health..."
	@docker-compose ps
	@curl -f http://localhost:8000/health/ 2>/dev/null && echo "✅ Web service healthy" || echo "❌ Web service unhealthy"

logs:
	@echo "📋 Showing service logs..."
	@docker-compose logs --tail=50 -f

# CI/CD commands
ci:
	@echo "🔧 Running CI pipeline locally..."
	@make install
	@make lint
	@make test
	@python manage.py collectstatic --noinput --clear
	@make build
	@echo "✅ CI pipeline completed!"

quick:
	@echo "⚡ Quick development build..."
	@make install
	@python manage.py collectstatic --noinput --clear
	@python manage.py migrate
	@echo "✅ Quick build completed!"

# Database commands
migrate:
	@echo "🗄️ Running database migrations..."
	@python manage.py migrate
	@echo "✅ Migrations completed!"

makemigrations:
	@echo "🗄️ Creating database migrations..."
	@python manage.py makemigrations
	@echo "✅ Migrations created!"

# Static files
collectstatic:
	@echo "📁 Collecting static files..."
	@python manage.py collectstatic --noinput --clear
	@echo "✅ Static files collected!"

# Development server
runserver:
	@echo "🌐 Starting development server..."
	@python manage.py runserver 0.0.0.0:8000

# Shell
shell:
	@echo "🐚 Starting Django shell..."
	@python manage.py shell