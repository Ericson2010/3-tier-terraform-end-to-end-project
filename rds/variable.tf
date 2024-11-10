variable "vpc_id" {
  type = string
}

variable "apci_db_subnet_az_1a_id" {
  type = string
}

variable "apci_db_subnet_az_1b_id" {
  type = string
}

variable "username" {
  type = string
}

variable "password" {
  type = string
}

variable "db_instance_type" {
  type = string
}

variable "tags" {
 type = map(string) 
}

variable "vpc_cidr_block" {
  type = string
}

variable "engine_version" {
  type = string
}