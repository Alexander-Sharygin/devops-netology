resource "yandex_compute_instance" "platform_task2" {
  depends_on = [yandex_compute_instance.platform]
  for_each = {for i in var.vm_resources_task2 : i.vm_name => i}
  name        = each.value.vm_name
  platform_id = var.vm_web_platform_id
  resources {
    cores         = each.value.cpu
    memory        = each.value.ram
    core_fraction = each.value.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = each.value.disk
    }
  }
  scheduling_policy {
    preemptible = var.vm_all_scheduling_policy
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = var.vm_all_network_interface_nat
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  metadata = {
    sshkey = local.sshkey
  }
}
