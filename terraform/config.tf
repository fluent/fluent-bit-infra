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
      version = "4.5.2"
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