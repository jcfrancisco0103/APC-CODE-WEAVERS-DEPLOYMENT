import os
from ecommerce.settings import *
from decouple import config

# Override settings for Vercel deployment
DEBUG = False

# Add Vercel domains to ALLOWED_HOSTS
ALLOWED_HOSTS = [
    'localhost', 
    '127.0.0.1', 
    '.vercel.app',
    '.now.sh',
    '*'  # Remove this in production and add your specific domain
]

# Use forwarded host/https from edge proxy
USE_X_FORWARDED_HOST = True
CSRF_TRUSTED_ORIGINS = [
    'https://*.vercel.app',
    'https://*.app.github.dev',
]

# Optional: allow overriding absolute URLs in emails
PUBLIC_BASE_URL = config('PUBLIC_BASE_URL', default='')

# Database configuration for Vercel (read-only SQLite bundled with code)
# For real production, use a managed database (PostgreSQL/MySQL) via env vars.
# Use ephemeral SQLite in /tmp for serverless. Tables are created on cold start.
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': '/tmp/db.sqlite3',
    }
}

# Use cookie-based sessions to avoid DB writes on serverless
SESSION_ENGINE = 'django.contrib.sessions.backends.signed_cookies'

# Static files configuration for Vercel
STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles_build', 'static')

# Media files configuration
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'staticfiles_build', 'media')

# Security settings for production
SECURE_SSL_REDIRECT = True
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_BROWSER_XSS_FILTER = True
X_FRAME_OPTIONS = 'DENY'

# CSRF settings
CSRF_COOKIE_SECURE = True
SESSION_COOKIE_SECURE = True

# Email configuration for production
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.gmail.com'
EMAIL_USE_TLS = True
EMAIL_PORT = 587
EMAIL_HOST_USER = config('EMAIL_HOST_USER', default='')
EMAIL_HOST_PASSWORD = config('EMAIL_HOST_PASSWORD', default='')
EMAIL_RECEIVING_USER = [config('EMAIL_RECEIVING_USER', default='')]

# PayPal configuration
PAYPAL_CLIENT_ID = config('PAYPAL_CLIENT_ID', default='')
PAYPAL_SECRET_KEY = config('PAYPAL_SECRET_KEY', default='')

# Cache configuration for production
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        'LOCATION': 'vercel-cache',
        'TIMEOUT': 300,
        'OPTIONS': {
            'MAX_ENTRIES': 1000,
        }
    }
}

# Log Django errors to console so Vercel logs show tracebacks
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
        },
    },
    'loggers': {
        'django': {'handlers': ['console'], 'level': 'ERROR', 'propagate': True},
        'django.request': {'handlers': ['console'], 'level': 'ERROR', 'propagate': True},
    },
}
