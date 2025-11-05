import os
import pathlib

from django.http import HttpResponse
from django.utils.deprecation import MiddlewareMixin
from django.db.utils import OperationalError, ProgrammingError


class DBReadinessMiddleware(MiddlewareMixin):
    """
    On Vercel cold starts, block requests until migrations complete to avoid 500s.
    Also catch OperationalError/ProgrammingError globally and return a friendly 503.
    """

    def process_request(self, request):
        try:
            if os.environ.get('VERCEL') and not pathlib.Path('/tmp/.migrated').exists():
                # Return 503 Service Unavailable with a short message
                return HttpResponse(
                    'System initialization in progress. Please try again shortly.',
                    status=503,
                )
        except Exception:
            # Fail open; let request continue
            return None

    def process_exception(self, request, exception):
        # Gracefully handle DB readiness issues during cold start
        if isinstance(exception, (OperationalError, ProgrammingError)):
            return HttpResponse(
                'Temporary system issue while initializing. Please try again.',
                status=503,
            )
        return None

