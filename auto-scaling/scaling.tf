
# PUBLIC JUPITER SERVER SECURITY GROUP ............................................................................................................
resource "aws_security_group" "jupiter_server_sg" {
  name        = "public_sg"
  description = "Allow ssh, http and https"
  vpc_id      = var.vpc_id

 tags = {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public_server_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "asg_alows_ssh" {
  security_group_id = aws_security_group.jupiter_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 44322
}

resource "aws_vpc_security_group_ingress_rule" "asg_alows_http" {
  security_group_id = aws_security_group.jupiter_server_sg.id
  referenced_security_group_id = var.alb_security_group_id
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "asg_alows_https" {
  security_group_id = aws_security_group.jupiter_server_sg.id
  referenced_security_group_id = var.alb_security_group_id
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.jupiter_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# LAUNCH TEMPLATE ............................................................................................................
/*resource "aws_launch_template" "jupiter_server_template" {
  name = "jupiter_server_template"
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 30
    }
  }
  image_id      = var.image_id
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.jupiter_server_sg.id]
  user_data = filebase64(file("scripts/frontend-server.sh"))
  tags = {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-jupiter_server_template"
  }
}*/

resource "aws_launch_template" "asg_launch_template" {
  name_prefix   = "apci_lt"
  image_id      = var.image_id
  instance_type = var.instance_type
  key_name      = var.key_name
  user_data = base64encode(file("script/frontend-server.sh"))
  


    network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.jupiter_server_sg.id]
 }
 tags = {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-jupiter_server_template"
}
}
# AUTOSCALING GROUP ............................................................................................................
resource "aws_autoscaling_group" "jupiter_server_asg" {
  name                      = "jupiter_server_asg"
  max_size                  = 5
  min_size                  = 2
  desired_capacity          = 4
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  termination_policies      = ["OldestInstance"]
  vpc_zone_identifier       = [var.apci_frontend_subnet_az_1a_id, var.apci_frontend_subnet_az_1b_id]
  target_group_arns         = [var.target_group_arn]
  launch_template {
    id      = aws_launch_template.asg_launch_template.id
    version = "$Latest"
  }
  
  tag {
    key                 = "Name"
    value               = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-jupiter_server_asg"
    propagate_at_launch = true
  }
}

