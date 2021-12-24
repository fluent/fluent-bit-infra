locals {
  project_id = var.metal_net_project_id
}

data "metal_device" "builder" {
  project_id = local.project_id
  hostname   = "builder.fluentbit.io"
}

data "metal_device" "dev-arm" {
  project_id = local.project_id
  hostname   = "dev-arm.fluentbit.io"
}

data "metal_device" "www" {
  project_id = local.project_id
  hostname   = "fluentbit.io"
}

data "metal_device" "perf-test" {
  project_id = local.project_id
  hostname   = "perf-test.fluentbit.io"
}

provider "google" {
  project     = var.gcp-project-id
  region      = var.gcp-default-region
  credentials = var.gcp-sa-key
}

resource "google_compute_network" "default-services" {
  name                    = "default-public-svc-network"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "default-services-subnet" {
  name          = "default-public-svc-subnet"
  ip_cidr_range = "192.168.1.0/24"
  network       = google_compute_network.default-services.self_link
  region        = var.gcp-default-region
}

resource "google_compute_firewall" "ssh_default" {
  name    = "default-public-svc-ssh"
  network = google_compute_network.default-services.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["public-ssh"]
}

resource "google_compute_address" "static" {
  name = "ipv4-address"
}

resource "google_compute_address" "static-01" {
  name = "ipv4-address-01"
}

resource "google_compute_disk" "test-data" {
  name = "test-data"
  type = "pd-ssd"
  zone = var.gcp-default-zone
  size = "4000"
}

resource "google_compute_disk" "test-data-01" {
  name = "test-data-01"
  type = "pd-ssd"
  zone = var.gcp-default-zone
  size = "500"
}

resource "google_compute_instance" "long-running-test-01" {
  name         = "long-running-test-01"
  machine_type = var.gcp-default-machine-type
  zone         = var.gcp-default-zone

  tags                      = ["public-ssh"]
  allow_stopping_for_update = true
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 200
    }
  }

  attached_disk {
    source = google_compute_disk.test-data-01.self_link
  }

  network_interface {
    subnetwork = google_compute_subnetwork.default-services-subnet.name
    access_config {
      nat_ip = google_compute_address.static-01.address
    }
  }

  metadata = {
    ssh-keys  = join("\n", [for user, key in var.gcp-ssh-keys : "${user}:${key}"])
    user-data = <<EOF
#cloud-config
package_update: true
packages:
  - docker-compose
disk_setup:
  /dev/sdb:
     table_type: 'gpt'
     layout: True
     overwrite: True
fs_setup:
  - label: None
    filesystem: 'ext4'
    device: '/dev/sdb'
    partition: 'auto'
mounts:
- [ sdb, /data ]
EOF
  }

  lifecycle {
    ignore_changes = [attached_disk]
  }
}

resource "google_compute_instance" "long-running-test" {
  name                      = "long-running-test"
  machine_type              = var.gcp-default-machine-type
  zone                      = var.gcp-default-zone
  allow_stopping_for_update = true

  tags = ["public-ssh"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 200
    }
  }

  attached_disk {
    source = google_compute_disk.test-data.self_link
  }

  network_interface {
    subnetwork = google_compute_subnetwork.default-services-subnet.name
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  metadata = {
    ssh-keys  = join("\n", [for user, key in var.gcp-ssh-keys : "${user}:${key}"])
    user-data = <<EOF
#cloud-config
package_update: true
packages:
  - docker-compose
disk_setup:
  /dev/sdb:
     table_type: 'gpt'
     layout: True
     overwrite: True
fs_setup:
  - label: None
    filesystem: 'ext4'
    device: '/dev/sdb'
    partition: 'auto'
mounts:
- [ sdb, /data ]
EOF
  }

  lifecycle {
    ignore_changes = [attached_disk]
  }
}

output "gcp-long-running-instance-ipv4" {
  value = google_compute_address.static.address
}

output "gcp-long-running-instance-01-ipv4" {
  value = google_compute_address.static-01.address
}

# Add staging build and test machines
locals {
  machines = toset(["arm,x86"])
}
resource "metal_device" "gh-runners" {
  for_each = local.machines

  hostname         = "runner-${each.key}.fluentbit.io"
  plan             = "c3.large.arm"
  metro            = "sv"
  operating_system = "ubuntu_20_04"
  billing_cycle    = "monthly"
  project_id       = local.project_id
  custom_data      = "${each.key}"
  user_data        = file("provision/user-data.sh")
  connection {
    host     = self.access_public_ipv4
    password = self.root_password
  }
}

# We provision them as Github runners here as directly related to machine creation
resource "null_resource" "gh-runners-provision" {
  count = length(metal_device.gh-runners)
  triggers = {
    public_ip    = metal_device.gh-runners[count.index].access_public_ipv4
    password     = metal_device.gh-runners[count.index].root_password
    # Following are required to be referenced via `self` for destroy phase
    github_token = var.github_token
    repo         = var.repo_full_name
  }
  provisioner "file" {
    source      = "provision/github-runner.create.sh"
    destination = "/tmp/provision-github-runner.create.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision-github-runner.create.sh",
      "sudo -i -u user bash /tmp/provision-github-runner.create.sh -l ${local.machines[count.index]} -t ${self.triggers.github_token} -o calyptia -r ${self.triggers.repo} -v ${var.github_runner_version}",
    ]
  }

  provisioner "file" {
    when        = destroy
    source      = "provision/github-runner.destroy.sh"
    destination = "/tmp/provision-github-runner.destroy.sh"
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "chmod +x /tmp/provision-github-runner.destroy.sh",
      "sudo -i -u user bash /tmp/provision-github-runner.destroy.sh -t ${self.triggers.github_token} -o calyptia -r ${self.triggers.repo}",
    ]
  }
}