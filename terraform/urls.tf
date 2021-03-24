# Redirect fluentbit.io/documentation to docs.fluentbit.io
resource "cloudflare_page_rule" "docs-fluentbitio" {
  zone_id  = lookup(data.cloudflare_zones.fluentbit-io-zone.zones[0], "id")
  target   = "https://${var.cloudflare_domain}/documentation*"
  priority = 1

  actions {
    forwarding_url {
      url         = "https://docs.${var.cloudflare_domain}/"
      status_code = 301
    }
  }
}

#Redirect fluentbit.io/downloads to https://docs.fluentbit.io/manual/installation/getting-started-with-fluent-bit
resource "cloudflare_page_rule" "downloads-fluentbitio" {
  zone_id  = lookup(data.cloudflare_zones.fluentbit-io-zone.zones[0], "id")
  target   = "https://${var.cloudflare_domain}/downloads*"
  priority = 1

  actions {
    forwarding_url {
      url         = "https://docs.${var.cloudflare_domain}/manual/installation/getting-started-with-fluent-bit"
      status_code = 301
    }
  }
}
