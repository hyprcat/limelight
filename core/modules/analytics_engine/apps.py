from django.apps import AppConfig


class AnalyticsEngineConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    label = "analytics_engine"
    verbose_name = "Analytics Control"
    name = 'modules.' + label
