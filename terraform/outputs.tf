output "nodes_public_ips" {
  description = "Публичные IP адреса серверов для Ansible inventory"
  value = {
    for name, instance in yandex_compute_instance.docker_nodes :
    name => instance.network_interface[0].nat_ip_address
  }
}

output "nodes_private_ips" {
  description = "Внутренние IP адреса серверов"
  value = {
    for name, instance in yandex_compute_instance.docker_nodes :
    name => instance.network_interface[0].ip_address
  }
}

# Добавляем генерацию файла inventory.ini для Ansible
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tftpl", {
    # Передаем публичные IP
    nodes = {
      for name, instance in yandex_compute_instance.docker_nodes :
      name => instance.network_interface[0].nat_ip_address
    },
    # Передаем приватные IP
    private_ips = {
      for name, instance in yandex_compute_instance.docker_nodes :
      name => instance.network_interface[0].ip_address
    }
  })

  filename = "${path.module}/../ansible/inventory.ini"
}
