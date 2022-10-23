terraform {

  backend "remote" {
    organization = "ishioni"
    workspaces {
      name = "minio"
    }
  }

  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "0.7.1"
    }
    minio = {
      source  = "aminueza/minio"
      version = "1.8.0"
    }
  }
}

data "sops_file" "minio_secrets" {
  source_file = "secret.sops.yaml"
}

provider "minio" {
  minio_server = data.sops_file.minio_secrets.data["minio_server"]
  # minio_region = "us-east-1"
  minio_access_key = data.sops_file.minio_secrets.data["minio_access_key"]
  minio_secret_key = data.sops_file.minio_secrets.data["minio_secret_key"]
  minio_ssl        = true
}

