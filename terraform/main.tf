# Main Terraform configuration file
# Resources are defined in separate files:
# - compute.tf
# - network.tf
# - dns.tf
# - datadog.tf
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
resource "yandex_vpc_network" "app_network" {
  name = "docker-cluster-network"
}

resource "yandex_vpc_subnet" "app_subnet_a" {
  name           = "docker-cluster-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.app_network.id
  v4_cidr_blocks = ["10.10.0.0/24"]
}

resource "yandex_vpc_security_group" "cluster_sg" {
  name       = "docker-cluster-sg"
  network_id = yandex_vpc_network.app_network.id

  # Разрешаем SSH отовсюду
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  # Разрешаем HTTP отовсюду для балансировщика
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  # Разрешаем HTTPS (443) отовсюду для защищенного доступа
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  # Разрешаем ICMP (эхо-запросы), чтобы работал ping домена и серверов
  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Разрешаем любой трафик между машинами ВНУТРИ этой Security Group
  ingress {
    protocol          = "ANY"
    predefined_target = "self_security_group"
  }

  # Разрешаем весь исходящий трафик в интернет
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}
