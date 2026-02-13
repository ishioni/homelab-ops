module "proxy-qbittorrent" {
  source             = "./proxy_application"
  name               = "QBittorrent"
  description        = "Torrent client"
  icon_url           = "https://raw.githubusercontent.com/qbittorrent/qBittorrent/master/src/webui/www/public/images/qbittorrent-tray.svg"
  group              = "Downloads"
  slug               = "torrent"
  domain             = var.public_domain
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  invalidation_flow  = resource.authentik_flow.provider-invalidation.uuid
  auth_groups        = [authentik_group.downloads.id]
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
  auth_groups        = [authentik_group.downloads.id]
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
  auth_groups        = [authentik_group.downloads.id]
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
  auth_groups        = [authentik_group.downloads.id]
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
  auth_groups        = [authentik_group.downloads.id]
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
  auth_groups        = [authentik_group.downloads.id]
}

module "oauth2-qui" {
  source             = "./oauth2_application"
  name               = "Qui"
  icon_url           = "https://raw.githubusercontent.com/autobrr/qui/refs/heads/main/web/public/qui.png"
  launch_url         = "https://qui.${var.private_domain}"
  description        = "Torrent UI"
  newtab             = true
  group              = "Downloads"
  auth_groups        = [authentik_group.downloads.id]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  invalidation_flow  = resource.authentik_flow.provider-invalidation.uuid
  client_id          = module.secret_qui.fields["OIDC_CLIENT_ID"]
  client_secret      = module.secret_qui.fields["OIDC_CLIENT_SECRET"]
  redirect_uris      = ["https://qui.${var.private_domain}/api/auth/oidc/callback"]
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
  auth_groups        = [authentik_group.users.id]
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
  auth_groups        = [authentik_group.users.id]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  invalidation_flow  = resource.authentik_flow.provider-invalidation.uuid
  client_id          = module.secret_immich.fields["OIDC_CLIENT_ID"]
  client_secret      = module.secret_immich.fields["OIDC_CLIENT_SECRET"]
  redirect_uris = [
    "https://photos.${var.public_domain}/auth/login",
    "app.immich:///oauth-callback"
  ]
}

module "oauth2-paperless" {
  source             = "./oauth2_application"
  name               = "Paperless"
  icon_url           = "https://raw.githubusercontent.com/paperless-ngx/paperless-ngx/dev/resources/logo/web/svg/Color%20logo%20-%20no%20background.svg"
  launch_url         = "https://documents.${var.private_domain}"
  description        = "Documents"
  newtab             = true
  group              = "Selfhosted"
  auth_groups        = [authentik_group.users.id]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  invalidation_flow  = resource.authentik_flow.provider-invalidation.uuid
  client_id          = module.secret_paperless.fields["OIDC_CLIENT_ID"]
  client_secret      = module.secret_paperless.fields["OIDC_CLIENT_SECRET"]
  redirect_uris      = ["https://documents.${var.private_domain}/accounts/oidc/authentik/login/callback/"]
}

# module "oauth2-romm" {
#   source             = "./oauth2_application"
#   name               = "Romm"
#   icon_url           = "https://raw.githubusercontent.com/rommapp/romm/refs/heads/release/frontend/assets/isotipo.svg"
#   launch_url         = "https://romm.${var.private_domain}"
#   description        = "Games"
#   newtab             = true
#   group              = "Downloads"
#   auth_groups        = [authentik_group.downloads.id]
#   authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
#   invalidation_flow  = resource.authentik_flow.provider-invalidation.uuid
#   client_id          = module.secret_romm.fields["OIDC_CLIENT_ID"]
#   client_secret      = module.secret_romm.fields["OIDC_CLIENT_SECRET"]
#   redirect_uris      = ["https://romm.${var.private_domain}/api/oauth/openid"]
# }

module "oauth2-vaultwarden" {
  source                = "./oauth2_application"
  name                  = "Vaultwarden"
  icon_url              = "https://raw.githubusercontent.com/dani-garcia/vaultwarden/refs/heads/main/resources/vaultwarden-icon.svg"
  launch_url            = "https://passwords.${var.public_domain}"
  description           = "Passwords"
  newtab                = true
  group                 = "Selfhosted"
  auth_groups           = [authentik_group.users.id]
  authorization_flow    = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  invalidation_flow     = resource.authentik_flow.provider-invalidation.uuid
  client_id             = module.secret_vaultwarden.fields["OIDC_CLIENT_ID"]
  client_secret         = module.secret_vaultwarden.fields["OIDC_CLIENT_SECRET"]
  redirect_uris         = ["https://passwords.${var.public_domain}/identity/connect/oidc-signin"]
  access_token_validity = "hours=1"
}

