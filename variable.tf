variable "vpc_cidr_block" {
  type = string
}
variable "frontend_cider_block" {
  type = list(string)
}
variable "backend_cider_block" {
  type = list(string)
}
variable "availability_zone" {
  type = list(string)

}
variable "db_cidr_block" {
  type = list(string)
}

variable "image_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}
variable "zone_id" {
  type = string
}

variable "certificate_arn" {
  type = string
}

variable "ssl_policy" {
  type = string
}

variable "dns_name" {
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

variable "engine_version" {
  type = string
}