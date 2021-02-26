locals {
  project_id = var.packet_net_project_id
}

data "packet_device" "builder" {
  project_id = local.project_id
  hostname   = "builder.fluentbit.io"
}

data "packet_device" "dev-arm" {
  project_id = local.project_id
  hostname   = "dev-arm.fluentbit.io"
}

data "packet_device" "www" {
  project_id = local.project_id
  hostname   = "fluentbit.io"
}

data "packet_device" "perf-test" {
  project_id = local.project_id
  hostname   = "perf-test.fluentbit.io"
}
