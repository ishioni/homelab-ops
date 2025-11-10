data "authentik_certificate_key_pair" "generated" {
  name = "authentik Self-signed Certificate"
}

resource "authentik_brand" "home" {
  domain                           = var.public_domain
  default                          = false
  branding_title                   = "Movishell"
  branding_custom_css              = file("./styles/glassmorphism.css")
  branding_logo                    = "https://cdn.${var.public_domain}/branding/Pacifico.svg"
  branding_favicon                 = "https://cdn.${var.public_domain}/branding/favicon.png"
  branding_default_flow_background = "https://cdn.${var.public_domain}/branding/Beachfront.webp"

  flow_authentication = authentik_flow.authentication.uuid
  flow_invalidation   = authentik_flow.invalidation.uuid
  flow_recovery       = authentik_flow.recovery.uuid
  flow_user_settings  = authentik_flow.user-settings.uuid
}

resource "authentik_service_connection_kubernetes" "local" {
  name  = "local"
  local = true
}

resource "authentik_outpost" "proxyoutpost" {
  name               = "proxy-outpost"
  type               = "proxy"
  service_connection = authentik_service_connection_kubernetes.local.id
  protocol_providers = [
    module.proxy-transmission.id,
    module.proxy-prowlarr.id,
    module.proxy-radarr.id,
    module.proxy-sonarr.id,
    module.proxy-lidarr.id,
    module.proxy-bazarr.id,
    module.proxy-navidrome.id,
    module.proxy-homepage.id
  ]
  config = jsonencode({
    authentik_host         = "https://auth.${var.public_domain}",
    log_level              = "warning",
    object_naming_template = "ak-outpost-%(name)s",
    kubernetes_replicas    = 1,
    kubernetes_namespace   = "security",
    kubernetes_httproute_parent_refs = [{
      group       = "gateway.networking.k8s.io"
      kind        = "Gateway"
      name        = "envoy-external"
      namespace   = "network"
      sectionName = "https"
    }]
    kubernetes_httproute_annotations = {
      "gatus.home-operations.com/enabled" = "false"
    }
    kubernetes_service_type        = "ClusterIP",
    kubernetes_disabled_components = ["ingress"],
  })
}

resource "authentik_system_settings" "settings" {
  avatars                   = "attributes.avatar, initials"
  default_user_change_email = true
  event_retention           = "days=14"
}
