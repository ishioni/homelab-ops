module "proxy-transmission" {
  source             = "./proxy_application"
  name               = "Transmission"
  description        = "Torrent client"
  icon_url           = "https://github.com/transmission/transmission/raw/main/web/assets/img/logo.png"
  group              = "Downloads"
  slug               = "torrent"
  domain             = var.public_domain
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  invalidation_flow  = resource.authentik_flow.provider-invalidation.uuid
  auth_groups        = [authentik_group.media.id]
}

module "proxy-prowlarr" {
  source             = "./proxy_application"
  name               = "Prowlarr"
  description        = "Torrent indexer"
  icon_url           = "https://raw.githubusercontent.com/Prowlarr/Prowlarr/develop/Logo/128.png"
  group              = "Downloads"
  slug               = "indexer"
  domain             = var.public_domain
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  invalidation_flow  = resource.authentik_flow.provider-invalidation.uuid
  auth_groups        = [authentik_group.media.id]
}

module "proxy-radarr" {
  source             = "./proxy_application"
  name               = "Radarr"
  description        = "Movies"
  icon_url           = "https://github.com/Radarr/Radarr/raw/develop/Logo/128.png"
  group              = "Downloads"
  slug               = "movies"
  domain             = var.public_domain
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  invalidation_flow  = resource.authentik_flow.provider-invalidation.uuid
  auth_groups        = [authentik_group.media.id]
}

module "proxy-sonarr" {
  source             = "./proxy_application"
  name               = "Sonarr"
  description        = "TV"
  icon_url           = "https://github.com/Sonarr/Sonarr/raw/develop/Logo/128.png"
  group              = "Downloads"
  slug               = "tv"
  domain             = var.public_domain
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  invalidation_flow  = resource.authentik_flow.provider-invalidation.uuid
  auth_groups        = [authentik_group.media.id]
}

module "proxy-lidarr" {
  source             = "./proxy_application"
  name               = "Lidarr"
  description        = "Music"
  icon_url           = "https://github.com/Lidarr/Lidarr/raw/develop/Logo/128.png"
  group              = "Downloads"
  slug               = "music"
  domain             = var.public_domain
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  invalidation_flow  = resource.authentik_flow.provider-invalidation.uuid
  auth_groups        = [authentik_group.media.id]
}

module "proxy-bazarr" {
  source             = "./proxy_application"
  name               = "Bazarr"
  description        = "Subtitles"
  icon_url           = "https://github.com/morpheus65535/bazarr/raw/master/frontend/public/images/logo128.png"
  group              = "Downloads"
  slug               = "bazarr"
  domain             = var.public_domain
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  invalidation_flow  = resource.authentik_flow.provider-invalidation.uuid
  auth_groups        = [authentik_group.media.id]
}

