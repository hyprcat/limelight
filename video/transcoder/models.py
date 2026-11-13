# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models
from django.conf import settings

from django_celery_beat.models import PeriodicTask as CeleryPeriodicTask

class PeriodicTask(CeleryPeriodicTask):
    class Meta:
        db_table = 'video_table'


class AnalyticsEngineChannelmetrics(models.Model):
    aggregation_type = models.CharField(max_length=12)
    impressions = models.PositiveBigIntegerField()
    likes = models.PositiveBigIntegerField()
    dislikes = models.PositiveBigIntegerField()
    comments = models.PositiveBigIntegerField()
    views = models.PositiveBigIntegerField()
    video_xp = models.PositiveBigIntegerField()
    log_date = models.DateTimeField()
    channel = models.ForeignKey('UserEngineChannel', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'analytics_engine_channelmetrics'


class AnalyticsEngineSubscribersmetriclog(models.Model):
    log_date = models.DateTimeField()
    log_type = models.CharField(max_length=6)
    subscriber_gain = models.PositiveBigIntegerField()
    subscriber_lost = models.PositiveBigIntegerField()
    total_subscribers = models.PositiveBigIntegerField()
    net_subscribers = models.IntegerField()
    subscriber_growth_percentage = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    channel = models.ForeignKey('UserEngineChannel', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'analytics_engine_subscribersmetriclog'


class AnalyticsEngineUsertopicrelations(models.Model):
    log_date = models.DateTimeField()
    relation_id = models.CharField(primary_key=True, max_length=100)
    topic_id = models.BigIntegerField()
    topic_category_id = models.BigIntegerField()
    likes = models.PositiveBigIntegerField()
    dislikes = models.PositiveBigIntegerField()
    comments = models.PositiveBigIntegerField()
    views = models.PositiveBigIntegerField()
    positive_comments_made = models.PositiveBigIntegerField()
    negative_comments_made = models.PositiveBigIntegerField()
    favoritism_weight = models.PositiveBigIntegerField()
    user = models.ForeignKey('UserEngineUserprofile', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'analytics_engine_usertopicrelations'


class AnalyticsEngineVideometricslog(models.Model):
    log_date = models.DateTimeField()
    log_type = models.CharField(max_length=6)
    impressions = models.PositiveBigIntegerField()
    likes = models.PositiveBigIntegerField()
    dislikes = models.PositiveBigIntegerField()
    comments = models.PositiveBigIntegerField()
    views = models.PositiveBigIntegerField()
    video_xp = models.PositiveBigIntegerField()
    video = models.ForeignKey('VideoEngineVideopost', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'analytics_engine_videometricslog'


class AnalyticsEngineViewdurationVideo(models.Model):
    log_type = models.CharField(max_length=6)
    average_seconds_watched = models.PositiveBigIntegerField()
    average_view_percentage = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    total_views = models.PositiveIntegerField()
    most_views_location = models.TextField()
    audience_retention_percentage = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    bounce_rate = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    conversion_rate = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    log_date = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'analytics_engine_viewduration_video'

class LoungeEngineLoungedislike(models.Model):
    creation_date = models.DateTimeField()
    disliked_by = models.ForeignKey('UserEngineLoungeparticipants', models.DO_NOTHING)
    post = models.ForeignKey('LoungeEngineLoungepost', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'lounge_engine_loungedislike'


class LoungeEngineLoungelike(models.Model):
    creation_date = models.DateTimeField()
    liked_by = models.ForeignKey('UserEngineLoungeparticipants', models.DO_NOTHING)
    post = models.ForeignKey('LoungeEngineLoungepost', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'lounge_engine_loungelike'


class LoungeEngineLoungepost(models.Model):
    id = models.CharField(primary_key=True, max_length=32)
    text = models.TextField()
    attachment = models.CharField(max_length=100)
    likes = models.PositiveBigIntegerField()
    dislikes = models.PositiveBigIntegerField()
    replies = models.PositiveBigIntegerField()
    topic_id = models.IntegerField()
    topic_category_id = models.IntegerField()
    post_sentiment = models.IntegerField()
    impressions = models.IntegerField()
    is_advertisement = models.BooleanField()
    post_depth = models.PositiveBigIntegerField()
    creation_date = models.DateTimeField()
    associated_lounge_section = models.ForeignKey('UserEngineLoungesections', models.DO_NOTHING)
    created_by = models.ForeignKey('UserEngineLoungeparticipants', models.DO_NOTHING)
    parent_post = models.ForeignKey('self', models.DO_NOTHING, blank=True, null=True)
    root_post = models.ForeignKey('self', models.DO_NOTHING, related_name='loungeengineloungepost_root_post_set', blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'lounge_engine_loungepost'


class LoungeEngineLoungeposthashtags(models.Model):
    hashtag_string = models.CharField(max_length=100)
    created_date = models.DateTimeField()
    associated_leaf = models.ForeignKey(LoungeEngineLoungepost, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'lounge_engine_loungeposthashtags'


class LoungeEngineLoungepostlogs(models.Model):
    day_difference = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    weekly_difference = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    monthly_difference = models.DecimalField(max_digits=10, decimal_places=5)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    day_update_date = models.DateTimeField(blank=True, null=True)
    week_update_date = models.DateField(blank=True, null=True)
    month_update_date = models.DateField(blank=True, null=True)
    linked_leaf = models.ForeignKey(LoungeEngineLoungepost, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'lounge_engine_loungepostlogs'


class LoungeEngineLoungepostmentions(models.Model):
    creation_date = models.DateTimeField()
    mentioned_in_comments = models.ForeignKey(LoungeEngineLoungepost, models.DO_NOTHING)
    mentioned_user = models.ForeignKey('UserEngineLoungeparticipants', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'lounge_engine_loungepostmentions'



class UserEngineChannel(models.Model):
    id = models.CharField(primary_key=True, max_length=32)
    name = models.CharField(unique=True, max_length=120)
    channel_description = models.TextField()
    subscriber_count = models.PositiveBigIntegerField()
    videos_count = models.PositiveBigIntegerField()
    level = models.PositiveBigIntegerField()
    xp = models.PositiveBigIntegerField(db_column='XP')  # Field name made lowercase.
    metrics_last_updated = models.DateTimeField()
    assoicated_lounge = models.ForeignKey('UserEngineLounge', models.DO_NOTHING, blank=True, null=True)
    owner = models.ForeignKey('UserEngineUserprofile', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'user_engine_channel'


class UserEngineChannelsubscribers(models.Model):
    creation_date = models.DateTimeField()
    channel = models.ForeignKey(UserEngineChannel, models.DO_NOTHING)
    subscribed_by = models.ForeignKey('UserEngineUserprofile', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'user_engine_channelsubscribers'
        unique_together = (('channel', 'subscribed_by'),)


class UserEngineLounge(models.Model):
    id = models.CharField(primary_key=True, max_length=32)
    name = models.CharField(max_length=120)
    lounge_xp = models.PositiveBigIntegerField()
    lounge_level = models.PositiveBigIntegerField()
    total_members = models.PositiveBigIntegerField()
    total_categories = models.PositiveBigIntegerField()
    lounge_description = models.TextField()
    lounge_tiers = models.PositiveBigIntegerField()
    channel = models.ForeignKey(UserEngineChannel, models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'user_engine_lounge'


class UserEngineLoungeaccess(models.Model):
    creator_videos_watched = models.BigIntegerField()
    lounge = models.ForeignKey(UserEngineLounge, models.DO_NOTHING)
    user = models.ForeignKey('UserEngineUserprofile', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'user_engine_loungeaccess'


class UserEngineLoungecategories(models.Model):
    id = models.CharField(primary_key=True, max_length=32)
    category_name = models.CharField(max_length=120)
    category_description = models.CharField(max_length=256)
    total_sections = models.PositiveBigIntegerField()
    creation_date = models.DateTimeField()
    lounge = models.ForeignKey(UserEngineLounge, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'user_engine_loungecategories'
        unique_together = (('lounge', 'category_name'),)


class UserEngineLoungeparticipants(models.Model):
    level = models.PositiveBigIntegerField()
    xp = models.PositiveBigIntegerField(db_column='XP')  # Field name made lowercase.
    challenges_completed = models.PositiveBigIntegerField()
    lounge = models.ForeignKey(UserEngineLounge, models.DO_NOTHING)
    member = models.ForeignKey('UserEngineUserprofile', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'user_engine_loungeparticipants'
        unique_together = (('lounge', 'member'),)


class UserEngineLoungesections(models.Model):
    id = models.CharField(primary_key=True, max_length=32)
    section_name = models.CharField(max_length=64)
    section_description = models.CharField(max_length=256)
    minimum_level_required = models.PositiveBigIntegerField()
    only_owner_can_post = models.BooleanField()
    creation_date = models.DateTimeField()
    lounge = models.ForeignKey(UserEngineLounge, models.DO_NOTHING)
    related_category = models.ForeignKey(UserEngineLoungecategories, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'user_engine_loungesections'
        unique_together = (('related_category', 'section_name'),)


class UserEngineUsergeolocations(models.Model):
    city = models.CharField(max_length=120)
    country = models.CharField(max_length=120)
    region = models.CharField(max_length=120)
    last_updated = models.DateTimeField()
    user = models.ForeignKey('UserEngineUserprofile', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'user_engine_usergeolocations'


class UserEngineUserprofile(models.Model):
    bio = models.TextField(blank=True, null=True)
    age = models.PositiveBigIntegerField(blank=True, null=True)
    gender = models.CharField(max_length=15, blank=True, null=True)
    profile_picture = models.CharField(max_length=100)
    profile_banner = models.CharField(max_length=100)
    subscribed_to_count = models.PositiveBigIntegerField()
    joined_lounges = models.PositiveBigIntegerField()
    creation_date = models.DateTimeField()
    xp = models.PositiveBigIntegerField(db_column='XP')  # Field name made lowercase.
    level = models.PositiveBigIntegerField()
    is_creator = models.BooleanField()
    is_advertiser = models.BooleanField()
    metrics_last_updated = models.DateTimeField()
    drafts = models.PositiveBigIntegerField()
    unlisted = models.PositiveBigIntegerField()
    lounge_only = models.PositiveBigIntegerField()
    active_videos = models.PositiveBigIntegerField()
    associated_channel = models.ForeignKey(UserEngineChannel, models.DO_NOTHING, blank=True, null=True)
    associated_lounge = models.ForeignKey(UserEngineLounge, models.DO_NOTHING, blank=True, null=True)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, related_name='user', on_delete= models.CASCADE)

    class Meta:
        managed = False
        db_table = 'user_engine_userprofile'



class VideoEngineComment(models.Model):
    comment_id = models.CharField(primary_key=True, max_length=32)
    comment = models.TextField()
    replies = models.PositiveBigIntegerField()
    likes = models.PositiveBigIntegerField()
    dislikes = models.PositiveBigIntegerField()
    comment_sentiment = models.IntegerField()
    is_reply = models.BooleanField()
    creation_date = models.DateTimeField()
    commented_by = models.ForeignKey(UserEngineUserprofile, models.DO_NOTHING)
    video = models.ForeignKey('VideoEngineVideopost', models.DO_NOTHING)
    root_comment = models.ForeignKey('self', models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'video_engine_comment'


class VideoEngineCommentdislikes(models.Model):
    creation_date = models.DateTimeField()
    comment = models.ForeignKey(VideoEngineComment, models.DO_NOTHING)
    disliked_by = models.ForeignKey(UserEngineUserprofile, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'video_engine_commentdislikes'


class VideoEngineCommentlikes(models.Model):
    creation_date = models.DateTimeField()
    comment = models.ForeignKey(VideoEngineComment, models.DO_NOTHING)
    liked_by = models.ForeignKey(UserEngineUserprofile, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'video_engine_commentlikes'


class VideoEngineCommentmentions(models.Model):
    creation_date = models.DateTimeField()
    comment = models.ForeignKey(VideoEngineComment, models.DO_NOTHING)
    mentioned_user = models.ForeignKey(UserEngineUserprofile, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'video_engine_commentmentions'


class VideoEngineDislikes(models.Model):
    creation_date = models.DateTimeField()
    disliked_by = models.ForeignKey(UserEngineUserprofile, models.DO_NOTHING)
    video = models.ForeignKey('VideoEngineVideopost', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'video_engine_dislikes'


class VideoEngineLikes(models.Model):
    creation_date = models.DateTimeField()
    liked_by = models.ForeignKey(UserEngineUserprofile, models.DO_NOTHING)
    video = models.ForeignKey('VideoEngineVideopost', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'video_engine_likes'


class VideoEnginePlaylist(models.Model):
    playlist_id = models.CharField(primary_key=True, max_length=32)
    name = models.CharField(max_length=120)
    description = models.TextField()
    creation_date = models.DateTimeField()
    views = models.BigIntegerField()
    created_by = models.ForeignKey(UserEngineUserprofile, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'video_engine_playlist'


class VideoEnginePlaylistitem(models.Model):
    added_at = models.DateTimeField()
    playlist = models.ForeignKey(VideoEnginePlaylist, models.DO_NOTHING)
    video = models.ForeignKey('VideoEngineVideopost', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'video_engine_playlistitem'


class VideoEngineVideodescriptionmentions(models.Model):
    creation_date = models.DateTimeField()
    mentioned_user = models.ForeignKey(UserEngineUserprofile, models.DO_NOTHING)
    video = models.ForeignKey('VideoEngineVideopost', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'video_engine_videodescriptionmentions'


class VideoEngineVideohashtags(models.Model):
    hashtag_string = models.TextField()
    creation_date = models.DateTimeField()
    video = models.ForeignKey('VideoEngineVideopost', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'video_engine_videohashtags'


class VideoEngineVideoimpressions(models.Model):
    times_impressed_again = models.PositiveBigIntegerField()
    creation_date = models.DateTimeField()
    impression_on = models.ForeignKey(UserEngineUserprofile, models.DO_NOTHING)
    video = models.ForeignKey('VideoEngineVideopost', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'video_engine_videoimpressions'


class VideoEngineVideopost(models.Model):
    video_id = models.CharField(primary_key=True, max_length=32)
    thumbnail = models.CharField(max_length=100, blank=True, null=True)
    title = models.CharField(max_length=120)
    video_file_original_name = models.TextField()
    video_file = models.CharField(max_length=100, blank=True, null=True)
    video_description = models.TextField(blank=True, null=True)
    video_duration_seconds = models.BigIntegerField(blank=True, null=True)
    impressions = models.PositiveBigIntegerField()
    likes = models.PositiveBigIntegerField()
    dislikes = models.PositiveBigIntegerField()
    comments = models.PositiveBigIntegerField()
    views = models.PositiveBigIntegerField()
    video_xp = models.PositiveBigIntegerField()
    topic_id = models.IntegerField()
    topic_category_id = models.IntegerField()
    language = models.CharField(max_length=64)
    transcript = models.TextField(blank=True, null=True)
    transcript_sentiment = models.IntegerField()
    description_sentiment = models.IntegerField()
    creation_date = models.DateTimeField()


    #META
    video_height = models.PositiveBigIntegerField()
    video_width = models.PositiveBigIntegerField()
    video_fps = models.PositiveBigIntegerField()
    video_frame_count = models.PositiveBigIntegerField()
    video_codec_info =  models.CharField(max_length=5)
    video_format = models.CharField(max_length=5)
    video_bitrate = models.FloatField()
    #AUDIO META
    audio_fps = models.PositiveBigIntegerField()
    audio_channels = models.PositiveBigIntegerField()
    audio_bitrate =  models.PositiveBigIntegerField()
    #
    is_processing = models.BooleanField()
    ml_processing_happening= models.BooleanField(default=False)
    ml_processing_contains_error = models.BooleanField(default=False)
    ml_processing_error_reason = models.TextField()

    is_processing = models.BooleanField(default=False)
    encoder_contains_error = models.BooleanField(default=False)
    encoder_error_reason = models.TextField()
    is_encoded = models.BooleanField()
    gone_through_ml = models.BooleanField() 
    is_active = models.BooleanField()
    is_advertisement = models.BooleanField()
    is_draft = models.BooleanField()
    is_unlisted = models.BooleanField()
    is_lounge_only = models.BooleanField()
    is_age_restricted = models.BooleanField()
    is_scheduled = models.BooleanField()
    contains_paid_promotion = models.BooleanField()
    scheduled_date = models.DateTimeField(blank=True, null=True)
    metrics_last_updated = models.DateTimeField()
    creator = models.ForeignKey(UserEngineUserprofile, models.DO_NOTHING)
    max_transcoded_resolution = models.BigIntegerField(default=0)

    class Meta:
        managed = False
        db_table = 'video_engine_videopost'


class VideoEngineVideoviews(models.Model):
    view_time_seconds = models.PositiveBigIntegerField()
    view_percentage = models.PositiveBigIntegerField()
    retention_percentage = models.PositiveBigIntegerField()
    times_rewatched = models.PositiveBigIntegerField()
    first_viewed = models.DateTimeField()
    last_rewatch = models.DateTimeField()
    video = models.ForeignKey(VideoEngineVideopost, models.DO_NOTHING)
    viewed_by = models.ForeignKey(UserEngineUserprofile, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'video_engine_videoviews'


class VideoEngineWatchlater(models.Model):
    added_at = models.DateTimeField()
    user = models.ForeignKey(UserEngineUserprofile, models.DO_NOTHING)
    video = models.ForeignKey(VideoEngineVideopost, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'video_engine_watchlater'
