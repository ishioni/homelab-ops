resource "authentik_outpost" "media-outpost" {
  name               = "media-outpost"
  type               = "proxy"
  service_connection = authentik_service_connection_kubernetes.local.id
  protocol_providers = [
    resource.authentik_provider_proxy.transmission.id,
    resource.authentik_provider_proxy.prowlarr.id,
    resource.authentik_provider_proxy.sonarr.id,
    resource.authentik_provider_proxy.radarr.id,
    resource.authentik_provider_proxy.readarr.id
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
    kubernetes_replicas     = 1,
    kubernetes_namespace    = "security",
    kubernetes_ingress_annotations = {
      "cert-manager.io/cluster-issuer" = "letsencrypt-production"
    },
    kubernetes_ingress_secret_name = "media-outpost-tls",
    kubernetes_service_type        = "ClusterIP",
    kubernetes_disabled_components = [],
    kubernetes_image_pull_secrets  = []
  })
}

resource "authentik_provider_proxy" "transmission" {
  name               = "transmission-provider"
  external_host      = "https://torrent.${data.sops_file.authentik_secrets.data["cluster_domain"]}"
  mode               = "forward_single"
  token_validity     = "hours=1"
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
}

resource "authentik_provider_proxy" "prowlarr" {
  name               = "prowlarr-provider"
  external_host      = "https://indexer.${data.sops_file.authentik_secrets.data["cluster_domain"]}"
  mode               = "forward_single"
  token_validity     = "hours=1"
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
}

resource "authentik_provider_proxy" "radarr" {
  name               = "radarr-provider"
  external_host      = "https://movies.${data.sops_file.authentik_secrets.data["cluster_domain"]}"
  mode               = "forward_single"
  token_validity     = "hours=1"
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
}

resource "authentik_provider_proxy" "sonarr" {
  name               = "sonarr-provider"
  external_host      = "https://tv.${data.sops_file.authentik_secrets.data["cluster_domain"]}"
  mode               = "forward_single"
  token_validity     = "hours=1"
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
}

resource "authentik_provider_proxy" "readarr" {
  name               = "readarr-provider"
  external_host      = "https://books.${data.sops_file.authentik_secrets.data["cluster_domain"]}"
  mode               = "forward_single"
  token_validity     = "hours=1"
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
}

resource "authentik_application" "transmission" {
  name              = "Transmission"
  slug              = "torrent"
  group             = "media"
  protocol_provider = resource.authentik_provider_proxy.transmission.id
  meta_icon         = "https://github.com/transmission/transmission/raw/main/web/assets/img/logo.png"
  meta_description  = "Torrent client"
  open_in_new_tab   = true
}

resource "authentik_application" "prowlarr" {
  name              = "Prowlarr"
  slug              = "indexer"
  group             = "media"
  protocol_provider = resource.authentik_provider_proxy.prowlarr.id
  meta_icon         = "https://raw.githubusercontent.com/Prowlarr/Prowlarr/develop/Logo/128.png"
  meta_description  = "Torrent indexer"
  open_in_new_tab   = true
}

resource "authentik_application" "radarr" {
  name              = "Sonarr"
  slug              = "movies"
  group             = "media"
  protocol_provider = resource.authentik_provider_proxy.radarr.id
  meta_icon         = "https://github.com/Radarr/Radarr/raw/develop/Logo/128.png"
  meta_description  = "Movies"
  open_in_new_tab   = true
}

resource "authentik_application" "sonarr" {
  name              = "Sonarr"
  slug              = "tv"
  group             = "media"
  protocol_provider = resource.authentik_provider_proxy.sonarr.id
  meta_icon         = "https://github.com/Sonarr/Sonarr/raw/develop/Logo/128.png"
  meta_description  = "TV"
  open_in_new_tab   = true
}

resource "authentik_application" "readarr" {
  name              = "Readarr"
  slug              = "books"
  group             = "media"
  protocol_provider = resource.authentik_provider_proxy.readarr.id
  meta_icon         = "https://github.com/Readarr/Readarr/raw/develop/Logo/128.png"
  meta_description  = "Books"
  open_in_new_tab   = true
}
