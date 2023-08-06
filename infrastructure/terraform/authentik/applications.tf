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

module "oauth2-grafana" {
  source             = "./oauth2_application"
  name               = "Grafana"
  icon_url           = "https://raw.githubusercontent.com/grafana/grafana/main/public/img/icons/mono/grafana.svg"
  launch_url         = "https://grafana.internal.${data.sops_file.authentik_secrets.data["cluster_domain"]}"
  description        = "Infrastructure graphs"
  newtab             = true
  group              = "Infrastructure"
  auth_groups        = [authentik_group.infrastructure.id]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  client_id          = data.sops_file.authentik_secrets.data["grafana_client_id"]
  client_secret      = data.sops_file.authentik_secrets.data["grafana_client_secret"]
  redirect_uris      = ["https://grafana.internal.${data.sops_file.authentik_secrets.data["cluster_domain"]}/login/generic_oauth"]
}

module "oauth2-immich" {
  source             = "./oauth2_application"
  name               = "Immich"
  icon_url           = "https://github.com/immich-app/immich/raw/main/docs/static/img/favicon.png"
  launch_url         = "https://photos.${data.sops_file.authentik_secrets.data["cluster_domain"]}"
  description        = "Photo managment"
  newtab             = true
  group              = "Media"
  auth_groups        = [authentik_group.media.id]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  client_id          = data.sops_file.authentik_secrets.data["immich_client_id"]
  client_secret      = data.sops_file.authentik_secrets.data["immich_client_secret"]
  redirect_uris = [
    "https://photos.${data.sops_file.authentik_secrets.data["cluster_domain"]}/auth/login",
    "app.immich:/"
  ]
}

module "oauth2-proxmox" {
  source             = "./oauth2_application"
  name               = "Proxmox"
  icon_url           = "https://www.proxmox.com/images/proxmox/proxmox-logo-color-stacked.png"
  launch_url         = "https://proxmox.services.${data.sops_file.authentik_secrets.data["cluster_domain"]}"
  description        = "Virtualization"
  newtab             = true
  group              = "Infrastructure"
  auth_groups        = [authentik_group.infrastructure.id]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  client_id          = data.sops_file.authentik_secrets.data["proxmox_client_id"]
  client_secret      = data.sops_file.authentik_secrets.data["proxmox_client_secret"]
  redirect_uris = [
    "https://proxmox.services.${data.sops_file.authentik_secrets.data["cluster_domain"]}",
    "https://proxmox-1.services.${data.sops_file.authentik_secrets.data["cluster_domain"]}",
    "https://proxmox-2.services.${data.sops_file.authentik_secrets.data["cluster_domain"]}",
    "https://proxmox-3.services.${data.sops_file.authentik_secrets.data["cluster_domain"]}",
    "https://proxmox-4.services.${data.sops_file.authentik_secrets.data["cluster_domain"]}"
  ]
}

module "oauth2-nextcloud" {
  source                       = "./oauth2_application"
  name                         = "Nextcloud"
  icon_url                     = "https://upload.wikimedia.org/wikipedia/commons/6/60/Nextcloud_Logo.svg"
  launch_url                   = "https://files.${data.sops_file.authentik_secrets.data["cluster_domain"]}"
  description                  = "Files"
  newtab                       = true
  group                        = "Groupware"
  auth_groups                  = [authentik_group.nextcloud.id]
  authorization_flow           = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  client_id                    = data.sops_file.authentik_secrets.data["nextcloud_client_id"]
  client_secret                = data.sops_file.authentik_secrets.data["nextcloud_client_secret"]
  include_claims_in_id_token   = false
  additional_property_mappings = formatlist(authentik_scope_mapping.openid-nextcloud.id)
  sub_mode                     = "user_username"
  redirect_uris                = ["https://files.${data.sops_file.authentik_secrets.data["cluster_domain"]}/apps/oidc_login/oidc"]
}

module "oauth2-tandoor" {
  source                     = "./oauth2_application"
  name                       = "Recipes"
  icon_url                   = "https://raw.githubusercontent.com/TandoorRecipes/recipes/develop/docs/logo_color.svg"
  launch_url                 = "https://recipes.${data.sops_file.authentik_secrets.data["cluster_domain"]}"
  description                = "Recipes"
  newtab                     = true
  group                      = "Groupware"
  auth_groups                = [authentik_group.nextcloud.id]
  authorization_flow         = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  client_id                  = data.sops_file.authentik_secrets.data["tandoor_client_id"]
  client_secret              = data.sops_file.authentik_secrets.data["tandoor_client_secret"]
  include_claims_in_id_token = false
  sub_mode                   = "user_username"
  redirect_uris              = ["https://recipes.${data.sops_file.authentik_secrets.data["cluster_domain"]}/accounts/authentik/login/callback/"]
}
