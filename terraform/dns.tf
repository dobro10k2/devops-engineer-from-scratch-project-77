# Создаем публичную DNS-зону в Yandex Cloud
resource "yandex_dns_zone" "main" {
  name        = "hex-infra-zone"
  description = "Public DNS zone for hex-infra.ru"

  # Обязательно с точкой на конце!
  zone   = "hex-infra.ru."
  public = true
}

# Создаем A-запись, которая направит домен на наш балансировщик (infra-node)
resource "yandex_dns_recordset" "a_record" {
  zone_id = yandex_dns_zone.main.id

  # Тоже с точкой на конце
  name = "hex-infra.ru."
  type = "A"
  ttl  = 300

  # Берем публичный IP-адрес infra-node прямо из стейта Terraform
  data = [yandex_compute_instance.docker_nodes["infra-node"].network_interface[0].nat_ip_address]
}
