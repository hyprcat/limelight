from django.db import models
from django.utils import timezone
from django.utils.translation import gettext_lazy as _

from modules.lounge_engine.models import LoungePost
from modules.user_engine.models import *
from modules.video_engine.models import *


class LogTypeAggregation(models.TextChoices):
    AVERAGE = "average", _("Average")
    TOTAL = "total", _("Total")


class LogType(models.TextChoices):
    DAY = "day", _("Day")
    WEEK = "week", _("Week")
    MONTH = "month", _("Month")
    YEAR = "year", _("Year")


class ViewDuration_VIDEO(models.Model):
    """Watch averages of one video: seconds watched, view percentage, retention and bounce rate."""

    log_type = models.CharField(
        max_length=6,
        choices=LogType.choices,
    )
    video = models.ForeignKey(VideoPost, related_name="keykeykey", on_delete=models.CASCADE, blank=True)
    average_seconds_watched = models.PositiveBigIntegerField(default=0)
    average_view_percentage = models.DecimalField(max_digits=4, decimal_places=3)
    total_views = models.PositiveIntegerField(default=0)
    most_views_location = models.TextField(blank=True)
    audience_retention_percentage = models.DecimalField(max_digits=4, decimal_places=3)
    bounce_rate = models.DecimalField(max_digits=5, decimal_places=2, default=0)
    conversion_rate = models.DecimalField(max_digits=5, decimal_places=2, default=0)
    log_date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.video.title}"

    class Meta:
        get_latest_by = ['log_date']
        verbose_name = "View Duration Video"
        verbose_name_plural = "View Duration Videos"


class VideoMetricsLog(models.Model):
    """Snapshot of a video's counters and XP at one point in time."""

    log_date = models.DateTimeField(auto_now_add=True)
    log_type = models.CharField(
        max_length=6,
        choices=LogType.choices,
    )
    impressions = models.PositiveBigIntegerField(default=0)
    likes = models.PositiveBigIntegerField(default=0)
    dislikes = models.PositiveBigIntegerField(default=0)
    comments = models.PositiveBigIntegerField(default=0)
    views = models.PositiveBigIntegerField(default=0)
    video_xp = models.PositiveBigIntegerField(default=0)
    video = models.ForeignKey(VideoPost, related_name="video_measured", on_delete=models.CASCADE)
    xp_growth_percentage = models.BigIntegerField(default=0)

    def __str__(self):
        return f"{self.video.title}"

    class Meta:
        get_latest_by = ['log_date']
        verbose_name = "Video Metrics Log"
        verbose_name_plural = "Video Metrics Logs"


class VideoXPDiffLog(models.Model):
    """XP change of a video over a day, week, month and year."""

    video = models.ForeignKey(VideoPost, related_name="e_video_measured", on_delete=models.CASCADE)
    day_usage_difference = models.BigIntegerField(default=0)
    week_usage_difference = models.BigIntegerField(default=0)
    month_usage_difference = models.BigIntegerField(default=0)
    yearly_usage_difference = models.BigIntegerField(default=0)
    logged_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"{self.video.title}"

    class Meta:
        get_latest_by = ['logged_at']
        verbose_name = "Video XP Log"
        verbose_name_plural = "Video XP Logs"


class SubscribersMetricLog(models.Model):
    """Subscriber gain and loss of a channel since its previous log of the same type."""

    log_date = models.DateTimeField(auto_now_add=True)
    log_type = models.CharField(
        max_length=6,
        choices=LogType.choices,
    )
    subscriber_gain = models.BigIntegerField(default=0)
    subscriber_lost = models.PositiveBigIntegerField(default=0)
    total_subscribers = models.PositiveBigIntegerField(default=0)
    net_subscribers = models.IntegerField(default=0)
    subscriber_growth_percentage = models.DecimalField(max_digits=5, decimal_places=2, default=0)
    channel = models.ForeignKey(Channel, related_name="sub_obj", on_delete=models.CASCADE)

    def __str__(self):
        return self.channel.name

    class Meta:
        get_latest_by = ['log_date']
        verbose_name = "Subscriber Metric Log"
        verbose_name_plural = "Subscriber Metric Logs"


