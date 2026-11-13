import logging
from datetime import timedelta
from decimal import Decimal, ROUND_DOWN

from django.core.exceptions import ObjectDoesNotExist
from django.db.models import Avg, Sum
from modules.analytics_engine.models import *
from modules.lounge_engine.models import LoungeDislike, LoungeLike, ReportedPost


class AnalyticsEngine:
    """Computes XP, levels and metric logs for videos, users, channels and lounges."""

    def __meta__(self):
        self.VERSION = 0.3
        self.MAX_OBJECT_LIMIT = 12
        self.BUILD = "ALPHA"

    def __lounge_weights___(self):
        self.lounge_members = 1
        self.lounge_challenges = 1.2

    def __favouritism_weights__(self):
        self.topic_likes_weight = 0.2
        self.topic_comments_weight = 0.6
        self.topic_sub_comments_weight = 0.5
        self.positive_comments_weight = 0.4
        self.negative_comments_weight = -0.1
        self.interactions_weight = 0.05
        self.average_sentiment_value = 0.2

    def __channel_weights__(self):
        self.channel_XP_video_average = 0.5
        self.channel_sub_count = 0.25
        self.channel_average_engagement = 2
        self.channel_average_view_percentage = 1
        self.channel_average_audience_retention_percentage = 1.5
        self.channel_average_conversion_rate = 0.75
        self.channel_impressions = 0.1
        self.channel_likes = 1
        self.channel_dislikes = 0
        self.channel_comments = 1.25
        self.channel_views = 0.15

    def __basic_metrics_weights__(self):
        self.like_weight = 1
        self.dislike_weight = 0
        self.comment_weight = 2
        self.view_weight = 0.1
        self.impression_weight = 0.15
        self.subscribers_weight = 0.25
        self.seconds_watched = 0.015
        self.audience_retention_percentage = 3
        self.average_view_percentage = 1.5
        self.bounce_rate = 1.25
        self.conversion_rate = 1.25
        self.XP_weight = 0.55
        self.age_restriction_penality = 0.25

        self.unlisted_ratio = 0.01
        self.unlisted_like_weight = self.like_weight * self.unlisted_ratio
        self.unlisted_dislike_weight = self.dislike_weight * self.unlisted_ratio
        self.unlisted_comment_weght = self.view_weight * self.unlisted_ratio
        self.unlisted_view_weight = self.view_weight * self.unlisted_ratio
        self.unlisted_impression_weight = self.impression_weight * self.unlisted_ratio

    def __init__(self) -> None:
        self.__meta__()
        self.__basic_metrics_weights__()
        self.__channel_weights__()
        self.__lounge_weights___()
        self.__favouritism_weights__()
        logging.info(f"Analytics Engine Manager {self.VERSION} {self.BUILD}")

    def _is_due(self, last_run, log_type):
        """Return True when more than one log_type period has passed since last_run."""
        if log_type == LogType.DAY:
            diff = timedelta(days=1)
        elif log_type == LogType.WEEK:
            diff = timedelta(weeks=1)
        elif log_type == LogType.MONTH:
            diff = timedelta(weeks=4)
        elif log_type == LogType.YEAR:
            diff = timedelta(weeks=52.14)
        else:
            diff = timedelta(seconds=5)

        return timezone.now() - last_run > diff

    def analytics_verification_logs(self, object, log_type):
        """Return True when a log row is older than one log_type period (5 seconds when log_type is None)."""
        return self._is_due(object.log_date, log_type)

    def analytics_verification(self, object, log_type):
        """Return True when the object's metrics are older than one log_type period (5 seconds when None)."""
        return self._is_due(object.metrics_last_updated, log_type)

    def _xp_growth_percentage(self, current_xp, previous_logs, xp_field):
        """Percentage change of current_xp against the latest row in previous_logs. 0 when there is no row or it holds 0."""
        try:
            previous_xp = getattr(previous_logs.latest(), xp_field)
            return ((current_xp - previous_xp) / previous_xp) * 100
        except (ObjectDoesNotExist, ZeroDivisionError):
            return 0

    # ---------------------------------------------------------------------------
    # FUNDAMENTAL METRICS
    def calculate_engagement(self, video: VideoPost):
        """Engagement rate of a video: (comments + likes + dislikes) / (impressions + views + subscribers)."""
        if video.views == 0:
            return 0
        else:
            comments = video.comments
            likes = video.likes
            dislikes = video.dislikes
            impressions = video.impressions
            views = video.views
            subscribers = video.creator.associated_channel.subscriber_count

            engagement_rate = (comments + likes + dislikes) / (impressions + views + subscribers)

            return engagement_rate

    def update_user_topic_relations(self, user_profile, video_post):
        """Recount the user's views, likes, dislikes and comments for the video's topic and topic category."""
        topic_id = video_post.topic_id
        topic_category_id = video_post.topic_category_id

        relation = UserTopicRelations.objects.filter(
            user=user_profile, topic_id=topic_id, topic_category_id=topic_category_id
        ).first()

        if relation is None:
            relation = UserTopicRelations()
            relation.user = user_profile
            relation.topic_id = topic_id
            relation.topic_category_id = topic_category_id

        views = VideoViews.objects.filter(video__topic_id=topic_id, viewed_by=user_profile).count()
        likes = Likes.objects.filter(video__topic_id=topic_id, liked_by=user_profile).count()
        dislikes = DisLikes.objects.filter(video__topic_id=topic_id, disliked_by=user_profile).count()
        comments = Comment.objects.filter(video__topic_id=topic_id, commented_by=user_profile).count()
        likes += CommentLikes.objects.filter(comment__video__topic_id=topic_id, liked_by=user_profile).count()
        dislikes += CommentDisLikes.objects.filter(comment__video__topic_id=topic_id, disliked_by=user_profile).count()

        views += VideoViews.objects.filter(video__topic_category_id=topic_category_id, viewed_by=user_profile).count()
        likes += Likes.objects.filter(video__topic_category_id=topic_category_id, liked_by=user_profile).count()
        dislikes += DisLikes.objects.filter(
            video__topic_category_id=topic_category_id, disliked_by=user_profile
        ).count()
        comments += Comment.objects.filter(
            video__topic_category_id=topic_category_id, commented_by=user_profile
        ).count()
        likes += CommentLikes.objects.filter(
            comment__video__topic_category_id=topic_category_id, liked_by=user_profile
        ).count()
        dislikes += CommentDisLikes.objects.filter(
            comment__video__topic_category_id=topic_category_id, disliked_by=user_profile
        ).count()

        relation.likes = likes
        relation.dislikes = dislikes
        relation.comments = comments
        relation.views = views
        relation.favoritism_weight = self.calculate_favoritism_bias(relation)
        relation.save()

    def calculate_total_user_topic_relations(self, user_profile):
        """Sum the user's likes, dislikes, views and comment sentiment counts over all topic relations."""
        user_relations = UserTopicRelations.objects.filter(user=user_profile)
        engagement_data = {
            "total_likes": user_relations.aggregate(Sum("likes"))["likes__sum"] or 0,
            "total_dislikes": user_relations.aggregate(Sum("dislikes"))["dislikes__sum"] or 0,
            "times_interacted": user_relations.aggregate(Sum("views"))["views__sum"] or 0,
            "positive_comments_made": user_relations.aggregate(Sum("positive_comments_made"))[
                "positive_comments_made__sum"
            ]
            or 0,
            "negative_comments_made": user_relations.aggregate(Sum("negative_comments_made"))[
                "negative_comments_made__sum"
            ]
            or 0,
        }
        return engagement_data

    def calculate_xp_USER(self, user_profile: UserProfile):
        """User XP: weighted likes, dislikes and views summed over the user's topic relations, scaled by XP_weight."""
        user_relations = self.calculate_total_user_topic_relations(user_profile)

        likes = user_relations["total_likes"]
        dislikes = user_relations["total_dislikes"]
        times_interacted_with_a_video = user_relations["times_interacted"]
        return (
            likes * self.like_weight
            + dislikes * self.dislike_weight
            + times_interacted_with_a_video * self.view_weight
        ) * self.XP_weight

    def calculate_xp_LOUNGE(self, lounge: Lounge):
        """Lounge XP: the sum of each category's average post XP, divided by the lounge's category count."""
        categories = lounge.total_categories
        categories_qs = LoungeCategories.objects.filter(lounge=lounge).all()

        sum_category_xp = 0
        for category in categories_qs:
            sum_category_xp += self.calculate_average_xp_per_lounge_category(category) or 0

        return sum_category_xp / categories if categories > 0 else 0

    def calculate_xp_VIDEO(self, video: VideoPost):
        """Video XP: weighted sum of likes, dislikes, comments, watch metrics, views and channel subscribers."""
        # NOTE: create_or_update_view_metrics never sets log_type on the rows it writes, and
        # get_view_duration_object filters on log_type=DAY, so the watch metrics below stay 0
        # and views come from video.views.
        video_view_duration = self.get_view_duration_object(video)
        likes = video.likes
        dislikes = video.dislikes
        comments = video.comments
        average_seconds_watched = 0
        average_view_percentage = 0
        total_views = video.views
        audience_retention_percentage = 0
        bounce_rate = 0
        conversion_rate = 0
        if video_view_duration is not None:
            average_seconds_watched = video_view_duration.average_seconds_watched
            average_view_percentage = video_view_duration.average_view_percentage
            total_views = video_view_duration.total_views
            audience_retention_percentage = video_view_duration.audience_retention_percentage
            bounce_rate = video_view_duration.bounce_rate
            conversion_rate = video_view_duration.conversion_rate

        subscribers = video.creator.associated_channel.subscriber_count

        experience_points = (
            (self.like_weight * likes)
            + (self.dislike_weight * dislikes)
            + (self.comment_weight * comments)
            + (self.seconds_watched * average_seconds_watched)
            + (self.average_view_percentage * average_view_percentage)
            + (self.view_weight * total_views)
            + (self.audience_retention_percentage * audience_retention_percentage)
            + (self.bounce_rate * bounce_rate)
            + (self.conversion_rate * conversion_rate)
            + (self.subscribers_weight * subscribers)
        )
        return experience_points

    def calculate_xp_CHANNEL(self, channel):
        """Channel XP: the average XP of the owner's videos times channel_XP_video_average."""
        average_XP_videos = self.calculate_channel_average_video_xp(channel)
        if average_XP_videos is None:
            return 0
        return self.channel_XP_video_average * average_XP_videos

    def get_experience_points_for_level(self, level, base_points=50, multiplier=2):
        """XP threshold for a level: base_points * multiplier ** level."""
        return base_points * (multiplier**level)

    def generate_level(self, user_exp_points, base_points=50, multiplier=2):
        """Return the level for an XP total. Level 1 below the level 1 threshold, then one level per doubling."""
        if user_exp_points < self.get_experience_points_for_level(1):
            return 1

        level = 2
        initial_level_points = self.get_experience_points_for_level(level, base_points, multiplier)
        while user_exp_points >= initial_level_points:
            level += 1
            initial_level_points = self.get_experience_points_for_level(level, base_points, multiplier)

        return level

    # ---------------------------------------------------------------------------

    def calculate_xp_lounge_post(self, lounge_post: LoungePost):
        """Lounge post XP: weighted likes, dislikes, impressions and replies, plus sentiment divided by depth."""
        likes = lounge_post.likes
        dislikes = lounge_post.dislikes
        replies = lounge_post.replies
        impressions = lounge_post.impressions

        post_sentiment = lounge_post.post_sentiment
        post_depth = lounge_post.post_depth

        xp = (
            (self.like_weight * likes)
            + (self.dislike_weight * dislikes)
            + (self.impression_weight * impressions)
            + (self.comment_weight * replies)
            + ((self.average_sentiment_value * post_sentiment) / post_depth)
        )
        return xp

    def calculate_average_xp_per_lounge_category(self, category):
        """Average XP of the posts in every section of a lounge category."""
        sections = LoungeSections.objects.filter(related_category=category).all()
        return LoungePost.objects.filter(associated_lounge_section__in=sections).aggregate(Avg("xp"))["xp__avg"]

    def calculate_net_xp_per_lounge_category(self, category):
        """Total XP of the posts in every section of a lounge category."""
        sections = LoungeSections.objects.filter(related_category=category).all()
        return LoungePost.objects.filter(associated_lounge_section__in=sections).aggregate(Sum("xp"))["xp__sum"]

    def calculate_engagement_for_lounge_posts(self, lounge_post: LoungePost):
        """Engagement rate of a lounge post: (replies + likes + dislikes) / (impressions + lounge members)."""
        likes = lounge_post.likes
        dislikes = lounge_post.dislikes
        replies = lounge_post.replies
        impressions = lounge_post.impressions

        engagement_rate = (replies + likes + dislikes) / (
            impressions + lounge_post.associated_lounge_section.lounge.total_members
        )
        return engagement_rate

    # ---------------------------------------------------------------------------
    def _average_view_field(self, video, field):
        """Average one VideoViews field over all views of a video, 0 when it has no views."""
        view_objects = VideoViews.objects.filter(video=video).all()
        total_objects = view_objects.count()
        field_sum = view_objects.aggregate(Sum(field))[f"{field}__sum"]
        return (field_sum / total_objects) if total_objects > 0 else 0

    def calculate_average_seconds_watched(self, video):
        """Average view_time_seconds over all views of a video."""
        return self._average_view_field(video, "view_time_seconds")

    def calculate_average_view_percentage(self, video):
        """Average view_percentage over all views of a video."""
        return self._average_view_field(video, "view_percentage")

    def calculate_retention_percentage(self, video):
        """Average retention_percentage over all views of a video."""
        return self._average_view_field(video, "retention_percentage")

    def calculate_bounce_rate(self, video):
        """Views divided by impressions, 0 when the video has no impressions."""
        return (video.views / video.impressions) if video.impressions > 0 else 0

    # ---------------------------------------------------------------------------
    # CHANNEL AVERAGES
    def _channel_aggregate(self, channel, aggregate, field):
        """Apply Avg or Sum to one VideoPost field over all videos of the channel owner."""
        key = f"{field}__{aggregate.name.lower()}"
        return VideoPost.objects.filter(creator=channel.owner).aggregate(aggregate(field))[key]

    def calculate_channel_average_impressions(self, channel):
        """Average impressions per video of the channel."""
        return self._channel_aggregate(channel, Avg, "impressions")

    def calculate_channel_average_likes(self, channel):
        """Average likes per video of the channel."""
        return self._channel_aggregate(channel, Avg, "likes")

    def calculate_channel_average_dislikes(self, channel):
        """Average dislikes per video of the channel."""
        return self._channel_aggregate(channel, Avg, "dislikes")

    def calculcate_channel_average_comments(self, channel):
        """Average comments per video of the channel."""
        return self._channel_aggregate(channel, Avg, "comments")

    def calculcate_channel_average_views(self, channel):
        """Average views per video of the channel."""
        return self._channel_aggregate(channel, Avg, "views")

    def calculate_channel_average_video_xp(self, channel):
        """Average XP per video of the channel."""
        return self._channel_aggregate(channel, Avg, "video_xp")

    # ---------------------------------------------------------------------------
    # CHANNEL TOTALS

    def calculate_channel_total_impressions(self, channel):
        """Total impressions over the channel's videos."""
        return self._channel_aggregate(channel, Sum, "impressions")

    def calculate_channel_total_likes(self, channel):
        """Total likes over the channel's videos."""
        return self._channel_aggregate(channel, Sum, "likes")

    def calculate_channel_total_dislikes(self, channel):
        """Total dislikes over the channel's videos."""
        return self._channel_aggregate(channel, Sum, "dislikes")

    def calculcate_channel_total_comments(self, channel):
        """Total comments over the channel's videos."""
        return self._channel_aggregate(channel, Sum, "comments")

    def calculcate_channel_total_views(self, channel):
        """Total views over the channel's videos."""
        return self._channel_aggregate(channel, Sum, "views")

    def calculate_channel_total_video_xp(self, channel):
        """Total XP over the channel's videos."""
        return self._channel_aggregate(channel, Sum, "video_xp")

    # ---------------------------------------------------------------------------
    # CHANNEL SUBSCRIBERS
    def _average_subscriber_metric(self, field, log_type, window):
        """Average one SubscribersMetricLog field over every channel's logs of log_type inside the window."""
        return SubscribersMetricLog.objects.filter(
            log_type=log_type,
            log_date__gte=timezone.now() - window,
        ).aggregate(Avg(field))[f"{field}__avg"]

    # SUBSCRIBER GAIN
    def calculate_average_gain_DAY(self):
        """Average subscriber gain in the daily logs of the last 30 days."""
        return self._average_subscriber_metric("subscriber_gain", LogType.DAY, timedelta(days=30))

    def calculate_average_gain_WEEK(self):
        """Average subscriber gain in the weekly logs of the last 8 weeks."""
        return self._average_subscriber_metric("subscriber_gain", LogType.WEEK, timedelta(weeks=8))

    def calculate_average_gain_MONTH(self):
        """Average subscriber gain in the monthly logs of the last 52 weeks."""
        return self._average_subscriber_metric("subscriber_gain", LogType.MONTH, timedelta(weeks=52))

    def calculate_average_gain_YEAR(self):
        """Average subscriber gain in the yearly logs of the last 5 years."""
        return self._average_subscriber_metric("subscriber_gain", LogType.YEAR, timedelta(weeks=52 * 5))

    # SUBSCRIBER LOSS
    def calculate_average_loss_DAY(self):
        """Average subscriber loss in the daily logs of the last 30 days."""
        return self._average_subscriber_metric("subscriber_lost", LogType.DAY, timedelta(days=30))

    def calculate_average_loss_WEEK(self):
        """Average subscriber loss in the weekly logs of the last 8 weeks."""
        return self._average_subscriber_metric("subscriber_lost", LogType.WEEK, timedelta(weeks=8))

    def calculate_average_loss_MONTH(self):
        """Average subscriber loss in the monthly logs of the last 52 weeks."""
        return self._average_subscriber_metric("subscriber_lost", LogType.MONTH, timedelta(weeks=52))

    def calculate_average_loss_YEAR(self):
        """Average subscriber loss in the yearly logs of the last 5 years."""
        return self._average_subscriber_metric("subscriber_lost", LogType.YEAR, timedelta(weeks=52 * 5))

    def calculate_average_subscriber_growth_percentage(self):
        """Average subscriber growth percentage in the yearly logs of the last 5 years."""
        return self._average_subscriber_metric("subscriber_growth_percentage", LogType.YEAR, timedelta(weeks=52 * 5))

    def calculate_subscriber_gain(self, channel, log_type):
        """Subscribers gained since the channel's latest log of this type, never below 0."""
        latest_log = (
            SubscribersMetricLog.objects.filter(channel=channel, log_type=log_type).order_by("-log_date").first()
        )
        if latest_log is None:
            return channel.subscriber_count
        value = channel.subscriber_count - latest_log.total_subscribers
        if value > 0:
            return value
        return 0

    def calculate_subcriber_loss(self, channel, log_type):
        """Subscribers lost since the channel's latest log of this type, never below 0."""
        latest_log = (
            SubscribersMetricLog.objects.filter(channel=channel, log_type=log_type).order_by("-log_date").first()
        )
        if latest_log is None:
            return channel.subscriber_count
        value = channel.subscriber_count - latest_log.total_subscribers
        if value < 0:
            return abs(value)
        return 0

    def calculate_subscriber_growth_percentage(self, subscriber_metrics_log):
        """Subscriber gain of a log row divided by its total subscribers."""
        return subscriber_metrics_log.subscriber_gain / subscriber_metrics_log.total_subscribers

    # ---------------------------------------------------------------------------
    # USER TOPIC RELATIONS
    def calculate_all_likes_topic(self, user_profile, topic_id):
        """Count the user's likes on videos of a topic."""
        video_posts = VideoPost.objects.filter(topic_id=topic_id)
        return Likes.objects.filter(
            liked_by=user_profile,
            video__in=video_posts,
        ).count()

    def calculate_all_dislikes_topic(self, user_profile, topic_id):
        """Count the user's dislikes on videos of a topic."""
        video_posts = VideoPost.objects.filter(topic_id=topic_id)
        return DisLikes.objects.filter(
            disliked_by=user_profile,
            video__in=video_posts,
        ).count()

    def calculate_all_comments_topic(self, user_profile, topic_id):
        """Count the user's comments on videos of a topic."""
        video_posts = VideoPost.objects.filter(topic_id=topic_id)
        return Comment.objects.filter(
            commented_by=user_profile,
            video__in=video_posts,
        ).count()

    def calculate_all_views_topic(self, user_profile, topic_id):
        """Count the user's views of videos of a topic."""
        video_posts = VideoPost.objects.filter(topic_id=topic_id)
        return VideoViews.objects.filter(
            viewed_by=user_profile,
            video__in=video_posts,
        ).count()

    def calculate_all_negative_comments_topic(self, user_profile, topic_id):
        """Count the user's comments with negative sentiment on videos of a topic."""
        video_posts = VideoPost.objects.filter(topic_id=topic_id)
        return Comment.objects.filter(
            commented_by=user_profile, video__in=video_posts, comment_sentiment__lt=0
        ).count()

    def calculate_all_positive_comments_topic(self, user_profile, topic_id):
        """Count the user's comments with zero or positive sentiment on videos of a topic."""
        video_posts = VideoPost.objects.filter(topic_id=topic_id)
        return Comment.objects.filter(
            commented_by=user_profile, video__in=video_posts, comment_sentiment__gte=0
        ).count()

    def calculate_favoritism_bias(self, relation):
        """Weighted score of how much a user favours a topic, from the counts on a UserTopicRelations row."""
        bias = 0
        try:
            bias += self.topic_likes_weight * (relation.likes - relation.dislikes)
            bias += self.topic_comments_weight * (relation.comments)
            # NOTE: UserTopicRelations has no sub_comments field, so this line raises and the
            # terms below it are never added.
            bias += self.topic_sub_comments_weight * relation.sub_comments
            bias += self.positive_comments_weight * relation.positive_comments_made
            bias += self.negative_comments_weight * relation.negative_comments_made
            # SENTIMENTS NOT YET PRESENT
            bias += 1 * (
                (relation.positive_comments_made + relation.negative_comments_made)
                / ((relation.comments) if (relation.comments) > 0 else 1)
            )

            return bias
        except AttributeError:
            pass
        return bias

    # ---------------------------------------------------------------------------

    def get_view_duration_object(self, video):
        """Latest daily ViewDuration_VIDEO row of a video, or None."""
        return ViewDuration_VIDEO.objects.filter(video=video, log_type=LogType.DAY).order_by("-log_date").first()

    def get_video_metrics_log_object(self, video):
        """Latest daily VideoMetricsLog row of a video, or None."""
        return VideoMetricsLog.objects.filter(video=video, log_type=LogType.DAY).order_by("-log_date").first()

    def get_subscriber_metrics_log(self, channel):
        """Latest daily SubscribersMetricLog row of a channel, or None."""
        return SubscribersMetricLog.objects.filter(channel=channel, log_type=LogType.DAY).order_by("-log_date").first()

    # ---------------------------------------------------------------------------
    # FOR CELERY
    def log_lounge_metrics(self, lounge: Lounge, log_type):
        """Write a LoungeMetricLog snapshot of the lounge when its metrics are due for this log_type."""
        try:
            if self.analytics_verification(lounge, log_type):
                log_object = LoungeMetricLog()
                log_object.log_type = log_type if log_type is not None else LogType.DAY
                log_object.lounge_xp = lounge.lounge_xp
                log_object.lounge_level = lounge.lounge_level
                log_object.total_members = lounge.total_members
                log_object.total_categories = lounge.total_categories
                log_object.lounge_tiers = lounge.lounge_tiers
                log_object.lounge = lounge
                log_object.xp_growth_percentage = self._xp_growth_percentage(
                    log_object.lounge_xp,
                    LoungeMetricLog.objects.filter(lounge=lounge, log_type=log_type),
                    "lounge_xp",
                )
                log_object.save()

                lounge.metrics_last_updated = timezone.now()
                lounge.save()
        except Exception as e:
            logging.error(f"Error while logging lounge metrics: {e}")

    def log_lounge_post_metrics(self, lounge_post: LoungePost, log_type):
        """Write a LoungePostMetricLog snapshot of the post when its metrics are due for this log_type."""
        try:
            if self.analytics_verification(lounge_post, log_type):
                log_object = LoungePostMetricLog()
                log_object.log_type = log_type
                log_object.likes = lounge_post.likes
                log_object.dislikes = lounge_post.dislikes
                log_object.replies = lounge_post.replies
                log_object.impressions = lounge_post.impressions
                log_object.xp = lounge_post.xp
                log_object.lounge_post = lounge_post
                log_object.xp_growth_percentage = self._xp_growth_percentage(
                    log_object.xp,
                    LoungePostMetricLog.objects.filter(lounge_post=lounge_post, log_type=log_type),
                    "xp",
                )
                log_object.save()

                lounge_post.metrics_last_updated = timezone.now()
                lounge_post.save()
        except Exception as e:
            logging.error(f"Error while logging lounge post metrics: {e}")

    def log_video_metrics(self, video, log_type):
        """Write a VideoMetricsLog snapshot of the video. A log_type of None is stored as DAY."""
        log_object = VideoMetricsLog()
        log_object.log_type = log_type if log_type is not None else LogType.DAY
        log_object.likes = video.likes
        log_object.dislikes = video.dislikes
        log_object.comments = video.comments
        log_object.views = video.views
        log_object.video_xp = video.video_xp
        log_object.video = video
        # NOTE: the previous row is looked up with the log_type as passed in, so a call with
        # log_type=None finds no previous row and stores a growth of 0.
        log_object.xp_growth_percentage = self._xp_growth_percentage(
            log_object.video_xp,
            VideoMetricsLog.objects.filter(video=video, log_type=log_type),
            "video_xp",
        )
        log_object.save()

        video.metrics_last_updated = timezone.now()
        video.save()

    def log_subscriber_metrics(self, channel, log_type):
        """Write a SubscribersMetricLog row with the gain and loss since the channel's previous log of this type."""
        try:
            log_object = SubscribersMetricLog()
            log_object.log_type = log_type
            log_object.channel = channel
            log_object.total_subscribers = channel.subscriber_count
            log_object.subscriber_gain = self.calculate_subscriber_gain(channel, log_type)
            log_object.subscriber_lost = self.calculate_subcriber_loss(channel, log_type)
            log_object.subscriber_growth_percentage = (
                log_object.subscriber_gain / log_object.total_subscribers if log_object.total_subscribers > 0 else 0
            )
            log_object.net_subscribers = log_object.subscriber_gain + log_object.subscriber_lost
            log_object.save()
        except Exception as e:
            logging.error(f"Error while logging subscriber metrics (log): {e}")

    def recount_likes_and_dislikes_VIDEO(self, video: VideoPost):
        """Count the like, dislike and comment rows of a video. Returns (likes, dislikes, comments)."""
        try:
            likes = Likes.objects.filter(video=video).count()
            dislikes = DisLikes.objects.filter(video=video).count()
            comments = Comment.objects.filter(video=video).count()

            return (likes, dislikes, comments)
        except Exception as e:
            logging.error(f"ERROR while recounting video likes and dislikes: {str(e)}")

    def recount_likes_and_dislikes_VIDEO_COMMENT(self, comment: Comment):
        """Count the like and dislike rows of a video comment. Returns (likes, dislikes)."""
        try:
            likes = CommentLikes.objects.filter(comment=comment).count()
            dislikes = CommentDisLikes.objects.filter(comment=comment).count()
            return (likes, dislikes)
        except Exception as e:
            logging.error(f"ERROR while recounting comment likes and dislikes: {str(e)}")

    def recount_likes_and_dislikes_LOUNGE_POST(self, post: LoungePost):
        """Count the like and dislike rows of a lounge post. Returns (likes, dislikes)."""
        try:
            likes = LoungeLike.objects.filter(post=post).count()
            dislikes = LoungeDislike.objects.filter(post=post).count()
            return (likes, dislikes)
        except Exception as e:
            logging.error(f"ERROR while recounting lounge post likes and dislikes: {str(e)}")

    def recount_videos(self, user_profile):
        """Store the number of videos the user has created on their channel."""
        total_videos = VideoPost.objects.filter(creator=user_profile).count()
        user_profile.associated_channel.videos_count = total_videos
        user_profile.associated_channel.save()

    def recount_lounge_members(self, lounge: Lounge):
        """Store the number of participants on the lounge."""
        participants = LoungeParticipants.objects.filter(lounge=lounge).count()
        lounge.total_members = participants
        lounge.save()

    def _clamped_percentage(self, value):
        """Convert a percentage to a 3 decimal place Decimal that fits max_digits=4. Values of 10 or more become 0.999."""
        value = Decimal(value)
        if abs(value) >= 10:
            value = Decimal("0.999") if value > 0 else Decimal("-0.999")
        return value.quantize(Decimal("1.000"), rounding=ROUND_DOWN)

    def create_or_update_view_metrics(self, video: VideoPost, log_type=None):
        """Refresh the video's ViewDuration_VIDEO row with its current watch averages. log_type is not used."""
        try:
            log_object = ViewDuration_VIDEO.objects.filter(video=video).last()
            if log_object is None:
                log_object = ViewDuration_VIDEO()
                log_object.video = video

            log_object.average_seconds_watched = self.calculate_average_seconds_watched(video)
            log_object.average_view_percentage = self._clamped_percentage(
                self.calculate_average_view_percentage(video)
            )
            log_object.total_views = video.views
            log_object.audience_retention_percentage = self._clamped_percentage(
                self.calculate_retention_percentage(video)
            )
            log_object.bounce_rate = Decimal(self.calculate_bounce_rate(video)).quantize(
                Decimal("1.00"), rounding=ROUND_DOWN
            )
            log_object.log_date = timezone.now()
            log_object.save()

        except Exception as e:
            logging.error(f"Error while logging view metrics: {e}")
            raise

    def celery_generate_relations(self, user_profile):
        """Rebuild the user's topic relations from every video they have viewed."""
        viewed_videos = VideoViews.objects.filter(viewed_by=user_profile).all()
        video_qs = VideoPost.objects.filter(video_id__in=viewed_videos.values("video"))
        logging.info("calculating topic relations")
        for video in video_qs:
            self.update_user_topic_relations(user_profile, video)
        logging.info("DONE WITH RELATIONS")

    def create_or_update_topic_relation_log(self, user_profile, topic_id, topic_category_id):
        """Recount one topic relation of a user, including positive and negative comment counts."""
        try:
            log_object, _ = UserTopicRelations.objects.get_or_create(
                user=user_profile, topic_id=topic_id, topic_category_id=topic_category_id
            )

            log_object.likes = self.calculate_all_likes_topic(user_profile, topic_id)
            log_object.dislikes = self.calculate_all_dislikes_topic(user_profile, topic_id)
            log_object.comments = self.calculate_all_comments_topic(user_profile, topic_id)
            log_object.positive_comments_made = self.calculate_all_positive_comments_topic(user_profile, topic_id)
            log_object.negative_comments_made = self.calculate_all_negative_comments_topic(user_profile, topic_id)
            log_object.favoritism_weight = self.calculate_favoritism_bias(log_object)
            log_object.log_date = timezone.now()
            log_object.save()
        except Exception as e:
            logging.error(f"Error while logging topic relation: {e}")

    def create_or_update_channel_metrics(self, channel, log_aggregation, log_type):
        """Refresh the channel's ChannelMetrics row for this aggregation and log_type when it is due."""
        try:
            log_object = ChannelMetrics.objects.filter(
                channel=channel, aggregation_type=log_aggregation, log_type=log_type
            ).last()

            if log_object is not None and not self.analytics_verification_logs(log_object, log_type):
                return

            if log_object is None:
                log_object = ChannelMetrics()
                log_object.aggregation_type = log_aggregation
                log_object.channel = channel
                log_object.log_type = log_type

            if log_aggregation == LogTypeAggregation.AVERAGE:
                log_object.impressions = self.calculate_channel_average_impressions(channel) or 0
                log_object.likes = self.calculate_channel_average_likes(channel) or 0
                log_object.dislikes = self.calculate_channel_average_dislikes(channel) or 0
                log_object.views = self.calculcate_channel_average_views(channel) or 0
                log_object.comments = self.calculcate_channel_average_comments(channel) or 0
                log_object.video_xp = self.calculate_channel_average_video_xp(channel) or 0
            else:
                log_object.impressions = self.calculate_channel_total_impressions(channel) or 0
                log_object.likes = self.calculate_channel_total_likes(channel) or 0
                log_object.dislikes = self.calculate_channel_total_dislikes(channel) or 0
                log_object.views = self.calculcate_channel_total_views(channel) or 0
                log_object.comments = self.calculcate_channel_total_comments(channel) or 0
                log_object.video_xp = self.calculate_channel_total_video_xp(channel) or 0

            log_object.xp_growth_percentage = self._xp_growth_percentage(
                log_object.video_xp,
                ChannelMetrics.objects.filter(channel=channel, aggregation_type=log_aggregation, log_type=log_type),
                "video_xp",
            )
            log_object.log_date = timezone.now()
            log_object.save()
        except Exception as e:
            logging.error(f"Error while logging channel metrics: {e}")

    def update_xp_VIDEO(self, video, log_type):
        """Recount the video's likes, dislikes and comments and recompute its XP when it is due."""
        if self.analytics_verification(video, log_type):
            likes, dislikes, comments = self.recount_likes_and_dislikes_VIDEO(video)
            video.likes = likes
            video.dislikes = dislikes
            video.comments = comments
            video.video_xp = self.calculate_xp_VIDEO(video)

            video.metrics_last_updated = timezone.now()
            video.save()

    def update_xp_USER(self, user, log_type):
        """Recompute the user's XP and level when they are due."""
        if self.analytics_verification(user, log_type):
            xp = self.calculate_xp_USER(user)
            user.XP = xp
            user.metrics_last_updated = timezone.now()
            user.level = self.generate_level(xp)
            user.save()

    def update_XP_CHANNEL(self, channel, log_type):
        """Recompute the channel's XP and level when they are due."""
        if self.analytics_verification(channel, log_type):
            xp = self.calculate_xp_CHANNEL(channel)
            channel.XP = xp
            channel.metrics_last_updated = timezone.now()
            channel.level = self.generate_level(xp)
            channel.save()

    def update_XP_LOUNGE(self, lounge: Lounge, log_type):
        """Recompute the lounge's XP and level when they are due."""
        if self.analytics_verification(lounge, log_type):
            xp = self.calculate_xp_LOUNGE(lounge)
            lounge.lounge_xp = xp
            lounge.metrics_last_updated = timezone.now()
            lounge.lounge_level = self.generate_level(xp)
            lounge.save()

    def update_XP_LOUNGE_POST(self, lounge_post: LoungePost, log_type):
        """Recount the post's likes and dislikes and recompute its XP when it is due."""
        if self.analytics_verification(lounge_post, log_type):
            likes, dislikes = self.recount_likes_and_dislikes_LOUNGE_POST(lounge_post)
            lounge_post.likes = likes
            lounge_post.dislikes = dislikes
            lounge_post.xp = abs(self.calculate_xp_lounge_post(lounge_post))
            lounge_post.metrics_last_updated = timezone.now()

            lounge_post.save()

    def _make_growth_log(self, model, count, prev):
        """Store a row of a console graph model: the count now, the previous row's count, and the change in percent."""
        obj = model()
        obj.count = count
        if prev is None:
            obj.day_before = 0
        else:
            obj.day_before = prev.count

        try:
            obj.growth_percentage_day = ((obj.count - obj.day_before) / obj.day_before) * 100
        except ZeroDivisionError:
            obj.growth_percentage_day = 100

        obj.save()

    def make_user_profile_growth_log(self):
        """Log the number of user profiles."""
        self._make_growth_log(
            UserProfileGrowthLog, UserProfile.objects.all().count(), self.get_latest_user_profile_growth_log()
        )

    def make_video_post_growth_log(self):
        """Log the number of video posts."""
        self._make_growth_log(
            VideoPostGrowthLog, VideoPost.objects.all().count(), self.get_latest_video_post_growth_log()
        )

    def make_threads_growth_log(self):
        """Log the number of threads: lounge posts plus video comments."""
        self._make_growth_log(
            ThreadsGrowthLog,
            LoungePost.objects.all().count() + Comment.objects.all().count(),
            self.get_latest_threads_growth_log(),
        )

    def make_reported_video_tracker(self):
        """Log the number of reported videos."""
        self._make_growth_log(
            ReportedVideoTracker, ReportedVideos.objects.all().count(), self.get_latest_reported_video_tracker()
        )

    def make_reported_threads_tracker(self):
        """Log the number of reported lounge posts."""
        self._make_growth_log(
            ReportedThreadsTracker, ReportedPost.objects.all().count(), self.get_latest_reported_threads_tracker()
        )

    def make_reported_comments_tracker(self):
        """Log the number of reported video comments."""
        self._make_growth_log(
            ReportedCommentTracker, ReportedComment.objects.all().count(), self.get_latest_reported_comments_tracker()
        )

    def make_videos_under_processing(self):
        """Log the number of videos that are neither encoded nor through ML."""
        self._make_growth_log(
            VideosUnderProcessing,
            VideoPost.objects.filter(is_encoded=False, gone_through_ml=False).all().count(),
            self.get_latest_videos_under_processing(),
        )

    def make_videos_under_ml_processing(self):
        """Log the number of videos that have not gone through ML."""
        self._make_growth_log(
            VideosUnderMLProcessing,
            VideoPost.objects.filter(gone_through_ml=False).all().count(),
            self.get_latest_videos_under_ml_processing(),
        )

    def make_videos_under_encoding(self):
        """Log the number of videos that are not encoded."""
        self._make_growth_log(
            VideosUnderEncoding,
            VideoPost.objects.filter(is_encoded=False).all().count(),
            self.get_latest_videos_under_encoding(),
        )

    def make_contest_objects(self, obj):
        """Make sure the user profile has a SeptemberContest row."""
        SeptemberContest.objects.get_or_create(user=obj)

    def modify_contest_time(self):
        """Copy the latest contest dates onto every contest row and recount subscribers gained since its start."""
        obj = SeptemberContestDetailsModifier.objects.latest()
        contest_qs = SeptemberContest.objects.all()
        for i in contest_qs.iterator(chunk_size=100):
            i.start_date = obj.start_date
            i.end_date = obj.end_date
            if i.at_start_subscribers == -1:
                i.at_start_subscribers = i.user.associated_channel.subscriber_count

            gain = i.user.associated_channel.subscriber_count - i.at_start_subscribers
            i.subscriber_count = gain if gain >= 0 else 0

            i.save()

    # ---------------------------------------------------------------------------
    def _latest_or_none(self, model):
        """Return the latest row of a model, or None when the table is empty."""
        try:
            return model.objects.latest()
        except model.DoesNotExist:
            return None

    def get_latest_user_profile_growth_log(self):
        """Latest UserProfileGrowthLog row, or None."""
        return self._latest_or_none(UserProfileGrowthLog)

    def get_latest_video_post_growth_log(self):
        """Latest VideoPostGrowthLog row, or None."""
        return self._latest_or_none(VideoPostGrowthLog)

    def get_latest_threads_growth_log(self):
        """Latest ThreadsGrowthLog row, or None."""
        return self._latest_or_none(ThreadsGrowthLog)

    def get_latest_reported_video_tracker(self):
        """Latest ReportedVideoTracker row, or None."""
        return self._latest_or_none(ReportedVideoTracker)

    def get_latest_reported_threads_tracker(self):
        """Latest ReportedThreadsTracker row, or None."""
        return self._latest_or_none(ReportedThreadsTracker)

    def get_latest_reported_comments_tracker(self):
        """Latest ReportedCommentTracker row, or None."""
        return self._latest_or_none(ReportedCommentTracker)

    def get_latest_videos_under_processing(self):
        """Latest VideosUnderProcessing row, or None."""
        return self._latest_or_none(VideosUnderProcessing)

    def get_latest_videos_under_ml_processing(self):
        """Latest VideosUnderMLProcessing row, or None."""
        return self._latest_or_none(VideosUnderMLProcessing)

    def get_latest_videos_under_encoding(self):
        """Latest VideosUnderEncoding row, or None."""
        return self._latest_or_none(VideosUnderEncoding)
