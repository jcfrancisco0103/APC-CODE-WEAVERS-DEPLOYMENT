Google Sign-In (OAuth2) Setup

Prerequisites
- Google Cloud project with OAuth consent screen in Testing or Production.
- Create OAuth Client ID (type: Web application).

Environment Variables
- `GOOGLE_OAUTH_CLIENT_ID` – your OAuth client ID
- `GOOGLE_OAUTH_CLIENT_SECRET` – your OAuth client secret

Local Development Redirect URIs
- Authorized redirect URI: `http://localhost:8000/oauth/complete/google-oauth2/`
- Authorized JavaScript origin: `http://localhost:8000`

Production Redirect URIs (examples)
- Redirect: `https://<your-domain>/oauth/complete/google-oauth2/`
- Origin: `https://<your-domain>`

Django Configuration
- Already configured in `ecommerce/settings.py`:
  - `social_django` in `INSTALLED_APPS`
  - social context processors in `TEMPLATES`
  - `AUTHENTICATION_BACKENDS` includes Google OAuth2 backend
  - `SOCIAL_AUTH_GOOGLE_OAUTH2_KEY` and `SOCIAL_AUTH_GOOGLE_OAUTH2_SECRET` read from env

URLs
- Social auth routes are mounted at: `/oauth/`
- Login/complete endpoints are provided by the library.

Templates
- Login: Google button links to `{% url 'social:begin' 'google-oauth2' %}`
- Signup: Google button links to the same begin URL

Steps to Test Locally
1. Set environment variables in your shell before running the server.
2. `python manage.py migrate` to apply `social_django` migrations.
3. `python manage.py runserver`
4. Visit `/customerlogin` or `/customersignup` and click the Google button.

Notes
- If a user signs in with Google for the first time, a Django user account is created if email is available and permitted by your consent screen.
- If you need to restrict domains or emails, add custom pipeline steps in `SOCIAL_AUTH_PIPELINE`.
- For Docker/Vercel, set env vars in the container/service configuration and ensure the correct redirect URIs are registered in Google Cloud.