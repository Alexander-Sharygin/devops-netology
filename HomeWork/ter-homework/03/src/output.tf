output "vm" {
  description = "Information about the created virtual machines"
  value = [
    for i in concat(yandex_compute_instance.platform, values(yandex_compute_instance.platform_task2), [yandex_compute_instance.platform-task3]) : {
      name = i.name
      id = i.id
      fqdn = i.fqdn
    }
  ]
}