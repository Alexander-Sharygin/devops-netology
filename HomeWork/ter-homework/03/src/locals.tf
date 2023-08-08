locals {
  sshkey = "ubuntu:${ file("/home/alexander/.ssh/id_rsa.pub") }"
}
