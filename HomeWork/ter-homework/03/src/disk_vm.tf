resource "yandex_compute_disk" "empty-disk" {
  count = 3
  name       = "empty-disk-${count.index}"
  type       = "network-hdd"
  zone       = var.default_zone
  size       = 1
}

resource "yandex_compute_instance" "platform-task3" {
  name        = "storage"
  platform_id = var.vm_web_platform_id
  resources {
    cores         = var.vm_resources.web.cores
    memory        = var.vm_resources.web.memory
    core_fraction = var.vm_resources.web.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
    dynamic "secondary_disk" {
    for_each = yandex_compute_disk.empty-disk[*].id
    content {
      disk_id     = secondary_disk.value
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
