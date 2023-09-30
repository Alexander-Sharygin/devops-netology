output "network_id" {
  description = "Network ID"
  value       = yandex_vpc_network.net.id
}

output "subnet_ids" {
  description = "Subnets IDs"
  value       = yandex_vpc_subnet.subnet.id
}
