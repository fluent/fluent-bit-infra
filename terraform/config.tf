terraform {
  required_providers {
    metal = {
      source  = "equinix/metal"
      version = "~> 3.3"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.21"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.31"
    }
    equinix = {
      source = "equinix/equinix"
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
  api_token = var.cloudflare_token
}

provider "metal" {
  auth_token = var.metal_token
}

# Configure the GitHub Provider
provider "github" {
  token = var.github_token
  owner = var.github_owner
}
