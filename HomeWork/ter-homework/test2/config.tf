data template_file "cloud-init" {
  template = file("./cloud-init.yml")

  vars = {
    ssh_public_key = file(var.ssh_public_key)
  }
}