class LoungeMetricLog(models.Model):
    """Snapshot of a lounge's XP, level, member count and category count."""

    log_date = models.DateTimeField(auto_now_add=True)
    log_type = models.CharField(
        max_length=6,
        choices=LogType.choices,
    )
    lounge_xp = models.BigIntegerField(default=0)
    lounge_level = models.PositiveBigIntegerField(default=1)
    total_members = models.PositiveBigIntegerField(default=0)
    total_categories = models.PositiveBigIntegerField(default=0)
    lounge_tiers = models.PositiveBigIntegerField(default=0)
    lounge = models.ForeignKey(Lounge, related_name="a_log", on_delete=models.CASCADE)
    xp_growth_percentage = models.BigIntegerField(default=0)

    def __str__(self):
        return self.lounge.name

    class Meta:
        get_latest_by = ['log_date']
        verbose_name = "Lounge Metric Log"
        verbose_name_plural = "Lounge Metric Logs"


class LoungePostMetricLog(models.Model):
    """Snapshot of a lounge post's counters and XP."""

    log_date = models.DateTimeField(auto_now_add=True)
    log_type = models.CharField(
        max_length=6,
        choices=LogType.choices,
    )
    xp = models.BigIntegerField(default=0)
    impressions = models.IntegerField(default=0)
    likes = models.PositiveBigIntegerField(default=0)
    dislikes = models.PositiveBigIntegerField(default=0)
    replies = models.PositiveBigIntegerField(default=0)
    xp_growth_percentage = models.BigIntegerField(default=0)
    lounge_post = models.ForeignKey(LoungePost, related_name="lp_obj", on_delete=models.CASCADE)

    def __str__(self):
        return self.lounge_post.text

    class Meta:
        get_latest_by = ['log_date']
        verbose_name = "Lounge Post Metric Log"
        verbose_name_plural = "Lounge Post Metric Logs"


class UserTopicRelations(models.Model):
    """How much one user has interacted with one topic and topic category."""

    log_date = models.DateTimeField(auto_now_add=True)
    relation_id = models.CharField(max_length=100, blank=True, unique=True, primary_key=True, default=uuid.uuid4)
    topic_id = models.BigIntegerField(default=-1)
    topic_category_id = models.BigIntegerField(default=-1)
    likes = models.PositiveBigIntegerField(default=0)
    dislikes = models.PositiveBigIntegerField(default=0)
    comments = models.PositiveBigIntegerField(default=0)
    views = models.PositiveBigIntegerField(default=0)
    positive_comments_made = models.PositiveBigIntegerField(default=0)
    negative_comments_made = models.PositiveBigIntegerField(default=0)
    favoritism_weight = models.PositiveBigIntegerField(default=0)
    user = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name="topic_relation_user")

    def __str__(self):
        return self.user.user.username

    class Meta:
        get_latest_by = ['log_date']
        verbose_name = "User Topic Relation Log"
        verbose_name_plural = "User Topic Relation Logs"


class ChannelMetrics(models.Model):
    """Average or total of a channel's video counters, one row per aggregation and log type."""

    aggregation_type = models.CharField(
        max_length=12,
        choices=LogTypeAggregation.choices,
    )
    log_type = models.CharField(max_length=6, choices=LogType.choices, default=LogType.DAY)
    channel = models.ForeignKey(Channel, related_name="cha_cha", on_delete=models.CASCADE)
    impressions = models.PositiveBigIntegerField(default=0, null=True)
    likes = models.PositiveBigIntegerField(
        default=0,
    )
    dislikes = models.PositiveBigIntegerField(default=0)
    comments = models.PositiveBigIntegerField(default=0)
    views = models.PositiveBigIntegerField(default=0)
    video_xp = models.PositiveBigIntegerField(default=0)
    xp_growth_percentage = models.BigIntegerField(default=0)
    log_date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.channel.name

    class Meta:
        get_latest_by = ['log_date']
        verbose_name = "Channel Metric Log"
        verbose_name_plural = "Channel Metric Logs"


class Blog(models.Model):
    author = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name="author")
    headline = models.TextField()
    text = models.TextField()
    impressions = models.PositiveBigIntegerField(default=0)
    creation_date = models.DateTimeField(auto_now_add=True)


