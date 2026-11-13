import hashlib
import json
import urllib.parse

import jwt
import requests
from django.conf import settings
from django.http import HttpResponseRedirect, JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
from google.auth.exceptions import GoogleAuthError
from google.auth.transport import requests as google_requests
from google.oauth2 import id_token
from rest_framework.authtoken.models import Token

from limelight_core.users.models import User
from modules.api import error_response, json_endpoint, make_response, redirect_to_cdn, stream_from_s3
from modules.user_engine.manager import UserEngine
from modules.user_engine.models import LoungeParticipants

user_control_object = UserEngine()

APPLE_ISSUER = "https://appleid.apple.com"
APPLE_PUBLIC_KEYS_URL = "https://appleid.apple.com/auth/keys"
ANDROID_PACKAGE = "ai.limetime.client.lime_time_app"


# Sign in with Google and Apple
# ------------------------------------------------------------------------------


def get_apple_public_key(kid):
    """Fetch the Apple signing key with the given key id."""
    response = requests.get(APPLE_PUBLIC_KEYS_URL, timeout=10)
    response.raise_for_status()
    for key in response.json().get("keys", []):
        if key["kid"] == kid:
            return key
    raise jwt.InvalidTokenError("No matching Apple public key")


def decode_apple_id_token(apple_token):
    """Verify an Apple identity token against Apple's public keys and return its claims."""
    kid = jwt.get_unverified_header(apple_token)["kid"]
    public_key = jwt.algorithms.RSAAlgorithm.from_jwk(json.dumps(get_apple_public_key(kid)))
    # NOTE: the audience (the app's bundle id or service id) is not checked.
    return jwt.decode(
        apple_token,
        public_key,
        algorithms=["RS256"],
        issuer=APPLE_ISSUER,
        options={"verify_aud": False},
    )


def login_social_user(email, provider_user_id, make_username):
    """Find or create the account for a verified social login and return the login response."""
    user, created = User.objects.get_or_create(email=email)
    if created:
        user.username = make_username()
        # NOTE: the password is derived from the provider's user id, which is not a secret.
        # set_unusable_password() would be the safer choice.
        user.set_password(hashlib.sha256(provider_user_id.encode("utf-8")).hexdigest())
        user.save()

    token, _ = Token.objects.get_or_create(user=user)
    if not user_control_object.get_user_profile(user):
        profile_status = user_control_object.create_user_profile({"token": token.key})
        if profile_status["message"] != "success":
            user.delete()
            return error_response("Authentication failed - I", 401)

    profile = user_control_object.get_user_profile(user)
    LoungeParticipants.objects.get_or_create(member=profile, lounge=profile.associated_lounge)
    return JsonResponse(
        {
            "status": 200,
            "message": "Login successful",
            "key": token.key,
            "user_info": user_control_object.to_json(user, profile),
        }
    )


@json_endpoint("token", header_token=False)
def validate_google_id_token(data):
    """Log in, or sign up, with a Firebase ID token from Google sign-in."""
    try:
        id_info = id_token.verify_firebase_token(
            data["token"],
            google_requests.Request(),
            audience=settings.FIREBASE_PROJECT_ID,
            clock_skew_in_seconds=16,
        )
    except (ValueError, GoogleAuthError):
        return error_response("Invalid token", 401)

    return login_social_user(
        email=id_info["email"],
        provider_user_id=id_info["sub"],
        make_username=lambda: user_control_object.generate_unique_username(id_info["name"]),
    )


@json_endpoint("token", header_token=False)
def validate_apple_id_token(data):
    """Log in, or sign up, with an identity token from Sign in with Apple."""
    try:
        claims = decode_apple_id_token(data["token"])
    except (jwt.PyJWTError, KeyError, requests.RequestException):
        return error_response("Invalid token", 401)

    if not claims.get("email_verified"):
        return error_response("E-Mail verification failed", 401)

    return login_social_user(
        email=claims["email"],
        provider_user_id=claims["sub"],
        make_username=lambda: claims["email"],
    )


class AndroidIntentRedirect(HttpResponseRedirect):
    allowed_schemes = ["intent"]


