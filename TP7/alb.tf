# Création de l'ALB
resource "aws_lb" "nextcloud" {
  name               = "ymontagnier-nextcloud-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [for s in aws_subnet.public : s.id] # Liste des sous-réseaux publics

  tags = {
    Name = "${local.name}-nextcloud-alb"
  }
}

# Création du groupe cible pour Nextcloud
resource "aws_lb_target_group" "nextcloud" {
  name     = "ymontagnier-nextcloud-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

    tags = {
    Name = "${local.name}-nextcloud-alb-tg"
  }
}

# Attachement de l'instance EC2 au groupe cible
resource "aws_lb_target_group_attachment" "nextcloud" {
  target_group_arn = aws_lb_target_group.nextcloud.arn
  target_id        = aws_instance.nextcloud.id
  port             = 80
}

# Configuration du listener HTTP (redirection vers HTTPS)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.nextcloud.arn
  port              = 80
  protocol          = "HTTP"

  # Redirection vers HTTPS
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  # Tags
  tags = {
    Name = "${local.name}-nextcloud-alb-http-listener"
  }
}