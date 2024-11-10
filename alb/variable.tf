variable "vpc_id" {
    type = string
}

variable "apci_frontend_subnet_az_1a_id" {
  type = string
}

variable "apci_frontend_subnet_az_1b_id" {
  type = string
}

variable "tags" {
 type = map(string) 
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