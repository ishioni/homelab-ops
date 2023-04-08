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
  from authentik.lib.config import CONFIG
  from authentik.core.models import (
      USER_ATTRIBUTE_CHANGE_EMAIL,
      USER_ATTRIBUTE_CHANGE_NAME,
      USER_ATTRIBUTE_CHANGE_USERNAME
  )
  prompt_data = request.context.get('prompt_data')

  if not request.user.group_attributes(request.http_request).get(
      USER_ATTRIBUTE_CHANGE_EMAIL, CONFIG.y_bool('default_user_change_email', True)
  ):
      if prompt_data.get('email') != request.user.email:
          ak_message('Not allowed to change email address.')
          return False

  if not request.user.group_attributes(request.http_request).get(
      USER_ATTRIBUTE_CHANGE_NAME, CONFIG.y_bool('default_user_change_name', True)
  ):
      if prompt_data.get('name') != request.user.name:
          ak_message('Not allowed to change name.')
          return False

  if not request.user.group_attributes(request.http_request).get(
      USER_ATTRIBUTE_CHANGE_USERNAME, CONFIG.y_bool('default_user_change_username', True)
  ):
      if prompt_data.get('username') != request.user.username:
          ak_message('Not allowed to change username.')
          return False

  return True
  EOT
}
## OAuth scopes
data "authentik_scope_mapping" "scopes" {
  managed_list = [
    "goauthentik.io/providers/oauth2/scope-email",
    "goauthentik.io/providers/oauth2/scope-openid",
    "goauthentik.io/providers/oauth2/scope-profile"
  ]
}

resource "authentik_scope_mapping" "openid-nextcloud" {
  name       = "OAuth Mapping: OpenID 'nextcloud'"
  scope_name = "nextcloud"
  expression = <<EOF
return {
  "nextcloudAdmin": user.attributes.get("nextcloudAdmin"),
  "nextcloudQuota": user.attributes.get("nextcloudQuota",user.group_attributes().get("defaultQuota", "100 MB"))
}
EOF
}

## Group bindings

resource "authentik_policy_binding" "transmission" {
  target = authentik_application.transmission.uuid
  group  = authentik_group.media.id
  order  = 0
}

resource "authentik_policy_binding" "prowlarr" {
  target = authentik_application.prowlarr.uuid
  group  = authentik_group.media.id
  order  = 0
}

resource "authentik_policy_binding" "sonarr" {
  target = authentik_application.sonarr.uuid
  group  = authentik_group.media.id
  order  = 0
}

resource "authentik_policy_binding" "radarr" {
  target = authentik_application.radarr.uuid
  group  = authentik_group.media.id
  order  = 0
}

resource "authentik_policy_binding" "readarr" {
  target = authentik_application.readarr.uuid
  group  = authentik_group.media.id
  order  = 0
}

resource "authentik_policy_binding" "uptime-kuma" {
  target = authentik_application.uptime-kuma.uuid
  group  = authentik_group.infrastructure.id
  order  = 0
}

resource "authentik_policy_binding" "hajimari" {
  target = authentik_application.hajimari.uuid
  group  = authentik_group.users.id
  order  = 0
}

resource "authentik_policy_binding" "grafana" {
  target = authentik_application.grafana.uuid
  group  = authentik_group.infrastructure.id
  order  = 0
}

resource "authentik_policy_binding" "proxmox" {
  target = authentik_application.proxmox.uuid
  group  = authentik_group.infrastructure.id
  order  = 0
}

resource "authentik_policy_binding" "immich" {
  target = authentik_application.immich.uuid
  group  = authentik_group.media.id
  order  = 0
}

resource "authentik_policy_binding" "nextcloud" {
  target = authentik_application.nextcloud.uuid
  group  = authentik_group.nextcloud.id
  order  = 0
}

resource "authentik_policy_binding" "tandoor" {
  target = authentik_application.tandoor.uuid
  group  = authentik_group.nextcloud.id
  order  = 0
}
