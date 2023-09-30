terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

#создаем облачную сеть
resource "yandex_vpc_network" "net" {
  name = var.env_name
}

#создаем подсеть
resource "yandex_vpc_subnet" "subnet" {
  name           = var.subnet_name
  zone           = var.subnet_zone
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = [var.subnet_v4_cidr_blocks]
}