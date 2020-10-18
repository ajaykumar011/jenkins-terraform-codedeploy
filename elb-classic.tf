# Disable alb.tf to use this , you should also enable codedeploy-bluegreen.tf
resource "aws_lb" "app-elb" {
  name               = "app-elb"
  name_prefix        = "classic"
  internal           = false
  subnets            = [aws_subnet.main-public-1.id, aws_subnet.main-public-2.id]
  security_groups    = [aws_security_group.elb-securitygroup.id]
  enable_deletion_protection = false

  // access_logs {
  //   bucket  = aws_s3_bucket.lb_logs.bucket
  //   prefix  = "app-lb"
  //   enabled = true
  // }

listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  // listener {
  //   instance_port      = 80
  //   instance_protocol  = "http"
  //   lb_port            = 443
  //   lb_protocol        = "https"
  //   ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
  // }

health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  //instances                   = [aws_instance.foo.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Environment = "production"
  }

}























// resource "aws_lb_target_group_attachment" "app-alb-tg-attachment" {
//   target_group_arn = aws_lb_target_group.app-alb-tg1.arn
//   target_id        = aws_instance.test.id
//   port             = 80
// }

resource "aws_lb_target_group" "app-alb-tg1" {
  name     = "app-alb-tg1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

// resource "aws_lb_listener" "front_end" {
//   load_balancer_arn = aws_lb.test.arn
//   port              = "443"
//   protocol          = "HTTPS"
//   ssl_policy        = "ELBSecurityPolicy-2016-08"
//   certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

//   default_action {
//     type             = "forward"
//     target_group_arn = aws_lb_target_group.front_end.arn
//   }
// }

resource "aws_lb_listener" "app-alb-listener" {
  load_balancer_arn = aws_lb.app-alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-alb-tg1.arn
  }
}


