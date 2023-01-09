data "github_repository" "fluentbit" {
  full_name = var.repo_full_name
}

data "github_repository" "fluent-bit-ci" {
  full_name = "fluent/fluent-bit-ci"
}

locals {
  repos_with_opensearch_aws_access = [data.github_repository.fluentbit, data.github_repository.fluent-bit-mirror, data.github_repository.fluent-bit-ci]
  repos_with_azure_access          = [data.github_repository.fluentbit, data.github_repository.fluent-bit-mirror, data.github_repository.fluent-bit-ci]
}

data "github_repository" "fluent-bit-mirror" {
  full_name = "fluent/fluent-bit-mirror"
}

resource "github_branch" "mirror-main-branch" {
  repository = data.github_repository.fluent-bit-mirror.name
  # We need a default branch not in the main repo to run the sync jobs
  branch = "mirror-main"
}

resource "github_branch_default" "mirror-default-branch" {
  repository = data.github_repository.fluent-bit-mirror.name
  branch     = github_branch.mirror-main-branch.branch
}

# No branch protection or environments supported for the private repos like the mirror

# We only want this for the normal Fluent Bit repository.
locals {
  fluent_bit_protected_branches = [
    data.github_repository.fluentbit.default_branch,
    "1.9",
    "1.8",
  ]
}
resource "github_branch_protection_v3" "default-branch-protection" {
  repository = data.github_repository.fluentbit.name

  for_each = toset(local.fluent_bit_protected_branches)
  branch   = each.value

  enforce_admins = false

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    required_approving_review_count = 1
  }

  required_status_checks {
    strict   = false
    contexts = ["Unit tests (matrix)", "Check Commit Message"]
  }
}

data "github_user" "release-approvers-users" {
  for_each = var.release-approvers-usernames
  username = each.value
}

resource "github_repository_environment" "release-environment" {
  environment = "release"
  repository  = data.github_repository.fluentbit.name
  reviewers {
    users = [for user in data.github_user.release-approvers-users : user.id]
  }
  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }
}

# The packaging server to use:
resource "github_actions_environment_secret" "release-server-hostname" {
  repository      = data.github_repository.fluentbit.name
  environment     = github_repository_environment.release-environment.environment
  secret_name     = "FLUENTBITIO_HOST"
  plaintext_value = var.release-server-hostname
}

resource "github_actions_environment_secret" "release-server-username" {
  repository      = data.github_repository.fluentbit.name
  environment     = github_repository_environment.release-environment.environment
  secret_name     = "FLUENTBITIO_USERNAME"
  plaintext_value = var.release-server-username
}

resource "github_actions_environment_secret" "release-server-sshkey" {
  repository      = data.github_repository.fluentbit.name
  environment     = github_repository_environment.release-environment.environment
  secret_name     = "FLUENTBITIO_SSHKEY"
  plaintext_value = var.release-server-sshkey
}

# The DockerHub details for release
resource "github_actions_environment_secret" "release-dockerhub-username" {
  repository      = data.github_repository.fluentbit.name
  environment     = github_repository_environment.release-environment.environment
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = var.release-dockerhub-username
}

resource "github_actions_environment_secret" "release-dockerhub-token" {
  repository      = data.github_repository.fluentbit.name
  environment     = github_repository_environment.release-environment.environment
  secret_name     = "DOCKERHUB_TOKEN"
  plaintext_value = var.release-dockerhub-token
}
resource "github_actions_environment_secret" "release-dockerhub-org" {
  repository      = data.github_repository.fluentbit.name
  environment     = github_repository_environment.release-environment.environment
  secret_name     = "DOCKERHUB_ORGANIZATION"
  plaintext_value = var.release-dockerhub-org
}

# Cosign signatures for release
resource "github_actions_environment_secret" "release-cosign-private-key" {
  repository      = data.github_repository.fluentbit.name
  environment     = github_repository_environment.release-environment.environment
  secret_name     = "COSIGN_PRIVATE_KEY"
  plaintext_value = var.release-cosign-private-key
}

