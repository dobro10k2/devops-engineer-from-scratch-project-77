terraform {
  required_version = ">= 1.5.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.100.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.0"
    }
    # Добавляем недостающий провайдер local
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0.0"
    }
  }
}
