from .settings import *
import os
import tempfile
from pathlib import Path

# Production defaults for Vercel; allow temporary debug via env
DEBUG = os.getenv('VERCEL_DEBUG', '') == '1'

# Allow Vercel preview/production domains and your custom domains
ALLOWED_HOSTS = [
    '.vercel.app',
    'worksteamwear.shop',
    'www.worksteamwear.shop',
    'ecom.worksteamwear.shop',
    '*',
]

# Trust proxy headers; Vercel terminates HTTPS at the edge
USE_X_FORWARDED_HOST = True
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')

# Use ephemeral SQLite in temp dir when DATABASE_URL is not provided
DATABASE_URL = os.getenv('DATABASE_URL', '')
if not DATABASE_URL:
    SQLITE_DB_PATH = os.getenv('SQLITE_DB_PATH', os.path.join(tempfile.gettempdir(), 'db.sqlite3'))
    # Ensure the temp directory exists in serverless environments
    try:
        Path(os.path.dirname(SQLITE_DB_PATH)).mkdir(parents=True, exist_ok=True)
    except Exception:
        pass
    DATABASES['default'] = {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': SQLITE_DB_PATH,
    }

# CSRF trusted origins for Vercel and your domain
CSRF_TRUSTED_ORIGINS = [
    'https://*.vercel.app',
    'https://worksteamwear.shop',
    'https://www.worksteamwear.shop',
    'http://worksteamwear.shop',
    'http://www.worksteamwear.shop',
    'https://ecom.worksteamwear.shop',
    'http://ecom.worksteamwear.shop',
]

# Social auth should report HTTPS behind proxy
SOCIAL_AUTH_REDIRECT_IS_HTTPS = True

# Static files and sessions adjustments for Vercel serverless
# Avoid ManifestStaticFilesStorage which requires collectstatic manifest
STATICFILES_STORAGE = 'whitenoise.storage.CompressedStaticFilesStorage'

# WhiteNoise: disable long caching and enable autorefresh for ephemeral FS
WHITENOISE_MAX_AGE = 0
WHITENOISE_AUTOREFRESH = True

# Use cookie-based sessions to avoid DB writes during cold starts
SESSION_ENGINE = 'django.contrib.sessions.backends.signed_cookies'

# Log server errors to console so Vercel shows tracebacks
DEBUG_PROPAGATE_EXCEPTIONS = True
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'simple': {
            'format': '[%(levelname)s] %(name)s: %(message)s'
        }
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'simple',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['console'],
            'level': 'INFO',
            'propagate': True,
        },
        'django.request': {
            'handlers': ['console'],
            'level': 'ERROR',
            'propagate': False,
        },
        'django.server': {
            'handlers': ['console'],
            'level': 'ERROR',
            'propagate': False,
        },
    },
}
