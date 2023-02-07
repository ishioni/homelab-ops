resource "authentik_group" "users" {
  name         = "users"
  is_superuser = false
}

resource "authentik_group" "media" {
  name         = "media"
  is_superuser = false
  parent       = resource.authentik_group.users.id
}

resource "authentik_group" "nextcloud" {
  name         = "nextcloud"
  is_superuser = false
  parent       = resource.authentik_group.users.id
  attributes = jsonencode({
    defaultQuota = "20 GB"
  })
}

resource "authentik_group" "infrastructure" {
  name         = "infrastructure"
  is_superuser = false
}

data "authentik_group" "admins" {
  name = "authentik Admins"
}

# resource "authentik_group" "nextcloud-users" {
#   name         = "nextcloud-users"
#   is_superuser = false
#   parent       = resource.authentik_group.users.id
#   attributes = jsonencode({
#     nextcloud_quota = "1 GB"
#   })
# }

# resource "authentik_group" "nextcloud-admins" {
#   name = "nextcloud-admins"
#   attributes = jsonencode({
#     nextcloud_admin = true
#   })
# }
