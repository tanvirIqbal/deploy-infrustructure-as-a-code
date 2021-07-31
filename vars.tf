variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default = "udacity-project1"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "East US"
}

variable "username" {
  description = "The username for VM."
  default = "tanviriqbal"
}

variable "password" {
  description = "The password for VM."
  default = "QwertyAsdfg1@3$5"
}

variable "number_of_vms" {
  description = "Number of VMs"
  type        = number
  default     = 3
}