module "proxy-navidrome" {
  source             = "./proxy_application"
  name               = "Navidrome"
  description        = "Music player"
  icon_url           = "https://github.com/navidrome/navidrome/raw/master/resources/logo-192x192.png"
  group              = "Selfhosted"
  slug               = "navidrome"
  domain             = var.public_domain
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  invalidation_flow  = resource.authentik_flow.provider-invalidation.uuid
  auth_groups        = [authentik_group.media.id]
  ignore_paths       = <<-EOT
  /rest/*
  /share/*
  EOT
}

module "proxy-homepage" {
  source             = "./proxy_application"
  name               = "Home"
  description        = "Homepage"
  icon_url           = "https://raw.githubusercontent.com/gethomepage/homepage/main/public/android-chrome-192x192.png"
  group              = "Selfhosted"
  slug               = "home"
  domain             = var.public_domain
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  invalidation_flow  = resource.authentik_flow.provider-invalidation.uuid
  auth_groups        = [authentik_group.users.id]
}

module "oauth2-grafana" {
  source             = "./oauth2_application"
  name               = "Grafana"
  icon_url           = "https://raw.githubusercontent.com/grafana/grafana/main/public/img/icons/mono/grafana.svg"
  launch_url         = "https://grafana.${var.private_domain}"
  description        = "Infrastructure graphs"
  newtab             = true
  group              = "Infrastructure"
  auth_groups        = [authentik_group.infrastructure.id]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  invalidation_flow  = resource.authentik_flow.provider-invalidation.uuid
  client_id          = module.secret_grafana.fields["OIDC_CLIENT_ID"]
  client_secret      = module.secret_grafana.fields["OIDC_CLIENT_SECRET"]
  redirect_uris      = ["https://grafana.${var.private_domain}/login/generic_oauth"]
}

module "oauth2-immich" {
  source             = "./oauth2_application"
  name               = "Immich"
  icon_url           = "https://github.com/immich-app/immich/raw/main/docs/static/img/favicon.png"
  launch_url         = "https://photos.${var.public_domain}"
  description        = "Photo managment"
  newtab             = true
  group              = "Selfhosted"
  auth_groups        = [authentik_group.media.id]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  invalidation_flow  = resource.authentik_flow.provider-invalidation.uuid
  client_id          = module.secret_immich.fields["OIDC_CLIENT_ID"]
  client_secret      = module.secret_immich.fields["OIDC_CLIENT_SECRET"]
  redirect_uris = [
    "https://photos.${var.public_domain}/auth/login",
    "app.immich:///oauth-callback"
  ]
}

module "oauth2-proxmox" {
  source             = "./oauth2_application"
  name               = "Proxmox"
  icon_url           = "https://www.proxmox.com/images/proxmox/proxmox-logo-color-stacked.png"
  launch_url         = "https://proxmox.${var.private_domain}"
  description        = "Virtualization"
  newtab             = true
  group              = "Infrastructure"
  auth_groups        = [authentik_group.infrastructure.id]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  invalidation_flow  = resource.authentik_flow.provider-invalidation.uuid
  client_id          = module.secret_proxmox.fields["OIDC_CLIENT_ID"]
  client_secret      = module.secret_proxmox.fields["OIDC_CLIENT_SECRET"]
  redirect_uris = [
    "https://proxmox.${var.private_domain}",
    "https://proxmox-1.${var.private_domain}",
    "https://proxmox-2.${var.private_domain}",
    "https://proxmox-3.${var.private_domain}",
    "https://proxmox-4.${var.private_domain}"
  ]
}

module "oauth2-audiobookshelf" {
  source             = "./oauth2_application"
  name               = "Audiobookshelf"
  icon_url           = "https://raw.githubusercontent.com/advplyr/audiobookshelf-web/master/static/Logo.png"
  launch_url         = "https://audiobooks.${var.public_domain}"
  description        = "Media player"
  newtab             = true
  group              = "Selfhosted"
  auth_groups        = [authentik_group.media.id]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  invalidation_flow  = resource.authentik_flow.provider-invalidation.uuid
  client_id          = module.secret_audiobookshelf.fields["OIDC_CLIENT_ID"]
  client_secret      = module.secret_audiobookshelf.fields["OIDC_CLIENT_SECRET"]
  redirect_uris      = ["https://audiobooks.${var.public_domain}/auth/openid/callback", "audiobookshelf://oauth"]
}

module "oauth2-paperless" {
  source             = "./oauth2_application"
  name               = "Paperless"
  icon_url           = "https://raw.githubusercontent.com/paperless-ngx/paperless-ngx/dev/resources/logo/web/svg/Color%20logo%20-%20no%20background.svg"
  launch_url         = "https://documents.${var.private_domain}"
  description        = "Documents"
  newtab             = true
  group              = "Selfhosted"
  auth_groups        = [authentik_group.infrastructure.id]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  invalidation_flow  = resource.authentik_flow.provider-invalidation.uuid
  client_id          = module.secret_paperless.fields["OIDC_CLIENT_ID"]
  client_secret      = module.secret_paperless.fields["OIDC_CLIENT_SECRET"]
  redirect_uris      = ["https://documents.${var.private_domain}/accounts/oidc/authentik/login/callback/"]
}

module "oauth2-nextcloud" {
  source                       = "./oauth2_application"
  name                         = "Nextcloud"
  icon_url                     = "https://upload.wikimedia.org/wikipedia/commons/6/60/Nextcloud_Logo.svg"
  launch_url                   = "https://files.${var.public_domain}"
  description                  = "Files"
  newtab                       = true
  group                        = "Selfhosted"
  auth_groups                  = [authentik_group.media.id]
  authorization_flow           = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  invalidation_flow            = resource.authentik_flow.provider-invalidation.uuid
  client_id                    = module.secret_nextcloud.fields["OIDC_CLIENT_ID"]
  client_secret                = module.secret_nextcloud.fields["OIDC_CLIENT_SECRET"]
  include_claims_in_id_token   = false
  additional_property_mappings = formatlist(authentik_property_mapping_provider_scope.openid-nextcloud.id)
  sub_mode                     = "user_username"
  redirect_uris                = ["https://files.${module.secret_authentik.fields["CLUSTER_DOMAIN"]}/apps/oidc_login/oidc"]
}
