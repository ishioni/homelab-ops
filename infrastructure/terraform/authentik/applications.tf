module "proxy-transmission" {
  source             = "./proxy_application"
  name               = "Transmission"
  description        = "Torrent client"
  icon_url           = "https://github.com/transmission/transmission/raw/main/web/assets/img/logo.png"
  group              = "Media"
  slug               = "torrent"
  domain             = data.sops_file.authentik_secrets.data["cluster_domain"]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  auth_groups        = [authentik_group.media.id]
}

module "proxy-prowlarr" {
  source             = "./proxy_application"
  name               = "Prowlarr"
  description        = "Torrent indexer"
  icon_url           = "https://raw.githubusercontent.com/Prowlarr/Prowlarr/develop/Logo/128.png"
  group              = "Media"
  slug               = "indexer"
  domain             = data.sops_file.authentik_secrets.data["cluster_domain"]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  auth_groups        = [authentik_group.media.id]
}

module "proxy-radarr" {
  source             = "./proxy_application"
  name               = "Radarr"
  description        = "Movies"
  icon_url           = "https://github.com/Radarr/Radarr/raw/develop/Logo/128.png"
  group              = "Media"
  slug               = "movies"
  domain             = data.sops_file.authentik_secrets.data["cluster_domain"]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  auth_groups        = [authentik_group.media.id]
}

module "proxy-sonarr" {
  source             = "./proxy_application"
  name               = "Sonarr"
  description        = "TV"
  icon_url           = "https://github.com/Sonarr/Sonarr/raw/develop/Logo/128.png"
  group              = "Media"
  slug               = "tv"
  domain             = data.sops_file.authentik_secrets.data["cluster_domain"]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  auth_groups        = [authentik_group.media.id]
}

module "proxy-hajimari" {
  source             = "./proxy_application"
  name               = "Startpage"
  description        = "Startpage"
  icon_url           = "https://github.com/toboshii/hajimari/raw/main/assets/logo.png"
  group              = "start"
  slug               = "start"
  domain             = data.sops_file.authentik_secrets.data["cluster_domain"]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  auth_groups        = [authentik_group.users.id]
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
  access_code_validity       = "hours=24"
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
  access_code_validity = "hours=24"
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
  access_code_validity = "hours=24"
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
  access_code_validity       = "hours=24"
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

resource "authentik_provider_oauth2" "tandoor" {
  name                       = "tandoor-oidc"
  client_id                  = data.sops_file.authentik_secrets.data["tandoor_client_id"]
  client_secret              = data.sops_file.authentik_secrets.data["tandoor_client_secret"]
  authorization_flow         = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  signing_key                = data.authentik_certificate_key_pair.generated.id
  client_type                = "confidential"
  issuer_mode                = "per_provider"
  access_code_validity       = "hours=24"
  sub_mode                   = "user_username"
  include_claims_in_id_token = false
  property_mappings = concat(
    data.authentik_scope_mapping.scopes.ids
  )
  redirect_uris = [
    "https://recipes.${data.sops_file.authentik_secrets.data["cluster_domain"]}/accounts/authentik/login/callback/"
  ]
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

resource "authentik_application" "tandoor" {
  name              = "Recipes"
  slug              = "tandoor"
  group             = "Groupware"
  protocol_provider = resource.authentik_provider_oauth2.tandoor.id
  meta_icon         = "https://raw.githubusercontent.com/TandoorRecipes/recipes/develop/docs/logo_color.svg"
  meta_description  = "Groupware"
  meta_launch_url   = "https://recipes.${data.sops_file.authentik_secrets.data["cluster_domain"]}"
  open_in_new_tab   = true
}
