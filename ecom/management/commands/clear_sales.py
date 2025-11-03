from django.core.management.base import BaseCommand
from django.db import transaction

from ecom.models import Orders, OrderItem

try:
    from ecom.models import DeliveryStatusLog, BulkOrderOperation
except Exception:
    # Optional models; handle absence gracefully
    DeliveryStatusLog = None
    BulkOrderOperation = None


class Command(BaseCommand):
    help = (
        "Clear all sales data (Orders, OrderItems, optional delivery logs and bulk operations). "
        "Keeps customers, users, and products intact."
    )

    def add_arguments(self, parser):
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Show counts that would be deleted without performing deletion",
        )
        parser.add_argument(
            "--yes",
            action="store_true",
            help="Proceed without interactive confirmation",
        )

    def handle(self, *args, **options):
        dry_run = options.get("dry_run", False)
        proceed = options.get("yes", False)

        counts = {
            "orders": Orders.objects.count(),
            "order_items": OrderItem.objects.count(),
        }
        if DeliveryStatusLog:
            counts["delivery_logs"] = DeliveryStatusLog.objects.count()
        if BulkOrderOperation:
            counts["bulk_operations"] = BulkOrderOperation.objects.count()

        if dry_run:
            self.stdout.write(self.style.WARNING(f"[DRY RUN] Would delete: {counts}"))
            return

        if not proceed:
            self.stdout.write(
                self.style.ERROR(
                    "Refusing to delete without --yes. Re-run with --dry-run to preview or --yes to execute."
                )
            )
            return

        with transaction.atomic():
            # Delete dependent/logging models first
            if DeliveryStatusLog:
                DeliveryStatusLog.objects.all().delete()
            if BulkOrderOperation:
                BulkOrderOperation.objects.all().delete()

            # Delete order items then orders
            OrderItem.objects.all().delete()
            Orders.objects.all().delete()

        self.stdout.write(self.style.SUCCESS(f"Deleted: {counts}"))

