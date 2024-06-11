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

module "proxy-navidrome" {
  source             = "./proxy_application"
  name               = "Navidrome"
  description        = "Music player"
  icon_url           = "https://github.com/navidrome/navidrome/raw/master/resources/logo-192x192.png"
  group              = "Selfhosted"
  slug               = "navidrome"
  domain             = module.secret_authentik.fields["CLUSTER_DOMAIN"]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
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
  domain             = module.secret_authentik.fields["CLUSTER_DOMAIN"]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  auth_groups        = [authentik_group.users.id]
}

module "oauth2-grafana" {
  source             = "./oauth2_application"
  name               = "Grafana"
  icon_url           = "https://raw.githubusercontent.com/grafana/grafana/main/public/img/icons/mono/grafana.svg"
  launch_url         = "https://grafana.${module.secret_authentik.fields["CLUSTER_DOMAIN"]}"
  description        = "Infrastructure graphs"
  newtab             = true
  group              = "Infrastructure"
  auth_groups        = [authentik_group.infrastructure.id]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  client_id          = module.secret_grafana.fields["OIDC_CLIENT_ID"]
  client_secret      = module.secret_grafana.fields["OIDC_CLIENT_SECRET"]
  redirect_uris      = ["https://grafana.${module.secret_authentik.fields["CLUSTER_DOMAIN"]}/login/generic_oauth"]
}

module "oauth2-immich" {
  source             = "./oauth2_application"
  name               = "Immich"
  icon_url           = "https://github.com/immich-app/immich/raw/main/docs/static/img/favicon.png"
  launch_url         = "https://photos.${module.secret_authentik.fields["CLUSTER_DOMAIN"]}"
  description        = "Photo managment"
  newtab             = true
  group              = "Selfhosted"
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
  launch_url         = "https://proxmox.ishioni.casa"
  description        = "Virtualization"
  newtab             = true
  group              = "Infrastructure"
  auth_groups        = [authentik_group.infrastructure.id]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  client_id          = module.secret_proxmox.fields["OIDC_CLIENT_ID"]
  client_secret      = module.secret_proxmox.fields["OIDC_CLIENT_SECRET"]
  redirect_uris = [
    "https://proxmox.ishioni.casa",
    "https://proxmox-1.ishioni.casa",
    "https://proxmox-2.ishioni.casa",
    "https://proxmox-3.ishioni.casa",
    "https://proxmox-4.ishioni.casa"
  ]
}

module "oauth2-audiobookshelf" {
  source             = "./oauth2_application"
  name               = "Audiobookshelf"
  icon_url           = "https://raw.githubusercontent.com/advplyr/audiobookshelf-web/master/static/Logo.png"
  launch_url         = "https://audiobooks.${module.secret_authentik.fields["CLUSTER_DOMAIN"]}"
  description        = "Media player"
  newtab             = true
  group              = "Selfhosted"
  auth_groups        = [authentik_group.media.id]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  client_id          = module.secret_audiobookshelf.fields["OIDC_CLIENT_ID"]
  client_secret      = module.secret_audiobookshelf.fields["OIDC_CLIENT_SECRET"]
  redirect_uris      = ["https://audiobooks.${module.secret_authentik.fields["CLUSTER_DOMAIN"]}/auth/openid/callback", "audiobookshelf://oauth"]
}

module "oauth2-paperless" {
  source             = "./oauth2_application"
  name               = "Paperless"
  icon_url           = "https://raw.githubusercontent.com/paperless-ngx/paperless-ngx/dev/resources/logo/web/svg/Color%20logo%20-%20no%20background.svg"
  launch_url         = "https://documents.movishell.pl"
  description        = "Documents"
  newtab             = true
  group              = "Selfhosted"
  auth_groups        = [authentik_group.infrastructure.id]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  client_id          = module.secret_paperless.fields["OIDC_CLIENT_ID"]
  client_secret      = module.secret_paperless.fields["OIDC_CLIENT_SECRET"]
  redirect_uris      = ["https://documents.movishell.pl/accounts/oidc/authentik/login/callback/"]
}

module "oauth2-ocis" {
  source             = "./oauth2_application"
  name               = "Owncloud"
  icon_url           = "https://raw.githubusercontent.com/owncloud/owncloud.github.io/main/static/favicon/favicon.png"
  launch_url         = "https://files.movishell.pl"
  description        = "Files"
  newtab             = true
  group              = "Selfhosted"
  auth_groups        = [authentik_group.users.id]
  client_type        = "public"
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  client_id          = module.secret_ocis.fields["OIDC_CLIENT_ID"]
  # additional_property_mappings = formatlist(authentik_scope_mapping.openid-nextcloud.id)
  redirect_uris = [
    "https://files.movishell.pl",
    "https://files.movishell.pl/oidc-callback.html",
    "https://files.movishell.pl/oidc-silent-redirect.html"
  ]
}

module "oauth2-ocis-android" {
  source             = "./oauth2_application"
  name               = "Owncloud-android"
  launch_url         = "blank://blank"
  auth_groups        = [authentik_group.users.id]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  client_id          = "e4rAsNUSIUs0lF4nbv9FmCeUkTlV9GdgTLDH1b5uie7syb90SzEVrbN7HIpmWJeD"
  client_secret      = "dInFYGV33xKzhbRmpqQltYNdfLdJIfJ9L5ISoKhNoT9qZftpdWSP71VrpGR9pmoD"
  redirect_uris      = ["oc://android.owncloud.com", ]
}

module "oauth2-ocis-desktop" {
  source             = "./oauth2_application"
  name               = "owncloud-desktop"
  launch_url         = "blank://blank"
  auth_groups        = [authentik_group.users.id]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  client_id          = "xdXOt13JKxym1B1QcEncf2XDkLAexMBFwiT9j6EfhhHFJhs2KM9jbjTmf8JBXE69"
  client_secret      = "UBntmLjC2yYCeHwsyj73Uwo9TAaecAetRwMw0xYcvNL9yRdLSUi0hUAHfvCHFeFh"
  redirect_uris = [
    "http://127.0.0.1(:.*)?",
    "http://localhost(:.*)?"
  ]
}
