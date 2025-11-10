resource "authentik_policy_password" "password-complexity" {
  name             = "password-complexity"
  length_min       = 8
  amount_digits    = 1
  amount_lowercase = 1
  amount_uppercase = 1
  error_message    = "Minimum password length: 10. At least 1 of each required: uppercase, lowercase, digit"
}

resource "authentik_policy_expression" "user-settings-avatar-authorization" {
  name       = "user-settings-avatar-authorization"
  expression = file("./expressions/user-settings-avatar-authorization.py")
}

resource "authentik_policy_expression" "user-settings-authorization" {
  name       = "user-settings-authorization"
  expression = file("./expressions/user-settings-authorization.py")
}

resource "authentik_property_mapping_provider_scope" "profile" {
  name       = "OAuth Mapping: OpenID 'profile'"
  scope_name = "profile"
  expression = file("./expressions/openid-scope-profile.py")
}

resource "authentik_property_mapping_provider_scope" "openid-nextcloud" {
  name       = "OAuth Mapping: OpenID 'nextcloud'"
  scope_name = "nextcloud"
  expression = file("./expressions/openid-scope-nextcloud.py")
}
