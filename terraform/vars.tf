variable fluent_bit_workspace {
  type = string
  default = "fluent-bit-infra"
}

variable fluent_bit_organization {
  type = string
  default = "calyptia"
}

variable packet_net_token {
  type = string
}

variable packet_net_project_id {
  type = string
  default = "25d09386-ae25-4259-a239-f8c5e14a3c0e"
}

variable cloudflare_domain {
  type = string
  default = "fluentbit.io"
}

variable cloudflare_email {
  type = string
  default = "j@calyptia.com"
}

variable cloudflare_token {
  type = string
}