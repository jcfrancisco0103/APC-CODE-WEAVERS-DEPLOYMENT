from .settings import *

# Production defaults for Vercel
DEBUG = False

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

# Use ephemeral SQLite in /tmp when DATABASE_URL is not provided
DATABASE_URL = os.getenv('DATABASE_URL', '')
if not DATABASE_URL:
    DATABASES['default'] = {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': '/tmp/db.sqlite3',
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

