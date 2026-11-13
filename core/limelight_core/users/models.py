from django.contrib.auth.models import AbstractUser
from django.db.models import CharField, EmailField
from django.urls import reverse
from django.utils.translation import gettext_lazy as _

from limelight_core.users.managers import UserManager


class User(AbstractUser):
    """Custom user model. Users log in with their email and also have a unique username."""

    # First and last name do not cover name patterns around the globe
    name = CharField(_("Name of User"), blank=True, max_length=255)
    first_name = None  # type: ignore
    last_name = None  # type: ignore
    email = EmailField(_("email address"), unique=True)
    username = CharField(_("user_name"), unique=True, max_length=64)  # type: ignore

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = ['username']

    objects = UserManager()

    def get_absolute_url(self) -> str:
        """Return the URL of the user's detail view."""
        return reverse("users:detail", kwargs={"pk": self.id})
