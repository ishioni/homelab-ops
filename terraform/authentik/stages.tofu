## Auth setup stages

resource "authentik_stage_authenticator_totp" "authenticator-totp-setup" {
  name           = "authenticator-totp-setup"
  friendly_name  = "TOTP Authenticator"
  digits         = 6
  configure_flow = authentik_flow.authenticator-totp-setup.uuid
}

resource "authentik_stage_authenticator_webauthn" "authenticator-webauthn-setup" {
  name                     = "authenticator-webauthn-setup"
  friendly_name            = "Passkey"
  resident_key_requirement = "preferred"
  user_verification        = "preferred"
  configure_flow           = authentik_flow.authenticator-webauthn-setup.uuid
}

resource "authentik_stage_authenticator_email" "authenticator-email" {
  name          = "authenticator-email-setup"
  friendly_name = "Email code"
  subject       = "Authentication code"
  template      = "email/email_otp.html"
}

## Authorization stages
resource "authentik_stage_identification" "authentication-identification" {
  name                      = "authentication-identification"
  user_fields               = ["username", "email"]
  case_insensitive_matching = false
  show_source_labels        = true
  show_matched_user         = false
  enable_remember_me        = true
  password_stage            = authentik_stage_password.authentication-password.id
  passwordless_flow         = authentik_flow.passwordless_authentication.uuid
  recovery_flow             = authentik_flow.recovery.uuid
}

resource "authentik_stage_password" "authentication-password" {
  name     = "authentication-password"
  backends = ["authentik.core.auth.InbuiltBackend"]
  # configure_flow                = data.authentik_flow.default-password-change.id
  failed_attempts_before_cancel = 3
}

resource "authentik_stage_authenticator_validate" "authentication-mfa-validation" {
  name                  = "authentication-mfa-validation"
  device_classes        = ["totp", "email"]
  not_configured_action = "configure"
  configuration_stages = [
    authentik_stage_authenticator_email.authenticator-email.id,
    authentik_stage_authenticator_totp.authenticator-totp-setup.id
  ]
}

resource "authentik_stage_authenticator_validate" "authentication-passkey-validation" {
  name                       = "authentication-passkey-validation"
  device_classes             = ["webauthn"]
  webauthn_user_verification = "required"
  not_configured_action      = "configure"
  configuration_stages = [
    authentik_stage_authenticator_webauthn.authenticator-webauthn-setup.id
  ]
}

resource "authentik_stage_user_login" "authentication-login" {
  name             = "authentication-login"
  session_duration = "hours=24"
}

## Invalidation stages
resource "authentik_stage_user_logout" "invalidation-logout" {
  name = "invalidation-logout"
}

## Recovery stages
resource "authentik_stage_identification" "recovery-identification" {
  name                      = "recovery-identification"
  user_fields               = ["username", "email"]
  case_insensitive_matching = false
  show_source_labels        = false
  show_matched_user         = false
}

resource "authentik_stage_email" "recovery-email" {
  name     = "recovery-email"
  template = "email/password_reset.html"
  subject  = "Password recovery"
}

resource "authentik_stage_prompt" "password-change-prompt" {
  name = "password-change-prompt"
  fields = [
    resource.authentik_stage_prompt_field.password.id,
    resource.authentik_stage_prompt_field.password-repeat.id
  ]
  validation_policies = [
    resource.authentik_policy_password.password-complexity.id
  ]
}

resource "authentik_stage_user_write" "password-change-write" {
  name                     = "password-change-write"
  create_users_as_inactive = false
}

## Invitation stages
resource "authentik_stage_invitation" "enrollment-invitation" {
  name                             = "enrollment-invitation"
  continue_flow_without_invitation = false
}

resource "authentik_stage_prompt" "source-enrollment-prompt" {
  name = "source-enrollment-prompt"
  fields = [
    resource.authentik_stage_prompt_field.username.id,
    resource.authentik_stage_prompt_field.name.id,
    resource.authentik_stage_prompt_field.email.id,
    resource.authentik_stage_prompt_field.password.id,
    resource.authentik_stage_prompt_field.password-repeat.id,
    resource.authentik_stage_prompt_field.avatar.id
  ]
  validation_policies = [
    resource.authentik_policy_password.password-complexity.id,
    resource.authentik_policy_expression.user-settings-avatar-authorization.id
  ]
}

resource "authentik_stage_user_write" "enrollment-user-write" {
  name                     = "enrollment-user-write"
  create_users_as_inactive = false
  create_users_group       = authentik_group.users.id
  user_type                = "internal"
}

resource "authentik_stage_user_login" "source-enrollment-login" {
  name             = "source-enrollment-login"
  session_duration = "seconds=0"
}

## User settings stages
resource "authentik_stage_prompt" "user-settings" {
  name = "user-settings"
  fields = [
    resource.authentik_stage_prompt_field.username.id,
    resource.authentik_stage_prompt_field.name.id,
    resource.authentik_stage_prompt_field.email.id,
    resource.authentik_stage_prompt_field.locale.id,
    resource.authentik_stage_prompt_field.avatar.id,
    resource.authentik_stage_prompt_field.avatar-reset.id
  ]

  validation_policies = [
    resource.authentik_policy_expression.user-settings-authorization.id,
    resource.authentik_policy_expression.user-settings-avatar-authorization.id
  ]

}

resource "authentik_stage_user_write" "user-settings-write" {
  name                     = "user-settings-write"
  create_users_as_inactive = false
}
