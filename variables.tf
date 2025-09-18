variable "location" {
  description = "The Azure region to deploy resources in"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "The environment for resource tagging"
  type        = string
  default     = "Dev"
}