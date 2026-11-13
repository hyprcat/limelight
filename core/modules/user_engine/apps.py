from django.apps import AppConfig


class UserEngineConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    label = "user_engine"
    verbose_name = "User Control"
    name = 'modules.' + label
