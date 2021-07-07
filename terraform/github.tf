data "github_repository" "fluentbit" {
  full_name = "fluent/fluent-bit"
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
    strict   = true
    contexts = ["Unit tests (matrix)", "Check Commit Message"]
  }

  depends_on = [data.github_repository.fluentbit]
}
