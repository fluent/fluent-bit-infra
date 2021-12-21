data "github_repository" "fluentbit" {
  full_name = var.repo_full_name
}
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

  depends_on = [data.github_repository.fluentbit]
}

data "github_user" "release-approvers-users" {
    for_each = var.release-approvers-usernames
    username = each.value
}

resource "github_repository_environment" "release-environment" {
  environment  = "release"
  repository   = data.github_repository.fluentbit.name
  reviewers {
    users = [ for user in data.github_user.release-approvers-users: user.id ]
  }
  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }

  depends_on = [data.github_repository.fluentbit]
}

resource "github_actions_environment_secret" "release-bucket-secret" {
  repository       = data.github_repository.fluentbit.name
  environment      = github_repository_environment.release-environment.environment
  secret_name      = "AWS_S3_BUCKET_RELEASE"
  plaintext_value  = var.release-s3-bucket
}

resource "github_repository_environment" "staging-environment" {
  environment  = "staging"
  repository   = data.github_repository.fluentbit.name
  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }

  depends_on = [data.github_repository.fluentbit]
}

resource "github_actions_environment_secret" "staging-bucket-secret" {
  repository       = data.github_repository.fluentbit.name
  environment      = github_repository_environment.staging-environment.environment
  secret_name      = "AWS_S3_BUCKET_STAGING"
  plaintext_value  = var.staging-s3-bucket
}

resource "github_actions_environment_secret" "staging-aws-access-key-id-secret" {
  repository       = data.github_repository.fluentbit.name
  environment      = github_repository_environment.staging-environment.environment
  secret_name      = "AWS_ACCESS_KEY_ID"
  plaintext_value  = var.staging-s3-access-id
}

resource "github_actions_environment_secret" "staging-aws-secret-access-key-secret" {
  repository       = data.github_repository.fluentbit.name
  environment      = github_repository_environment.staging-environment.environment
  secret_name      = "AWS_SECRET_ACCESS_KEY"
  plaintext_value  = var.staging-s3-secret-access-key
}

resource "github_actions_environment_secret" "staging-gpg-private-key-secret" {
  repository       = data.github_repository.fluentbit.name
  environment      = github_repository_environment.staging-environment.environment
  secret_name      = "GPG_PRIVATE_KEY"
  plaintext_value  = var.staging-gpg-key
}
