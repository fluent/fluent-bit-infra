data "cloudflare_zones" "fluentbit-io-zone" {
  filter {
    name = var.cloudflare_domain
  }
}

resource "cloudflare_record" "builder" {
  name    = "builder"
  value   = data.packet_device.builder.access_public_ipv4
  type    = "A"
  proxied = false
  zone_id = lookup(data.cloudflare_zones.fluentbit-io-zone.zones[0], "id")
}

resource "cloudflare_record" "dev-arm" {
  name    = "dev-arm"
  value   = data.packet_device.dev-arm.access_public_ipv4
  type    = "A"
  proxied = false
  zone_id = lookup(data.cloudflare_zones.fluentbit-io-zone.zones[0], "id")
}

resource "cloudflare_record" "www" {
  name    = "www"
  value   = data.packet_device.www.access_public_ipv4
  type    = "A"
  proxied = false
  zone_id = lookup(data.cloudflare_zones.fluentbit-io-zone.zones[0], "id")
}

resource "cloudflare_record" "root-www" {
  name    = "fluentbit.io"
  value   = data.packet_device.www.access_public_ipv4
  type    = "A"
  proxied = true
  zone_id = lookup(data.cloudflare_zones.fluentbit-io-zone.zones[0], "id")
}

resource "cloudflare_record" "perf-test" {
  name    = "perf-test"
  value   = data.packet_device.perf-test.access_public_ipv4
  type    = "A"
  proxied = false
  zone_id = lookup(data.cloudflare_zones.fluentbit-io-zone.zones[0], "id")
}

resource "cloudflare_record" "backup" {
  name    = "backup"
  value   = "166.78.105.113"
  type    = "A"
  proxied = false
  zone_id = lookup(data.cloudflare_zones.fluentbit-io-zone.zones[0], "id")
}

resource "cloudflare_record" "packages" {
  name    = "packages"
  value   = data.packet_device.www.access_public_ipv4
  type    = "A"
  proxied = false
  zone_id = lookup(data.cloudflare_zones.fluentbit-io-zone.zones[0], "id")
}

resource "cloudflare_record" "apt" {
  name    = "apt"
  value   = data.packet_device.www.access_public_ipv4
  type    = "A"
  proxied = false
  zone_id = lookup(data.cloudflare_zones.fluentbit-io-zone.zones[0], "id")
}

resource "cloudflare_record" "config-validator-dev" {
  zone_id = lookup(data.cloudflare_zones.fluentbit-io-zone.zones[0], "id")
  name    = "config-validator-dev"
  type    = "TXT"
  value   = "google-site-verification=3LKmK6H60ZzDiqsRV_gzyMZUPBLyo_8spm020ec0wTc"
  ttl     = 3600
}

resource "cloudflare_record" "config-validator" {
  zone_id = lookup(data.cloudflare_zones.fluentbit-io-zone.zones[0], "id")
  name    = "config-validator"
  type    = "TXT"
  value   = "google-site-verification=1TdzXCdR-l4olN5FH32pJeLp4jygGM5DXJo3YgS0L20"
  ttl     = 3600
}

resource "cloudflare_record" "fluentd-config-validator" {
  zone_id = lookup(data.cloudflare_zones.fluentbit-io-zone.zones[0], "id")
  name    = "fluentd-config-validator"
  type    = "TXT"
  value   = "google-site-verification=1s_WLkyRBIzVqkgflYJaMEdUrVNj61vOhGDfo2tnh94"
  ttl     = 3600
}

resource "cloudflare_record" "fluentd-config-validator-dev" {
  zone_id = lookup(data.cloudflare_zones.fluentbit-io-zone.zones[0], "id")
  name    = "fluentd-config-validator-dev"
  type    = "TXT"
  value   = "google-site-verification=874rZ1WmtdJ3IY3K-81LQHBdkZFVd0ABXdtu6HKv6A8"
  ttl     = 3600
}

resource "cloudflare_record" "docs" {
  name    = "docs"
  value   = "hosting.gitbook.com"
  type    = "CNAME"
  proxied = false
  zone_id = lookup(data.cloudflare_zones.fluentbit-io-zone.zones[0], "id")
}

resource "cloudflare_record" "test-subdomain" {
  name    = "test-subdomain"
  value   = data.packet_device.www.access_public_ipv4
  type    = "A"
  proxied = false
  zone_id = lookup(data.cloudflare_zones.fluentbit-io-zone.zones[0], "id")
}
