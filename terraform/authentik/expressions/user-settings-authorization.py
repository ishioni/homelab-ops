from authentik.core.models import (
    USER_ATTRIBUTE_CHANGE_EMAIL,
    USER_ATTRIBUTE_CHANGE_NAME,
    USER_ATTRIBUTE_CHANGE_USERNAME
)
prompt_data = request.context.get("prompt_data")

if not request.user.group_attributes(request.http_request).get(
    USER_ATTRIBUTE_CHANGE_EMAIL, request.http_request.tenant.default_user_change_email
):
    if prompt_data.get("email") != request.user.email:
        ak_message("Not allowed to change email address.")
        return False

if not request.user.group_attributes(request.http_request).get(
    USER_ATTRIBUTE_CHANGE_NAME, request.http_request.tenant.default_user_change_name
):
    if prompt_data.get("name") != request.user.name:
        ak_message("Not allowed to change name.")
        return False

if not request.user.group_attributes(request.http_request).get(
    USER_ATTRIBUTE_CHANGE_USERNAME, request.http_request.tenant.default_user_change_username
):
    if prompt_data.get("username") != request.user.username:
        ak_message("Not allowed to change username.")
        return False

return True
