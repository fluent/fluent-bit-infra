data "github_repository" "fluentbit" {
  full_name = var.repo_full_name
}

# resource "github_repository" "fluent-bit-mirror" {
#   name        = "fluent-bit-mirror"
#   description = "A private mirror of Fluent Bit purely to mitigate security concerns of using self-hosted runners."

#   visibility = "private"

#   archive_on_destroy     = true
#   delete_branch_on_merge = true
#   vulnerability_alerts   = true
# }
data "github_repository" "fluent-bit-mirror" {
  full_name = "fluent/fluent-bit-mirror"
}

resource "github_branch" "mirror-main-branch" {
  repository = data.github_repository.fluent-bit-mirror.name
  # We need a default branch not in the main repo to run the sync jobs
  branch     = "mirror-main"
}

resource "github_branch_default" "mirror-default-branch"{
  repository = data.github_repository.fluent-bit-mirror.name
  branch     = github_branch.mirror-main-branch.branch
}

# No branch protection or environments supported for the private repos like the mirror

# We only want this for the normal Fluent Bit repository.
resource "github_branch_protection_v3" "default-branch-protection" {
  repository     = data.github_repository.fluentbit.name
  branch         = data.github_repository.fluentbit.default_branch
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
    users = [ for user in data.github_user.release-approvers-users: user.id ]
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

resource "github_repository_environment" "staging-environment" {
  environment = "staging"
  repository      = data.github_repository.fluentbit.name
  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }
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
    github_actions_environment_secret.release-gpg-private-key-secret
  ]
}

resource "github_actions_secret" "mirror-release-secrets" {
  for_each = { for secret in local.mirror-release-secrets: secret.secret_name => secret }

  repository      = data.github_repository.fluent-bit-mirror
  secret_name     = each.key
  encrypted_value = each.value.encrypted_value
}