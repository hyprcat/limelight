import json

from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST

from transcoder.tasks import start_encoding_pipeline_async, start_ml_pipeline_async

# NOTE: these two endpoints have no authentication. They only queue work for a
# video id that already exists, and both pipelines skip videos that are done.


def queue_for_video(request, task, message):
    """Queue a pipeline task for the `video_id` in the JSON body."""
    try:
        video_id = json.loads(request.body)["video_id"]
    except (ValueError, KeyError, TypeError):
        return JsonResponse({"status": 400, "message": "Missing fields: video_id"}, status=400)
    task.delay(video_id)
    return JsonResponse({"message": message})


@csrf_exempt
@require_POST
def start_encoding_task(request):
    """Queue HLS transcoding for a video."""
    return queue_for_video(request, start_encoding_pipeline_async, "Task created on encoding pipeline")


@csrf_exempt
@require_POST
def start_ml_task(request):
    """Queue the ML pipeline (transcript, scene captions, sentiment, topic) for a video."""
    return queue_for_video(request, start_ml_pipeline_async, "Task created on ML pipeline")
