resource "aws_lb" "app-alb" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"
  
  subnets            = [aws_subnet.main-public-1.id, aws_subnet.main-public-2.id]
  security_groups    = [aws_security_group.elb-securitygroup.id]
  enable_deletion_protection = false

  // access_logs {
  //   bucket  = aws_s3_bucket.lb_logs.bucket
  //   prefix  = "app-lb"
  //   enabled = true
  // }
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


