# Authentik User Avatar Policy with JWT-signed URLs
# For Enrollment/User Settings Stage

import hashlib
import time
from base64 import b64decode
from os import environ, remove
from os.path import isfile
from urllib.parse import parse_qs, urlparse
from uuid import uuid4

import jwt

# === CONFIGURATION ===
AK_DOMAIN = "auth.movishell.pl"
USAGE = "media"
SCHEMA = "public"
SUB_PATH = "user-avatars"

INTERNAL_WRITE_DIR = f"/data/{USAGE}/{SCHEMA}/{SUB_PATH}/"
JWT_PATH_PREFIX = f"{USAGE}/{SCHEMA}/{SUB_PATH}/"
URL_BASE = f"https://{AK_DOMAIN}/files/{JWT_PATH_PREFIX}"

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

# Token validity: 10 years
TOKEN_EXPIRY_SECONDS = 10 * 365 * 24 * 60 * 60


# === HELPER FUNCTIONS ===


def format_size(size_bytes):
    """Converts bytes to human-readable size (KiB, MiB, etc.)"""
    for unit in ["B", "KiB", "MiB", "GiB"]:
        if size_bytes < 1024.0:
            return f"{size_bytes:.0f} {unit}"
        size_bytes /= 1024.0
    return f"{size_bytes:.0f} TiB"


def generate_signed_url(filename):
    """Generates a JWT-signed URL for file access."""
    base_secret = environ.get("AUTHENTIK_SECRET_KEY", "")
    signing_key = hashlib.sha256(f"{base_secret}:{USAGE}".encode()).hexdigest()

    path_claim = f"{JWT_PATH_PREFIX}{filename}"
    now = int(time.time())

    payload = {
        "path": path_claim,
        "exp": now + TOKEN_EXPIRY_SECONDS,
        "nbf": now - 30,
    }

    token = jwt.encode(payload, signing_key, algorithm="HS256")

    if isinstance(token, bytes):
        token = token.decode("utf-8")

    return f"{URL_BASE}{filename}?token={token}"


def extract_filename_from_avatar_url(avatar_url):
    """Extracts the filename from a signed avatar URL."""
    if not avatar_url or not avatar_url.startswith(URL_BASE):
        return None

    # Parse URL and extract path (without query parameters)
    parsed = urlparse(avatar_url)
    path = parsed.path

    # Filename is the last part of the path
    if "/" in path:
        return path.rsplit("/", 1)[-1]
    return None


def remove_old_avatar_file():
    """Deletes the user's old avatar file if it exists."""
    avatar = request.user.attributes.get("avatar", None)
    if not avatar:
        return

    filename = extract_filename_from_avatar_url(avatar)
    if filename:
        old_filepath = INTERNAL_WRITE_DIR + filename
        if isfile(old_filepath):
            try:
                remove(old_filepath)
            except OSError:
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

        # 4. Save file
        full_path = INTERNAL_WRITE_DIR + avatar_filename
        try:
            with open(full_path, "wb") as f:
                f.write(avatar_binary)
        except OSError as e:
            ak_message(f"Failed to save avatar file: {type(e).__name__}: {e}")
            return False
        except Exception as e:
            ak_message(f"Unexpected error: {type(e).__name__}: {e}")
            return False

        # 5. Delete old file and set new signed URL
        avatar_overwritten = True
        remove_old_avatar_file()
        prompt_data["attributes"]["avatar"] = generate_signed_url(avatar_filename)


# Handle avatar reset
if "avatar_reset" in prompt_data.get("attributes", {}):
    del prompt_data["attributes"]["avatar_reset"]

    # If a new avatar was uploaded, the previous one is already deleted
    if not avatar_overwritten:
        remove_old_avatar_file()
        prompt_data["attributes"]["avatar"] = None
        ak_message("User avatar has been deleted.")

return True
