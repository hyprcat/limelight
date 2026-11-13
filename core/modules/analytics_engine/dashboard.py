"""Context for the admin home page (templates/admin/index.html).

Unfold calls `dashboard_callback` through the UNFOLD["DASHBOARD_CALLBACK"] setting.
The growth numbers come from the daily logs written by analytics_engine.tasks.
"""
import json

from django.db.models import Q
from django.utils.safestring import mark_safe
from django.utils.translation import gettext_lazy as _

from modules.analytics_engine.models import (
    ReportedCommentTracker,
    ReportedVideoTracker,
    ThreadsGrowthLog,
    UserProfileGrowthLog,
    VideoPostGrowthLog,
    VideosUnderEncoding,
    VideosUnderMLProcessing,
    VideosUnderProcessing,
)
from modules.lounge_engine.models import ReportedPost
from modules.user_engine.models import ReportedUser, UserAccountRemovalRequest, UserProfile
from modules.video_engine.manager import VideoEngineManager
from modules.video_engine.models import ReportedComment, ReportedVideos, VideoPost

DAYS_SHOWN = 28
# Topic category ids the classifier uses for "no category" (see video/machine_learning).
UNCATEGORISED_TOPIC_IDS = (-1, 19)


def daily_growth_chart(log_model, colour, label=None):
    """Build chart.js data from the last DAYS_SHOWN daily growth logs, oldest first."""
    logs = list(log_model.objects.order_by("-creation_date")[:DAYS_SHOWN])[::-1]
    dataset = {"data": [log.growth_percentage_day for log in logs], "borderColor": colour}
    if label:
        dataset.update({"label": label, "backgroundColor": colour})
    return json.dumps({"labels": [log.creation_date.strftime("%a") for log in logs], "datasets": [dataset]})


def latest_growth(log_model):
    return log_model.objects.latest().growth_percentage_day


def make_footer(percentage):
    """Render a day-over-day growth figure, green when positive and red otherwise."""
    if percentage > 0:
        css_class, text = "text-green-600", f"+{percentage}"
    else:
        css_class, text = "text-red-600", str(percentage)
    return mark_safe(f'<strong class="{css_class} font-medium">{text}%</strong>&nbsp;growth from yesterday')


def kpi(title, metric, growth_log=None):
    card = {"title": title, "metric": str(metric)}
    if growth_log is not None:
        card["footer"] = make_footer(latest_growth(growth_log))
    return card


def videos_per_category(videos_uploaded):
    """Count videos per topic category for the "Trending Video Categories" card."""

    def share(count):
        return (count / videos_uploaded) * 100 if videos_uploaded else 0

    rows = []
    for category, topic_ids in VideoEngineManager().TOPIC_MAP.items():
        count = VideoPost.objects.filter(topic_category_id__in=topic_ids).count()
        rows.append({"title": category, "description": str(count), "value": share(count)})

    uncategorised = VideoPost.objects.filter(
        Q(topic_category_id__in=UNCATEGORISED_TOPIC_IDS), gone_through_ml=True
    ).count()
    rows.append(
        {
            "title": "Out Of Scope / Requires Manual Categorisation",
            "description": str(uncategorised),
            "value": share(uncategorised),
        }
    )
    return rows


def dashboard_callback(request, context):
    """Add the platform, moderation and video pipeline numbers to the admin home page."""
    videos_uploaded = VideoPost.objects.count()

    context.update(
        {
            "navigation": [
                {"title": _("Dashboard"), "link": "/console", "active": False},
                {"title": _("Pipeline "), "link": "#pipeline", "active": False},
            ],
            "kpi": [
                kpi("Users", UserProfile.objects.count(), UserProfileGrowthLog),
                kpi("Videos", videos_uploaded, VideoPostGrowthLog),
                kpi("Threads", ThreadsGrowthLog.objects.latest().count, ThreadsGrowthLog),
                kpi("Account Removal Requests", UserAccountRemovalRequest.objects.count()),
            ],
            "kpi2": [
                kpi(
                    "Videos Under Processing",
                    VideoPost.objects.filter(gone_through_ml=False, is_encoded=False).count(),
                    VideosUnderProcessing,
                ),
                kpi("Requires Encoding", VideoPost.objects.filter(is_encoded=False).count(), VideosUnderEncoding),
                kpi(
                    "Requires ML Processing",
                    VideoPost.objects.filter(gone_through_ml=False).count(),
                    VideosUnderMLProcessing,
                ),
            ],
            "kpi3": [
                kpi("Reported Videos", ReportedVideos.objects.count(), ReportedVideoTracker),
                kpi("Reported Comments", ReportedComment.objects.count(), ReportedCommentTracker),
                kpi("Reported Lounge Posts", ReportedPost.objects.count()),
                kpi("Reported Users", ReportedUser.objects.count()),
            ],
            "progress": videos_per_category(videos_uploaded),
            "chart": daily_growth_chart(UserProfileGrowthLog, "#f0abfc", label="Users Growth Percentage"),
            "performance": [
                {
                    "title": _("Threads Growth Percentage"),
                    "metric": f"{latest_growth(ThreadsGrowthLog)}%",
                    "chart": daily_growth_chart(ThreadsGrowthLog, "#f43f5e"),
                },
                {
                    "title": _("Video Upload Growth"),
                    "metric": f"{latest_growth(VideoPostGrowthLog)}%",
                    "chart": daily_growth_chart(VideoPostGrowthLog, "#9333ea"),
                },
                {
                    "title": _("Video Processing Growth"),
                    "metric": f"{latest_growth(VideosUnderProcessing)}%",
                    "chart": daily_growth_chart(VideosUnderProcessing, "#9333ea"),
                },
            ],
        },
    )
    return context
