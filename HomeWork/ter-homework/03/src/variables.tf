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
  description = "VPC network&subnet name"
}



###task1

variable "image_family" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "Image family"
}

variable "vm_web_platform_id" {
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

##task2
variable "vm_resources_task3" {
  type = map(object({
    vm_name = string,
    cpu     = number,
    ram     = number,
    disk    = number,
    core_fraction = number
  }))
  default = {
    main = {
      vm_name       = "main"
      cpu           = 4
      ram           = 2
      disk          = 1
      core_fraction = 20
    },
    replica = {
      vm_name       = "replica"
      cpu           = 2
      ram           = 1
      disk          = 1
      core_fraction = 5
    }
  }
}

/*variable "vm_resources_task3" {
  type = list(object({
    vm_name       = string
    cores         = number
    memory        = number
    core_fraction = number
  }
    def

    }
*/
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
  default = {serial-port-enable=1, ssh-keys  = "$local.sshkey"}
}



