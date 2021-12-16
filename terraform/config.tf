terraform {
  required_providers {
    packet = {
      source  = "packethost/packet"
      version = "3.2.1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "2.18.0"
    }
    github = {
      source  = "integrations/github"
      version = "4.19.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "3.59.0"
    }
  }
  backend "remote" {
    organization = "calyptia"
    hostname     = "app.terraform.io"

    workspaces {
      name = "fluent-bit-infra"
    }
  }
}

provider "cloudflare" {
  email     = var.cloudflare_email
  api_token = var.cloudflare_token
}

provider "packet" {
  auth_token = var.packet_net_token
}

# Configure the GitHub Provider
provider "github" {
  token        = var.github_token
  owner        = var.github_owner
  organization = "fluent"
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