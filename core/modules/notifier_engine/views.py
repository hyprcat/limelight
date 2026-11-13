from modules.api import json_endpoint
from modules.notifier_engine.manager import notifierAgent


def endpoint(*required):
    """Notification endpoints carry the session token in the body, next to the other fields."""
    return json_endpoint(*required, "token", header_token=False)


@endpoint("page_number")
def render_lounge_notifications(data):
    """List the logged-in user's notifications about lounge posts."""
    return notifierAgent.render_lounges(data["token"], data["page_number"])


@endpoint("page_number")
def render_replies(data):
    """List the logged-in user's notifications about replies."""
    return notifierAgent.render_replies(data["token"], data["page_number"])


@endpoint("page_number")
def render_subscriptions(data):
    """List the logged-in user's notifications from subscribed channels."""
    return notifierAgent.render_subscriptions(data["token"], data["page_number"])


@endpoint("page_number")
def render_for_you(data):
    """List the logged-in user's "For you" notifications."""
    return notifierAgent.render_for_you(data["token"], data["page_number"])


@endpoint("object_type", "object_id")
def mark_notification_as_seen(data):
    """Mark one notification as seen."""
    return notifierAgent.mark_notification_as_seen(data["token"], data["object_type"], data["object_id"])


@endpoint()
def get_unread_notification_count(data):
    """Return how many notifications the logged-in user has not seen."""
    return notifierAgent.get_unread_notification_count(data["token"])