# CONSOLE GRAPH LOGS
# Each model below stores a count, the count of the previous row and the change in percent.
# The admin console draws its graphs from them.

class UserProfileGrowthLog(models.Model):
    count = models.PositiveBigIntegerField(default=0)
    day_before = models.PositiveBigIntegerField(default=0)
    growth_percentage_day = models.BigIntegerField(default=0)
    creation_date = models.DateTimeField(auto_now_add=True)

    class Meta:
        get_latest_by = ['creation_date']


class VideoPostGrowthLog(models.Model):
    count = models.PositiveBigIntegerField(default=0)
    day_before = models.PositiveBigIntegerField(default=0)
    growth_percentage_day = models.BigIntegerField(default=0)
    creation_date = models.DateTimeField(auto_now_add=True)

    class Meta:
        get_latest_by = ['creation_date']


class ThreadsGrowthLog(models.Model):
    count = models.PositiveBigIntegerField(default=0)
    day_before = models.PositiveBigIntegerField(default=0)
    growth_percentage_day = models.BigIntegerField(default=0)
    creation_date = models.DateTimeField(auto_now_add=True)

    class Meta:
        get_latest_by = ['creation_date']


class ReportedVideoTracker(models.Model):
    count = models.PositiveBigIntegerField(default=0)
    day_before = models.PositiveBigIntegerField(default=0)
    growth_percentage_day = models.BigIntegerField(default=0)
    creation_date = models.DateTimeField(auto_now_add=True)

    class Meta:
        get_latest_by = ['creation_date']


class ReportedThreadsTracker(models.Model):
    count = models.PositiveBigIntegerField(default=0)
    day_before = models.PositiveBigIntegerField(default=0)
    growth_percentage_day = models.BigIntegerField(default=0)
    creation_date = models.DateTimeField(auto_now_add=True)

    class Meta:
        get_latest_by = ['creation_date']


class ReportedCommentTracker(models.Model):
    count = models.PositiveBigIntegerField(default=0)
    day_before = models.PositiveBigIntegerField(default=0)
    growth_percentage_day = models.BigIntegerField(default=0)
    creation_date = models.DateTimeField(auto_now_add=True)

    class Meta:
        get_latest_by = ['creation_date']


class VideosUnderProcessing(models.Model):
    count = models.PositiveBigIntegerField(default=0)
    day_before = models.PositiveBigIntegerField(default=0)
    growth_percentage_day = models.BigIntegerField(default=0)
    creation_date = models.DateTimeField(auto_now_add=True)

    class Meta:
        get_latest_by = ['creation_date']


class VideosUnderEncoding(models.Model):
    count = models.PositiveBigIntegerField(default=0)
    day_before = models.PositiveBigIntegerField(default=0)
    growth_percentage_day = models.BigIntegerField(default=0)
    creation_date = models.DateTimeField(auto_now_add=True)

    class Meta:
        get_latest_by = ['creation_date']


class VideosUnderMLProcessing(models.Model):
    count = models.PositiveBigIntegerField(default=0)
    day_before = models.PositiveBigIntegerField(default=0)
    growth_percentage_day = models.BigIntegerField(default=0)
    creation_date = models.DateTimeField(auto_now_add=True)

    class Meta:
        get_latest_by = ['creation_date']


class SeptemberContest(models.Model):
    """One user's entry in the September 2024 subscriber contest."""

    user = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name="september_contestent")
    subscriber_count = models.BigIntegerField(default=-1)
    at_start_subscribers = models.BigIntegerField(default=-1)
    end_date = models.DateTimeField(default = timezone.datetime(2024, 9, 10))
    start_date = models.DateTimeField(default = timezone.datetime(2024, 9, 7))
    creation_date = models.DateTimeField(auto_now_add=True)


class SeptemberContestDetailsModifier(models.Model):
    """Contest dates set from the admin. The latest row is copied onto every SeptemberContest entry."""

    end_date = models.DateTimeField(default = timezone.datetime(2024, 9, 10))
    start_date = models.DateTimeField(default = timezone.datetime(2024, 9, 7))
    creation_date = models.DateTimeField(auto_now_add=True)

    class Meta:
        get_latest_by = ['creation_date']