# module "oauth2-openwebui" {
#   source             = "./oauth2_application"
#   name               = "OpenWebUI"
#   icon_url           = "https://raw.githubusercontent.com/open-webui/open-webui/refs/heads/main/static/favicon.png"
#   launch_url         = "https://ai.${var.public_domain}"
#   description        = "AI-powered web interface"
#   newtab             = true
#   group              = "Selfhosted"
#   auth_groups        = [authentik_group.users.id]
#   authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
#   invalidation_flow  = resource.authentik_flow.provider-invalidation.uuid
#   client_id          = module.secret_openwebui.fields["OIDC_CLIENT_ID"]
#   client_secret      = module.secret_openwebui.fields["OIDC_CLIENT_SECRET"]
#   redirect_uris      = ["https://ai.${var.public_domain}/oauth/oidc/callback"]
# }

module "oauth2-opencloud" {
  source             = "./oauth2_application"
  name               = "OpenCloud"
  icon_url           = "https://raw.githubusercontent.com/opencloud-eu/docs/refs/heads/main/static/img/oc-favicon.svg"
  launch_url         = "https://opencloud.${var.public_domain}"
  description        = "OpenCloud"
  newtab             = true
  group              = "Selfhosted"
  auth_groups        = [authentik_group.users.id]
  client_type        = "public"
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  invalidation_flow  = resource.authentik_flow.provider-invalidation.uuid
  client_id          = "web"
  # additional_property_mappings = formatlist(authentik_scope_mapping.openid-nextcloud.id)
  redirect_uris = [
    "https://opencloud.${var.public_domain}",
    "https://opencloud.${var.public_domain}/oidc-callback.html",
    "https://opencloud.${var.public_domain}/oidc-silent-redirect.html"
  ]
}

module "oauth2-opencloud-desktop" {
  source             = "./oauth2_application"
  name               = "OpenCloudDesktop"
  launch_url         = "blank://blank"
  auth_groups        = [authentik_group.users.id]
  client_type        = "public"
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  invalidation_flow  = resource.authentik_flow.provider-invalidation.uuid
  client_id          = "OpenCloudDesktop"
  redirect_uris = [
    { matching_mode = "regex", url = "http://127.0.0.1(:.*)?" },
    { matching_mode = "regex", url = "http://localhost(:.*)?" }
  ]
}

module "oauth2-opencloud-android" {
  source             = "./oauth2_application"
  name               = "OpenCloudAndroid"
  launch_url         = "blank://blank"
  auth_groups        = [authentik_group.users.id]
  client_type        = "public"
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  invalidation_flow  = resource.authentik_flow.provider-invalidation.uuid
  client_id          = "OpenCloudAndroid"
  redirect_uris      = ["oc://android.opencloud.eu"]
}

module "oauth2-opencloud-ios" {
  source             = "./oauth2_application"
  name               = "OpenCloudIOS"
  launch_url         = "blank://blank"
  auth_groups        = [authentik_group.users.id]
  client_type        = "public"
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  invalidation_flow  = resource.authentik_flow.provider-invalidation.uuid
  client_id          = "OpenCloudIOS"
  redirect_uris      = ["oc://ios.opencloud.eu"]
}

module "oauth2-readur" {
  source             = "./oauth2_application"
  name               = "Readur"
  icon_url           = "https://raw.githubusercontent.com/readur/readur/refs/heads/main/frontend/public/readur-64.png"
  launch_url         = "https://readur.${var.public_domain}"
  description        = "Documents managment system"
  newtab             = true
  group              = "Selfhosted"
  auth_groups        = [authentik_group.users.id]
  authorization_flow = resource.authentik_flow.provider-authorization-implicit-consent.uuid
  invalidation_flow  = resource.authentik_flow.provider-invalidation.uuid
  client_id          = module.secret_readur.fields["OIDC_CLIENT_ID"]
  client_secret      = module.secret_readur.fields["OIDC_CLIENT_SECRET"]
  redirect_uris      = ["https://readur.${var.private_domain}/api/auth/oidc/callback"]
}
