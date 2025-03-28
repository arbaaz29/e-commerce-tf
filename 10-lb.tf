//create application loadbalancer and attach the respective security group to it check application blocks if you want to confiure it  
resource "aws_lb" "alb" {
  name               = "${var.basename}-alb"
  depends_on         = [aws_lb_target_group.tg]
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_loadbalancer.id]
  subnets            = [aws_subnet.public-subnet["subnet-az1"].id, aws_subnet.public-subnet["subnet-az2"].id]
  #   access_logs {
  #   bucket  = aws_s3_bucket.alb_logs.id
  #   prefix  = "alb-access-logs"
  #   enabled = true
  # }
  # connection_logs {
  #   bucket = aws_s3_bucket.alb.id
  #   prefix  = "alb-connection-logs"
  #   enabled = true
  # }

  tags = {
    Name = "${var.basename}-loadbalancer"
  }
}

//encryption certificates to be used for 443
resource "aws_lb_listener_certificate" "lb_cert" {
  listener_arn    = aws_lb_listener.https_lb_listener.arn
  certificate_arn = aws_acm_certificate.self_signed_cert.arn
}

//create listener to redirect http traffic to https traffic over port 443
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  tags = {
    Name = "${var.basename}-listener"
  }
}
//create listener for encrypted communication
resource "aws_lb_listener" "https_lb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.self_signed_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }


  tags = {
    Name = "${var.basename}-secure-listener"
  }
}

//create target group
resource "aws_lb_target_group" "tg" {
  depends_on = [aws_instance.webserver]
  name       = "ec2-target-group"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = aws_vpc.main.id
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }
}
//search for ec2 instance targets in private subnet
resource "aws_lb_target_group_attachment" "lb_attachment" {
  for_each         = aws_instance.webserver
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver[each.key].id
  port             = 80
  depends_on       = [aws_lb_target_group.tg]
}

# # S3 Bucket for ALB Logs with Object Ownership
# resource "aws_s3_bucket" "alb_logs" {
#   bucket = "e-commerce-alb-logs-${data.aws_caller_identity.current.account_id}"
# }

# resource "aws_s3_bucket_ownership_controls" "alb_logs" {
#   bucket = aws_s3_bucket.alb_logs.id

#   rule {
#     object_ownership = "BucketOwnerEnforced"
#   }
# }


