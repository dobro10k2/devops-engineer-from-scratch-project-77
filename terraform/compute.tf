data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

locals {
  vms = {
    "infra-node" = { cores = 2, memory = 2, fraction = 5 }
    "app-node-1" = { cores = 2, memory = 2, fraction = 5 }
    "app-node-2" = { cores = 2, memory = 2, fraction = 5 }
  }
}

resource "yandex_compute_instance" "docker_nodes" {
  for_each = local.vms

  name = each.key
  zone = "ru-central1-a"

  resources {
    cores         = each.value.cores
    memory        = each.value.memory
    core_fraction = each.value.fraction
  }

  allow_stopping_for_update = true

  scheduling_policy {
    preemptible = false
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 15
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.app_subnet_a.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.cluster_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}
