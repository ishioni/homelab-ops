data "cloudflare_zone" "domain" {
    name = var.public_domain
}

locals {
  public_domain_zone = data.cloudflare_zone.domain.id
}

data "http" "ipv4" {
  url = "http://ipv4.icanhazip.com"
}

resource "cloudflare_record" "root" {
  name    = var.public_domain
  content = chomp(data.http.ipv4.response_body)
  ttl     = 60
  type    = "A"
  zone_id = local.public_domain_zone
}

resource "cloudflare_record" "external" {
  name    = "external"
  content = chomp(data.http.ipv4.response_body)
  ttl     = 60
  type    = "A"
  zone_id = local.public_domain_zone
}

resource "cloudflare_record" "minecraft" {
  name    = "minecraft.${var.public_domain}"
  content = "external.${var.public_domain}"
  ttl     = 300
  type    = "CNAME"
  zone_id = local.public_domain_zone
}

resource "cloudflare_record" "archie_ip" {
  name    = "archie"
  content = module.secret_cf.fields.ARCHIE_IP
  ttl     = 60
  type    = "A"
  zone_id = local.public_domain_zone
}

resource "cloudflare_record" "archie_ip_wildcard" {
  name    = "*.archie.${var.public_domain}"
  content = "archie.${var.public_domain}"
  ttl     = 60
  type    = "CNAME"
  zone_id = local.public_domain_zone
}

resource "cloudflare_record" "mail-1" {
  name    = "mail"
  content = "66.111.4.148"
  ttl     = 3600
  type    = "A"
  zone_id = local.public_domain_zone
}

resource "cloudflare_record" "caa" {
  name    = var.public_domain
  type = "CAA"
  ttl  = 43200
  zone_id = local.public_domain_zone
  data {
    flags = "0"
    tag   = "issue"
    value = "letsencrypt.org"
  }
}

resource "cloudflare_record" "mail-2" {
  name    = "mail"
  content = "66.111.4.147"
  ttl     = 3600
  type    = "A"
  zone_id = local.public_domain_zone
}

resource "cloudflare_record" "dkim-1" {
  name    = "fm1._domainkey.${var.public_domain}"
  content = "fm1.${var.public_domain}.dkim.fmhosted.com"
  ttl     = 43200
  type    = "CNAME"
  zone_id = local.public_domain_zone
}

resource "cloudflare_record" "dkim-2" {
  name    = "fm2._domainkey.${var.public_domain}"
  content = "fm2.${var.public_domain}.dkim.fmhosted.com"
  ttl     = 43200
  type    = "CNAME"
  zone_id = local.public_domain_zone
}

resource "cloudflare_record" "dkim-3" {
  name    = "fm3._domainkey.${var.public_domain}"
  content = "fm3.${var.public_domain}.dkim.fmhosted.com"
  ttl     = 43200
  type    = "CNAME"
  zone_id = local.public_domain_zone
}

resource "cloudflare_record" "mailmx-1" {
  name     = var.public_domain
  content  = "in1-smtp.messagingengine.com"
  priority = 10
  type     = "MX"
  ttl      = 3600
  zone_id  = local.public_domain_zone
}

resource "cloudflare_record" "mailmx-2" {
  name     = var.public_domain
  content  = "in2-smtp.messagingengine.com"
  priority = 20
  ttl      = 3600
  type     = "MX"
  zone_id  = local.public_domain_zone
}

resource "cloudflare_record" "txt_spf" {
  name    = var.public_domain
  content = "v=spf1 include:spf.messagingengine.com -all"
  ttl     = 43200
  type    = "TXT"
  zone_id = local.public_domain_zone
}

resource "cloudflare_record" "txt_dmarc" {
  name    = var.public_domain
  content = "v=DMARC1; p=quarantine; pct=100; rua=mailto:postmaster@${var.public_domain}; ruf=mailto:postmaster@${var.public_domain}"
  type    = "TXT"
  ttl     = 43200
  zone_id = local.public_domain_zone
}

resource "cloudflare_record" "fastmail-caldavs" {
  name    = "_caldavs._tcp.${var.public_domain}"
  ttl  = 3600
  type = "SRV"
  zone_id = local.public_domain_zone
  data {
    priority = 0
    weight   = 1
    port     = 443
    target   = "caldav.fastmail.com"
  }
}

resource "cloudflare_record" "fastmail-caldav" {
  name    = "_caldav._tcp.module.${var.public_domain}"
  ttl  = 3600
  type = "SRV"
  zone_id = local.public_domain_zone
  data {
    priority = 0
    weight   = 0
    port     = 0
    target   = "."
  }

}

resource "cloudflare_record" "fastmail-carddavs" {
  name    = "_carddavs._tcp.{$var.public_domain}"
  ttl  = 3600
  type = "SRV"
  zone_id = local.public_domain_zone
  data {
    priority = 0
    weight   = 1
    port     = 443
    target   = "carddav.fastmail.com"
  }

}

resource "cloudflare_record" "fastmail-carddav" {
  name    = "_carddav._tcp.${var.public_domain}"
  ttl  = 3600
  type = "SRV"
  zone_id = local.public_domain_zone
  data {
    priority = 0
    weight   = 0
    port     = 0
    target   = "."
  }
}

resource "cloudflare_record" "fastmail-imaps" {
  name    = "_imaps._tcp.${var.public_domain}"
  ttl  = 3600
  type = "SRV"
  zone_id = local.public_domain_zone
  data {
    priority = 0
    weight   = 1
    port     = 993
    target   = "imap.fastmail.com"
  }
}

resource "cloudflare_record" "fastmail-imap" {
  name    = "_imap._tcp.${var.public_domain}"
  ttl  = 3600
  type = "SRV"
  zone_id = local.public_domain_zone
  data {
    priority = 0
    weight   = 0
    port     = 0
    target   = "."
  }
}

resource "cloudflare_record" "fastmail-jmap" {
  name    = "_jmap._tcp.${var.public_domain}"
  ttl  = 3600
  type = "SRV"
  zone_id = local.public_domain_zone
  data {
    priority = 0
    weight   = 1
    port     = 443
    target   = "jmap.fastmail.com"
  }
}

resource "cloudflare_record" "fastmail-pop3s" {
  name    = "_pop3s._tcp.${var.public_domain}"
  ttl  = 3600
  type = "SRV"
  zone_id = local.public_domain_zone
  data {
    priority = 0
    weight   = 1
    port     = 995
    target   = "pop.fastmail.com"
  }
}

resource "cloudflare_record" "fastmail-pop3" {
  name    = "_pop3._tcp.${var.public_domain}"
  ttl  = 3600
  type = "SRV"
  zone_id = local.public_domain_zone
  data {
    priority = 0
    weight   = 0
    port     = 0
    target   = "."
  }
}

resource "cloudflare_record" "fastmail-submission" {
  name    = "_submission._tcp.${var.public_domain}"
  ttl  = 3600
  type = "SRV"
  zone_id = local.public_domain_zone
  data {
    priority = 0
    weight   = 1
    port     = 587
    target   = "smtp.fastmail.com"
  }
}
