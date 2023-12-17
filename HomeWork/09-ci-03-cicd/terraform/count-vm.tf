#data "yandex_compute_image" "" {
#  family = xvar.image_family
#}
resource "yandex_compute_instance" "cicd" {
  count = 2
  name        = "cicd-0${count.index+1}"
  platform_id = var.vm_platform_id
  resources {
    cores         = var.vm_resources.web.cores
    memory        = var.vm_resources.web.memory
    core_fraction = var.vm_resources.web.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_all_scheduling_policy
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = var.vm_all_network_interface_nat
  }

  metadata = {
    ssh-keys = local.sshkey
  }
}

