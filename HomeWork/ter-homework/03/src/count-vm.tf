##vm_web
data "yandex_compute_image" "ubuntu" {
  family = var.image_family
}
resource "yandex_compute_instance" "platform" {
  count = 2
  name        = "web-${count.index+1}"
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
  scheduling_policy {
    preemptible = var.vm_all_scheduling_policy
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = var.vm_all_network_interface_nat
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  metadata = {
    ssh-keys = local.sshkey
  }
}
