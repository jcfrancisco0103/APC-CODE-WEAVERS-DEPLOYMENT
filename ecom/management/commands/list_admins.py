from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from ecom.models import SuperAdmin


class Command(BaseCommand):
    help = "List admin accounts (is_staff/is_superuser) and SuperAdmin records"

    def handle(self, *args, **options):
        admins = User.objects.filter(is_staff=True) | User.objects.filter(is_superuser=True)
        admins = admins.distinct().order_by('username')

        self.stdout.write(self.style.NOTICE("Admins (Django auth users with is_staff or is_superuser):"))
        if admins.exists():
            for u in admins:
                self.stdout.write(f"- username='{u.username}' email='{u.email}' is_staff={u.is_staff} is_superuser={u.is_superuser}")
        else:
            self.stdout.write("(none)")

        self.stdout.write("")
        self.stdout.write(self.style.NOTICE("SuperAdmins (records in ecom.SuperAdmin):"))
        superadmins = SuperAdmin.objects.select_related('user').all().order_by('user__username')
        if superadmins.exists():
            for sa in superadmins:
                self.stdout.write(
                    f"- username='{sa.user.username}' employee_id='{sa.employee_id}' active={sa.is_active}"
                )
        else:
            self.stdout.write("(none)")

