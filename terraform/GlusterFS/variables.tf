variable "size" {
  type    = "string"
  default = "t2.micro"
}

variable "subnets" {
  type        = "list"
  description = "List of CIDR Block Notation for placement subnets."
}

variable "vpc" {}
