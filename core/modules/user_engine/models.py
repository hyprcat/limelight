import uuid
import os

from django.db import models
from django.conf import settings


from django_celery_beat.models import PeriodicTask as CeleryPeriodicTask


class PeriodicTask(CeleryPeriodicTask):
    """The django-celery-beat periodic task, stored in the table core_table."""

    class Meta:
        db_table = "core_table"


def generate_lounge_picture_path(instance, filename):
    """Storage path of a user's lounge picture. The uploaded file name is ignored."""
    return os.path.join(f"users/{instance.user.username}/", "lounge_picture.jpeg")


def generate_profile_picture_path(instance, filename):
    """Storage path of a user's profile picture. The uploaded file name is ignored."""
    return os.path.join(f"users/{instance.user.username}/", "profile_picture.jpeg")


def generate_profile_banner_path(instance, filename):
    """Storage path of a user's profile banner. The uploaded file name is ignored."""
    return os.path.join(f"users/{instance.user.username}/", "profile_banner.jpeg")


class UserProfile(models.Model):
    """Profile of a user: bio, picture and banner, XP and level, device info, and links to their channel and lounge."""

    user = models.ForeignKey(settings.AUTH_USER_MODEL, related_name="user", on_delete=models.CASCADE)
    bio = models.TextField(null=True, blank=True)
    age = models.PositiveBigIntegerField(default=0, null=True, blank=True)
    gender = models.CharField(null=True, max_length=15)
    profile_picture = models.FileField(upload_to=generate_profile_picture_path, default=None, blank=True)
    profile_banner = models.FileField(upload_to=generate_profile_banner_path, default=None, blank=True)
    subscribed_to_count = models.PositiveBigIntegerField(default=0)
    joined_lounges = models.PositiveBigIntegerField(default=0)
    creation_date = models.DateTimeField(auto_now_add=True)
    XP = models.PositiveBigIntegerField(default=0)
    level = models.PositiveBigIntegerField(default=0)
    is_creator = models.BooleanField(default=False)
    is_advertiser = models.BooleanField(default=False)
    metrics_last_updated = models.DateTimeField(auto_now_add=True)
    associated_channel = models.ForeignKey(
        "Channel", related_name="their_channel", on_delete=models.CASCADE, null=True, blank=True
    )
    associated_lounge = models.ForeignKey(
        "Lounge", related_name="their_lounge", on_delete=models.CASCADE, null=True, blank=True
    )

    # INTERNAL
    drafts = models.PositiveBigIntegerField(default=0)
    unlisted = models.PositiveBigIntegerField(default=0)
    lounge_only = models.PositiveBigIntegerField(default=0)
    active_videos = models.PositiveBigIntegerField(default=0)
    fcm_token = models.CharField(max_length=255, blank=True, null=True)
    device_model = models.CharField(max_length=255, blank=True, null=True)
    os_version = models.CharField(max_length=50, blank=True, null=True)
    device_info_updated_at = models.DateTimeField(auto_now=True)
    is_banned = models.BooleanField(default=False)

    def __str__(self):
        return self.user.username

    class Meta:
        verbose_name = "User Profile"
        verbose_name_plural = "User Profiles"


class UserGeolocations(models.Model):
    """Last known city, country and region of a user."""

    user = models.ForeignKey(UserProfile, related_name="user_g", on_delete=models.CASCADE)
    city = models.CharField(max_length=120)
    country = models.CharField(max_length=120)
    region = models.CharField(max_length=120)
    last_updated = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.user.user.username

    class Meta:
        verbose_name = "GeoLocation"
        verbose_name_plural = "GeoLocations"


class Channel(models.Model):
    """A user's channel. Holds the subscriber and video counts and the channel XP and level."""

    id = models.UUIDField(editable=False, default=uuid.uuid4, unique=True, primary_key=True)
    name = models.CharField(max_length=120, null=False, unique=True)
    channel_description = models.TextField()
    subscriber_count = models.PositiveBigIntegerField(default=0)
    videos_count = models.PositiveBigIntegerField(default=0)
    level = models.PositiveBigIntegerField(default=0)
    XP = models.PositiveBigIntegerField(default=0)
    owner = models.ForeignKey("UserProfile", related_name="owner", on_delete=models.CASCADE)
    assoicated_lounge = models.ForeignKey(
        "Lounge", related_name="channel_lounge", on_delete=models.CASCADE, null=True, blank=True
    )
    metrics_last_updated = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = "Channel"
        verbose_name_plural = "Channels"


