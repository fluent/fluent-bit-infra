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
  proxied = false
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

resource "cloudflare_record" "docs" {
  name    = "docs"
  value   = "hosting.gitbook.com"
  type    = "CNAME"
  proxied = false
  zone_id = lookup(data.cloudflare_zones.fluentbit-io-zone.zones[0], "id")
}

resource "cloudflare_record" "test-subdomain" {
  name   = "test-subdomain"
  value  = data.packet_device.www.access_public_ipv4
  type   = "A"
  proxied = false
  zone_id = lookup(data.cloudflare_zones.fluentbit-io-zone.zones[0], "id")
}
