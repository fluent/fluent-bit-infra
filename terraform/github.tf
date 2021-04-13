data "github_repository" "fluentbit" {
  full_name = "fluent/fluent-bit"
}

resource "github_branch_protection_v3" "default-branch-protection" {

  repository = data.github_repository.fluentbit.name
  branch     = data.github_repository.fluentbit.default_branch

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    required_approving_review_count = 1
  }

  depends_on = [data.github_repository.fluentbit]
}