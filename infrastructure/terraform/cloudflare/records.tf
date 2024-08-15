data "cloudflare_zones" "domain" {
  filter {
    name = module.secret_cf.fields.DOMAIN
  }
}

data "http" "ipv4" {
  url = "http://ipv4.icanhazip.com"
}

resource "cloudflare_record" "root" {
  name    = module.secret_cf.fields.DOMAIN
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  content = chomp(data.http.ipv4.response_body)
  type    = "A"
  ttl     = 300
}

resource "cloudflare_record" "external" {
  name    = "external"
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  content = chomp(data.http.ipv4.response_body)
  type    = "A"
  ttl     = 300
}

resource "cloudflare_record" "minecraft" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = "minecraft.${module.secret_cf.fields.DOMAIN}"
  content = "external.${module.secret_cf.fields.DOMAIN}"
  type    = "CNAME"
  ttl     = 60
}

resource "cloudflare_record" "mail-1" {
  name    = "mail"
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  content = "66.111.4.148"
  type    = "A"
  ttl     = 1
}

resource "cloudflare_record" "mail-2" {
  name    = "mail"
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  content = "66.111.4.147"
  type    = "A"
  ttl     = 1
}

resource "cloudflare_record" "archie_ip" {
  name    = "archie"
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  content = module.secret_cf.fields.ARCHIE_IP
  type    = "A"
  ttl     = 60
}

resource "cloudflare_record" "archie_ip_wildcard" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = "*.archie.${module.secret_cf.fields.DOMAIN}"
  content = "archie.${module.secret_cf.fields.DOMAIN}"
  type    = "CNAME"
  ttl     = 60
}

resource "cloudflare_record" "caa" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = module.secret_cf.fields.DOMAIN
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
  name    = "fm1._domainkey.${module.secret_cf.fields.DOMAIN}"
  content = "fm1.${module.secret_cf.fields.DOMAIN}.dkim.fmhosted.com"
  type    = "CNAME"
  ttl     = 1
}

resource "cloudflare_record" "dkim-2" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = "fm2._domainkey.${module.secret_cf.fields.DOMAIN}"
  content = "fm2.${module.secret_cf.fields.DOMAIN}.dkim.fmhosted.com"
  type    = "CNAME"
  ttl     = 1
}

resource "cloudflare_record" "dkim-3" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = "fm3._domainkey.${module.secret_cf.fields.DOMAIN}"
  content = "fm3.${module.secret_cf.fields.DOMAIN}.dkim.fmhosted.com"
  type    = "CNAME"
  ttl     = 1
}

resource "cloudflare_record" "mailmx-1" {
  zone_id  = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name     = module.secret_cf.fields.DOMAIN
  content  = "in1-smtp.messagingengine.com"
  type     = "MX"
  priority = 10
  ttl      = 1
}

resource "cloudflare_record" "mailmx-2" {
  zone_id  = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name     = module.secret_cf.fields.DOMAIN
  content  = "in2-smtp.messagingengine.com"
  type     = "MX"
  priority = 20
  ttl      = 1
}

resource "cloudflare_record" "txt_spf" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = module.secret_cf.fields.DOMAIN
  content = "v=spf1 include:spf.messagingengine.com -all"
  type    = "TXT"
  ttl     = 1
}

resource "cloudflare_record" "txt_dmarc" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = module.secret_cf.fields.DOMAIN
  content = "v=DMARC1; p=quarantine; pct=100; rua=mailto:postmaster@${module.secret_cf.fields.DOMAIN}; ruf=mailto:postmaster@${module.secret_cf.fields.DOMAIN}"
  type    = "TXT"
  ttl     = 1
}

resource "cloudflare_record" "fastmail-caldavs" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = "_caldavs._tcp.${module.secret_cf.fields.DOMAIN}"
  data {
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
  name    = "_caldav._tcp.module.${module.secret_cf.fields.DOMAIN}"
  data {
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
  name    = "_carddavs._tcp.{$module.secret_cf.fields.DOMAIN}"
  data {
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
  name    = "_carddav._tcp.${module.secret_cf.fields.DOMAIN}"
  data {
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
  name    = "_imaps._tcp.${module.secret_cf.fields.DOMAIN}"
  data {
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
  name    = "_imap._tcp.${module.secret_cf.fields.DOMAIN}"
  data {
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
  name    = "_jmap._tcp.${module.secret_cf.fields.DOMAIN}"
  data {
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
  name    = "_pop3s._tcp.${module.secret_cf.fields.DOMAIN}"
  data {
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
  name    = "_pop3._tcp.${module.secret_cf.fields.DOMAIN}"
  data {
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
  name    = "_submission._tcp.${module.secret_cf.fields.DOMAIN}"
  data {
    priority = 0
    weight   = 1
    port     = 587
    target   = "smtp.fastmail.com"
  }
  type = "SRV"
  ttl  = 1
}
