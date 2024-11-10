
# BASTION HOST SECURITY GROUP ..............................................................
resource "aws_security_group" "bastion_host_sg" {
    description = "Allow SSH trafic"
    vpc_id = var.vpc_id

     tags = {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-bastion_host_sg"
}
  
}

resource "aws_vpc_security_group_ingress_rule" "allow_bastion_host_ssh" {
  security_group_id = aws_security_group.bastion_host_sg.id
  cidr_ipv4         = "18.206.107.24/29"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_from_bastion_host" {
  security_group_id = aws_security_group.bastion_host_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# BASTION HOST EC2 INSTANCE ..............................................................
resource "aws_instance" "bastion_host" {
  ami           = var.image_id
  instance_type = var.instance_type
  subnet_id     = var.apci_frontend_subnet_az_1a_id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.bastion_host_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-bastion_host"
  }
}

# BACKEND SECURITY GROUP ..............................................................
resource "aws_security_group" "backend_sg" {
    description = "Allow trafic from bastion host"
    vpc_id = var.vpc_id

     tags = {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-backend_sg"
}
}

resource "aws_vpc_security_group_ingress_rule" "allow_backend_ssh" {
  security_group_id = aws_security_group.backend_sg.id
  referenced_security_group_id = aws_security_group.bastion_host_sg.id
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_from_backend_server" {
   security_group_id = aws_security_group.backend_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# BACKEND EC2 INSTANCE ..............................................................
resource "aws_instance" "backend_server_az1a" {
  ami           = var.image_id
  instance_type = var.instance_type
  subnet_id     = var.apci_backend_subnet_az_1a_id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  associate_public_ip_address = false

  tags = {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-backend_server_az1a"
  }
}

resource "aws_instance" "backend_server_az1b" {
  ami           = var.image_id
  instance_type = var.instance_type
  subnet_id     = var.apci_backend_subnet_az_1b_id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  associate_public_ip_address = false

  tags = {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-backend_server_az1b"
  }
}