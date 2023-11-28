module "proxy-transmission" {
  source             = "./proxy_application"
  name               = "Transmission"
  description        = "Torrent client"
  icon_url           = "https://github.com/transmission/transmission/raw/main/web/assets/img/logo.png"
  group              = "Downloads"
  slug               = "torrent"
  domain             = module.secret_authentik.fields["CLUSTER_DOMAIN"]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  auth_groups        = [authentik_group.media.id]
}

module "proxy-prowlarr" {
  source             = "./proxy_application"
  name               = "Prowlarr"
  description        = "Torrent indexer"
  icon_url           = "https://raw.githubusercontent.com/Prowlarr/Prowlarr/develop/Logo/128.png"
  group              = "Downloads"
  slug               = "indexer"
  domain             = module.secret_authentik.fields["CLUSTER_DOMAIN"]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  auth_groups        = [authentik_group.media.id]
}

module "proxy-radarr" {
  source             = "./proxy_application"
  name               = "Radarr"
  description        = "Movies"
  icon_url           = "https://github.com/Radarr/Radarr/raw/develop/Logo/128.png"
  group              = "Downloads"
  slug               = "movies"
  domain             = module.secret_authentik.fields["CLUSTER_DOMAIN"]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  auth_groups        = [authentik_group.media.id]
}

module "proxy-sonarr" {
  source             = "./proxy_application"
  name               = "Sonarr"
  description        = "TV"
  icon_url           = "https://github.com/Sonarr/Sonarr/raw/develop/Logo/128.png"
  group              = "Downloads"
  slug               = "tv"
  domain             = module.secret_authentik.fields["CLUSTER_DOMAIN"]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  auth_groups        = [authentik_group.media.id]
}

module "proxy-lidarr" {
  source             = "./proxy_application"
  name               = "Lidarr"
  description        = "Music"
  icon_url           = "https://github.com/Lidarr/Lidarr/raw/develop/Logo/128.png"
  group              = "Downloads"
  slug               = "music"
  domain             = module.secret_authentik.fields["CLUSTER_DOMAIN"]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  auth_groups        = [authentik_group.media.id]
}

module "proxy-bazarr" {
  source             = "./proxy_application"
  name               = "Bazarr"
  description        = "Subtitles"
  icon_url           = "https://github.com/morpheus65535/bazarr/raw/master/frontend/public/images/logo128.png"
  group              = "Downloads"
  slug               = "bazarr"
  domain             = module.secret_authentik.fields["CLUSTER_DOMAIN"]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  auth_groups        = [authentik_group.media.id]
}

module "proxy-readarr" {
  source             = "./proxy_application"
  name               = "Readarr"
  description        = "Books"
  icon_url           = "https://raw.githubusercontent.com/Readarr/Readarr/develop/Logo/128.png"
  group              = "Downloads"
  slug               = "readarr"
  domain             = module.secret_authentik.fields["CLUSTER_DOMAIN"]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  auth_groups        = [authentik_group.media.id]
}

