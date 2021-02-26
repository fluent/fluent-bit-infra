# fluent-bit-infra

Automation related to fluent-bit infrastructure 

# changes

Changes are managed by (PRs), the required votes (+1)  should pass together
with the terraform checks (lint/fmt/validate).

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
