resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/ansible.tftpl",
    { webservers =  yandex_compute_instance.platform,
      database = yandex_compute_instance.platform_task2,
      storage = yandex_compute_instance.platform-task3
    })
  filename = "${abspath(path.module)}/hosts.cfg"
}