import logging
import os
import subprocess
from datetime import date, datetime, timedelta
from tempfile import NamedTemporaryFile

import cv2
from celery import shared_task
from django.conf import settings
from django.core.files.base import ContentFile
from django.utils import timezone

from modules.lounge_engine.manager import LoungeManager
from modules.lounge_engine.models import UserPasswordReset
from modules.s3 import BOTO_S3
from modules.user_engine.models import Lounge, LoungeLogs, UserProfile
from modules.video_engine.manager import get_video


@shared_task(soft_time_limit=1200, time_limit=1220)
def generate_lounge_logs():
    """Update the day, week and month XP figures in LoungeLogs for every lounge."""
    logging.info("GENERATING LOUNGE LOGS")
    today = date.today()
    one_week_ago = today - timedelta(days=7)
    one_month_ago = today - timedelta(days=30)

    lounges = Lounge.objects.all()
    for lounge in lounges.iterator(chunk_size=100):
        log_entry = LoungeLogs.objects.filter(linked_lounge=lounge).first()
        if log_entry is None:
            log_entry = LoungeLogs()
            log_entry.linked_lounge = lounge
            log_entry.day_update_date = datetime.now()
            log_entry.month_update_date = datetime.now()
            log_entry.week_update_date = datetime.now()

        modified = False
        day_xp_difference = lounge.lounge_xp - log_entry.day_difference
        week_xp_difference = lounge.lounge_xp - log_entry.weekly_difference
        month_xp_difference = lounge.lounge_xp - log_entry.monthly_difference

        if today > log_entry.day_update_date.date():
            log_entry.day_difference = day_xp_difference
            log_entry.day_update_date = today
            modified = True

        # NOTE: week_update_date and month_update_date are DateFields, so .date() fails on a row
        # loaded from the database. The two comparisons below also look inverted.
        if log_entry.week_update_date.date() > one_week_ago:
            log_entry.weekly_difference = week_xp_difference
            log_entry.week_update_date = today
            modified = True

        if log_entry.month_update_date.date() > one_month_ago:
            log_entry.monthly_difference = month_xp_difference
            log_entry.month_update_date = today
            modified = True

        if modified:
            log_entry.save()

    logging.info("GENERATED LOUNGE LOGS")


@shared_task(soft_time_limit=1200, time_limit=1220)
def set_lounge_invites():
    """Check every user against every lounge and create invites for those who qualify."""
    logging.info("SETTING LOUNGE INVITES")
    lounge_engine = LoungeManager()

    # NOTE: this is a full users x lounges scan on every run.
    for user in UserProfile.objects.all().iterator(chunk_size=100):
        for lounge in Lounge.objects.all():
            try:
                lounge_engine.set_lounge_access(lounge, user)
            except Exception as e:
                logging.error(f"Error setting lounge access for user {user.id} and lounge {lounge.id}: {str(e)}")

    logging.info("INVITES SENT.")


@shared_task
def clean_up_password_resets():
    """Delete password reset rows whose expiry time has passed."""
    reset_qs = UserPasswordReset.objects.all()
    for obj in reset_qs.iterator(chunk_size=100):
        current_time = timezone.now()
        expiry = obj.expires
        if current_time.timestamp() > expiry.timestamp():
            obj.delete()

    logging.info("> Cleared up password reset objects.")


