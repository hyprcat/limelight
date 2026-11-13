from django.urls import path

from transcoder import views

urlpatterns = [
    path("start_encoding_task", views.start_encoding_task, name="encode"),
    path("start_ml_task", views.start_ml_task, name="ml"),
]
