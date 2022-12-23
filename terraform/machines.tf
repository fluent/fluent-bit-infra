locals {
  project_id = var.metal_net_project_id
}

data "metal_device" "legacy_www" {
  project_id = local.project_id
  hostname   = "fluentbit.io"
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
  machines = zipmap(["arm64", "x64"], ["c3.large.arm", "c3.medium.x86"])
}

# Ensure we have an SSH key set up we can use
resource "tls_private_key" "gh-runner-provision-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "metal_ssh_key" "gh-runner-provision-ssh-pub-key" {
  name       = "gh-runner-provision-ssh-pub-key"
  public_key = chomp(tls_private_key.gh-runner-provision-key.public_key_openssh)
}

resource "metal_device" "gh-runners" {
  for_each = local.machines

  hostname         = "runner-${each.key}.fluentbit.io"
  plan             = each.value
  metro            = "da"
  operating_system = "ubuntu_20_04"
  billing_cycle    = "hourly"
  project_id       = local.project_id
  tags             = [each.key, "github-runner"] # we use this for the key data
  user_data        = file("provision/user-data.sh")
  depends_on       = [metal_ssh_key.gh-runner-provision-ssh-pub-key]
  connection {
    host     = self.access_public_ipv4
    password = self.root_password
  }
}

# We provision them as Github runners here as directly related to machine creation
resource "null_resource" "gh-runners-provision" {
  for_each = metal_device.gh-runners
  triggers = {
    public_ip   = each.value.access_public_ipv4
    private_key = chomp(tls_private_key.gh-runner-provision-key.private_key_pem)
    # Following are required to be referenced via `self` for destroy phase
    github_token = var.github_token
    repo         = data.github_repository.fluent-bit-mirror.full_name
  }
  connection {
    host        = self.triggers.public_ip
    private_key = self.triggers.private_key
  }

  provisioner "file" {
    source      = "provision/github-runner.create.sh"
    destination = "/tmp/provision-github-runner.create.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision-github-runner.create.sh",
      "sudo -i -u provisioner bash /tmp/provision-github-runner.create.sh -l ${each.value.tags[0]} -t ${self.triggers.github_token} -r ${self.triggers.repo} -v ${var.github_runner_version}",
    ]
  }

  provisioner "file" {
    when        = destroy
    source      = "provision/github-runner.destroy.sh"
    destination = "/tmp/provision-github-runner.destroy.sh"
    # Ignore failures, e.g. resource was deleted so cannot SSH to it
    on_failure = continue
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "chmod +x /tmp/provision-github-runner.destroy.sh",
      "sudo -i -u provisioner bash /tmp/provision-github-runner.destroy.sh -t ${self.triggers.github_token} -r ${self.triggers.repo}",
    ]
    # Ignore failures, e.g. resource was deleted so cannot SSH to it
    on_failure = continue
  }
}

resource "tls_private_key" "packages-fluent-bit-provision-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "equinix_metal_ssh_key" "packages-fluent-bit-provision-ssh-pub-key" {
  name       = "packages-fluent-bit-provision-ssh-pub-key"
  public_key = chomp(tls_private_key.packages-fluent-bit-provision-key.public_key_openssh)
}

resource "equinix_metal_device" "packages-fluent-bit" {
  hostname         = "packages-managed.fluentbit.io"
  plan             = "c3.small.x86"
  metro            = "da"
  operating_system = "ubuntu_20_04"
  billing_cycle    = "hourly"
  project_id       = local.project_id
  user_data        = <<EOF
#cloud-config
package_update: true
packages:
  - docker.io
  - nginx
  - awscli
  - git
EOF
  depends_on       = [equinix_metal_ssh_key.packages-fluent-bit-provision-ssh-pub-key]
  connection {
    host     = self.access_public_ipv4
    password = self.root_password
  }
}

resource "null_resource" "packages-fluent-bit-provision" {

  depends_on = [
    equinix_metal_ssh_key.packages-fluent-bit-provision-ssh-pub-key,
    equinix_metal_device.packages-fluent-bit,
  ]
  triggers = {
    public_ip   = equinix_metal_device.packages-fluent-bit.access_public_ipv4
    private_key = chomp(equinix_metal_ssh_key.packages-fluent-bit-provision-ssh-pub-key)
  }
  connection {
    host        = self.triggers.public_ip
    private_key = self.triggers.private_key
  }

  provisioner "file" {
    source      = "provision/package-server-provision.sh"
    destination = "/tmp/provision-package-server-provision.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision-package-server-provision.sh",
      "sudo -i -u provisioner bash /tmp/provision-package-server-provision.sh",
    ]
  }
}
