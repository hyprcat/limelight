"""The S3 client and CDN URL helper shared by every engine."""
import boto3
from django.conf import settings

BOTO_S3 = boto3.client(
    "s3",
    aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
    aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
    region_name=settings.AWS_S3_REGION_NAME,
)


def cdn_url(key):
    """Return the CloudFront URL for an object key in the media bucket."""
    return f"https://{settings.CLOUDFRONT_DOMAIN}/{key}"
