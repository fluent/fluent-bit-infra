# fluent-bit-infra

Automation related to fluent-bit infrastructure 

# changes

Changes are managed by (PRs), the required votes (+1)  should pass together
with the terraform checks (lint/fmt/validate).

# credentials

Currently managed secrets are:

```yaml
TF_API_TOKEN
CLOUDFLARE_TOKEN
PACKET_NET_TOKEN
```
