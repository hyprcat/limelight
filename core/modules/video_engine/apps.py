from django.apps import AppConfig


class VideoEngineConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    label = "video_engine"
    verbose_name = "Video Related Control"
    name = 'modules.' + label
