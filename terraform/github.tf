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
    strict   = false
    contexts = ["Unit tests (matrix)", "Check Commit Message"]
  }

  depends_on = [data.github_repository.fluentbit]
}

# Create local values to retrieve items from CSVs
locals {
  # Parse team member files
  team_members_path = "team-members"
  team_members_files = {
    for file in fileset(local.team_members_path, "*.csv") :
    trimsuffix(file, ".csv") => csvdecode(file("${local.team_members_path}/${file}"))
  }
  # Create temp object that has team ID and CSV contents
  team_members_temp = flatten([
    for team, members in local.team_members_files : [
      for tn, t in github_team.all : {
        name    = t.name
        id      = t.id
        slug    = t.slug
        members = members
      } if t.slug == team
    ]
  ])

  # Create object for each team-user relationship
  team_members = flatten([
    for team in local.team_members_temp : [
      for member in team.members : {
        name     = "${team.slug}-${member.username}"
        team_id  = team.id
        username = member.username
        role     = member.role
      }
    ]
  ])
}

resource "github_team" "all" {
    for_each = {
        for team in csvdecode(file("calyptia/teams.csv")) :
        team.name => team
    }

    name                      = each.value.name
    description               = each.value.description
    privacy                   = each.value.privacy
    # adds the creating user to the team
    create_default_maintainer = true
}

resource "github_team_membership" "members" {
    for_each = { for tm in local.team_members : tm.name => tm }

    team_id  = each.value.team_id
    username = each.value.username
    role     = each.value.role
}

resource "github_team_repository" "fluentbit_repo_team_mapping" {
  repository = data.github_repository.fluentbit.name

  for_each = {
    for team in github_team.all :
    team.team_name => {
      team_id    = github_team.all[team.team_name].id
      permission = team.permission
    }
  }

  team_id    = each.value.team_id
  permission = each.value.permission
}

resource "github_repository_environment" "release-environment" {
  environment  = "release"
  repository   = data.github_repository.fluentbit.name
  reviewers {
    teams = [github_team.all["Release Approvers Team"].id]
  }
  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = false
  }

  depends_on = [data.github_repository.fluentbit]
}

resource "github_actions_environment_secret" "release-bucket-secret" {
  repository       = data.github_repository.fluentbit.name
  environment      = github_repository_environment.release-environment.environment
  secret_name      = "S3_BUCKET_NAME_RELEASE"
  plaintext_value  = var.release-s3-bucket
}

resource "github_repository_environment" "staging-environment" {
  environment  = "staging"
  repository   = data.github_repository.fluentbit.name
  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = false
  }

  depends_on = [data.github_repository.fluentbit]
}

resource "github_actions_environment_secret" "staging-bucket-secret" {
  repository       = data.github_repository.fluentbit.name
  environment      = github_repository_environment.staging-environment.environment
  secret_name      = "S3_BUCKET_NAME_STAGING"
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
