import logging

from celery import shared_task
from django.db import close_old_connections

from modules.analytics_engine.manager import AnalyticsEngine
from modules.analytics_engine.models import LogType, LogTypeAggregation
from modules.lounge_engine.models import LoungePost
from modules.lounge_engine.tasks import extract_first_frame, set_video_parameters
from modules.user_engine.manager import UserEngine
from modules.user_engine.models import Channel, Lounge, UserProfile
from modules.video_engine.models import VideoPost

analytics_object = AnalyticsEngine()


def make_graph_models():
    """Write one row to each admin console graph model."""
    analytics_object.make_user_profile_growth_log()
    analytics_object.make_video_post_growth_log()
    analytics_object.make_threads_growth_log()

    analytics_object.make_reported_video_tracker()
    analytics_object.make_reported_threads_tracker()
    analytics_object.make_reported_comments_tracker()

    analytics_object.make_videos_under_processing()
    analytics_object.make_videos_under_ml_processing()
    analytics_object.make_videos_under_encoding()


def _log_channels_and_videos(log_type):
    """Write subscriber, channel, view and video metric logs of one log_type."""
    logging.info("STARTING SUBSCRIBER LOGS PROCESS")
    for channel in Channel.objects.all().iterator(chunk_size=100):
        analytics_object.log_subscriber_metrics(channel, log_type)
        analytics_object.create_or_update_channel_metrics(channel, LogTypeAggregation.AVERAGE, log_type)
        analytics_object.create_or_update_channel_metrics(channel, LogTypeAggregation.TOTAL, log_type)

    logging.info("STARTING Video Metrics LOGS PROCESS")
    for video in VideoPost.objects.all().iterator(chunk_size=100):
        analytics_object.create_or_update_view_metrics(video, log_type)
        analytics_object.update_xp_VIDEO(video, log_type)
        analytics_object.log_video_metrics(video, log_type)


def _log_lounges(log_type):
    """Write lounge and lounge post metric logs of one log_type."""
    logging.info("Logging Lounges")
    for lounge in Lounge.objects.all().iterator(chunk_size=100):
        analytics_object.log_lounge_metrics(lounge, log_type)

    logging.info("Logging lounge posts")
    for lounge_post in LoungePost.objects.all().iterator(chunk_size=100):
        analytics_object.log_lounge_post_metrics(lounge_post, log_type)


@shared_task()
def analytics_realtime_tasks():
    """Recompute XP, levels, counts, topic relations and contest standings for every object."""
    close_old_connections()
    try:
        logging.info("REALTIME TASKS PERFORMER")
        logging.info("STARTING Video Metrics LOGS PROCESS")
        logging.info("STARTING SUBSCRIBER LOGS PROCESS")
        for channel in Channel.objects.all().iterator(chunk_size=100):
            analytics_object.log_subscriber_metrics(channel, LogType.DAY)
            analytics_object.create_or_update_channel_metrics(channel, LogTypeAggregation.AVERAGE, LogType.DAY)
            analytics_object.create_or_update_channel_metrics(channel, LogTypeAggregation.TOTAL, LogType.DAY)

        for video in VideoPost.objects.all().iterator(chunk_size=100):
            analytics_object.create_or_update_view_metrics(video, None)
            analytics_object.update_xp_VIDEO(video, None)
            analytics_object.log_video_metrics(video, None)
            extract_first_frame(video_id=video.video_id)
            set_video_parameters(video_id=video.video_id)

        logging.info("Updating user levels and ranks")
        for user in UserProfile.objects.all().iterator(chunk_size=100):
            analytics_object.recount_videos(user)
            analytics_object.update_xp_USER(user, None)
            analytics_object.celery_generate_relations(user)
            analytics_object.make_contest_objects(user)

        logging.info("Updating channel ranks")
        for channel in Channel.objects.all():
            analytics_object.update_XP_CHANNEL(channel, None)

        logging.info("Updating Lounges")
        for lounge in Lounge.objects.all().iterator(chunk_size=100):
            analytics_object.log_lounge_metrics(lounge, LogType.DAY)
            analytics_object.update_XP_LOUNGE(lounge, None)
            analytics_object.recount_lounge_members(lounge)

        logging.info("Updating lounge posts")
        for lounge_post in LoungePost.objects.all().iterator(chunk_size=100):
            analytics_object.update_XP_LOUNGE_POST(lounge_post, None)

        analytics_object.modify_contest_time()
        UserEngine().update_user_rankings()
        logging.info("REALTIME TASKS COMPLETED SUCCESSFULLY")
    finally:
        close_old_connections()


@shared_task
def analytics_daily_tasks():
    """Write the daily metric logs and the admin console graph rows."""
    close_old_connections()
    try:
        logging.info("DAILY TASKS PERFORMER")
        _log_channels_and_videos(LogType.DAY)
        make_graph_models()
        _log_lounges(LogType.DAY)
        logging.info("DAILY TASKS COMPLETED SUCCESSFULLY")
    finally:
        close_old_connections()


@shared_task(soft_time_limit=1200, time_limit=1220)
def analytics_weekly_tasks():
    """Write the weekly metric logs."""
    close_old_connections()
    try:
        logging.info("WEEKLY TASKS PERFORMER")
        _log_channels_and_videos(LogType.WEEK)
        _log_lounges(LogType.WEEK)
        logging.info("WEEKLY TASKS COMPLETED SUCCESSFULLY")
    finally:
        close_old_connections()


@shared_task
def analytics_monthly_tasks():
    """Write the monthly metric logs."""
    close_old_connections()
    try:
        logging.info("MONTHLY TASKS PERFORMER")
        _log_channels_and_videos(LogType.MONTH)
        _log_lounges(LogType.MONTH)
        logging.info("MONTHLY TASKS COMPLETED SUCCESSFULLY")
    finally:
        close_old_connections()


@shared_task
def analytics_yearly_tasks():
    """Write the yearly metric logs."""
    close_old_connections()
    try:
        logging.info("YEARLY TASKS PERFORMER")
        _log_channels_and_videos(LogType.YEAR)
        _log_lounges(LogType.YEAR)
        logging.info("YEARLY TASKS COMPLETED SUCCESSFULLY")
    finally:
        close_old_connections()