# AWS credentials
resource "github_actions_environment_secret" "release-bucket-secret" {
  repository      = data.github_repository.fluentbit.name
  environment     = github_repository_environment.release-environment.environment
  secret_name     = "AWS_S3_BUCKET_RELEASE"
  plaintext_value = var.release-s3-bucket
}

# Release needs to take out of staging and into release bucket
resource "github_actions_environment_secret" "release-staging-bucket-secret" {
  repository      = data.github_repository.fluentbit.name
  environment     = github_repository_environment.release-environment.environment
  secret_name     = "AWS_S3_BUCKET_STAGING"
  plaintext_value = var.staging-s3-bucket
}

resource "github_actions_environment_secret" "release-aws-access-key-id-secret" {
  repository      = data.github_repository.fluentbit.name
  environment     = github_repository_environment.release-environment.environment
  secret_name     = "AWS_ACCESS_KEY_ID"
  plaintext_value = var.release-s3-access-id
}

resource "github_actions_environment_secret" "release-aws-secret-access-key-secret" {
  repository      = data.github_repository.fluentbit.name
  environment     = github_repository_environment.release-environment.environment
  secret_name     = "AWS_SECRET_ACCESS_KEY"
  plaintext_value = var.release-s3-secret-access-key
}

resource "github_actions_environment_secret" "release-gpg-private-key-secret" {
  repository      = data.github_repository.fluentbit.name
  environment     = github_repository_environment.release-environment.environment
  secret_name     = "GPG_PRIVATE_KEY"
  plaintext_value = var.release-gpg-key
}

resource "github_actions_environment_secret" "release-gpg-private-key-passphrase-secret" {
  repository      = data.github_repository.fluentbit.name
  environment     = github_repository_environment.release-environment.environment
  secret_name     = "GPG_PRIVATE_KEY_PASSPHRASE"
  plaintext_value = var.release-gpg-key-passphrase
}

resource "github_repository_environment" "staging-environment" {
  environment = "staging"
  repository  = data.github_repository.fluentbit.name
}

resource "github_actions_environment_secret" "staging-bucket-secret" {
  repository      = data.github_repository.fluentbit.name
  environment     = github_repository_environment.staging-environment.environment
  secret_name     = "AWS_S3_BUCKET_STAGING"
  plaintext_value = var.staging-s3-bucket
}

resource "github_actions_environment_secret" "staging-aws-access-key-id-secret" {
  repository      = data.github_repository.fluentbit.name
  environment     = github_repository_environment.staging-environment.environment
  secret_name     = "AWS_ACCESS_KEY_ID"
  plaintext_value = var.staging-s3-access-id
}

resource "github_actions_environment_secret" "staging-aws-secret-access-key-secret" {
  repository      = data.github_repository.fluentbit.name
  environment     = github_repository_environment.staging-environment.environment
  secret_name     = "AWS_SECRET_ACCESS_KEY"
  plaintext_value = var.staging-s3-secret-access-key
}

resource "github_actions_environment_secret" "staging-gpg-private-key-secret" {
  repository      = data.github_repository.fluentbit.name
  environment     = github_repository_environment.staging-environment.environment
  secret_name     = "GPG_PRIVATE_KEY"
  plaintext_value = var.staging-gpg-key
}

resource "github_actions_environment_secret" "staging-gpg-private-key-passphrase-secret" {
  repository      = data.github_repository.fluentbit.name
  environment     = github_repository_environment.staging-environment.environment
  secret_name     = "GPG_PRIVATE_KEY_PASSPHRASE"
  plaintext_value = var.staging-gpg-key-passphrase
}

resource "github_actions_secret" "appveyor_token" {
  repository      = data.github_repository.fluentbit.name
  secret_name     = "APPVEYOR_TOKEN"
  plaintext_value = var.appveyor_token
}

resource "github_actions_secret" "appveyor_account" {
  repository      = data.github_repository.fluentbit.name
  secret_name     = "APPVEYOR_ACCOUNT"
  plaintext_value = var.appveyor_account
}

