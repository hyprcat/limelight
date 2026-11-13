from django.apps import AppConfig


class LoungeEngineConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    label = "lounge_engine"
    verbose_name = "Lounge Control"
    name = 'modules.' + label
