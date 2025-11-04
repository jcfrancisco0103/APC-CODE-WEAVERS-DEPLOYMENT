from django.contrib.auth.models import Group
from django.contrib.auth import get_user_model
from django.db import transaction

from .models import Customer


def ensure_active_customer(strategy, details, user=None, is_new=False, *args, **kwargs):
    """
    Social-auth pipeline step to:
    - Ensure the user is active (skip local email verification for social users)
    - Ensure a Customer profile exists and add user to CUSTOMER group
    - Sync email if provided by the provider
    """
    UserModel = get_user_model()

    # If user wasn't created by previous steps, nothing to do
    if user is None:
        return

    # Update email from provider details when missing
    email = (details or {}).get('email')
    if email and user.email != email:
        user.email = email

    # Always activate social-auth users to allow immediate login
    if not user.is_active:
        user.is_active = True

    # Persist user changes
    user.save()

    # Ensure Customer exists and group assignment
    try:
        with transaction.atomic():
            customer, created = Customer.objects.get_or_create(user=user)
            # Add to CUSTOMER group
            customer_group, _ = Group.objects.get_or_create(name='CUSTOMER')
            customer_group.user_set.add(user)
    except Exception:
        # Silently ignore; social flow should still complete even if profile creation fails
        pass

    return