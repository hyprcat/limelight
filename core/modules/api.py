"""Request and response helpers shared by every engine's views.

Almost every endpoint has the same shape: a POST with a JSON body, the session
token in the Authorization header, and a JSON reply built by a manager.
`json_endpoint` holds that shape once so each view is only its own logic.
"""
import json
import logging
from functools import wraps

from botocore.exceptions import BotoCoreError, ClientError
from django.conf import settings
from django.http import FileResponse, HttpResponse, HttpResponseRedirect, JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST

from modules.s3 import BOTO_S3, cdn_url


def make_response(payload):
    """Return payload as JSON text under Django's default content type.

    The first endpoints replied this way and the mobile client decodes the
    string itself, so they still do. Later endpoints use JsonResponse.
    """
    return HttpResponse(content=json.dumps(payload))


def error_response(message, status):
    """Return a JSON error whose body carries the same status as the HTTP response."""
    return JsonResponse({"status": status, "message": message}, status=status)


def json_endpoint(*required, header_token=True, as_text=False):
    """Turn `handler(data)` into a POST-only JSON view.

    required:      body fields that must be present, otherwise the reply is a 400.
    header_token:  put the Authorization header into data["token"]. Endpoints
                   written before the header was used read "token" from the body.
    as_text:       reply through make_response instead of JsonResponse.

    A handler may also return a ready HttpResponse, for example an error_response.

    The client is a mobile app that authenticates with a token and holds no
    session cookie, so the views are exempt from CSRF checks.
    """

    def decorator(handler):
        @csrf_exempt
        @require_POST
        @wraps(handler)
        def view(request):
            try:
                data = json.loads(request.body)
            except ValueError:
                return error_response("Request body is not valid JSON.", 400)
            if not isinstance(data, dict):
                return error_response("Request body must be a JSON object.", 400)

            if header_token:
                data["token"] = request.headers.get("Authorization")

            missing = [field for field in required if field not in data]
            if missing:
                return error_response(f"Missing fields: {', '.join(missing)}", 400)

            response = handler(data)
            if isinstance(response, HttpResponse):
                return response
            if as_text:
                return make_response(response)
            return JsonResponse(response, safe=False)

        return view

    return decorator


def redirect_to_cdn(key):
    """Redirect to the CloudFront copy of an object in the media bucket."""
    return HttpResponseRedirect(cdn_url(key))


def s3_object(key):
    """Fetch an object from the media bucket, or return an error response instead."""
    try:
        return BOTO_S3.get_object(Bucket=settings.AWS_STORAGE_BUCKET_NAME, Key=key), None
    except BOTO_S3.exceptions.NoSuchKey:
        return None, HttpResponse(status=404)
    except (BotoCoreError, ClientError):
        logging.exception("Could not read %s from S3", key)
        return None, HttpResponse(status=500)


def stream_from_s3(key, content_type):
    """Stream an object from the media bucket to the client."""
    s3_response, error = s3_object(key)
    if error:
        return error
    return FileResponse(s3_response["Body"], content_type=content_type)
