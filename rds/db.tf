# DATABASE SECURITY GROUP .....................................................................
resource "aws_security_group" "db_sg" {
    description = "Allow SSH trafic"
    vpc_id = var.vpc_id

     tags = {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db_sg"
}
  
}

resource "aws_vpc_security_group_ingress_rule" "allow_mysql" {
  security_group_id = aws_security_group.db_sg.id
  cidr_ipv4         = var.vpc_cidr_block
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_from_db" {
  security_group_id = aws_security_group.db_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# DATABASE SUBNET GROUP ......................................................................
resource "aws_db_subnet_group" "db_subnet_group" {
  name = "db-subnet-group"
  subnet_ids = [var.apci_db_subnet_az_1a_id, var.apci_db_subnet_az_1b_id]
  description = "Subnet group for DB"

  tags = {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db-subnet-group"
  }
}

resource "aws_db_instance" "db_instance" {
  allocated_storage    = 20
  storage_type         = "gp3"
  engine               = "mysql"
  engine_version       = var.engine_version
  instance_class       = var.db_instance_type
  db_name              = "jupiter_server_db"
  username             = var.username
  password             = var.password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  multi_az = false
  publicly_accessible = false
  # apply_immediately = true
  # deletion_protection = false
  # storage_encrypted = true
  # monitoring_interval = 60
  # monitoring_role_arn = var.monitoring_role_arn
  # enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  # performance_insights_enabled = true
  # performance_insights_kms_key_id = var.performance_insights_kms_key_id
  # performance_insights_retention_period = 7
  # availability_zone = var.availability_zone_1a
  # identifier = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db-instance"
  # final_snapshot_identifier = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db-instance"
  # copy_tags_to_snapshot = true
  # delete_automated_backups = true
  # backup_retention_period = 30
  # backup_window = "04:00-06:00"
  # maintenance_window = "Mon:06:00-Mon:08:00"
  # auto_minor_version_upgrade = true
  # allow_major_version_upgrade = true
  # port = 3306


  tags = {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db-instance"
  }
}