class ChannelSubscribers(models.Model):
    """A subscription of one user to one channel. A user can subscribe to a channel once."""

    channel = models.ForeignKey(Channel, related_name="subscribed_channel", on_delete=models.CASCADE)
    subscribed_by = models.ForeignKey(UserProfile, related_name="subscriber", on_delete=models.CASCADE)
    creation_date = models.DateTimeField(auto_now_add=True)


    def __str__(self):
        return f"{self.subscribed_by.user.username} - {self.channel.name}"


    class Meta:
        constraints = [models.UniqueConstraint(fields=["channel", "subscribed_by"], name="Subscription")]
        verbose_name = "Subscriber"
        verbose_name_plural = "Subscribers"


class Lounge(models.Model):
    """The community space attached to a channel."""

    id = models.UUIDField(editable=False, default=uuid.uuid4, unique=True, primary_key=True)
    name = models.CharField(max_length=120)
    lounge_xp = models.PositiveBigIntegerField(default=0)
    lounge_level = models.PositiveBigIntegerField(default=1)
    channel = models.ForeignKey(
        Channel, related_name="channel_lounge", on_delete=models.CASCADE, null=True, blank=True
    )
    total_members = models.PositiveBigIntegerField(default=0)
    total_categories = models.PositiveBigIntegerField(default=0)
    lounge_description = models.TextField()
    is_public = models.BooleanField(default=True)
    metrics_last_updated = models.DateTimeField(auto_now_add=True)
    lounge_tiers = models.PositiveBigIntegerField(default=0)

    def __str__(self):
        if self.name is not None and self.name != "":
            return self.name
        
        return UserProfile.objects.filter(associated_lounge__id = self.id).first().user.username

    class Meta:
        verbose_name = "Lounge"
        verbose_name_plural = "Lounges"

class LoungeLogs(models.Model):
    """Day, week and month XP of a lounge and the change in each."""

    day_xp = models.PositiveBigIntegerField(default=0)
    day_difference = models.DecimalField(default=0, max_digits=15, decimal_places=6)
    week_xp = models.PositiveBigIntegerField(default=0)
    weekly_difference = models.DecimalField(default=0, max_digits=15, decimal_places=6)
    month = models.PositiveBigIntegerField(default=0)
    monthly_difference = models.DecimalField(default=0, max_digits=15, decimal_places=6)
    day_update_date = models.DateTimeField(auto_now_add=True)
    week_update_date = models.DateField(auto_now_add=True)
    month_update_date = models.DateField(auto_now_add=True)
    linked_lounge = models.ForeignKey(Lounge, related_name="linked_post", on_delete=models.CASCADE)

    def __str__(self):
        if self.linked_lounge.name is not None and self.linked_lounge.name != "":
            return self.linked_lounge.name
        
        return UserProfile.objects.filter(associated_lounge__id = self.linked_lounge.id).first().user.username

    class Meta:
        verbose_name = "Lounge Log"
        verbose_name_plural = "Lounge Logs"


class LoungeParticipants(models.Model):
    """Membership of a user in a lounge, with their level and XP there. A user can join a lounge once."""

    lounge = models.ForeignKey(Lounge, related_name="lounge_name", on_delete=models.CASCADE)
    member = models.ForeignKey(UserProfile, related_name="lounge_participant", on_delete=models.CASCADE)
    level = models.PositiveBigIntegerField(default=1)
    XP = models.PositiveBigIntegerField(default=0)
    challenges_completed = models.PositiveBigIntegerField(default=0)

    def __str__(self):
        if self.lounge.name is not None and self.lounge.name != "":
            return self.lounge.name
        
        return f"@{self.member.user.username}"

    class Meta:
        constraints = [models.UniqueConstraint(fields=["lounge", "member"], name="membership")]
        verbose_name = "Lounge Member"
        verbose_name_plural = "Lounge Members"


class LoungeCategories(models.Model):
    """A category inside a lounge. Category names are unique within a lounge."""

    id = models.UUIDField(editable=False, default=uuid.uuid4, unique=True, primary_key=True)
    lounge = models.ForeignKey(Lounge, related_name="parent_lounge", on_delete=models.CASCADE)
    category_name = models.CharField(max_length=120, null=False)
    category_description = models.CharField(max_length=256)
    total_sections = models.PositiveBigIntegerField(default=0)
    creation_date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        if self.lounge.name is not None and self.lounge.name != "":
            return f"{self.category_name} - {self.lounge.name}"

        
        lounge_name =  UserProfile.objects.filter(associated_lounge__id = self.lounge.id).first().user.username
        return f"{self.category_name} - {lounge_name}"

    class Meta:
        constraints = [models.UniqueConstraint(fields=["lounge", "category_name"], name="channels")]
        verbose_name = "Lounge Category"
        verbose_name_plural = "Lounge Categories"

