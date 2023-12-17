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
  default     = "centos-7"
  description = "Image family"
}

variable "image_id" {
  type        = string
  default     = "fd8g060b9a67p0mm91af"
  description = "Image id"
  }


variable "vm_platform_id" {
  type        = string
  default     = "standard-v1"
}

variable "vm_resources" {
  type  = map(map(number))
  default = {
      web={
      cores         = 2
      memory        = 4
      core_fraction = 5
    }
      db={
      cores         = 2
      memory        = 2
      core_fraction = 20
    }
  }
}

variable "vm_all_scheduling_policy" {
  type          = bool
  default       = true
}

variable "vm_all_network_interface_nat" {
  type = bool
  default = true
}

variable "metadata" {
  default = {serial-port-enable=1, ssh-keys  = ""}
}

variable "out_name" {
  type        = list(string)
  default     = ["name","id","cidr"]
  description = "naming for output"
}