@csrf_exempt
@require_POST
def apple_callback(request):
    """Hand Apple's web sign-in callback back to the Android app through an intent URL."""
    encoded_parameters = urllib.parse.urlencode(request.POST.dict())
    return AndroidIntentRedirect(
        f"intent://callback?{encoded_parameters}#Intent;"
        f"package={ANDROID_PACKAGE};"
        f"scheme=signinwithapple;end"
    )


# Accounts
# ------------------------------------------------------------------------------


@json_endpoint("user_name", "user_email", "user_password", as_text=True)
def create_user_api(data):
    """Create an account with a username, email and password."""
    return user_control_object.create_user(data)


@csrf_exempt
@require_POST
def create_user_profile(request):
    """Create or update the logged-in user's profile. Multipart, with an optional `media` picture."""
    data = {
        "token": request.headers.get("Authorization"),
        "bio": request.POST.get("bio"),
        "age": request.POST.get("age"),
        "gender": request.POST.get("gender"),
    }
    if "media" in request.FILES:
        data["user_dp"] = request.FILES["media"]
    return make_response(user_control_object.create_user_profile(data))


@json_endpoint("token", header_token=False, as_text=True)
def get_logged_in_user(data):
    """Return the account and profile that a session token belongs to."""
    user = user_control_object.get_logged_in_user(data["token"])
    if user is None:
        return error_response("Invalid Login credentials", 401)
    return user_control_object.get_user_info(user)


@json_endpoint("user_id")
def get_user_info(data):
    """Return another user's public profile, with block and subscription state for the caller."""
    logged_in_user = user_control_object.get_logged_in_user(data["token"])
    if logged_in_user is None:
        return error_response("Invalid Login credentials", 401)
    user_profile = user_control_object.get_user_profile_with_id(data["user_id"])
    if user_profile is None:
        return error_response("User not found", 404)

    user_info = user_control_object.to_json(user_profile.user, user_profile)
    user_info["block_status"] = user_control_object.check_block(data["token"], user_info["user_id"], as_bool=True)
    user_info["reverse_block"] = user_control_object.check_reverse_block(
        logged_in_user.id, user_info["user_id"], as_bool=True
    )
    user_info["subscription_status"] = user_control_object.get_subscription_status(
        user_info["user_channel"]["id"], logged_in_user.id, just_bool=True
    )
    return user_info


@json_endpoint()
def recheck_token(data):
    """Check that the session token is still valid."""
    return user_control_object.recheck_token(data["token"])


@json_endpoint("user_id")
def check_ban(data):
    """Return whether a user is banned."""
    return user_control_object.check_ban_status(data["user_id"])


@json_endpoint()
def update_geo_location(data):
    """Store the location the client reports for the logged-in user."""
    return user_control_object.update_user_geo_locations(data)


# Password reset
# ------------------------------------------------------------------------------


@json_endpoint("email")
def start_reset_pipeline(data):
    """Email a one-time code to start a password reset."""
    return user_control_object.start_reset_pipeline(data["email"])


@json_endpoint("email", "otp")
def verify_otp(data):
    """Check the one-time code from the reset email."""
    return user_control_object.verify_otp(data["email"], data["otp"])


@json_endpoint("email", "password")
def reset_password(data):
    """Set a new password once the one-time code has been verified."""
    return user_control_object.reset_password(data["email"], data["password"])


# Profile and channel
# ------------------------------------------------------------------------------


def get_media_url(_, user_name):
    """Stream a user's profile picture from S3."""
    return stream_from_s3(f"media/users/{user_name}/profile_picture.jpeg", "image/jpeg")


def get_banner(_, user_name):
    """Redirect to a user's profile banner on the CDN."""
    return redirect_to_cdn(f"media/users/{user_name}/profile_banner.jpeg")


def _upload_profile_media(request, save):
    """Shared body of the two multipart profile image uploads."""
    if "media" not in request.FILES:
        return error_response("Missing fields: media", 400)
    return make_response(save(request.headers.get("Authorization"), request.FILES["media"]))


@csrf_exempt
@require_POST
def update_profile_picture(request):
    """Replace the logged-in user's profile picture. Multipart, file field `media`."""
    return _upload_profile_media(request, user_control_object.update_profile_picture)