class LoungeSections(models.Model):
    """A section inside a lounge category. Section names are unique within a category."""

    id = models.UUIDField(editable=False, default=uuid.uuid4, unique=True, primary_key=True)
    lounge = models.ForeignKey(Lounge, related_name="c_parent_lounge", on_delete=models.CASCADE)
    related_category = models.ForeignKey(
        LoungeCategories, related_name="associated_category", on_delete=models.CASCADE
    )
    section_name = models.CharField(max_length=64)
    section_description = models.CharField(max_length=256)
    minimum_level_required = models.PositiveBigIntegerField(default=1)
    only_owner_can_post = models.BooleanField(default=0)
    creation_date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        if self.lounge.name is not None and self.lounge.name != "":
            return f"{self.section_name} - {self.lounge.name}"
        
        lounge_name =  UserProfile.objects.filter(associated_lounge__id = self.lounge.id).first().user.username
        return f"{self.section_name} - {lounge_name}"
    
    class Meta:
        constraints = [models.UniqueConstraint(fields=["related_category", "section_name"], name="section_lock")]
        verbose_name = "Lounge Section"
        verbose_name_plural = "Lounge Section"


class LoungeAccess(models.Model):
    """Per user and lounge: how many of the creator's videos the user has watched, and whether the invite is active."""

    user = models.ForeignKey(UserProfile, related_name="invitable_user", on_delete=models.CASCADE)
    lounge = models.ForeignKey(Lounge, related_name="lounge_unlock", on_delete=models.CASCADE)
    creator_videos_watched = models.BigIntegerField(default=0)
    invite_active = models.BooleanField(default=True)

    def __str__(self):
        if self.lounge.name is not None and self.lounge.name != "":
            return f"{self.user.user.username} - {self.lounge.name}"
        
        lounge_name =  UserProfile.objects.filter(associated_lounge__id = self.lounge.id).first().user.username
        return f"{self.user.user.username} - {lounge_name}"


    class Meta:
        verbose_name = "Lounge Access"
        verbose_name_plural = "Lounge Access"


class UserExpLogs(models.Model):
    """XP gained by a creator's videos per day, week and month, and the creator's rank in each window."""

    day_difference = models.DecimalField(default=0, max_digits=15, decimal_places=6)
    weekly_difference = models.DecimalField(default=0, max_digits=15, decimal_places=6)
    monthly_difference = models.DecimalField(default=0, max_digits=15, decimal_places=6)
    daily_rank = models.BigIntegerField(default=-1)
    weekly_rank = models.BigIntegerField(default=-1)
    monthly_rank = models.BigIntegerField(default=-1)
    day_update_date = models.DateTimeField(null=True)
    week_update_date = models.DateField(null=True)
    month_update_date = models.DateField(null=True)
    linked_user = models.ForeignKey(
        UserProfile, on_delete=models.CASCADE, primary_key=True, related_name="linked_user"
    )


    def __str__(self):
        return self.linked_user.user.username


    class Meta:
        verbose_name = "User XP Log"
        verbose_name_plural = "User XP Logs"


class LimeLightStars(models.Model):
    """Users shown as star creators. No code creates these rows; they are added in the admin."""

    linked_user = models.ForeignKey(
        UserProfile, on_delete=models.CASCADE, primary_key=True, related_name="star_creator"
    )
    creation_date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.linked_user.user.username


    class Meta:
        verbose_name = "LimeLight Star"
        verbose_name_plural = "LimeLight Stars"


class ReportedUser(models.Model):
    """A report filed by one user against another."""

    user =  models.ForeignKey(UserProfile, related_name='reported_user', on_delete=models.CASCADE)
    reported_by = models.ForeignKey(UserProfile, related_name='u_reported_by', on_delete=models.CASCADE)
    reason = models.TextField()
    added_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.user.username}"

    class Meta:
        verbose_name = "Reported Users"
        verbose_name_plural = "Reported Users"

class UserAccountRemovalRequest(models.Model):
    """A user's request to have their account removed."""

    user =  models.ForeignKey(UserProfile, related_name='uarr_user', on_delete=models.CASCADE)
    reason = models.TextField()
    added_at = models.DateTimeField(auto_now_add=True)
    status = models.BooleanField(default=True)
    def __str__(self):
        return f"{self.user.user.username}"

    class Meta:
        verbose_name = "User Account Removal Request"
        verbose_name_plural = "User Account Removal Requests"

class BlockedProfiles(models.Model):
    """A block placed by one user (blocked_by) on another (user)."""

    user =  models.ForeignKey(UserProfile, related_name='b_user', on_delete=models.CASCADE)
    blocked_by = models.ForeignKey(UserProfile, related_name='blocked_by', on_delete=models.CASCADE)
    added_at = models.DateTimeField(auto_now_add=True)
    def __str__(self):
        return f"{self.user.user.username}"

    class Meta:
        verbose_name = "Blocked User"
        verbose_name_plural = "Blocked Users"
