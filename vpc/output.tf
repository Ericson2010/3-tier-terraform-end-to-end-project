output "vpc_id" {
  value = aws_vpc.apci_main_vpc.id
}

/*output "public_subnets" {
  value = ["aws_subnet.apci_frontend_subnet_az_1a.id", "aws_subnet.apci_frontend_subnet_az_1b.id" ]
}*/

output "apci_frontend_subnet_az_1a_id" {
  value = aws_subnet.apci_frontend_subnet_az_1a.id
}

output "apci_frontend_subnet_az_1b_id" {
  value = aws_subnet.apci_frontend_subnet_az_1b.id
}

output "apci_backend_subnet_az_1a_id" {
  value = aws_subnet.apci_backend_subnet_az_1a.id
}

output "apci_backend_subnet_az_1b_id" {
  value = aws_subnet.apci_backend_subnet_az_1b.id
}

output "apci_db_subnet_az_1a_id" {
  value = aws_subnet.apci_db_subnet_az_1a.id
}

output "apci_db_subnet_az_1b_id" {
  value = aws_subnet.apci_db_subnet_az_1b.id
}