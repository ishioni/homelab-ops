resource "authentik_outpost" "proxyoutpost" {
  name               = "proxy-outpost"
  type               = "proxy"
  service_connection = authentik_service_connection_kubernetes.local.id
  protocol_providers = [
    resource.authentik_provider_proxy.transmission.id,
    resource.authentik_provider_proxy.prowlarr.id,
    resource.authentik_provider_proxy.sonarr.id,
    resource.authentik_provider_proxy.radarr.id,
    resource.authentik_provider_proxy.readarr.id,
    resource.authentik_provider_proxy.hajimari.id,
    resource.authentik_provider_proxy.uptime-kuma.id
  ]
  config = jsonencode({
    authentik_host          = "https://auth.${data.sops_file.authentik_secrets.data["cluster_domain"]}",
    authentik_host_insecure = false,
    authentik_host_browser  = "",
    log_level               = "debug",
    object_naming_template  = "ak-outpost-%(name)s",
    docker_network          = null,
    docker_map_ports        = true,
    docker_labels           = null,
    container_image         = null,
    kubernetes_replicas     = 2,
    kubernetes_namespace    = "security",
    kubernetes_ingress_annotations = {
      "cert-manager.io/cluster-issuer" = "letsencrypt-production"
    },
    kubernetes_ingress_secret_name = "proxy-outpost-tls",
    kubernetes_service_type        = "ClusterIP",
    kubernetes_disabled_components = [],
    kubernetes_image_pull_secrets  = []
  })
}

resource "authentik_provider_proxy" "transmission" {
  name               = "transmission-provider"
  external_host      = "https://torrent.${data.sops_file.authentik_secrets.data["cluster_domain"]}"
  mode               = "forward_single"
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
}

resource "authentik_provider_proxy" "prowlarr" {
  name               = "prowlarr-provider"
  external_host      = "https://indexer.${data.sops_file.authentik_secrets.data["cluster_domain"]}"
  mode               = "forward_single"
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
}

resource "authentik_provider_proxy" "radarr" {
  name               = "radarr-provider"
  external_host      = "https://movies.${data.sops_file.authentik_secrets.data["cluster_domain"]}"
  mode               = "forward_single"
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
}

resource "authentik_provider_proxy" "sonarr" {
  name               = "sonarr-provider"
  external_host      = "https://tv.${data.sops_file.authentik_secrets.data["cluster_domain"]}"
  mode               = "forward_single"
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
}

resource "authentik_provider_proxy" "readarr" {
  name               = "readarr-provider"
  external_host      = "https://books.${data.sops_file.authentik_secrets.data["cluster_domain"]}"
  mode               = "forward_single"
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
}

resource "authentik_provider_proxy" "hajimari" {
  name               = "hajimari-provider"
  external_host      = "https://start.${data.sops_file.authentik_secrets.data["cluster_domain"]}"
  mode               = "forward_single"
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
}

resource "authentik_provider_proxy" "uptime-kuma" {
  name               = "uptime-kuma-provider"
  external_host      = "https://status.${data.sops_file.authentik_secrets.data["cluster_domain"]}"
  mode               = "forward_single"
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  skip_path_regex    = <<EOF
^/$
^/status
^/assets/
^/assets
^/icon.svg
^/api/.*
^/upload/.*
^/metrics
EOF
}

resource "authentik_provider_oauth2" "immich" {
  name                       = "immich-oidc"
  client_id                  = data.sops_file.authentik_secrets.data["immich_client_id"]
  client_secret              = data.sops_file.authentik_secrets.data["immich_client_secret"]
  authorization_flow         = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  signing_key                = data.authentik_certificate_key_pair.generated.id
  client_type                = "confidential"
  include_claims_in_id_token = true
  issuer_mode                = "per_provider"
  sub_mode                   = "user_username"
  access_code_validity       = "minutes=10"
  property_mappings = concat(
    data.authentik_scope_mapping.scopes.ids
  )
  redirect_uris = [
    "https://photos.${data.sops_file.authentik_secrets.data["cluster_domain"]}/auth/login",
    "app.immich:/"
  ]
}