# For the mirror we need release environment secrets but as full-blown repository secrets
# as private repos do not support without Github Enterprise.
# We unfortunately cannot splat them all together dynamically either:
# https://github.com/hashicorp/terraform/issues/19931
# Potentially we could do a post processing state list: https://www.terraform.io/cli/commands/state/list
# To keep it simple we just list them.
# We may need staging secrets separately if we want to sign with a different key or use different S3 access.
locals {
  mirror-release-secrets = [
    github_actions_environment_secret.release-server-hostname,
    github_actions_environment_secret.release-server-username,
    github_actions_environment_secret.release-server-sshkey,
    github_actions_environment_secret.release-dockerhub-username,
    github_actions_environment_secret.release-dockerhub-token,
    github_actions_environment_secret.release-dockerhub-org,
    github_actions_environment_secret.release-cosign-private-key,
    github_actions_environment_secret.release-bucket-secret,
    github_actions_environment_secret.release-staging-bucket-secret,
    github_actions_environment_secret.release-aws-secret-access-key-secret,
    github_actions_environment_secret.release-gpg-private-key-secret,
    github_actions_environment_secret.release-gpg-private-key-passphrase-secret
  ]
}

resource "github_actions_secret" "mirror-release-secrets" {
  for_each = { for secret in local.mirror-release-secrets : secret.secret_name => secret }

  repository      = data.github_repository.fluent-bit-mirror.name
  secret_name     = each.key
  plaintext_value = each.value.plaintext_value
}

# Primarily to resolve https://github.com/fluent/fluent-bit/discussions/5160 by moving
# pre-releases to a separate repository until Github resolve the issue.
resource "github_repository" "fluent-bit-unstable-releases" {
  name        = "fluent-bit-unstable-releases"
  description = "A repository to handle Fluent Bit releases that are not official to reduce notification spam."

  archive_on_destroy     = true
  delete_branch_on_merge = true
  vulnerability_alerts   = true
  has_issues             = false
  has_projects           = false
  has_wiki               = false
  homepage_url           = "https://fluentbit.io"
  auto_init              = true
  license_template       = "apache-2.0"
}

resource "github_branch" "fluent-bit-unstable-releases" {
  repository = github_repository.fluent-bit-unstable-releases.name
  branch     = "main"
}

resource "github_branch_default" "fluent-bit-unstable-releases" {
  repository = github_repository.fluent-bit-unstable-releases.name
  branch     = github_branch.fluent-bit-unstable-releases.branch
}

# No one should be merging
resource "github_branch_protection_v3" "fluent-bit-unstable-releases" {
  repository     = github_repository.fluent-bit-unstable-releases.name
  branch         = github_branch.fluent-bit-unstable-releases.branch
  enforce_admins = false

  restrictions {
    users = []
    teams = []
    apps  = []
  }
}

resource "github_repository_environment" "unstable-environment" {
  environment = "unstable"
  repository  = data.github_repository.fluentbit.name
}

# Create necessary secrets for publishing pre-releases from unstable and staging environments
resource "github_actions_environment_secret" "unstable-release-repos" {
  for_each    = toset([github_repository_environment.unstable-environment.environment, github_repository_environment.staging-environment.environment])
  environment = each.key

  repository      = data.github_repository.fluentbit.name
  secret_name     = "RELEASE_REPO"
  plaintext_value = github_repository.fluent-bit-unstable-releases.full_name
}

resource "github_actions_environment_secret" "unstable-release-tokens" {
  for_each    = toset([github_repository_environment.unstable-environment.environment, github_repository_environment.staging-environment.environment])
  environment = each.key

  repository      = data.github_repository.fluentbit.name
  secret_name     = "RELEASE_TOKEN"
  plaintext_value = var.unstable-release-token
}

# Create the needed secrets for fluent-bit and fluent-bit-ci repositories
resource "github_actions_secret" "fluent-bit-ci-opensearch-aws-access-id" {
  for_each        = toset([for repo in local.repos_with_opensearch_aws_access : repo.id])
  repository      = each.key
  secret_name     = "OPENSEARCH_AWS_ACCESS_ID"
  plaintext_value = var.fluent-bit-ci-opensearch-aws-access-id
}

