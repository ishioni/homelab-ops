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
