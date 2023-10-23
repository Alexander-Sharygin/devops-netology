locals {
  sshkey = "root:${ file("/root/.ssh/id_rsa.pub") }"
}
