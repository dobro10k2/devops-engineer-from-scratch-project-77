terraform {
  backend "s3" {
    endpoint = "https://storage.yandexcloud.net"
    bucket   = "hexlet-state-bucket-dobro10k2"
    region   = "ru-central1"
    key      = "terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}
