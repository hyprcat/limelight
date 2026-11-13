import os

from celery import Celery

# set the default Django settings module for the 'celery' program.
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings.local")

app = Celery("limelight_video")

# Encoding runs on CPU instances and the ML pipeline on the GPU instance,
# so each has its own queue and its own worker (see compose/production/django/celery).
app.conf.task_routes = {
    "transcoder.tasks.start_encoding_pipeline_async": {"queue": "encoder_queue"},
    "transcoder.tasks.start_ml_pipeline_async": {"queue": "ml_queue"},
}
app.config_from_object("django.conf:settings", namespace="CELERY")

app.autodiscover_tasks()
