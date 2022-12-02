terraform {
  backend "remote" {
    organization = "ishioni"
    workspaces {
      name = "cloudflare"
    }
  }
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "3.29.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.2.1"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.7.1"
    }
  }
}

data "sops_file" "cloudflare_secrets" {
  source_file = "secret.sops.yaml"
}

provider "cloudflare" {
  email   = data.sops_file.cloudflare_secrets.data["cloudflare_email"]
  api_key = data.sops_file.cloudflare_secrets.data["cloudflare_apikey"]
}

data "cloudflare_zones" "domain" {
  filter {
    name = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  }
}

data "http" "ipv4" {
  url = "http://ipv4.icanhazip.com"
}

resource "cloudflare_record" "root" {
  name    = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = chomp(data.http.ipv4.response_body)
  type    = "A"
  ttl     = 300
}

resource "cloudflare_record" "mail-1" {
  name    = "mail"
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = "66.111.4.148"
  type    = "A"
  ttl     = 1
}

resource "cloudflare_record" "mail-2" {
  name    = "mail"
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = "66.111.4.147"
  type    = "A"
  ttl     = 1
}

resource "cloudflare_record" "caa" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  data {
    flags = "0"
    tag   = "issue"
    value = "letsencrypt.org"
  }
  type = "CAA"
  ttl  = 1
}

resource "cloudflare_record" "dkim-1" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = "fm1._domainkey.${data.sops_file.cloudflare_secrets.data["cloudflare_domain"]}"
  value   = "fm1.${data.sops_file.cloudflare_secrets.data["cloudflare_domain"]}.dkim.fmhosted.com"
  type    = "CNAME"
  ttl     = 1
}

resource "cloudflare_record" "dkim-2" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = "fm2._domainkey.${data.sops_file.cloudflare_secrets.data["cloudflare_domain"]}"
  value   = "fm2.${data.sops_file.cloudflare_secrets.data["cloudflare_domain"]}.dkim.fmhosted.com"
  type    = "CNAME"
  ttl     = 1
}

resource "cloudflare_record" "dkim-3" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = "fm3._domainkey.${data.sops_file.cloudflare_secrets.data["cloudflare_domain"]}"
  value   = "fm3.${data.sops_file.cloudflare_secrets.data["cloudflare_domain"]}.dkim.fmhosted.com"
  type    = "CNAME"
  ttl     = 1
}

resource "cloudflare_record" "mailmx-1" {
  zone_id  = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name     = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  value    = "in1-smtp.messagingengine.com"
  type     = "MX"
  priority = 10
  ttl      = 1
}

resource "cloudflare_record" "mailmx-2" {
  zone_id  = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name     = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  value    = "in2-smtp.messagingengine.com"
  type     = "MX"
  priority = 20
  ttl      = 1
}

resource "cloudflare_record" "txt_spf" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  value   = "v=spf1 include:spf.messagingengine.com ?all"
  type    = "TXT"
  ttl     = 1
}

resource "cloudflare_record" "fastmail-caldavs" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = "_caldavs._tcp.${data.sops_file.cloudflare_secrets.data["cloudflare_domain"]}"
  data {
    service  = "_caldavs"
    proto    = "_tcp"
    name     = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
    priority = 0
    weight   = 1
    port     = 443
    target   = "caldav.fastmail.com"
  }
  type = "SRV"
  ttl  = 1
}

resource "cloudflare_record" "fastmail-caldav" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  data {
    service  = "_caldav"
    proto    = "_tcp"
    name     = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
    priority = 0
    weight   = 0
    port     = 0
    target   = "."
  }
  type = "SRV"
  ttl  = 1
}

resource "cloudflare_record" "fastmail-carddavs" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  data {
    service  = "_carddavs"
    proto    = "_tcp"
    name     = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
    priority = 0
    weight   = 1
    port     = 443
    target   = "carddav.fastmail.com"
  }
  type = "SRV"
  ttl  = 1
}

resource "cloudflare_record" "fastmail-carddav" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  data {
    service  = "_carddav"
    proto    = "_tcp"
    name     = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
    priority = 0
    weight   = 0
    port     = 0
    target   = "."
  }
  type = "SRV"
  ttl  = 1
}

resource "cloudflare_record" "fastmail-imaps" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  data {
    service  = "_imaps"
    proto    = "_tcp"
    name     = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
    priority = 0
    weight   = 1
    port     = 993
    target   = "imap.fastmail.com"
  }
  type = "SRV"
  ttl  = 1
}

resource "cloudflare_record" "fastmail-imap" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  data {
    service  = "_imap"
    proto    = "_tcp"
    name     = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
    priority = 0
    weight   = 0
    port     = 0
    target   = "."
  }
  type = "SRV"
  ttl  = 1
}

resource "cloudflare_record" "fastmail-jmap" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  data {
    service  = "_jmap"
    proto    = "_tcp"
    name     = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
    priority = 0
    weight   = 1
    port     = 443
    target   = "jmap.fastmail.com"
  }
  type = "SRV"
  ttl  = 1
}

resource "cloudflare_record" "fastmail-pop3s" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  data {
    service  = "_pop3s"
    proto    = "_tcp"
    name     = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
    priority = 0
    weight   = 1
    port     = 995
    target   = "pop.fastmail.com"
  }
  type = "SRV"
  ttl  = 1
}

resource "cloudflare_record" "fastmail-pop3" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  data {
    service  = "_pop3"
    proto    = "_tcp"
    name     = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
    priority = 0
    weight   = 0
    port     = 0
    target   = "."
  }
  type = "SRV"
  ttl  = 1
}

resource "cloudflare_record" "fastmail-submission" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  data {
    service  = "_submission"
    proto    = "_tcp"
    name     = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
    priority = 0
    weight   = 1
    port     = 587
    target   = "smtp.fastmail.com"
  }
  type = "SRV"
  ttl  = 1
}
