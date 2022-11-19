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
}

data "authentik_group" "admins" {
  name = "authentik Admins"
}