resource "authentik_provider_oauth2" "grafana" {
  name                 = "grafana-oidc"
  client_id            = data.sops_file.authentik_secrets.data["grafana_client_id"]
  client_secret        = data.sops_file.authentik_secrets.data["grafana_client_secret"]
  authorization_flow   = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  signing_key          = data.authentik_certificate_key_pair.generated.id
  client_type          = "confidential"
  issuer_mode          = "per_provider"
  access_code_validity = "minutes=10"
  property_mappings = concat(
    data.authentik_scope_mapping.scopes.ids
  )
  redirect_uris = [
    "https://grafana.internal.${data.sops_file.authentik_secrets.data["cluster_domain"]}/login/generic_oauth"
  ]
}

resource "authentik_provider_oauth2" "proxmox" {
  name                 = "proxmox-oidc"
  client_id            = data.sops_file.authentik_secrets.data["proxmox_client_id"]
  client_secret        = data.sops_file.authentik_secrets.data["proxmox_client_secret"]
  authorization_flow   = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  signing_key          = data.authentik_certificate_key_pair.generated.id
  client_type          = "confidential"
  issuer_mode          = "per_provider"
  access_code_validity = "minutes=10"
  property_mappings = concat(
    data.authentik_scope_mapping.scopes.ids
  )
  redirect_uris = [
    "https://proxmox.services.${data.sops_file.authentik_secrets.data["cluster_domain"]}",
    "https://proxmox-1.services.${data.sops_file.authentik_secrets.data["cluster_domain"]}",
    "https://proxmox-2.services.${data.sops_file.authentik_secrets.data["cluster_domain"]}",
    "https://proxmox-3.services.${data.sops_file.authentik_secrets.data["cluster_domain"]}",
    "https://proxmox-4.services.${data.sops_file.authentik_secrets.data["cluster_domain"]}"
  ]
}

resource "authentik_provider_oauth2" "nextcloud" {
  name                       = "nextcloud-oidc"
  client_id                  = data.sops_file.authentik_secrets.data["nextcloud_client_id"]
  client_secret              = data.sops_file.authentik_secrets.data["nextcloud_client_secret"]
  authorization_flow         = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  signing_key                = data.authentik_certificate_key_pair.generated.id
  client_type                = "confidential"
  issuer_mode                = "per_provider"
  access_code_validity       = "minutes=10"
  sub_mode                   = "user_username"
  include_claims_in_id_token = false
  property_mappings = concat(
    data.authentik_scope_mapping.scopes.ids,
    formatlist(authentik_scope_mapping.openid-nextcloud.id)
  )
  redirect_uris = [
    "https://files.${data.sops_file.authentik_secrets.data["cluster_domain"]}/apps/oidc_login/oidc"
  ]
}

resource "authentik_application" "transmission" {
  name              = "Transmission"
  slug              = "torrent"
  group             = "Media"
  protocol_provider = resource.authentik_provider_proxy.transmission.id
  meta_icon         = "https://github.com/transmission/transmission/raw/main/web/assets/img/logo.png"
  meta_description  = "Torrent client"
  open_in_new_tab   = true
}

resource "authentik_application" "prowlarr" {
  name              = "Prowlarr"
  slug              = "indexer"
  group             = "Media"
  protocol_provider = resource.authentik_provider_proxy.prowlarr.id
  meta_icon         = "https://raw.githubusercontent.com/Prowlarr/Prowlarr/develop/Logo/128.png"
  meta_description  = "Torrent indexer"
  open_in_new_tab   = true
}

