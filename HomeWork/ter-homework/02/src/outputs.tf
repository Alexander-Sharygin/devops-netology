output "db-ext_ip" {
  value = yandex_compute_instance.platform-db.network_interface[0].nat_ip_address
}

output "web-ext_ip" {
  value = yandex_compute_instance.platform.network_interface[0].nat_ip_address
}