module "proxy-navidrome" {
  source             = "./proxy_application"
  name               = "Navidrome"
  description        = "Music player"
  icon_url           = "https://github.com/navidrome/navidrome/raw/master/resources/logo-192x192.png"
  group              = "Media"
  slug               = "navidrome"
  domain             = module.secret_authentik.fields["CLUSTER_DOMAIN"]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  auth_groups        = [authentik_group.media.id]
  ignore_paths       = <<-EOT
  /rest/*
  /share/*
  EOT
}

module "proxy-hajimari" {
  source             = "./proxy_application"
  name               = "Startpage"
  description        = "Startpage"
  icon_url           = "https://github.com/toboshii/hajimari/raw/main/assets/logo.png"
  group              = "start"
  slug               = "start"
  domain             = module.secret_authentik.fields["CLUSTER_DOMAIN"]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  auth_groups        = [authentik_group.users.id]
}

module "oauth2-grafana" {
  source             = "./oauth2_application"
  name               = "Grafana"
  icon_url           = "https://raw.githubusercontent.com/grafana/grafana/main/public/img/icons/mono/grafana.svg"
  launch_url         = "https://grafana.internal.${module.secret_authentik.fields["CLUSTER_DOMAIN"]}"
  description        = "Infrastructure graphs"
  newtab             = true
  group              = "Infrastructure"
  auth_groups        = [authentik_group.infrastructure.id]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  client_id          = module.secret_grafana.fields["OIDC_CLIENT_ID"]
  client_secret      = module.secret_grafana.fields["OIDC_CLIENT_SECRET"]
  redirect_uris      = ["https://grafana.internal.${module.secret_authentik.fields["CLUSTER_DOMAIN"]}/login/generic_oauth"]
}

module "oauth2-immich" {
  source             = "./oauth2_application"
  name               = "Immich"
  icon_url           = "https://github.com/immich-app/immich/raw/main/docs/static/img/favicon.png"
  launch_url         = "https://photos.${module.secret_authentik.fields["CLUSTER_DOMAIN"]}"
  description        = "Photo managment"
  newtab             = true
  group              = "Media"
  auth_groups        = [authentik_group.media.id]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  client_id          = module.secret_immich.fields["OIDC_CLIENT_ID"]
  client_secret      = module.secret_immich.fields["OIDC_CLIENT_SECRET"]
  redirect_uris = [
    "https://photos.${module.secret_authentik.fields["CLUSTER_DOMAIN"]}/auth/login",
    "app.immich:/"
  ]
}

module "oauth2-proxmox" {
  source             = "./oauth2_application"
  name               = "Proxmox"
  icon_url           = "https://www.proxmox.com/images/proxmox/proxmox-logo-color-stacked.png"
  launch_url         = "https://proxmox.services.${module.secret_authentik.fields["CLUSTER_DOMAIN"]}"
  description        = "Virtualization"
  newtab             = true
  group              = "Infrastructure"
  auth_groups        = [authentik_group.infrastructure.id]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  client_id          = module.secret_proxmox.fields["OIDC_CLIENT_ID"]
  client_secret      = module.secret_proxmox.fields["OIDC_CLIENT_SECRET"]
  redirect_uris = [
    "https://proxmox.services.${module.secret_authentik.fields["CLUSTER_DOMAIN"]}",
    "https://proxmox-1.services.${module.secret_authentik.fields["CLUSTER_DOMAIN"]}",
    "https://proxmox-2.services.${module.secret_authentik.fields["CLUSTER_DOMAIN"]}",
    "https://proxmox-3.services.${module.secret_authentik.fields["CLUSTER_DOMAIN"]}",
    "https://proxmox-4.services.${module.secret_authentik.fields["CLUSTER_DOMAIN"]}"
  ]
}

module "oauth2-nextcloud" {
  source                       = "./oauth2_application"
  name                         = "Nextcloud"
  icon_url                     = "https://upload.wikimedia.org/wikipedia/commons/6/60/Nextcloud_Logo.svg"
  launch_url                   = "https://files.${module.secret_authentik.fields["CLUSTER_DOMAIN"]}"
  description                  = "Files"
  newtab                       = true
  group                        = "Groupware"
  auth_groups                  = [authentik_group.nextcloud.id]
  authorization_flow           = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  client_id                    = module.secret_nextcloud.fields["OIDC_CLIENT_ID"]
  client_secret                = module.secret_nextcloud.fields["OIDC_CLIENT_SECRET"]
  include_claims_in_id_token   = false
  additional_property_mappings = formatlist(authentik_scope_mapping.openid-nextcloud.id)
  sub_mode                     = "user_username"
  redirect_uris                = ["https://files.${module.secret_authentik.fields["CLUSTER_DOMAIN"]}/apps/oidc_login/oidc"]
}

module "oauth2-tandoor" {
  source                     = "./oauth2_application"
  name                       = "Recipes"
  icon_url                   = "https://raw.githubusercontent.com/TandoorRecipes/recipes/develop/docs/logo_color.svg"
  launch_url                 = "https://recipes.${module.secret_authentik.fields["CLUSTER_DOMAIN"]}"
  description                = "Recipes"
  newtab                     = true
  group                      = "Groupware"
  auth_groups                = [authentik_group.nextcloud.id]
  authorization_flow         = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  client_id                  = module.secret_tandoor.fields["OIDC_CLIENT_ID"]
  client_secret              = module.secret_tandoor.fields["OIDC_CLIENT_SECRET"]
  include_claims_in_id_token = false
  sub_mode                   = "user_username"
  redirect_uris              = ["https://recipes.${module.secret_authentik.fields["CLUSTER_DOMAIN"]}/accounts/authentik/login/callback/"]
}

module "oauth2-midarr" {
  source             = "./oauth2_application"
  name               = "Midarr"
  icon_url           = "https://raw.githubusercontent.com/midarrlabs/midarr-server/master/priv/static/logo.svg"
  launch_url         = "https://midarr.${module.secret_authentik.fields["CLUSTER_DOMAIN"]}"
  description        = "Media player"
  newtab             = true
  group              = "Media"
  auth_groups        = [authentik_group.media.id]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  client_id          = module.secret_midarr.fields["OIDC_CLIENT_ID"]
  client_secret      = module.secret_midarr.fields["OIDC_CLIENT_SECRET"]
  redirect_uris      = ["https://midarr.${module.secret_authentik.fields["CLUSTER_DOMAIN"]}/auth"]
}

module "oauth2-audiobookshelf" {
  source             = "./oauth2_application"
  name               = "Audiobookshelf"
  icon_url           = "https://raw.githubusercontent.com/advplyr/audiobookshelf-web/master/static/Logo.png"
  launch_url         = "https://audiobooks.${module.secret_authentik.fields["CLUSTER_DOMAIN"]}"
  description        = "Media player"
  newtab             = true
  group              = "Media"
  auth_groups        = [authentik_group.media.id]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  client_id          = module.secret_audiobookshelf.fields["OIDC_CLIENT_ID"]
  client_secret      = module.secret_audiobookshelf.fields["OIDC_CLIENT_SECRET"]
  redirect_uris      = ["https://audiobooks.${module.secret_authentik.fields["CLUSTER_DOMAIN"]}/auth/openid/callback", "audiobookshelf://oauth"]
}
