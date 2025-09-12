variable "vpc_cider" {
  description   = "The CIDR block for the VPC"
  type          = string
  default       = "10.0.0.0/16"
}

variable "environment" {
  description = "The environment for the VPC (e.g., dev, prod)"
  type        = string
  default     = "dev"
}