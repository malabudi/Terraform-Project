variable "resource_group_name" {
  description = "Name of the resource group where network resources will be created"
  type        = string
}

variable "location" {
  description = "Azure location for all network resources"
  type        = string
}

variable "environment" {
  description = "The environment for resource tagging"
  type        = string
}