resource "authentik_application" "radarr" {
  name              = "Sonarr"
  slug              = "movies"
  group             = "Media"
  protocol_provider = resource.authentik_provider_proxy.radarr.id
  meta_icon         = "https://github.com/Radarr/Radarr/raw/develop/Logo/128.png"
  meta_description  = "Movies"
  open_in_new_tab   = true
}

resource "authentik_application" "sonarr" {
  name              = "Sonarr"
  slug              = "tv"
  group             = "Media"
  protocol_provider = resource.authentik_provider_proxy.sonarr.id
  meta_icon         = "https://github.com/Sonarr/Sonarr/raw/develop/Logo/128.png"
  meta_description  = "TV"
  open_in_new_tab   = true
}

resource "authentik_application" "readarr" {
  name              = "Readarr"
  slug              = "books"
  group             = "Media"
  protocol_provider = resource.authentik_provider_proxy.readarr.id
  meta_icon         = "https://github.com/Readarr/Readarr/raw/develop/Logo/128.png"
  meta_description  = "Books"
  open_in_new_tab   = true
}

resource "authentik_application" "hajimari" {
  name              = "Startpage"
  slug              = "startpage"
  group             = "Start"
  protocol_provider = resource.authentik_provider_proxy.hajimari.id
  meta_icon         = "https://github.com/toboshii/hajimari/raw/main/assets/logo.png"
  meta_description  = "Startpage"
  open_in_new_tab   = true
}

resource "authentik_application" "immich" {
  name              = "immich"
  slug              = "immich"
  group             = "Media"
  protocol_provider = resource.authentik_provider_oauth2.immich.id
  meta_icon         = "https://github.com/immich-app/immich/raw/main/docs/static/img/favicon.png"
  meta_description  = "Photo managment"
  meta_launch_url   = "https://photos.${data.sops_file.authentik_secrets.data["cluster_domain"]}"
  open_in_new_tab   = true

}

resource "authentik_application" "uptime-kuma" {
  name              = "Uptime-kuma"
  slug              = "uptime"
  group             = "Infrastructure"
  protocol_provider = resource.authentik_provider_proxy.uptime-kuma.id
  meta_icon         = "https://github.com/louislam/uptime-kuma/raw/master/public/icon.svg"
  meta_description  = "Uptime"
  meta_launch_url   = "https://status.${data.sops_file.authentik_secrets.data["cluster_domain"]}/dashboard"
  open_in_new_tab   = true
}

resource "authentik_application" "grafana" {
  name              = "Grafana"
  slug              = "grafana"
  group             = "Infrastructure"
  protocol_provider = resource.authentik_provider_oauth2.grafana.id
  meta_icon         = "https://raw.githubusercontent.com/grafana/grafana/main/public/img/icons/mono/grafana.svg"
  meta_description  = "Infrastructure graphs"
  meta_launch_url   = "https://grafana.internal.${data.sops_file.authentik_secrets.data["cluster_domain"]}"
  open_in_new_tab   = true
}

resource "authentik_application" "proxmox" {
  name              = "Proxmox"
  slug              = "proxmox"
  group             = "Infrastructure"
  protocol_provider = resource.authentik_provider_oauth2.proxmox.id
  meta_icon         = "https://www.proxmox.com/images/proxmox/proxmox-logo-color-stacked.png"
  meta_description  = "Virtualization"
  meta_launch_url   = "https://proxmox.services.${data.sops_file.authentik_secrets.data["cluster_domain"]}"
  open_in_new_tab   = true
}

resource "authentik_application" "nextcloud" {
  name              = "Nextcloud"
  slug              = "nextcloud"
  group             = "Groupware"
  protocol_provider = resource.authentik_provider_oauth2.nextcloud.id
  meta_icon         = "https://upload.wikimedia.org/wikipedia/commons/6/60/Nextcloud_Logo.svg"
  meta_description  = "Files"
  meta_launch_url   = "https://files.${data.sops_file.authentik_secrets.data["cluster_domain"]}"
  open_in_new_tab   = true
}
