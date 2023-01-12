variable "metal_token" {
  type      = string
  sensitive = true
}

variable "metal_net_project_id" {
  type    = string
  default = "25d09386-ae25-4259-a239-f8c5e14a3c0e"
}

variable "cloudflare_domain" {
  type    = string
  default = "fluentbit.io"
}

variable "cloudflare_token" {
  type      = string
  sensitive = true
}

variable "github_token" {
  type      = string
  sensitive = true
}

variable "github_owner" {
  type    = string
  default = "fluent"
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
  type      = string
  sensitive = true
}

variable "gcp-default-machine-type" {
  type    = string
  default = "e2-highmem-8"
}

variable "gcp-ssh-keys" {
  type = map(string)
  default = {
    "niedbalski" = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzZuSdTxnKLzhps2W6ECMS6CCPFj6HaS7gxSkBsYFqOudbiJerQ+mhnXBa1EOESc461F3HgWko6XsnSMGu2K7x+7TKqxzOfzBTlD5ohzO8YzGBHN1t7yNBvQS3bPZ7gsd7TqpseZzmvbis8tZjyWzhuMxAUvKEuA6fjMdH6ndjSbmvAdjpKEVZxFvBMY1NwzazPkNKcMSXAxIbY5jPxbim/xVd8kbXG8z8ltF8IYxLLuKiYrMeiV6hI80tA8QS91uwP6WBmeY+7iG9sLd7atyc2KSo3qsWJvOlLq1o+M54HzxEcpk48Wnwg0Z5oxK/PAv1ncxfuO2Mjus9KRGimEPn niedbalski@theos-mobile"
  }
}

variable "release-s3-bucket" {
  type    = string
  default = "packages.fluentbit.io"
}

variable "release-sources-s3-bucket" {
  type    = string
  default = "releases.fluentbit.io"
}

variable "release-s3-access-id" {
  type      = string
  sensitive = true
}

variable "release-s3-secret-access-key" {
  type      = string
  sensitive = true
}

variable "release-gpg-key" {
  type      = string
  sensitive = true
}

variable "release-gpg-key-passphrase" {
  type      = string
  sensitive = true
}

variable "staging-s3-bucket" {
  type    = string
  default = "fluentbit-staging"
}

variable "staging-s3-access-id" {
  type      = string
  sensitive = true
}

variable "staging-s3-secret-access-key" {
  type      = string
  sensitive = true
}

variable "staging-gpg-key" {
  type      = string
  sensitive = true
}

variable "staging-gpg-key-passphrase" {
  type      = string
  sensitive = true
}

variable "release-approvers-usernames" {
  description = "The list of users making up the release-approvers team."
  type        = set(string)
  default = [
    "edsiper",
    "agup006",
    "niedbalski",
    "patrick-stephens"
  ]
}

variable "repo_full_name" {
  type    = string
  default = "fluent/fluent-bit"
}

variable "github_runner_version" {
  type        = string
  description = "Version of action runner to install"
  default     = "2.285.1"
}

variable "release-server-hostname" {
  type = string
}
variable "release-server-username" {
  type = string
}
variable "release-server-sshkey" {
  type      = string
  sensitive = true
}
variable "release-dockerhub-username" {
  type = string
}
variable "release-dockerhub-token" {
  type      = string
  sensitive = true
}

variable "release-cosign-private-key" {
  type      = string
  sensitive = true
}

variable "release-dockerhub-org" {
  type    = string
  default = "fluent/fluent-bit"
}

variable "appveyor_token" {
  type      = string
  sensitive = true
}

variable "appveyor_account" {
  type      = string
  sensitive = true
}

variable "unstable-release-token" {
  type      = string
  sensitive = true
}

variable "fluent-bit-ci-opensearch-aws-access-id" {
  type      = string
  sensitive = true
}

variable "fluent-bit-ci-opensearch-aws-secret-key" {
  type      = string
  sensitive = true
}

variable "fluent-bit-ci-opensearch-admin-password" {
  type      = string
  sensitive = true
}

variable "fluent-bit-sandbox-maintainers" {
  description = "The list of users making up the fluent-bit-sandbox-maintainers team."
  type        = set(string)
  default = [
    "edsiper",
    "agup006",
    "niedbalski",
    "patrick-stephens"
  ]
}

variable "fluent-bit-ci-azure-client-id" {
  type      = string
  sensitive = true
}

variable "fluent-bit-ci-azure-client-secret" {
  type      = string
  sensitive = true
}

variable "fluent-bit-ci-azure-subscription-id" {
  type      = string
  sensitive = true
}

variable "fluent-bit-ci-azure-tenant-id" {
  type      = string
  sensitive = true
}

variable "grafana-cloud-prometheus-username" {
  type      = string
  sensitive = true
}

variable "grafana-cloud-prometheus-apikey" {
  type      = string
  sensitive = true
}

variable "public-readonly-dockerhub-username" {
  type = string
}

variable "public-readonly-dockerhub-token" {
  type      = string
  sensitive = true
}
