import logging

from django.core.mail import send_mail
from celery import shared_task


@shared_task(bind=True)
def send_password_reset_email(self, user_name, passcode, target_mail):
    """Email the password reset OTP to a user."""
    send_mail(
        "🚀 Your One-Time Password (OTP) for LimeLight",
        (
            f"Dear {user_name},\n\n"
            "At Limelight, we take your account security very seriously. We understand that forgetting your password can be a concern, and we are here to assist you in securing your account.\n\n"
            f"Your One-Time Password (OTP) is: {passcode}\n\n"
            "Please use this OTP to promptly create a new, strong password for your account. It is essential to ensure the security of your personal information.\n\n"
            "If you require any assistance or have any questions, our support team is available to help you.\n\n"
            "Thank you for your attention to this important matter.\n\n"
            "Regards\n"
            "Team Hazel"
        ),
        "no-reply@hazel.gg",
        [target_mail],
        fail_silently=False,
    )
    logging.info(f"> MAIL SENT TO {user_name}")
