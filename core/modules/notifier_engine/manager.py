import logging

import firebase_admin
from django.conf import settings
from django.core.paginator import Paginator
from modules.lounge_engine.manager import LoungeManager
from modules.lounge_engine.models import LoungePost
from modules.notifier_engine.models import (
    LoungePostNotification,
    LoungePostReplyNotification,
    PromotionalNotification,
    VideoCommentNotification,
    VideoCommentReplyNotification,
    VideoLikeScheduledNotification,
    VideoProcessedNotification,
    VideoUploadedNotification,
)
from modules.user_engine.manager import UserEngine
from modules.user_engine.models import ChannelSubscribers, LoungeParticipants, UserProfile
from modules.video_engine.manager import video_metadata_to_json_obj, VideoEngineManager
from modules.video_engine.models import Comment, VideoPost
from pyfcm import FCMNotification


class NotifierEngine:
    """Creates notification rows, pushes them through Firebase Cloud Messaging and serves the in-app lists."""

    def __meta__(self):
        self.VERSION = 0.1
        self.MAX_OBJECT_LIMIT = 30
        self.BUILD = "PRE_ALPHA"

    def __init__(self):
        self.__meta__()
        self.__load_fcm_json_credentials__()

    def __load_fcm_json_credentials__(self):
        """Load the Firebase service account named by settings.FIREBASE_CREDENTIALS_FILE."""
        json_path = settings.FIREBASE_CREDENTIALS_FILE
        self.cred = firebase_admin.credentials.Certificate(json_path)
        self.push_service = FCMNotification(service_account_file=json_path, project_id=settings.FIREBASE_PROJECT_ID)
        firebase_admin.initialize_app(self.cred)

    def build_response(self, message):
        """Wrap a message in the standard {"status": 200, "message": ...} payload."""
        return {"status": 200, "message": message}

    def register_video_uploaded_notification(
        self, receiver: UserProfile, video: VideoPost
    ) -> VideoUploadedNotification | None:
        """Create the "new video" notification for one subscriber and push it once."""
        try:
            notification_object, created = VideoUploadedNotification.objects.get_or_create(
                receiver=receiver, linked_video=video
            )
            if created:
                notification_object.message_json = f"@{video.creator.user.username} has uploaded a new video."
                notification_object.save()
                self.run_function_on_celery(self.send_video_uploaded_notification, notification_object)

            logging.info("> Registered video uploaded notification.")
            return notification_object
        except Exception as e:
            logging.warning(f"> Error occurred while registering video uploaded notification: {str(e)}")

    def register_lounge_post_notification(
        self, receiver: UserProfile, linked_lounge: UserProfile, post: LoungePost
    ) -> LoungePostNotification | None:
        """Create the "new thread in a lounge" notification for one lounge member and push it once."""
        try:
            notification_object, created = LoungePostNotification.objects.get_or_create(
                receiver=receiver, linked_lounge_user=linked_lounge, post=post
            )

            if created:
                notification_object.message_json = (
                    f"@{linked_lounge.user.username} has started a new thread in their lounge.: {post.text}"
                )
                notification_object.save()
                self.run_function_on_celery(self.send_lounge_post_created_notification, notification_object)
                logging.info("> Registered lounge post notification.")

            return notification_object
        except Exception as e:
            logging.warning(f"> Error occurred while registering lounge post notification: {str(e)}")

    def register_video_comment_reply_notification(
        self, reply_comment: Comment, replied_to_comment: Comment
    ) -> VideoCommentReplyNotification | None:
        """Create the "reply to your comment" notification for the parent comment's author and push it once."""
        try:
            notification_object, created = VideoCommentReplyNotification.objects.get_or_create(
                receiver=replied_to_comment.commented_by, replied_to=replied_to_comment, reply_comment=reply_comment
            )
            if created:
                notification_object.message_json = f"@{reply_comment.commented_by.user.username} has replied to your thread on video: {replied_to_comment.video.title}."
                notification_object.save()
                self.run_function_on_celery(self.send_video_comment_reply_created_notification, notification_object)

            logging.info("> Registered video comment reply notification.")
            return notification_object
        except Exception as e:
            logging.warning(f"> Error occurred while registering video comment reply notification: {str(e)}")

    def register_lounge_post_reply_notification(
        self, reply_comment: LoungePost, replied_to_comment: LoungePost
    ) -> LoungePostReplyNotification | None:
        """Create the "reply to your thread" notification for the parent post's author and push it once."""
        try:
            notification_object, created = LoungePostReplyNotification.objects.get_or_create(
                receiver=replied_to_comment.created_by.member, replied_to=replied_to_comment, reply_comment=reply_comment
            )
            if created:
                notification_object.message_json = f"@{reply_comment.created_by.member.user.username} has replied to your thread: {replied_to_comment.text}."
                notification_object.save()
                self.run_function_on_celery(self.send_lounge_post_reply_created_notification, notification_object)

                logging.info("> Registered lounge post reply notification.")
            return notification_object
        except Exception as e:
            logging.warning(f"> Error occurred while registering lounge post reply notification: {str(e)}")

    def register_promotional_notification(
        self, receiver: UserProfile, title: str, message: str
    ) -> PromotionalNotification | None:
        """Create or reuse the promotional notification for one user and push it."""
        try:
            notification_object, _ = PromotionalNotification.objects.get_or_create(
                receiver=receiver, title=title, message=message
            )
            notification_object.save()
            self.run_function_on_celery(self.send_promo_notification, notification_object)
            logging.info("> Registered promotion notification.")
            return notification_object
        except Exception as e:
            logging.warning(f"> Error occurred while registering promotion notification: {str(e)}")

    def register_video_like_schedule_notification(
        self, receiver: UserProfile, video: VideoPost
    ) -> VideoLikeScheduledNotification | None:
        """Create a "liked your video" notification and push it once."""
        try:
            notification_object = VideoLikeScheduledNotification()
            notification_object.receiver = receiver
            notification_object.message_json = f"@{video.creator.user.username} has liked your video."
            notification_object.linked_video = video
            notification_object.save()
            self.run_function_on_celery(self.send_video_liked_scheduled_notification, notification_object)
            logging.info("> Registered video like notification.")
            return notification_object
        except Exception as e:
            logging.warning(f"> Error occurred while registering video like notification: {str(e)}")

    def register_video_comment_created_notification(
        self, receiver: UserProfile, linked_comment: Comment
    ) -> VideoCommentNotification | None:
        """Create the "new comment on your video" notification for the video's creator and push it once."""
        try:
            notification_object, created = VideoCommentNotification.objects.get_or_create(
                receiver=receiver, linked_comment=linked_comment
            )
            if created:
                notification_object.message_json = (
                    f"@{linked_comment.commented_by.user.username} has commented your video: {linked_comment.video.title} "
                )
                notification_object.save()
                self.run_function_on_celery(self.send_video_comment_created_notification, notification_object)

            logging.info("> Registered video comment notification.")
            return notification_object
        except Exception as e:
            logging.warning(f"> Error occurred while registering video comment notification: {str(e)}")

    def register_video_processed_notification(
        self, receiver: UserProfile, video: VideoPost
    ) -> VideoProcessedNotification | None:
        """Create the "your video is processed" notification for the creator and push it once."""
        try:
            notification_object, created = VideoProcessedNotification.objects.get_or_create(
                receiver=receiver, linked_video=video
            )
            if created:
                notification_object.message_json = f"Your video is processed now: {video.title}"
                notification_object.save()
                self.run_function_on_celery(self.send_video_processed_notification, notification_object)

            logging.info("> Registered video processed notification.")
            return notification_object
        except Exception as e:
            logging.warning(f"> Error occurred while registering video processed notification: {str(e)}")

    def _push(self, notification, name, build_payload):
        """Send one unsent notification row to its receiver's device. Mark it sent when FCM returns a message name."""
        try:
            fcm_token = notification.receiver.fcm_token

            if notification.notification_sent:
                return

            if fcm_token is None:
                raise Exception("No device associated with user profile.")

            if not self.push_service:
                raise Exception("Push service not available.")

            result = self.push_service.notify(fcm_token=fcm_token, data_payload=build_payload())
            if result is not None and 'name' in result and result['name']:
                notification.notification_sent = True
                notification.save()

            logging.info(f"> Sent {name}: {result}")
        except Exception as e:
            logging.warning(f"> Did not send {name}: {str(e)}")

    def send_video_uploaded_notification(self, object: VideoUploadedNotification):
        """Push a "new video" notification."""
        self._push(object, "video uploaded notification", lambda: {
            "type": "send_video_uploaded_notification",
            "title": f"@{object.linked_video.creator.user.username} has uploaded a new video.",
            "linked_video": str(object.linked_video.video_id),
            "body": object.linked_video.title,
        })

    def send_lounge_post_created_notification(self, object: LoungePostNotification):
        """Push a "new thread in a lounge" notification."""
        self._push(object, "lounge post created notification", lambda: {
            "type": "send_lounge_post_created_notification",
            "title": f"@{object.linked_lounge_user.user.username} has started a new thread in their lounge.",
            "linked_user_id": str(object.linked_lounge_user.user.id),
            "body": "Hop on in and keep the conversation going.",
        })

    def send_video_comment_reply_created_notification(self, object: VideoCommentReplyNotification):
        """Push a "reply to your comment" notification."""
        self._push(object, "video comment reply notification", lambda: {
            "type": "send_video_comment_reply_created_notification",
            "title": f"@{object.reply_comment.commented_by.user.username} has replied to your thread on video: {object.replied_to.video.title}.",
            "linked_video_comment": str(object.reply_comment.comment_id),
            "body": object.reply_comment.comment,
        })

    def send_lounge_post_reply_created_notification(self, object: LoungePostReplyNotification):
        """Push a "reply to your thread" notification."""
        self._push(object, "lounge post reply notification", lambda: {
            "type": "send_lounge_post_reply_created_notification",
            "title": f"@{object.reply_comment.created_by.member.user.username} has replied to your thread: {object.replied_to.text}.",
            "linked_video_comment": str(object.reply_comment.id),
            "body": object.reply_comment.text,
        })

    def send_promo_notification(self, object: PromotionalNotification):
        """Push a promotional notification."""
        self._push(object, "promo notification", lambda: {
            "type": "send_promo_notification",
            "title": object.title,
            "body": object.message,
        })

    def send_video_liked_scheduled_notification(self, object: VideoLikeScheduledNotification):
        """Push a "liked your video" notification."""
        # NOTE: the row does not store who liked the video, so the title names the video's creator.
        self._push(object, "video liked notification", lambda: {
            "type": "send_video_liked_scheduled_notification",
            "title": f"@{object.linked_video.creator.user.username} has liked your video.",
            "linked_video": str(object.linked_video.video_id),
            "body": object.linked_video.title,
        })

    def send_video_comment_created_notification(self, object: VideoCommentNotification):
        """Push a "new comment on your video" notification."""
        self._push(object, "video comment created notification", lambda: {
            "type": "send_video_comment_created_notification",
            "title": f"@{object.linked_comment.commented_by.user.username} has started a new thread on video: {object.linked_comment.video.title}.",
            "linked_video_comment": str(object.linked_comment.comment_id),
            "body": object.linked_comment.comment,
        })

    def send_video_processed_notification(self, object: VideoProcessedNotification):
        """Push a "your video is processed" notification."""
        self._push(object, "video processed notification", lambda: {
            "title": "Your video has been processed and now ready for your audience.",
            "body": object.linked_video.title,
        })

    def distrubute_lounge_post_notifications(self, linked_lounge: UserProfile, post: LoungePost):
        """Notify every participant of the lounge about a new top-level post."""
        target_participants = LoungeParticipants.objects.filter(lounge=linked_lounge.associated_lounge)
        target_user_set = UserProfile.objects.filter(user__id__in=target_participants.values("member__user__id")).all()

        logging.info(f"Starting lounge post distribution:{post.text}.")

        for user in target_user_set.iterator(chunk_size=100):
            notification = self.register_lounge_post_notification(user, linked_lounge, post)
            if notification is not None:
                self.send_lounge_post_created_notification(notification)

        logging.info("Distributed lounge post notification. ")

    def distrubute_promotional_notifications(self, promo_title, promo_message):
        """Send a promotion to every user profile."""
        logging.info(f"Starting promotion distribution:{promo_title}.")
        for user in UserProfile.objects.all().iterator(chunk_size=100):
            notification = self.register_promotional_notification(
                receiver=user, title=promo_title, message=promo_message
            )
            if notification is not None:
                self.send_promo_notification(notification)

        logging.info("Distributed promotion notification. ")

    def distrubute_video_uploaded_notifications(self, video: VideoPost):
        """Notify everyone who subscribed before the upload, once the video is encoded and through ML."""
        logging.info(f"Starting video uploaded distribution:{video.title}.")

        if video.is_encoded and video.gone_through_ml and not video.notification_sent:
            subscribers = ChannelSubscribers.objects.filter(channel=video.creator.associated_channel)
            for subscription in subscribers.iterator(chunk_size=100):
                if subscription.creation_date < video.creation_date:
                    notification = self.register_video_uploaded_notification(
                        receiver=subscription.subscribed_by, video=video
                    )
                    if notification is not None:
                        self.send_video_uploaded_notification(notification)

            video.notification_sent = True
            video.save(update_fields=["notification_sent"])
            logging.info("Distributed video uploaded notification. ")

    def mark_notification_as_seen(self, token, object_type, object_id):
        """Mark one notification as viewed when it belongs to the logged in user."""
        user_engine = UserEngine()
        logged_in_user = user_engine.get_logged_in_user(token)

        if logged_in_user is None:
            raise Exception("invaild Token")

        if object_type is None:
            raise Exception("Invalid object type")

        if object_id is None:
            raise Exception("Invalid object id")

        models_by_type = {
            "video_upload": VideoUploadedNotification,
            "lounge_post_created": LoungePostNotification,
            "video_comment_reply": VideoCommentReplyNotification,
            "lounge_post_reply": LoungePostReplyNotification,
            "promotion": PromotionalNotification,
            "video_comment_created": VideoCommentNotification,
            "video_processed": VideoProcessedNotification,
        }
        if object_type not in models_by_type:
            raise Exception("Object cannot be none")

        obj = models_by_type[object_type].objects.get(pk=object_id)

        user_profile = user_engine.get_user_profile(logged_in_user)
        if obj.receiver == user_profile:
            obj.viewed = True
            obj.save()
            return self.build_response("set viewed.")
        else:
            return self.build_response("Authenication failed")

    def video_upload_to_json(self, obj: VideoUploadedNotification, token) -> dict:
        """Serialise a "new video" notification."""
        return {
            "pk": obj.pk,
            "type": "video_upload",
            "receiver": UserEngine().to_json(obj.receiver.user, obj.receiver),
            "message": obj.message_json,
            "creation_date": str(obj.creation_date),
            "viewed": obj.viewed,
            "linked_video": video_metadata_to_json_obj(obj.linked_video),
            "notification_sent": obj.notification_sent,
        }

    def lounge_post_created_to_json(self, obj: LoungePostNotification, token) -> dict:
        """Serialise a "new thread in a lounge" notification."""
        return {
            "pk": obj.pk,
            "type": "lounge_post_created",
            "receiver": UserEngine().to_json(obj.receiver.user, obj.receiver),
            "message": obj.message_json,
            "creation_date": str(obj.creation_date),
            "viewed": obj.viewed,
            "linked_lounge": UserEngine().to_json(obj.linked_lounge_user.user, obj.linked_lounge_user),
        }

    def lounge_post_reply_to_json(self, obj: LoungePostReplyNotification, token) -> dict:
        """Serialise a "reply to your thread" notification."""
        return {
            "pk": obj.pk,
            "type": "lounge_post_reply",
            "receiver": UserEngine().to_json(obj.receiver.user, obj.receiver),
            "message": obj.message_json,
            "creation_date": str(obj.creation_date),
            "viewed": obj.viewed,
            "reply_comment": LoungeManager().lounge_post_to_dict(obj.reply_comment, token),
            "replied_to": LoungeManager().lounge_post_to_dict(obj.replied_to, token),
        }

    def video_comment_reply_to_json(self, obj: VideoCommentReplyNotification, token):
        """Serialise a "reply to your comment" notification."""
        return {
            "pk": obj.pk,
            "type": "video_comment_reply",
            "receiver": UserEngine().to_json(obj.receiver.user, obj.receiver),
            "message": obj.message_json,
            "creation_date": str(obj.creation_date),
            "viewed": obj.viewed,
            "reply_comment": VideoEngineManager().comment_metadata_to_json_obj(obj.reply_comment, token),
            "replied_to": VideoEngineManager().comment_metadata_to_json_obj(obj.replied_to, token),
        }

    def promotion_to_json(self, obj: PromotionalNotification, token):
        """Serialise a promotional notification."""
        return {
            "pk": obj.pk,
            "type": "promotion",
            "receiver": UserEngine().to_json(obj.receiver.user, obj.receiver),
            "message": obj.message,
            "title": obj.title,
            "viewed": obj.viewed,
            "creation_date": str(obj.creation_date),
        }

    def video_comment_created(self, obj: VideoCommentNotification, token):
        """Serialise a "new comment on your video" notification."""
        return {
            "pk": obj.pk,
            "type": "video_comment_created",
            "receiver": UserEngine().to_json(obj.receiver.user, obj.receiver),
            "message": obj.message_json,
            "viewed": obj.viewed,
            "creation_date": str(obj.creation_date),
            "linked_comment": VideoEngineManager().comment_metadata_to_json_obj(obj.linked_comment, token),
        }

    def video_processed_notification(self, obj: VideoProcessedNotification, token):
        """Serialise a "your video is processed" notification."""
        return {
            "pk": obj.pk,
            "type": "video_processed",
            "receiver": UserEngine().to_json(obj.receiver.user, obj.receiver),
            "message": obj.message_json,
            "viewed": obj.viewed,
            "creation_date": str(obj.creation_date),
            "linked_video": video_metadata_to_json_obj(obj.linked_video),
        }

    def _get_notifications(self, token, page_number, model, serialiser):
        """Return one page of the logged in user's notifications of one model, newest first. None on any error."""
        try:
            user_engine = UserEngine()
            logged_in_user = user_engine.get_logged_in_user(token)

            if logged_in_user is None:
                raise Exception("invaild Token")

            user_profile = user_engine.get_user_profile(logged_in_user)
            query_set = model.objects.filter(receiver=user_profile).order_by("-creation_date")
            return self.paginator(query_set, page_number, serialiser, token)
        except Exception as e:
            logging.error(str(e))

    def get_video_uploaded_notifications(self, token: str, page_number: int) -> dict | None:
        """One page of the user's "new video" notifications."""
        return self._get_notifications(token, page_number, VideoUploadedNotification, self.video_upload_to_json)

    def get_lounge_post_created_notification(self, token: str, page_number: int) -> dict | None:
        """One page of the user's "new thread in a lounge" notifications."""
        return self._get_notifications(token, page_number, LoungePostNotification, self.lounge_post_created_to_json)

    def get_video_comment_replied_notifications(self, token: str, page_number: int) -> dict | None:
        """One page of the user's "reply to your comment" notifications."""
        return self._get_notifications(
            token, page_number, VideoCommentReplyNotification, self.video_comment_reply_to_json
        )

    def get_lounge_post_reply_notifications(self, token: str, page_number: int) -> dict | None:
        """One page of the user's "reply to your thread" notifications."""
        return self._get_notifications(token, page_number, LoungePostReplyNotification, self.lounge_post_reply_to_json)

    def get_promotional_notifications(self, token: str, page_number: int) -> dict | None:
        """One page of the user's promotional notifications."""
        return self._get_notifications(token, page_number, PromotionalNotification, self.promotion_to_json)

    def get_video_comment_notification(self, token: str, page_number: int) -> dict | None:
        """One page of the user's "new comment on your video" notifications."""
        return self._get_notifications(token, page_number, VideoCommentNotification, self.video_comment_created)

    def get_video_processed_notification(self, token: str, page_number: int) -> dict | None:
        """One page of the user's "your video is processed" notifications."""
        return self._get_notifications(
            token, page_number, VideoProcessedNotification, self.video_processed_notification
        )

    def get_max_pages(self, *args):
        """Largest total_pages among the given page payloads, ignoring None. None when all are None."""
        max_pages = None

        for arg in args:
            if arg is not None:
                if max_pages is None:
                    max_pages = arg["total_pages"]
                else:
                    max_pages = max(max_pages, arg["total_pages"])

        return max_pages

    def _merge_pages(self, page_number, *pages):
        """Join several page payloads into one, in the order given. Pages that failed or ran out are skipped."""
        pages = [page for page in pages if page is not None and "data" in page]
        result = {"page_number": page_number, "total_pages": self.get_max_pages(*pages), "data": []}
        for page in pages:
            result["data"].extend(page["data"])
        return result

    def render_for_you(self, token, page_number):
        """The "for you" tab: promotions followed by processed-video notifications."""
        promos = self.get_promotional_notifications(token, page_number)
        video_processed = self.get_video_processed_notification(token, page_number)
        return self._merge_pages(page_number, promos, video_processed)

    def render_subscriptions(self, token, page_number):
        """The "subscriptions" tab: new videos from subscribed channels."""
        uploads = self.get_video_uploaded_notifications(token, page_number)
        return self._merge_pages(page_number, uploads)

    def render_replies(self, token, page_number):
        """The "replies" tab: lounge replies, comment replies, new comments and new lounge threads."""
        created = self.get_video_comment_notification(token, page_number)
        lounge_post_created = self.get_lounge_post_created_notification(token, page_number)
        lounge_post_replies = self.get_lounge_post_reply_notifications(token, page_number)
        comment_post_replies = self.get_video_comment_replied_notifications(token, page_number)
        return self._merge_pages(page_number, lounge_post_replies, comment_post_replies, created, lounge_post_created)

    def render_lounges(self, token, page_number):
        """The "lounges" tab: new threads in joined lounges."""
        lounge_post_created = self.get_lounge_post_created_notification(token, page_number)
        return lounge_post_created

    def run_function_on_celery(self, func, object):
        """Call func(object) in this process. Nothing is handed to Celery here."""
        return func(object)

    def get_unread_notification_count(self, token):
        """Count the logged in user's unviewed notifications over all eight notification models."""
        count = 0
        user_engine = UserEngine()
        logged_in_user = user_engine.get_logged_in_user(token)

        if logged_in_user is None:
            raise Exception("invaild Token")
        user_profile = user_engine.get_user_profile(logged_in_user)

        for model in (
            VideoUploadedNotification,
            LoungePostNotification,
            VideoCommentReplyNotification,
            LoungePostReplyNotification,
            PromotionalNotification,
            VideoLikeScheduledNotification,
            VideoCommentNotification,
            VideoProcessedNotification,
        ):
            count += model.objects.filter(receiver=user_profile, viewed=False).count()

        return self.build_response(count)

    def paginator(self, query_set, page_number, serialiser, token):
        """Return one page of a query set, each row passed through serialiser(obj, token)."""
        pagination_obj = Paginator(query_set, self.MAX_OBJECT_LIMIT)
        total_pages = pagination_obj.page_range[-1]
        if page_number > total_pages:
            return {"status": -131, "message": f"Page number does not exists. (total pages available : {total_pages})"}
        response = {
            "page_number": page_number,
            "total_pages": total_pages,
            "data": [serialiser(obj, token) for obj in pagination_obj.get_page(page_number)],
        }

        return response


notifierAgent = NotifierEngine()
