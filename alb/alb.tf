
# APPLICATION LOAD BALANCE SECURITY GROUP ......................................................................................................
resource "aws_security_group" "apci_alb_sg" {
  name        = "apci_alb_s"
  description = "Allow http and https"
  vpc_id      = var.vpc_id

 tags = {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-alb_sg"
  }
}


resource "aws_vpc_security_group_ingress_rule" "alows_http" {
  security_group_id = aws_security_group.apci_alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "alows_https" {
  security_group_id = aws_security_group.apci_alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.apci_alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# ALB TARGET GROUP ..............................................................................................................
resource "aws_lb_target_group" "apci_tg" {
  name     = "apci-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "instance"
  health_check {
    path                = "/"
    interval            = 30
    matcher             = "200,301,302"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    protocol            = "HTTP"
  }
}
# APPLICATION LOAD BALANCE ......................................................................................................
resource "aws_lb" "apci_alb" {
  name               = "apci-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.apci_alb_sg.id]
  subnets            = [var.apci_frontend_subnet_az_1a_id, var.apci_frontend_subnet_az_1b_id]
  enable_deletion_protection = false
  depends_on = [ aws_security_group.apci_alb_sg ]
  /*access_logs {
    bucket  = var.aws_s3_bucket.apci_alb_access_log_bucket.bucket
    prefix  = "alb-access-log"
    enabled = true
  }*/

 tags = {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-alb"
  }
}

resource "aws_lb_listener" "apci_alb_listener" {
  load_balancer_arn = aws_lb.apci_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "redirect"

        redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
    
  }

resource "aws_lb_listener" "apci_https_listener" {
  load_balancer_arn = aws_lb.apci_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.apci_tg.arn
  }
}