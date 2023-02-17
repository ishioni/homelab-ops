terraform {

  backend "remote" {
    organization = "ishioni"
    workspaces {
      name = "authentik"
    }
  }

  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "0.7.2"
    }
    authentik = {
      source  = "goauthentik/authentik"
      version = "2023.2.1"
    }
  }
}

data "sops_file" "authentik_secrets" {
  source_file = "secret.sops.yaml"
}

provider "authentik" {
  url   = data.sops_file.authentik_secrets.data["authnetik_endpoint"]
  token = data.sops_file.authentik_secrets.data["authentik_token"]
}