@csrf_exempt
@require_POST
def update_profile_banner(request):
    """Replace the logged-in user's profile banner. Multipart, file field `media`."""
    return _upload_profile_media(request, user_control_object.update_profile_banner)


@json_endpoint()
def delete_user_profile_picture(data):
    """Remove the logged-in user's profile picture."""
    return user_control_object.delete_profile_picture(data["token"])


@json_endpoint()
def delete_user_profile_banner(data):
    """Remove the logged-in user's profile banner."""
    return user_control_object.delete_profile_banner(data["token"])


@json_endpoint()
def update_profile_details(data):
    """Update the logged-in user's profile fields."""
    return user_control_object.update_user_profile(data)


@json_endpoint()
def update_channel_details(data):
    """Update the logged-in user's channel details."""
    return user_control_object.update_channel_details(data["token"], data)


# Subscriptions
# ------------------------------------------------------------------------------


@json_endpoint("channel_id")
def subscribe_channel(data):
    """Subscribe the logged-in user to a channel."""
    return user_control_object.subscribe_channel(data["channel_id"], data["token"])


@json_endpoint("channel_id")
def unsubscribe_channel(data):
    """Unsubscribe the logged-in user from a channel."""
    return user_control_object.unsubscribe_channel(data["channel_id"], data["token"])


@json_endpoint("channel_id", "user_id")
def subscription_status(data):
    """Return whether a user is subscribed to a channel."""
    return user_control_object.get_subscription_status(data["channel_id"], data["user_id"])


@json_endpoint("page_number")
def get_subscribed_to_api(data):
    """List the channels the logged-in user is subscribed to."""
    return user_control_object.get_subscribed_to(data["page_number"], data["token"])


# Leaderboards
# ------------------------------------------------------------------------------


def _top_users(data, ranking):
    """Shared body of the day, week and month leaderboards, optionally filtered by place."""
    return ranking(data["page_number"], data["token"], data.get("city"), data.get("country"), data.get("region"))


@json_endpoint("page_number")
def get_top_users_day_view(data):
    """List the top creators of the day."""
    return _top_users(data, user_control_object.get_top_users_day)


@json_endpoint("page_number")
def get_top_users_week_view(data):
    """List the top creators of the week."""
    return _top_users(data, user_control_object.get_top_users_week)


@json_endpoint("page_number")
def get_top_users_month_view(data):
    """List the top creators of the month."""
    return _top_users(data, user_control_object.get_top_users_month)


@json_endpoint("page_number")
def get_star_creators(data):
    """List the creators picked as LimeLight Stars."""
    return user_control_object.get_star_creators(data["token"], data["page_number"])


@json_endpoint()
def get_september_contest_details(data):
    """Return the September creator contest details for the logged-in user."""
    return user_control_object.get_september_contest_details(data["token"])


# Blocking, reporting and account removal
# ------------------------------------------------------------------------------


@json_endpoint("user_id")
def block_user(data):
    """Block a user for the logged-in user."""
    return user_control_object.block_user(data["token"], data["user_id"])


@json_endpoint("user_id")
def unblock_user(data):
    """Remove a block the logged-in user placed."""
    return user_control_object.unblock_user(data["token"], data["user_id"])


@json_endpoint("user_id")
def check_block(data):
    """Return whether the logged-in user has blocked a user."""
    return user_control_object.check_block(data["token"], data["user_id"])


@json_endpoint("page_number")
def get_blocked_users(data):
    """List the users the logged-in user has blocked."""
    return user_control_object.get_blocked_users(data["page_number"], data["token"])


@json_endpoint("user_id", "reason")
def report_user(data):
    """Report a user to the moderators."""
    return user_control_object.report_user(data["token"], data["user_id"], data["reason"])


@json_endpoint("reason")
def add_user_account_removal_request(data):
    """Ask for the logged-in user's account to be deleted."""
    return user_control_object.add_user_account_removal_request(data["token"], data["reason"])


@json_endpoint()
def check_user_account_removal_request(data):
    """Return whether the logged-in user has a pending account deletion request."""
    return user_control_object.check_user_account_removal_request(data["token"])
