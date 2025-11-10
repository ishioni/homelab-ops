AK_DOMAIN = "auth.movishell.pl"
FILE_PATH = "/media/user-avatars/"
URL_PATH = f"https://{AK_DOMAIN}{FILE_PATH}"
MAX_UPLOAD_SIZE = 5 * 1024 * 1024
ACCEPTED_FILE_TYPES = {
    "image/png": "png",
    "image/jpeg": "jpeg",
    "image/webp": "webp",
    # "image/svg+xml": "svg", # if you trust your users not to upload malicious svg files
    "image/gif": "gif",
    "image/bmp": "bmp",
    "image/vnd.microsoft.icon": "ico",
}

EMPTY_FILE = "data:application/octet-stream;base64,"

from uuid import uuid4
from base64 import b64decode
from os import remove, makedirs
from os.path import isfile

def naturalsize(value, binary=False, format="%.1f"):
    """
    Convert a size in bytes into a human-readable format.

    :param value: size in bytes
    :param binary: if True, use 1024-based units (KiB, MiB), otherwise 1000-based (KB, MB)
    :param format: number format string (default "%.1f")
    :return: string like "10.5 MB"
    """
    units = ["B", "KB", "MB", "GB", "TB", "PB", "EB"]
    if binary:
        step = 1024.0
        units = ["B", "KiB", "MiB", "GiB", "TiB", "PiB", "EiB"]
    else:
        step = 1000.0

    size = float(value)
    for unit in units:
        if abs(size) < step:
            return (format % size).rstrip("0").rstrip(".") + " " + unit
        size /= step
    return (format % size).rstrip("0").rstrip(".") + " " + units[-1]

def remove_old_avatar_file():
    if not request.user.is_authenticated:
        return
    avatar = request.user.attributes.get("avatar", None)
    if avatar:
        components = avatar.split(URL_PATH, 1)
        if len(components) == 2 and components[0] == "" and components[1]:
            old_filename = FILE_PATH + components[1]
            if isfile(old_filename):
                remove(old_filename)

prompt_data = request.context.get("prompt_data")
avatar_overwritten = False

if "avatar" in prompt_data.get("attributes", {}):
    avatar = prompt_data["attributes"]["avatar"]
    if avatar == EMPTY_FILE:
        # No upload file specified, ignore
        del prompt_data["attributes"]["avatar"]
    else:
        avatar_mimetype = avatar.split("data:", 1)[1].split(";", 1)[0]
        if avatar_mimetype not in ACCEPTED_FILE_TYPES:
            ak_message("User avatar must be an image (" + ", ".join(ACCEPTED_FILE_TYPES.values()) + ") file.")
            return False
        # Now we know it is one of the accepted image file types
        avatar_base64 = avatar.split(",", 1)[1]
        avatar_binary = b64decode(avatar_base64)
        avatar_size = len(avatar_binary)
        if avatar_size > MAX_UPLOAD_SIZE:
            ak_message("User avatar file size must not exceed " + naturalsize(MAX_UPLOAD_SIZE, binary=True, format = "%.0f") + ".")
            return False
        # Set a random file name with extension reflecting mime type
        avatar_filename = str(uuid4()) + "." + ACCEPTED_FILE_TYPES[avatar_mimetype]
        try:
            makedirs(FILE_PATH, exist_ok=True)
            with open(FILE_PATH + avatar_filename, "wb") as f:
                f.write(avatar_binary)
        except Exception:
            ak_message("Could not write avatar file.")
            return False
        avatar_overwritten = True
        remove_old_avatar_file()
        prompt_data["attributes"]["avatar"] = URL_PATH + avatar_filename

if "avatar_reset" in prompt_data.get("attributes", {}):
    del prompt_data["attributes"]["avatar_reset"]
    # If a new avatar was uploaded, previous avatar is deleted anyway, so ignore
    if not avatar_overwritten:
        prompt_data["attributes"]["avatar"] = None
        remove_old_avatar_file()
        ak_message("Deleted user avatar.")

return True
