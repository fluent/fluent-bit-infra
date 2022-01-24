# fluent-bit-infra

Automation related to fluent-bit infrastructure 

# changes

Changes are managed by (PRs), the required votes (+1)  should pass together
with the terraform checks (lint/fmt/validate).

## Adding repositories

To add Github repositories do this manually via the `fluent` organization with appropriate privileges in Github.
Once complete, make sure to import them as `github_repository.XXX` items under Terraform to then manage the rest.
Terraform is not used for repository creation, only management after that.

## adding domains

For adding domains, edit terraform/domains.tf with the required subdomain changes
and submit a PR.

## adding packet managed machines

For adding machines, edit terraform/machines.tf with the name of the machines to
be imported from packet API.

# credentials

Currently managed secrets are:

```yaml
TF_API_TOKEN
CLOUDFLARE_TOKEN
PACKET_NET_TOKEN
```
