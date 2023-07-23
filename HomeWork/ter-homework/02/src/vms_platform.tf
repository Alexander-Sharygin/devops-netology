###Переменные по заданию 2
variable "image_family" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "Image family"
}

variable "vm_web_platform_id" {
  type        = string
  default     = "standard-v1"
}

##db

variable "vm_db_platform_id" {
  type        = string
  default     = "standard-v1"
}

variable "vm_resources" {
  type  = map(map(number))
  default = {
      web={
      cores         = 2
      memory        = 1
      core_fraction = 5
    }
      db={
      cores         = 2
      memory        = 2
      core_fraction = 20
    }
  }
}

##Общие для вм параметры
variable "vm_all_scheduling_policy" {
  type          = bool
  default       = true
}

variable "vm_all_network_interface_nat" {
  type = bool
  default = true
}

variable "metadata" {
  default = {serial-port-enable=1, ssh-keys  = "ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrG/4XPZmT3AQpWv4YSc0wbglW9UarTW4ofzyBvvUaQPYS1L2QxknkSIGU5bP1NorR/vYTyz9lLMCQStgaAohq691olIQCOskVNuBR3HnFElFJVwDS7ZzeE1+Ow5/cmoxkDUpDd+89Ge1hc3tEymVc571B6uEtztTDrTQmgtB8MHcLLEwJwRraeRUBSbOvfMgczVAc2mUhE9xUGLe/bjOtG2ymchaJml3qW3Dmb65UFk4FlkIXqCF27G3yZO0kjkrVNEsKmQzVpf1kzbHGzlPXfy9v2tlVkQI/yRvH3HPYy76cLoK/v4k2KeSMfx6sTDhuWBkgR6CgayZtT07P1zi2c0eZV+MU0onJ8Isy1Cu2byCK7hXDUkW/5tBZd1jdtkuSToa+4kct2MrUzWprLsBjMtE5lgIQYFjzVVt8BZzZ0/KlCw2kOdNgXik/A3R+6xw/zuxMvdhRH/LzC3yGCRnNBHeItMXgQHMmIR1FLdyTPraK1Mt72cbTbX9HrV6Prlc= root@ThinkBook-14-G2-ARE"}
}

###ssh vars