def extract_first_frame(video_id):
    """Save the first frame of a video as its thumbnail if it has none."""
    video_instance = get_video(video_id)
    if video_instance.thumbnail is not None and video_instance.thumbnail != "":
        return "Already has thumbnail."

    video_id = "".join(str(video_instance.video_id).split("-"))
    video_key = f"media/videos/{video_id}/original.mp4"
    video_obj = BOTO_S3.get_object(Bucket=settings.AWS_STORAGE_BUCKET_NAME, Key=video_key)
    video_data = video_obj["Body"].read()

    with NamedTemporaryFile(delete=True) as video_temp_file:
        video_temp_file.write(video_data)
        video_temp_file.flush()
        cap = cv2.VideoCapture(video_temp_file.name)
        success, frame = cap.read()
        if success:
            _, buffer = cv2.imencode(".jpg", frame)
            frame_image = ContentFile(buffer.tobytes())
            with NamedTemporaryFile(delete=False, suffix=".jpg") as frame_temp_file:
                frame_temp_file.write(buffer.tobytes())
                frame_temp_file.flush()
                frame_temp_file_path = frame_temp_file.name

            video_instance.thumbnail.save("thumbnail.jpeg", frame_image)
            video_instance.save()
            upload_to_s3(frame_temp_file_path, f"media/videos/{video_id}/thumbnail.jpeg")
            os.remove(frame_temp_file_path)
            logging.info(f"Thumbnail saved for video {video_id}")

        cap.release()


def set_video_parameters(video_id):
    """Read width, height, fps, frame count, duration and bitrate from the original file and store them."""
    video_instance = get_video(video_id)
    if video_instance.video_height != 0 and video_instance.video_width != 0:
        return "Already has parameters set."

    video_id = "".join(str(video_instance.video_id).split("-"))
    video_key = f"media/videos/{video_id}/original.mp4"
    video_obj = BOTO_S3.get_object(Bucket=settings.AWS_STORAGE_BUCKET_NAME, Key=video_key)
    video_data = video_obj["Body"].read()

    with NamedTemporaryFile(delete=False) as video_temp_file:
        temp_filename = video_temp_file.name
        video_temp_file.write(video_data)
        video_temp_file.flush()

    try:
        fixed_video_path = fix_video_file_structure(temp_filename)

        cap = cv2.VideoCapture(fixed_video_path)
        if not cap.isOpened():
            raise Exception("Error opening video file")

        video_instance.video_width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        video_instance.video_height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        video_instance.video_fps = cap.get(cv2.CAP_PROP_FPS)
        video_instance.video_frame_count = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        video_instance.video_duration_seconds = video_instance.video_frame_count / video_instance.video_fps
        video_instance.video_bitrate = int(cap.get(cv2.CAP_PROP_BITRATE))

        # NOTE: OpenCV does not read the audio stream. These three fields are filled from
        # video properties and do not describe the audio.
        video_instance.audio_fps = int(cap.get(cv2.CAP_PROP_FPS))
        video_instance.audio_channels = int(cap.get(cv2.CAP_PROP_CHANNEL))
        video_instance.audio_bitrate = int(cap.get(cv2.CAP_PROP_BITRATE))
        video_instance.save()

        cap.release()
    finally:
        os.remove(temp_filename)


def upload_to_s3(local_file_path, s3_key):
    """Upload a local file to the media bucket. Errors are logged, not raised."""
    try:
        BOTO_S3.upload_file(local_file_path, settings.AWS_STORAGE_BUCKET_NAME, s3_key)
        logging.info(f"File uploaded to S3: {s3_key}")
    except Exception as e:
        logging.error(f"Error uploading to S3: {str(e)}")


def fix_video_file_structure(input_file):
    """Remux a video in place with ffmpeg faststart. Returns the input path whether or not it worked."""
    try:
        # NOTE: the output name is fixed, so two workers using the same temp directory can collide.
        temp_output_file = "/".join(input_file.split("/")[:-1]) + "/temp.mp4"
        ffmpeg_command = ['ffmpeg', '-i', input_file,
            '-c', 'copy', '-movflags', '+faststart', '-y', temp_output_file]

        result = subprocess.run(ffmpeg_command)

        if result.returncode != 0:
            logging.warning(f"ffmpeg exited with code {result.returncode} for {input_file}")
            return input_file

        os.replace(temp_output_file, input_file)

        return input_file

    except Exception:
        logging.exception(f"Could not fix video file structure for {input_file}")
        return input_file
