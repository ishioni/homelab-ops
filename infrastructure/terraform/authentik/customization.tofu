resource "authentik_policy_password" "password-complexity" {
  name             = "password-complexity"
  length_min       = 8
  amount_digits    = 1
  amount_lowercase = 1
  amount_uppercase = 1
  error_message    = "Minimum password length: 10. At least 1 of each required: uppercase, lowercase, digit"
}

resource "authentik_policy_expression" "user-settings-authorization" {
  name       = "user-settings-authorization"
  expression = <<-EOT
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
  EOT
}
## OAuth scopes
data "authentik_property_mapping_provider_scope" "scopes" {
  managed_list = [
    "goauthentik.io/providers/oauth2/scope-email",
    "goauthentik.io/providers/oauth2/scope-openid",
    "goauthentik.io/providers/oauth2/scope-profile",
    "goauthentik.io/providers/oauth2/scope-offline_access"
  ]
}

resource "authentik_property_mapping_provider_scope" "openid-nextcloud" {
  name       = "OAuth Mapping: OpenID 'nextcloud'"
  scope_name = "nextcloud"
  expression = <<EOF
return {
  "nextcloudAdmin": user.attributes.get("nextcloudAdmin"),
  "nextcloudQuota": user.attributes.get("nextcloudQuota",user.group_attributes().get("defaultQuota", "100 MB"))
}
EOF
}
