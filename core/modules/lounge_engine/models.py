from datetime import datetime, timedelta
import uuid
import os

from django.db import models

from modules.user_engine.models import LoungeSections, LoungeParticipants, UserProfile

def generate_path(instance, filename):
    """Return the upload path of a post attachment: lounge_posts/<post id>/media.<extension>."""
    return os.path.join(f'lounge_posts/{instance.id}/', "media." + filename.rsplit(".", 1)[-1])


class LoungePost(models.Model):
    """A post or reply in a lounge section. Replies point to their parent post."""
    id = models.UUIDField(editable=False, default=uuid.uuid4, unique=True, primary_key=True)
    associated_lounge_section = models.ForeignKey(LoungeSections, related_name='associated_lounge_section', on_delete=models.CASCADE, null=True, blank=True)
    created_by =  models.ForeignKey(LoungeParticipants, related_name='l_creator', on_delete=models.CASCADE,  null=True, blank=True)
    text = models.TextField()
    xp = models.BigIntegerField(default=0)
    attachment = models.FileField(upload_to= generate_path,default=None, blank= True)
    likes = models.PositiveBigIntegerField(default=0)
    dislikes = models.PositiveBigIntegerField(default=0)
    replies = models.PositiveBigIntegerField(default=0)
    topic_id = models.IntegerField (default=-1)
    topic_category_id = models.IntegerField(default=-1)
    post_sentiment = models.IntegerField(default=-42)
    impressions = models.IntegerField(default=0)
    is_advertisement = models.BooleanField(default=False)
    headless= models.BooleanField(default=True)
    user = models.ForeignKey(UserProfile, related_name='lu_creator', on_delete=models.CASCADE, null= True, blank= True)
    # Thread structure
    root_post =  models.ForeignKey('self', null=True, blank=True,
                                     on_delete=models.CASCADE, related_name='main_post')
    parent_post = models.ForeignKey('self', null=True, blank=True,
                                  on_delete=models.CASCADE, related_name='threaded_post')
    post_depth = models.PositiveBigIntegerField(default=1)
    metrics_last_updated = models.DateTimeField(auto_now_add=True)
    creation_date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.text

    class Meta:
        verbose_name = "Lounge Thread"
        verbose_name_plural = "Lounge Threads"

class LoungeLike(models.Model):
    """A like on a post by a lounge member. One per member and post."""
    post = models.ForeignKey(LoungePost, related_name='l_liked_post', on_delete=models.CASCADE)
    liked_by = models.ForeignKey(LoungeParticipants, related_name='l_liked_by', on_delete=models.CASCADE)
    creation_date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.post.text}"

    class Meta:
        verbose_name = "Lounge Thread Like"
        verbose_name_plural = "Lounge Thread Likes"
        constraints = [
            models.UniqueConstraint(fields=['post', 'liked_by'], name='l_like_constraint')
        ]

class LoungeDislike(models.Model):
    """A dislike on a post by a lounge member. One per member and post."""
    post = models.ForeignKey(LoungePost, related_name='l_disliked_post', on_delete=models.CASCADE)
    disliked_by = models.ForeignKey(LoungeParticipants, related_name='l_disliked_by', on_delete=models.CASCADE)
    creation_date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.post.text}"

    class Meta:
        verbose_name = "Lounge Thread Dislike"
        verbose_name_plural = "Lounge Thread Dislikes"
        constraints = [
            models.UniqueConstraint(fields=['post', 'disliked_by'], name='l_dislike_constraint')
        ]

class LoungePostMentions(models.Model):
    """A mention of a lounge member in a post."""
    mentioned_user = models.ForeignKey(
        LoungeParticipants, related_name="mentioned_post_user", on_delete=models.CASCADE
    )
    mentioned_in_comments = models.ForeignKey(LoungePost, related_name="mentioned_post", on_delete=models.CASCADE)
    creation_date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.mentioned_in_comments.text}"

    class Meta:
        verbose_name = "Lounge Thread Mention"
        verbose_name_plural = "Lounge Thread Mention"

class LoungePostLogs(models.Model):
    """Day, week and month difference figures for a post."""
    day_difference = models.DecimalField(default=0, max_digits=15, decimal_places=6)
    weekly_difference = models.DecimalField(default=0, max_digits=15, decimal_places=6)
    monthly_difference = models.DecimalField(default=0, max_digits=15, decimal_places=6)
    day_update_date = models.DateTimeField(auto_now_add=True)
    week_update_date = models.DateField(auto_now_add=True)
    month_update_date = models.DateField(auto_now_add=True)
    linked_post = models.ForeignKey(LoungePost, related_name="linked_post", on_delete=models.CASCADE)

    def __str__(self):
        return f"{self.linked_post.text}"

    class Meta:
        verbose_name = "Lounge Post Log"
        verbose_name_plural = "Lounge Post Logs"


class LoungePostImpressions(models.Model):
    """A record that a user saw a post. One per user and post."""
    post = models.ForeignKey(LoungePost, related_name='l_impreession_post', on_delete=models.CASCADE)
    viewed_by = models.ForeignKey(UserProfile, related_name='l_viewed_by', on_delete=models.CASCADE)
    creation_date = models.DateTimeField(auto_now_add=True)
    def __str__(self):
        return f"{self.post.text}"

    class Meta:
        verbose_name = "Lounge Post Impression"
        verbose_name_plural = "Lounge Post Impressions"
        constraints = [
            models.UniqueConstraint(fields=['post', 'viewed_by'], name='l_view_constraint')
        ]


class LoungePostHashtags(models.Model):
    """A hashtag used in a post."""
    hashtag_string = models.CharField(max_length=100, null=False)
    associated_leaf = models.ForeignKey(LoungePost, related_name="hashtaged_post", on_delete=models.CASCADE)
    created_date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.hashtag_string}"

    class Meta:
        verbose_name = "Lounge Post Hashtag"
        verbose_name_plural = "Lounge Post Hashtags"


class ReportedPost(models.Model):
    """A report filed by a user against a post."""
    post =  models.ForeignKey(LoungePost, related_name='reported_post', on_delete=models.CASCADE)
    reported_by = models.ForeignKey(UserProfile, related_name='l_reported_by', on_delete=models.CASCADE)
    reason = models.TextField()
    added_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.post.text}"

    class Meta:
        verbose_name = "Reported Post"
        verbose_name_plural = "Reported Post"

class UserPasswordReset(models.Model):
    """A password reset request with its verification code and expiry time."""
    user_email = models.EmailField(unique=True)
    user_verification_code = models.BigIntegerField(default=0)
    created_at =  models.DateTimeField(auto_now_add=True)
    is_authenicated = models.BooleanField(default=False)
    # NOTE: this default is computed once, when the module is imported. Every row gets the same
    # expiry (process start + 15 minutes) and each makemigrations run sees a new default.
    expires = models.DateTimeField(default=datetime.now() + timedelta(minutes=15))

    def __str__(self):
        return f"{self.user_email}"

    class Meta:
        verbose_name = "User Verification"
        verbose_name_plural = "User Verification"