resource "github_actions_secret" "fluent-bit-ci-opensearch-aws-secret-key" {
  for_each        = toset([for repo in local.repos_with_opensearch_aws_access : repo.id])
  repository      = each.key
  secret_name     = "OPENSEARCH_AWS_SECRET_KEY"
  plaintext_value = var.fluent-bit-ci-opensearch-aws-secret-key
}

resource "github_actions_secret" "fluent-bit-ci-opensearch-password" {
  for_each        = toset([for repo in local.repos_with_opensearch_aws_access : repo.id])
  repository      = each.key
  secret_name     = "OPENSEARCH_ADMIN_PASSWORD"
  plaintext_value = var.fluent-bit-ci-opensearch-admin-password
}

resource "github_team" "fluent-bit-sandbox-maintainers" {
  name        = "fluent-bit-sandbox-maintainers"
  description = "The maintainers team for Fluent Bit Sandbox. Only modify via Terraform."
  privacy     = "closed"
}

resource "github_team_membership" "fluent-bit-sandbox-maintainers" {
  for_each = var.fluent-bit-sandbox-maintainers

  team_id  = github_team.fluent-bit-sandbox-maintainers.id
  username = each.value
  role     = "member"
}

resource "github_repository" "fluent-bit-sandbox" {
  name        = "fluent-bit-sandbox"
  description = "A repository to covering the setup and configuration of the Fluent Bit Sandbox."

  archive_on_destroy     = true
  delete_branch_on_merge = true
  vulnerability_alerts   = true
  has_issues             = true
  has_projects           = true
  has_wiki               = true
  homepage_url           = "https://fluentbit.io"
  auto_init              = true
  license_template       = "apache-2.0"
}

resource "github_branch" "fluent-bit-sandbox" {
  repository = github_repository.fluent-bit-sandbox.name
  branch     = "main"
}

resource "github_branch_default" "fluent-bit-sandbox" {
  repository = github_repository.fluent-bit-sandbox.name
  branch     = github_branch.fluent-bit-sandbox.branch
}

resource "github_branch_protection_v3" "fluent-bit-sandbox" {
  repository     = github_repository.fluent-bit-sandbox.name
  branch         = github_branch.fluent-bit-sandbox.branch
  enforce_admins = false

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    required_approving_review_count = 1
  }

  restrictions {
    teams = [github_team.fluent-bit-sandbox-maintainers.slug]
  }
}

resource "github_team_repository" "fluent-bit-sandbox-maintainers" {
  team_id    = github_team.fluent-bit-sandbox-maintainers.id
  repository = github_repository.fluent-bit-sandbox.name
  permission = "maintain"
}

resource "github_actions_secret" "fluent-bit-ci-azure-client-id" {
  for_each        = toset([for repo in local.repos_with_azure_access : repo.id])
  repository      = each.key
  secret_name     = "AZURE_CLIENT_ID"
  plaintext_value = var.fluent-bit-ci-azure-client-id
}

resource "github_actions_secret" "ffluent-bit-ci-azure-client-secret" {
  for_each        = toset([for repo in local.repos_with_azure_access : repo.id])
  repository      = each.key
  secret_name     = "AZURE_CLIENT_SECRET"
  plaintext_value = var.fluent-bit-ci-azure-client-secret
}

resource "github_actions_secret" "fluent-bit-ci-azure-subscription-id" {
  for_each        = toset([for repo in local.repos_with_azure_access : repo.id])
  repository      = each.key
  secret_name     = "AZURE_SUBSCRIPTION_ID"
  plaintext_value = var.fluent-bit-ci-azure-subscription-id
}

resource "github_actions_secret" "fluent-bit-ci-azure-tenant-id" {
  for_each        = toset([for repo in local.repos_with_azure_access : repo.id])
  repository      = each.key
  secret_name     = "AZURE_TENANT_ID"
  plaintext_value = var.fluent-bit-ci-azure-tenant-id
}
