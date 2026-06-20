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
