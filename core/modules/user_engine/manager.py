import logging
import datetime
import random
import string
import time
import uuid


from django.db import transaction
from django.conf import settings
from django.core.paginator import Paginator
from dj_rest_auth.models import get_token_model
from django_otp.oath import totp
from django.db.models import Sum, F, Window
from django.db.models.functions import RowNumber
from django.db.models import OuterRef, Subquery

from modules.analytics_engine.models import (
    ChannelMetrics,
    LogType,
    LogTypeAggregation,
    SeptemberContest,
    VideoXPDiffLog,
)

from modules.lounge_engine.models import UserPasswordReset

from limelight_core.users.models import User
from modules.user_engine.models import (
    BlockedProfiles,
    LimeLightStars,
    LoungeParticipants,
    ReportedUser,
    UserAccountRemovalRequest,
    UserExpLogs,
    UserGeolocations,
    UserProfile,
    Channel,
    ChannelSubscribers,
    Lounge,
)


from limelight_core.users.tasks import send_password_reset_email
from modules.s3 import BOTO_S3


class UserEngine:
    def __meta__(self):
        """Set the version, the build label and the page size used by the paginators."""
        self.VERSION = 0.9
        self.MAX_OBJECT_LIMIT = 14
        self.BUILD = "BETA"

    def __init__(self):
        """Initialize the User Engine Manager."""
        self.__meta__()

    def build_response(self, message):
        """Wrap a message in the response dictionary that the views send back."""
        return {"status": 200, "message": message}

    # ---------------------------------------------------------------------------
    # Accounts and profiles

    def create_user(self, data):
        """Create an active user from 'user_name', 'user_email' and 'user_password'."""
        user_name = data["user_name"]
        user_email = data["user_email"]
        user_password = data["user_password"]
        try:
            user = User()
            user.username = user_name
            user.email = user_email
            user.set_password(user_password)
            user.is_active = True
            user.save()
            return self.build_response("user successfully created.")
        except Exception as e:
            # NOTE: the exception text goes back to the client.
            logging.exception("User creation failed")
            return self.build_response(f"user creation failed {e}")

    def generate_unique_username(self, display_name):
        """Turn a display name into a username that no other user has."""
        base_username = "".join(ch for ch in display_name if ch.isalnum())
        username = base_username

        while User.objects.filter(username=username).exists():
            # If the username is taken, append a random string
            random_suffix = "".join(random.choices(string.ascii_letters + string.digits, k=5))
            username = f"{base_username}_{random_suffix}"

        return username

    def _apply_profile_fields(self, profile_obj, data):
        """Copy bio, age, gender and profile picture from the request data onto a profile."""
        profile_obj.bio = data.get("bio", "")
        profile_obj.age = data.get("age", 0)
        profile_obj.gender = data.get("gender", "")
        profile_obj.profile_picture = data.get("user_dp", None)

    def create_user_profile(self, data):
        """Create the profile, channel and lounge of the logged in user, or update the profile if it exists."""
        logged_in_user = self.get_logged_in_user(data.get("token"))
        profile_obj = self.get_user_profile(logged_in_user)
        if profile_obj:
            self._apply_profile_fields(profile_obj, data)

            profile_obj.associated_channel.channel_description = profile_obj.bio
            profile_obj.associated_channel.save()
            profile_obj.save()

            return self.build_response("success")

        profile_obj = UserProfile()
        profile_obj.user = logged_in_user
        profile_obj.save()

        # Every user gets one channel, and every channel gets one lounge that its owner joins.
        channel_obj = Channel.objects.create(name=profile_obj.user.username, owner=profile_obj)
        lounge_obj = Lounge.objects.create(channel=channel_obj)
        channel_obj.assoicated_lounge = lounge_obj
        channel_obj.save()

        LoungeParticipants.objects.get_or_create(member=profile_obj, lounge=lounge_obj)
        self._apply_profile_fields(profile_obj, data)

        profile_obj.associated_channel = channel_obj
        profile_obj.associated_lounge = lounge_obj
        profile_obj.save()

        return self.build_response("success")

    def update_user_profile(self, data):
        """Update the bio of the logged in user."""
        try:
            logged_in_user = self.get_logged_in_user(data.get("token"))

            if logged_in_user:
                profile_obj = self.get_user_profile(logged_in_user)
                profile_obj.bio = data.get("bio", profile_obj.bio)
                profile_obj.save()

                return self.build_response("Updated successfully.")
            else:
                return self.build_response("Not authenticated")

        except Exception as e:
            logging.exception("Error occurred when updating user profile")
            return self.build_response(f"Error occurred when updating user profile: {str(e)}")

    def _profile_media_key(self, profile, filename):
        """Return the S3 key of a profile image of this user."""
        return f"media/users/{profile.user.username}/{filename}"

    def update_profile_picture(self, token, media):
        """Replace the profile picture of the logged in user and delete the old file from S3."""
        logged_in_user = self.get_logged_in_user(token)
        if logged_in_user is not None:
            profile = self.get_user_profile(logged_in_user)
            try:
                if profile.profile_picture is not None:
                    profile_key = self._profile_media_key(profile, "profile_picture.jpeg")
                    BOTO_S3.delete_object(Bucket=settings.AWS_STORAGE_BUCKET_NAME, Key=profile_key)
            except Exception:
                logging.exception("Could not delete the old profile picture from S3")

            profile.profile_picture = media
            profile.save()
            return self.build_response("updated.")
        else:
            return self.build_response("Not authenicated")

    def update_profile_banner(self, token, media):
        """Replace the profile banner of the logged in user and delete the old file from S3."""
        logged_in_user = self.get_logged_in_user(token)
        if logged_in_user is not None:
            profile = self.get_user_profile(logged_in_user)
            try:
                if profile.profile_banner is not None:
                    profile_key = self._profile_media_key(profile, "profile_banner.jpeg")
                    BOTO_S3.delete_object(Bucket=settings.AWS_STORAGE_BUCKET_NAME, Key=profile_key)
            except Exception:
                logging.exception("Could not delete the old profile banner from S3")
            profile.profile_banner = media
            profile.save()
            return self.build_response("updated.")
        else:
            return self.build_response("Not authenicated")

    def delete_profile_picture(self, token):
        """Remove the profile picture of the logged in user and delete the file from S3."""
        logged_in_user = self.get_logged_in_user(token)
        if logged_in_user is not None:
            profile = self.get_user_profile(logged_in_user)
            if profile.profile_picture is not None:
                profile_key = self._profile_media_key(profile, "profile_picture.jpeg")
                BOTO_S3.delete_object(Bucket=settings.AWS_STORAGE_BUCKET_NAME, Key=profile_key)
            profile.profile_picture = None
            profile.save()
            return self.build_response("updated.")
        else:
            return self.build_response("Not authenicated")

    def delete_profile_banner(self, token):
        """Remove the profile banner of the logged in user and delete the file from S3."""
        logged_in_user = self.get_logged_in_user(token)
        if logged_in_user is not None:
            profile = self.get_user_profile(logged_in_user)
            try:
                if profile.profile_banner is not None:
                    profile_key = self._profile_media_key(profile, "profile_banner.jpeg")
                    BOTO_S3.delete_object(Bucket=settings.AWS_STORAGE_BUCKET_NAME, Key=profile_key)
            except Exception:
                logging.exception("Could not delete the profile banner from S3")
            profile.profile_banner = None
            profile.save()
            return self.build_response("updated.")
        else:
            return self.build_response("Not authenicated")

    def update_user_geo_locations(self, data):
        """Store the city, country and region of the logged in user, plus the device info sent with them."""
        logged_in_user = self.get_logged_in_user(data["token"])
        if logged_in_user is not None:
            profile = self.get_user_profile(logged_in_user)
            geo_location, _ = UserGeolocations.objects.get_or_create(user=profile)
            geo_location.city = data["city"]
            geo_location.country = data["country"]
            geo_location.region = data["region"]
            geo_location.last_updated = datetime.datetime.now()
            geo_location.save()

            profile.fcm_token = data.get("fcm_token", None)
            profile.device_model = data.get("device_model", None)
            profile.os_version = data.get("os_version")
            profile.device_info_updated_at = datetime.datetime.now()
            profile.save()
            return self.build_response("success")
        else:
            return self.build_response("Not authenicated")

    # ---------------------------------------------------------------------------
    # Channels and subscriptions

    def subscribe_channel(self, channel_id, token=None):
        """Subscribe the logged in user to a channel and raise its subscriber count."""
        if token:
            logged_in_user = self.get_logged_in_user(token)
            channel_obj = self.get_channel_object(channel_id)
            with transaction.atomic():
                _, created = ChannelSubscribers.objects.get_or_create(
                    channel=channel_obj, subscribed_by=self.get_user_profile(logged_in_user)
                )
                if created:
                    channel_obj.subscriber_count += 1
                    channel_obj.save()
                    logging.info(f"User {logged_in_user.username} subscribed to channel {channel_obj.name}.")
                    return self.build_response("Subscription successful.")

                return self.build_response("Already subscribed.")

        else:
            return self.build_response("Token invalid")

    def unsubscribe_channel(self, channel_id, token=None):
        """Unsubscribe the logged in user from a channel and lower its subscriber count."""
        if token:
            logged_in_user = self.get_logged_in_user(token)
            channel_obj = self.get_channel_object(channel_id)
            try:
                with transaction.atomic():
                    subscriber_obj = ChannelSubscribers.objects.get(
                        channel=channel_obj, subscribed_by=self.get_user_profile(logged_in_user)
                    )
                    subscriber_obj.delete()
                    channel_obj.subscriber_count -= 1

                    channel_obj.save()
                    logging.info(f"User {logged_in_user.username} unsubscribed from channel {channel_obj.name}.")
                    return self.build_response("Unsubscription successful.")
            except ChannelSubscribers.DoesNotExist:
                return self.build_response("Error: Subscriber not found for this channel and user.")
            except Exception:
                logging.exception("Error occurred while unsubscribing")
                return self.build_response("Internal Server Error")

        else:
            return self.build_response("Token invalid")

    def get_subscription_status(self, channel_id, user_id, just_bool=False):
        """Tell whether a user is subscribed to a channel."""
        try:
            channel_obj = self.get_channel_object(channel_id)
            user_obj = self.get_user_profile_with_id(user_id)
            ChannelSubscribers.objects.get(channel=channel_obj, subscribed_by=user_obj)
        except ChannelSubscribers.DoesNotExist:
            # NOTE: a missing subscription returns a bare False, also when just_bool is off.
            return False

        if just_bool:
            return True

        return self.build_response(True)

    def update_channel_details(self, token, data):
        """Update the name and description of the logged in user's channel."""
        try:
            logged_in_user = self.get_logged_in_user(token)
            user_profile = self.get_user_profile(logged_in_user)

            if user_profile:
                channel = user_profile.associated_channel
                channel.name = data.get("channel_name", channel.name)
                channel.channel_description = data.get("description", channel.channel_description)
                channel.save()
                logging.info(f"Channel details updated by user {logged_in_user.username}.")
                return self.build_response("Updated successfully.")
            else:
                logging.warning("Invalid token provided for updating channel details.")
                return self.build_response("Token invalid")
        except Exception:
            logging.exception("Error updating channel details")
            return self.build_response("Error occurred while updating channel details.")

    # ---------------------------------------------------------------------------
    # Serialisers

    def get_user_info(self, user):
        """Return the user and their profile as a dictionary."""
        profile_obj = self.get_user_profile(user)
        return self.to_json(user, profile_obj)

    def to_json(self, user, profile):
        """Convert a user and their profile, channel and lounge to a dictionary."""
        return {
            "user_id": user.id,
            "user_name": user.username,
            "user_email": user.email,
            "age": str(profile.age) if profile is not None else "",
            "bio": profile.bio if profile is not None else "",
            "gender": profile.gender if profile is not None else "",
            "profile_picture": profile.profile_picture.name if profile is not None else "",
            "profile_banner": profile.profile_banner.name if profile is not None else "",
            "joined_communities": str(profile.joined_lounges) if profile is not None else "0",
            "creation_date": str(profile.creation_date),
            "is_creator": profile.is_creator,
            "is_advertisor": profile.is_advertiser,
            "is_banned": profile.is_banned,
            "user_channel": self.channel_to_dict(profile.associated_channel),
            "user_lounge": self.lounge_to_dict(profile.associated_lounge),
        }

    def channel_to_dict(self, channel_obj):
        """Convert a channel to a dictionary."""
        return {
            "id": str(channel_obj.id),
            "name": channel_obj.name,
            "channel_description": channel_obj.channel_description,
            "subscriber_count": channel_obj.subscriber_count,
            "videos_count": channel_obj.videos_count,
            "level": channel_obj.level,
            "XP": channel_obj.XP,
            "metrics_last_updated": channel_obj.metrics_last_updated.isoformat(),
        }

    def lounge_to_dict(self, lounge_obj):
        """Convert a lounge to a dictionary."""
        return {
            "id": str(lounge_obj.id),
            "total_members": lounge_obj.total_members,
            "total_categories": lounge_obj.total_categories,
            "lounge_description": lounge_obj.lounge_description,
            "lounge_tiers": lounge_obj.lounge_tiers,
            "name": lounge_obj.name,
            "xp": lounge_obj.lounge_xp,
            "level": lounge_obj.lounge_level,
            "is_public": lounge_obj.is_public,
        }

    # ---------------------------------------------------------------------------
    # Password reset
    #
    # start_reset_pipeline stores a 6 digit code for the email and mails it.
    # verify_otp marks the stored request as verified when the code matches.
    # reset_password sets the new password if the request for that email is verified.
    #
    # NOTE: verify_otp has no attempt limit, and reset_password only checks the
    # email, so it does not prove the caller is the one who verified the code.

    def save_reset_obj(self, email, otp):
        """Store a password reset request. Returns 100 on success and -111 on failure."""
        try:
            obj = UserPasswordReset()
            obj.user_email = email
            obj.user_verification_code = otp
            obj.save()
            return 100
        except Exception:
            logging.exception("Could not save the password reset request")
            return -111

    def reset_password(self, email, password):
        """Set a new password if the reset request for this email has a verified OTP."""
        try:
            reset_obj = self.get_reset_object(email)
            if reset_obj.is_authenicated:
                user_obj = self.get_user_via_email(email)
                user_obj.set_password(password)
                user_obj.save()
                self.clean_up_obj(email)
                return self.build_response("Password reset successful. You can login with your new password now.")
            # NOTE: returns None when the OTP has not been verified yet.
        except Exception:
            logging.exception("Error while changing password")
            self.clean_up_obj(email)
            return self.build_response("Error while changing password.")

    def get_user_via_email(self, email):
        """Return the user with this email. Raises User.DoesNotExist if there is none."""
        return User.objects.get(email=email)

    def send_email(self, email, otp):
        """Queue the OTP email. Drops the reset request if the email cannot be queued."""
        try:
            user_obj = self.get_user_via_email(email)
            send_password_reset_email.delay(user_obj.username, otp, email)
            return self.build_response("Mail sent with OTP.")
        except Exception as E:
            # NOTE: the exception text goes back to the client, so an unknown email is told apart from a known one.
            logging.exception("Error occurred while sending the password reset email")
            self.clean_up_obj(email)
            return self.build_response(f"Error occurred while sending email. {E}")

    def clean_up_obj(self, email):
        """Delete the reset request of this email. Returns 100 on success and -111 on failure."""
        obj = self.get_reset_object(email)
        if obj is None:
            return -111
        try:
            obj.delete()
            return 100
        except Exception:
            logging.exception("Could not delete the password reset request")
            return -111

    def verify_otp(self, email, input_otp):
        """Mark the reset request of this email as verified if the OTP matches."""
        reset_obj = self.get_reset_object(email)
        if reset_obj is None:
            return self.build_response("OTP might have expired. Please try again.")
        true_otp = reset_obj.user_verification_code
        if str(input_otp) == str(true_otp):
            reset_obj.is_authenicated = True
            reset_obj.save()
            return self.build_response("OTP verification successful")
        else:
            return self.build_response("OTP does not match.")

    def generate_session_id(self):
        """Return a random 32 character uppercase hex string."""
        session_id = str(uuid.uuid4()).upper().replace("-", "")
        return session_id

    def generate_password_reset_otp(self, email):
        """Return a one-time code of up to 6 digits. The TOTP key is random, so the code is random too."""
        now = int(time.time())
        return totp(key=bytes(self.generate_session_id(), "utf-8"), step=900, digits=6, t0=now)

    def get_reset_object(self, user_email):
        """Return the pending reset request of this email, or None."""
        return UserPasswordReset.objects.filter(user_email=user_email).first()

    def start_reset_pipeline(self, email):
        """Create a reset request for this email and mail the OTP, unless one is already pending."""
        if self.get_reset_object(email):
            return self.build_response("User has already raised a password reset request.")

        otp = self.generate_password_reset_otp(email)

        if self.save_reset_obj(email, otp) == 100:
            return self.send_email(email, otp)
        else:
            return self.build_response("Something occurred internally.")

    # ---------------------------------------------------------------------------
    # Lookups

    def get_user_object(self, user_id):
        """Return the user with this id. Raises User.DoesNotExist if there is none."""
        return User.objects.get(id=user_id)

    def get_user_profile(self, user_obj):
        """Return the profile of a user, or None."""
        return UserProfile.objects.filter(user=user_obj).first()

    def get_user_profile_with_id(self, id):
        """Return the profile of the user with this id, or None."""
        try:
            user = self.get_user_object(id)
            return self.get_user_profile(user)
        except User.DoesNotExist:
            return None
        except Exception:
            logging.exception("Could not load the profile of user %s", id)
            return None

    def get_logged_in_user(self, key):
        """Return the user who owns this auth token, or None."""
        token_model = get_token_model()
        try:
            return token_model.objects.get(key=key).user
        except token_model.DoesNotExist:
            return None

    def get_channel_object(self, channel_id):
        """Return the channel with this id, or None."""
        return Channel.objects.filter(id=channel_id).first()

    # ---------------------------------------------------------------------------
    # XP rankings, top users and star creators

    def update_user_rankings(self):
        """
        Rank creators by the XP their videos gained today, in the last 7 days and this month.

        Reads VideoXPDiffLog, sums the XP differences per creator for each window, numbers the
        creators from 1 in descending order of that sum, and stores sum, rank and date in UserExpLogs.
        """
        today = datetime.datetime.now().date()

        # Day: logs written today.
        daily_xp_qs = (
            VideoXPDiffLog.objects.filter(logged_at__date=today)
            .values("video__creator")
            .annotate(day_xp_diff=Sum("day_usage_difference"))
            .order_by("-day_xp_diff")
        )

        daily_ranked_qs = daily_xp_qs.annotate(
            daily_rank=Window(
                expression=RowNumber(),
                order_by=F("day_xp_diff").desc(),
            )
        )

        # Week: logs from 7 days ago up to and including today.
        week_start = today - datetime.timedelta(days=7)
        weekly_xp_qs = (
            VideoXPDiffLog.objects.filter(logged_at__date__range=[week_start, today])
            .values("video__creator")
            .annotate(week_xp_diff=Sum("week_usage_difference"))
            .order_by("-week_xp_diff")
        )

        weekly_ranked_qs = weekly_xp_qs.annotate(
            weekly_rank=Window(
                expression=RowNumber(),
                order_by=F("week_xp_diff").desc(),
            )
        )

        # Month: logs from the first day of the current month up to and including today.
        month_start = today.replace(day=1)
        monthly_xp_qs = (
            VideoXPDiffLog.objects.filter(logged_at__date__range=[month_start, today])
            .values("video__creator")
            .annotate(month_xp_diff=Sum("month_usage_difference"))
            .order_by("-month_xp_diff")
        )

        monthly_ranked_qs = monthly_xp_qs.annotate(
            monthly_rank=Window(
                expression=RowNumber(),
                order_by=F("month_xp_diff").desc(),
            )
        )

        # One UserExpLogs row per creator. Each loop only writes the columns of its own window.
        for user_data in daily_ranked_qs:
            user_id = user_data["video__creator"]
            day_diff = user_data["day_xp_diff"]
            daily_rank = user_data["daily_rank"]

            UserExpLogs.objects.update_or_create(
                linked_user_id=user_id,
                defaults={
                    "day_difference": day_diff,
                    "daily_rank": daily_rank,
                    "day_update_date": today,
                },
            )

        for user_data in weekly_ranked_qs:
            user_id = user_data["video__creator"]
            week_diff = user_data["week_xp_diff"]
            weekly_rank = user_data["weekly_rank"]

            UserExpLogs.objects.update_or_create(
                linked_user_id=user_id,
                defaults={
                    "weekly_difference": week_diff,
                    "weekly_rank": weekly_rank,
                    "week_update_date": today,
                },
            )

        for user_data in monthly_ranked_qs:
            user_id = user_data["video__creator"]
            month_diff = user_data["month_xp_diff"]
            monthly_rank = user_data["monthly_rank"]

            UserExpLogs.objects.update_or_create(
                linked_user_id=user_id,
                defaults={
                    "monthly_difference": month_diff,
                    "monthly_rank": monthly_rank,
                    "month_update_date": today,
                },
            )

    def log_to_json(self, user_profile):
        """Return the XP differences and ranks stored for a profile, with the profile itself."""
        xp_log_obj = UserExpLogs.objects.filter(linked_user=user_profile).first()
        return {
            "day_difference": xp_log_obj.day_difference,
            "weekly_difference": xp_log_obj.weekly_difference,
            "monthly_difference": xp_log_obj.monthly_difference,
            "daily_rank": xp_log_obj.daily_rank,
            "weekly_rank": xp_log_obj.weekly_rank,
            "monthly_rank": xp_log_obj.monthly_rank,
            "user_profile": self.to_json(user_profile.user, user_profile),
        }

    def get_top_videos(self, user_id):
        """Return the published video of this user with the highest XP, or None."""
        from modules.video_engine.models import VideoPost
        from modules.video_engine.manager import video_metadata_to_json_obj

        top_video = (
            VideoPost.objects.filter(creator__user__id=user_id)
            .filter(is_active=True, is_encoded=True, gone_through_ml=True)
            .order_by("-video_xp")
            .first()
        )
        return video_metadata_to_json_obj(top_video) if top_video is not None else None

    def get_top_comment(self, user_id, token):
        """Return (video, comment) for the most liked comment of this user, or (None, None)."""
        from modules.video_engine.models import Comment
        from modules.video_engine.manager import VideoEngineManager, video_metadata_to_json_obj

        top_comment = Comment.objects.filter(commented_by__user__id=user_id).order_by("-likes").first()
        if (
            top_comment is not None
            and top_comment.video.is_active
            and top_comment.video.is_encoded
            and top_comment.video.gone_through_ml
        ):
            return (
                video_metadata_to_json_obj(top_comment.video),
                VideoEngineManager().comment_metadata_to_json_obj(top_comment, token),
            )
        return (None, None)

    def _add_viewer_context(self, pagination_result, token, logged_in_user, top_content=False, subscription=True):
        """Add the fields that depend on the viewer to every user of a page.

        Always adds block_status and reverse_block. Adds subscription_status and the
        user's top video and top comment when asked.
        """
        if "data" not in pagination_result:
            return pagination_result

        for user_map in pagination_result["data"]:
            user_id = user_map["user_id"]
            if top_content:
                associated_video, top_comment = self.get_top_comment(user_id, token)
                user_map["top_video"] = self.get_top_videos(user_id)
                user_map["top_comment"] = top_comment
                user_map["associated_video"] = associated_video
            user_map["block_status"] = self.check_block(token, user_id, as_bool=True)
            user_map["reverse_block"] = self.check_reverse_block(logged_in_user.id, user_id, as_bool=True)
            if subscription:
                user_map["subscription_status"] = self.get_subscription_status(
                    user_map["user_channel"]["id"], logged_in_user.id, just_bool=True
                )
        return pagination_result

    def get_star_creators(self, token, page_number):
        """Return a page of the users listed in LimeLightStars, with their top video and top comment."""
        star_qs = LimeLightStars.objects.all()
        user_qs = UserProfile.objects.filter(user__in=star_qs.values("linked_user__user")).all()
        pagination_result = self.user_paginator(user_qs, page_number)
        logged_in_user = self.get_logged_in_user(token)
        return self._add_viewer_context(pagination_result, token, logged_in_user, top_content=True)

    def _get_top_users(self, log_type, days, page_number, token, city, country, region):
        """Return a page of users ordered by the video XP of their channel in a recent window.

        Takes the TOTAL ChannelMetrics rows of the given log type from the last `days` days
        and orders the channel owners by the highest video_xp among their rows.
        """
        end_date = datetime.datetime.now()
        start_date = end_date - datetime.timedelta(days=days)
        channel_logs = ChannelMetrics.objects.filter(
            log_type=log_type, aggregation_type=LogTypeAggregation.TOTAL, log_date__range=(start_date, end_date)
        ).order_by("-video_xp")
        user_qs = UserProfile.objects.filter(associated_channel__in=channel_logs.values("channel")).distinct().all()

        # The app sends the string "null" for a location filter it does not use.
        # Only the first filter that is set applies: city, then country, then region.
        for field, value in (("city", city), ("country", country), ("region", region)):
            if value != "null":
                geo_qs = UserGeolocations.objects.filter(**{field: value})
                user_qs = user_qs.filter(user__in=geo_qs.values("user__user"))
                break

        user_qs = user_qs.annotate(
            video_xp=Subquery(
                channel_logs.filter(channel=OuterRef("associated_channel"))
                .order_by("-video_xp")
                .values("video_xp")[:1]
            )
        ).order_by("-video_xp")
        pagination_result = self.user_paginator(user_qs, page_number)

        logged_in_user = self.get_logged_in_user(token)
        return self._add_viewer_context(pagination_result, token, logged_in_user, top_content=True)

    def get_top_users_day(self, page_number, token, city=None, country=None, region=None):
        """Top users by the daily channel metrics of the last day."""
        return self._get_top_users(LogType.DAY, 1, page_number, token, city, country, region)

    def get_top_users_week(self, page_number, token, city=None, country=None, region=None):
        """Top users by the weekly channel metrics of the last 7 days."""
        return self._get_top_users(LogType.WEEK, 7, page_number, token, city, country, region)

    def get_top_users_month(self, page_number, token, city=None, country=None, region=None):
        """Top users by the monthly channel metrics of the last 30 days."""
        return self._get_top_users(LogType.MONTH, 30, page_number, token, city, country, region)

    def get_top_users_year(self, page_number, token, city=None, country=None, region=None):
        """Top users by the yearly channel metrics of the last 30 days."""
        # NOTE: the window is 30 days, the same as the monthly list. No view calls this.
        return self._get_top_users(LogType.YEAR, 30, page_number, token, city, country, region)

    def get_subscribed_to(self, page_number, token):
        """Return a page of the users whose channels the logged in user is subscribed to."""
        if token is None:
            raise Exception("Token cannot be empty")

        logged_in_user = self.get_logged_in_user(token)
        if not logged_in_user:
            raise Exception("No logged in user found.")

        user_profile = self.get_user_profile(logged_in_user)
        subscribed_to_qs = ChannelSubscribers.objects.filter(subscribed_by=user_profile).order_by("-creation_date")
        user_qs = UserProfile.objects.filter(user__in=subscribed_to_qs.values("channel__owner__user"))
        pagination_result = self.user_paginator(user_qs, page_number)
        return self._add_viewer_context(pagination_result, token, logged_in_user)

    # ---------------------------------------------------------------------------
    # September contest

    def contest_to_json(self, contest):
        """Convert a September contest entry to a dictionary."""
        return {
            "user": self.to_json(contest.user.user, contest.user),
            "subscriber_count": contest.subscriber_count,
            "end_date": str(contest.end_date),
            "start_date": str(contest.start_date),
            "creation_date": str(contest.creation_date),
        }

    def get_september_contest_details(self, token):
        """Return the September contest entry of the logged in user, creating it on first use."""
        if token is None:
            raise Exception("Token cannot be empty")

        logged_in_user = self.get_logged_in_user(token)
        if not logged_in_user:
            raise Exception("No logged in user found.")

        user_profile = self.get_user_profile(logged_in_user)

        contest_object, _ = SeptemberContest.objects.get_or_create(user=user_profile)
        return self.contest_to_json(contest_object)

    # ---------------------------------------------------------------------------
    # Session checks

    def check_ban_status(self, user_id):
        """Tell whether the user with this id is banned."""
        if user_id is None:
            raise Exception("Token cannot be empty")

        user_profile = self.get_user_profile_with_id(user_id)
        return self.build_response(user_profile.is_banned)

    def recheck_token(self, token):
        """Tell whether an auth token still exists."""
        if token is None:
            return self.build_response(False)

        try:
            return self.build_response(get_token_model().objects.filter(key=token).exists())
        except Exception:
            logging.exception("Could not check the auth token")
            return self.build_response(False)

    # ---------------------------------------------------------------------------
    # Paginators

    def _paginate(self, query_set, page_number, serialise):
        """Return one page of a query set, with each object passed through `serialise`."""
        pagination_obj = Paginator(query_set, self.MAX_OBJECT_LIMIT)
        total_pages = pagination_obj.page_range[-1]
        if page_number > total_pages:
            return {"status": -131, "message": f"Page number does not exists. (total pages available : {total_pages})"}
        response = {
            "page_number": page_number,
            "total_pages": total_pages,
            "data": [serialise(obj) for obj in pagination_obj.get_page(page_number)],
        }

        return response

    def token_paginator(
        self,
        query_set,
        page_number,
        serialiser,
        token=None,
    ):
        """Paginate a query set, serialising each object with `serialiser(obj, token)`."""
        return self._paginate(query_set, page_number, lambda obj: serialiser(obj, token))

    def user_paginator(self, query_set, page_number):
        """Paginate a query set of user profiles, serialising each one with `to_json`."""
        return self._paginate(query_set, page_number, lambda obj: self.to_json(obj.user, obj))

    # ---------------------------------------------------------------------------
    # Reports, account removal and blocking

    def report_user(self, token, user_id, reason):
        """Record a report by the logged in user against another user."""
        logged_in_user = self.get_logged_in_user(token)

        logged_in_profile = self.get_user_profile_with_id(logged_in_user.id)
        reported_user = self.get_user_profile_with_id(user_id)

        reported_obj = ReportedUser()
        reported_obj.user = reported_user
        reported_obj.reason = reason
        reported_obj.reported_by = logged_in_profile

        reported_obj.save()
        return self.build_response("success")

    def add_user_account_removal_request(self, token, reason):
        """Record a request by the logged in user to have their account removed."""
        logged_in_user = self.get_logged_in_user(token)

        logged_in_profile = self.get_user_profile_with_id(logged_in_user.id)

        request = UserAccountRemovalRequest()
        request.user = logged_in_profile
        request.reason = reason
        request.save()
        return self.build_response("success")

    def _get_logged_in_profile(self, token):
        """Return the profile behind a token. Raises if the token is empty or unknown."""
        if token is None:
            raise Exception("Empty Token")

        logged_in_user = self.get_logged_in_user(token)

        if logged_in_user is None:
            raise Exception("Session invalid")

        return self.get_user_profile_with_id(logged_in_user.id)

    def block_user(self, token, user_id):
        """Block a user on behalf of the logged in user."""
        logged_in_profile = self._get_logged_in_profile(token)

        request = BlockedProfiles()
        request.blocked_by = logged_in_profile
        request.user = self.get_user_profile_with_id(user_id)
        request.save()
        return self.build_response("success")

    def unblock_user(self, token, user_id):
        """Remove the logged in user's block on a user."""
        logged_in_profile = self._get_logged_in_profile(token)

        BlockedProfiles.objects.filter(
            blocked_by=logged_in_profile, user=self.get_user_profile_with_id(user_id)
        ).delete()
        return self.build_response("success")

    def check_block(self, token, user_id, as_bool=False):
        """Tell whether the logged in user has blocked this user."""
        logged_in_profile = self._get_logged_in_profile(token)

        obj = BlockedProfiles.objects.filter(
            blocked_by=logged_in_profile, user=self.get_user_profile_with_id(user_id)
        ).first()
        if as_bool:
            return obj is not None

        return self.build_response(obj is not None)

    def check_reverse_block(self, root_id, user_id, as_bool=False):
        """Tell whether the user `user_id` has blocked the user `root_id`."""
        logged_in_profile = self.get_user_profile_with_id(root_id)

        obj = BlockedProfiles.objects.filter(
            user=logged_in_profile, blocked_by=self.get_user_profile_with_id(user_id)
        ).first()
        if as_bool:
            return obj is not None

        return self.build_response(obj is not None)

    def check_user_account_removal_request(self, token):
        """Tell whether the logged in user has asked for their account to be removed."""
        logged_in_profile = self._get_logged_in_profile(token)

        obj = UserAccountRemovalRequest.objects.filter(user=logged_in_profile).first()
        return self.build_response(obj is not None)

    def get_blocked_users(self, page_number, token):
        """Return a page of the users that the logged in user has blocked."""
        if token is None:
            raise Exception("Token cannot be empty")

        logged_in_user = self.get_logged_in_user(token)
        if not logged_in_user:
            raise Exception("No logged in user found.")

        user_profile = self.get_user_profile(logged_in_user)
        blocked_qs = BlockedProfiles.objects.filter(blocked_by=user_profile).order_by("-added_at")
        user_qs = UserProfile.objects.filter(user__in=blocked_qs.values("user__user"))
        pagination_result = self.user_paginator(user_qs, page_number)
        return self._add_viewer_context(pagination_result, token, logged_in_user, subscription=False)
