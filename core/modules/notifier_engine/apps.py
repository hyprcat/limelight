from django.apps import AppConfig


class NotifierEngineConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    label = "notifier_engine"
    verbose_name = "Notification Control"
    name = "modules." + label
