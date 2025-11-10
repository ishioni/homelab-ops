## Authenticator setup

resource "authentik_flow" "authenticator-totp-setup" {
  name           = "authenticator-totp-setup"
  title          = "Setup Two-Factor authentication"
  slug           = "authenticator-totp-setup"
  designation    = "stage_configuration"
  authentication = "require_authenticated"
}

resource "authentik_flow_stage_binding" "authenticator-totp-setup-binding-00" {
  target = authentik_flow.authenticator-totp-setup.uuid
  stage  = authentik_stage_authenticator_totp.authenticator-totp-setup.id
  order  = 0
}

resource "authentik_flow" "authenticator-webauthn-setup" {
  name           = "authenticator-webauthn-setup"
  title          = "Setup WebAuthn"
  slug           = "authenticator-webauthn-setup"
  designation    = "stage_configuration"
  authentication = "require_authenticated"
}

resource "authentik_flow_stage_binding" "authenticator-webauthn-setup-binding-00" {
  target = authentik_flow.authenticator-webauthn-setup.uuid
  stage  = authentik_stage_authenticator_webauthn.authenticator-webauthn-setup.id
  order  = 0
}


## Authentication flow
resource "authentik_flow" "authentication" {
  name               = "authentication-flow"
  title              = "Welcome!"
  slug               = "authentication-flow"
  designation        = "authentication"
  policy_engine_mode = "all"
}

resource "authentik_flow_stage_binding" "authentication-flow-binding-00" {
  target = authentik_flow.authentication.uuid
  stage  = authentik_stage_identification.authentication-identification.id
  order  = 0
}

resource "authentik_flow_stage_binding" "authentication-flow-binding-10" {
  target = authentik_flow.authentication.uuid
  stage  = authentik_stage_authenticator_validate.authentication-mfa-validation.id
  order  = 10
}

resource "authentik_flow_stage_binding" "authentication-flow-binding-100" {
  target = authentik_flow.authentication.uuid
  stage  = authentik_stage_user_login.authentication-login.id
  order  = 100
}

resource "authentik_flow" "passwordless_authentication" {
  name               = "passwordless_authentication"
  title              = "Passkey"
  slug               = "passwordless-flow"
  designation        = "authentication"
  policy_engine_mode = "all"
}

resource "authentik_flow_stage_binding" "passwordless_authentication-binding-00" {
  target = authentik_flow.passwordless_authentication.uuid
  stage  = authentik_stage_authenticator_validate.authentication-passkey-validation.id
  order  = 0
}

resource "authentik_flow_stage_binding" "passwordless_authentication-binding-10" {
  target               = authentik_flow.passwordless_authentication.uuid
  stage                = authentik_stage_user_login.authentication-login.id
  evaluate_on_plan     = false
  re_evaluate_policies = true
  order                = 10
}

## Invalidation flow
resource "authentik_flow" "invalidation" {
  name               = "invalidation-flow"
  title              = "Invalidation Flow"
  slug               = "invalidation-flow"
  policy_engine_mode = "any"
  designation        = "invalidation"
  denied_action      = "continue"
}

resource "authentik_flow_stage_binding" "invalidation-flow-binding-00" {
  target = authentik_flow.invalidation.uuid
  stage  = authentik_stage_user_logout.invalidation-logout.id
  order  = 0
}

## Provider invalidation flow
resource "authentik_flow" "provider-invalidation" {
  name               = "Logged out of application"
  title              = "You've logged out of %(app)s."
  slug               = "provider-invalidation-flow"
  policy_engine_mode = "any"
  designation        = "invalidation"
  denied_action      = "continue"
}

## Password recovery flow
resource "authentik_flow" "recovery" {
  name               = "recovery-flow"
  title              = "Password recovery"
  slug               = "password-recovery"
  designation        = "recovery"
  compatibility_mode = true
}

resource "authentik_flow_stage_binding" "recovery-flow-binding-00" {
  target = authentik_flow.recovery.uuid
  stage  = authentik_stage_identification.recovery-identification.id
  order  = 0
}

resource "authentik_flow_stage_binding" "recovery-flow-binding-10" {
  target = authentik_flow.recovery.uuid
  stage  = authentik_stage_email.recovery-email.id
  order  = 10
}

resource "authentik_flow_stage_binding" "recovery-flow-binding-20" {
  target = authentik_flow.recovery.uuid
  stage  = authentik_stage_prompt.password-change-prompt.id
  order  = 20
}

resource "authentik_flow_stage_binding" "recovery-flow-binding-30" {
  target = authentik_flow.recovery.uuid
  stage  = authentik_stage_user_write.password-change-write.id
  order  = 30
}

## Invitation flow
resource "authentik_flow" "enrollment-invitation" {
  name               = "enrollment-invitation-flow"
  title              = "Enrollment invitation"
  slug               = "enrollmment-invitation"
  designation        = "enrollment"
  compatibility_mode = true
}

resource "authentik_flow_stage_binding" "enrollment-invitation-flow-binding-00" {
  target = authentik_flow.enrollment-invitation.uuid
  stage  = authentik_stage_invitation.enrollment-invitation.id
  order  = 0
}

resource "authentik_flow_stage_binding" "enrollment-invitation-flow-binding-10" {
  target = authentik_flow.enrollment-invitation.uuid
  stage  = authentik_stage_prompt.source-enrollment-prompt.id
  order  = 10
}

resource "authentik_flow_stage_binding" "enrollment-invitation-flow-binding-20" {
  target = authentik_flow.enrollment-invitation.uuid
  stage  = authentik_stage_user_write.enrollment-user-write.id
  order  = 20
}

resource "authentik_flow_stage_binding" "enrollment-invitation-flow-binding-30" {
  target = authentik_flow.enrollment-invitation.uuid
  stage  = authentik_stage_user_login.source-enrollment-login.id
  order  = 30
}

## User settings flow
resource "authentik_flow" "user-settings" {
  name               = "User settings"
  title              = "Update your info"
  slug               = "user-settings-flow"
  policy_engine_mode = "any"
  denied_action      = "message_continue"
  designation        = "stage_configuration"
}

resource "authentik_flow_stage_binding" "user-settings-flow-binding-20" {
  target = authentik_flow.user-settings.uuid
  stage  = authentik_stage_prompt.user-settings.id
  order  = 20
}

resource "authentik_flow_stage_binding" "user-settings-flow-binding-100" {
  target = authentik_flow.user-settings.uuid
  stage  = authentik_stage_user_write.user-settings-write.id
  order  = 100
}

## Authorization flow
resource "authentik_flow" "provider-authorization-implicit-consent" {
  name               = "Authorize Application"
  title              = "Redirecting to %(app)s"
  slug               = "provider-authorization-implicit-consent"
  policy_engine_mode = "any"
  denied_action      = "message_continue"
  designation        = "authorization"
}
