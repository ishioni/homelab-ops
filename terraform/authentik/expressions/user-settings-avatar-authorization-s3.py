# Authentik User Avatar Policy with S3 Storage
# For Enrollment/User Settings Stage

import io
from base64 import b64decode
from os import environ
from urllib.parse import urlparse
from uuid import uuid4

import boto3
from botocore.exceptions import BotoCoreError, ClientError

# === CONFIGURATION ===
S3_ENDPOINT = environ.get(
    "AUTHENTIK_STORAGE__MEDIA__S3__ENDPOINT", "https://s3.ishioni.casa"
)
S3_BUCKET = environ.get("AUTHENTIK_STORAGE__MEDIA__S3__BUCKET_NAME", "cdn")
S3_ACCESS_KEY = environ.get("AUTHENTIK_STORAGE__MEDIA__S3__ACCESS_KEY", "")
S3_SECRET_KEY = environ.get("AUTHENTIK_STORAGE__MEDIA__S3__SECRET_KEY", "")
S3_KEY_PREFIX = "user-avatars/"

URL_BASE = f"{S3_ENDPOINT}/{S3_BUCKET}/{S3_KEY_PREFIX}"

MAX_UPLOAD_SIZE = 5 * 1024 * 1024  # 5 MB
ACCEPTED_FILE_TYPES = {
    "image/png": "png",
    "image/jpeg": "jpeg",
    "image/webp": "webp",
    "image/svg+xml": "svg",
    "image/gif": "gif",
    "image/bmp": "bmp",
    "image/vnd.microsoft.icon": "ico",
}
EMPTY_FILE = "data:application/octet-stream;base64,"

# === S3 CLIENT ===
s3_client = boto3.client(
    "s3",
    endpoint_url=S3_ENDPOINT,
    aws_access_key_id=S3_ACCESS_KEY,
    aws_secret_access_key=S3_SECRET_KEY,
)


# === HELPER FUNCTIONS ===


def format_size(size_bytes):
    """Converts bytes to human-readable size (KiB, MiB, etc.)"""
    for unit in ["B", "KiB", "MiB", "GiB"]:
        if size_bytes < 1024.0:
            return f"{size_bytes:.0f} {unit}"
        size_bytes /= 1024.0
    return f"{size_bytes:.0f} TiB"


def generate_avatar_url(filename):
    """Generates a public URL for the avatar on S3."""
    return f"{URL_BASE}{filename}"


def extract_filename_from_avatar_url(avatar_url):
    """Extracts the filename from an S3 avatar URL."""
    if not avatar_url or not avatar_url.startswith(URL_BASE):
        return None

    # Parse URL and extract path (without query parameters)
    parsed = urlparse(avatar_url)
    path = parsed.path

    # Filename is the last part of the path
    if "/" in path:
        return path.rsplit("/", 1)[-1]
    return None


def upload_avatar_to_s3(filename, avatar_binary, content_type):
    """Uploads avatar binary data to S3."""
    s3_key = f"{S3_KEY_PREFIX}{filename}"
    try:
        s3_client.put_object(
            Bucket=S3_BUCKET,
            Key=s3_key,
            Body=io.BytesIO(avatar_binary),
            ContentType=content_type,
        )
    except ClientError as e:
        ak_message(f"Failed to upload avatar: {e.response['Error']['Message']}")
        return False
    except BotoCoreError as e:
        ak_message(f"Failed to upload avatar: {e}")
        return False
    except Exception as e:
        ak_message(f"Unexpected error uploading avatar: {type(e).__name__}: {e}")
        return False
    return True


def delete_old_avatar():
    """Deletes the user's old avatar from S3 if it exists."""
    avatar = request.user.attributes.get("avatar", None)
    if not avatar:
        return

    filename = extract_filename_from_avatar_url(avatar)
    if filename:
        s3_key = f"{S3_KEY_PREFIX}{filename}"
        try:
            s3_client.delete_object(Bucket=S3_BUCKET, Key=s3_key)
        except (ClientError, BotoCoreError):
            pass  # Ignore deletion errors


# === MAIN LOGIC ===

prompt_data = request.context.get("prompt_data")
avatar_overwritten = False

if "avatar" in prompt_data.get("attributes", {}):
    avatar = prompt_data["attributes"]["avatar"]

    if avatar == EMPTY_FILE:
        # No file uploaded, ignore field
        del prompt_data["attributes"]["avatar"]
    else:
        # 1. Validate MIME type
        try:
            avatar_mimetype = avatar.split("data:", 1)[1].split(";", 1)[0]
        except (IndexError, AttributeError):
            ak_message("Invalid file format for user avatar.")
            return False

        if avatar_mimetype not in ACCEPTED_FILE_TYPES:
            allowed_types = ", ".join(ACCEPTED_FILE_TYPES.values())
            ak_message(f"User avatar must be an image file ({allowed_types}).")
            return False

        # 2. Decode Base64 and validate size
        try:
            avatar_base64 = avatar.split(",", 1)[1]
            avatar_binary = b64decode(avatar_base64)
        except (IndexError, ValueError):
            ak_message("Avatar file could not be decoded.")
            return False

        avatar_size = len(avatar_binary)
        if avatar_size > MAX_UPLOAD_SIZE:
            ak_message(
                f"User avatar file size must not exceed {format_size(MAX_UPLOAD_SIZE)}."
            )
            return False

        # 3. Generate random filename
        file_extension = ACCEPTED_FILE_TYPES[avatar_mimetype]
        avatar_filename = f"{uuid4()}.{file_extension}"

        # 4. Upload to S3
        if not upload_avatar_to_s3(avatar_filename, avatar_binary, avatar_mimetype):
            return False

        # 5. Delete old avatar and set new public URL
        avatar_overwritten = True
        delete_old_avatar()
        prompt_data["attributes"]["avatar"] = generate_avatar_url(avatar_filename)


# Handle avatar reset
if "avatar_reset" in prompt_data.get("attributes", {}):
    del prompt_data["attributes"]["avatar_reset"]

    # If a new avatar was uploaded, the previous one is already deleted
    if not avatar_overwritten:
        delete_old_avatar()
        prompt_data["attributes"]["avatar"] = None
        ak_message("User avatar has been deleted.")

return True
