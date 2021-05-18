variable "fluent_bit_workspace" {
  type    = string
  default = "fluent-bit-infra"
}

variable "fluent_bit_organization" {
  type    = string
  default = "calyptia"
}

variable "packet_net_token" {
  type = string
}

variable "packet_net_project_id" {
  type    = string
  default = "25d09386-ae25-4259-a239-f8c5e14a3c0e"
}

variable "cloudflare_domain" {
  type    = string
  default = "fluentbit.io"
}

variable "cloudflare_email" {
  type    = string
  default = "j@calyptia.com"
}

variable "cloudflare_token" {
  type = string
}

variable "github_owner" {
  type = string
}

variable "github_token" {
  type = string
}

variable "gcp-project-id" {
  type    = string
  default = "fluent-bit-ci"
}

variable "gcp-default-region" {
  type    = string
  default = "us-east1"
}

variable "gcp-default-zone" {
  type    = string
  default = "us-east1-c"
}

variable "gcp-sa-key" {
  type = string
}

variable "gcp-default-machine-type" {
  type = string
  default = "e2-standard-16"
}

variable "gcp-ssh-keys" {
  type = "map"
  default = {
    "niedbalski" = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzZuSdTxnKLzhps2W6ECMS6CCPFj6HaS7gxSkBsYFqOudbiJerQ+mhnXBa1EOESc461F3HgWko6XsnSMGu2K7x+7TKqxzOfzBTlD5ohzO8YzGBHN1t7yNBvQS3bPZ7gsd7TqpseZzmvbis8tZjyWzhuMxAUvKEuA6fjMdH6ndjSbmvAdjpKEVZxFvBMY1NwzazPkNKcMSXAxIbY5jPxbim/xVd8kbXG8z8ltF8IYxLLuKiYrMeiV6hI80tA8QS91uwP6WBmeY+7iG9sLd7atyc2KSo3qsWJvOlLq1o+M54HzxEcpk48Wnwg0Z5oxK/PAv1ncxfuO2Mjus9KRGimEPn niedbalski@theos-mobile"
  }
}