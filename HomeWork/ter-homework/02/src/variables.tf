###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network & subnet name"
}


###ssh vars

variable "vms_ssh_root_key" {
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrG/4XPZmT3AQpWv4YSc0wbglW9UarTW4ofzyBvvUaQPYS1L2QxknkSIGU5bP1NorR/vYTyz9lLMCQStgaAohq691olIQCOskVNuBR3HnFElFJVwDS7ZzeE1+Ow5/cmoxkDUpDd+89Ge1hc3tEymVc571B6uEtztTDrTQmgtB8MHcLLEwJwRraeRUBSbOvfMgczVAc2mUhE9xUGLe/bjOtG2ymchaJml3qW3Dmb65UFk4FlkIXqCF27G3yZO0kjkrVNEsKmQzVpf1kzbHGzlPXfy9v2tlVkQI/yRvH3HPYy76cLoK/v4k2KeSMfx6sTDhuWBkgR6CgayZtT07P1zi2c0eZV+MU0onJ8Isy1Cu2byCK7hXDUkW/5tBZd1jdtkuSToa+4kct2MrUzWprLsBjMtE5lgIQYFjzVVt8BZzZ0/KlCw2kOdNgXik/A3R+6xw/zuxMvdhRH/LzC3yGCRnNBHeItMXgQHMmIR1FLdyTPraK1Mt72cbTbX9HrV6Prlc= root@ThinkBook-14-G2-ARE"
  description = "ssh-keygen -t ed25519"
}
