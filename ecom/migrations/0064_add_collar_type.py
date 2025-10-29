# Generated manually to fix collar_type NOT NULL constraint

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('ecom', '0063_merge_20251029_1549'),
    ]

    operations = [
        migrations.AddField(
            model_name='customjerseydesign',
            name='collar_type',
            field=models.CharField(default='standard', max_length=50),
        ),
    ]