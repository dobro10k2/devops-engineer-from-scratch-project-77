provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://api.datadoghq.eu/"
}

# Сам Alert (Монитор), который проверяет доступность
resource "datadog_monitor" "redmine_availability" {
  name    = "Redmine is DOWN on {{host.name}}"
  type    = "service check"
  query   = "\"http.can_connect\".over(\"instance:redmine_check\").by(\"host\").last(3).count_by_status()"
  message = "Внимание! Приложение недоступно. Упал HTTP check на хосте {{host.name}}."

  tags = ["project:hexlet-7", "service:redmine"]

  # Выносим настройки из options в корень ресурса
  notify_audit      = false
  timeout_h         = 0
  no_data_timeframe = 10

  # Блок пороговых значений в Terraform называется monitor_thresholds
  monitor_thresholds {
    critical = 1
    warning  = 1
    ok       = 1
  }
}
