# Template pour la création d'un Auto Scaling Group (ASG) avec Terraform
# Cette ressource définit une ressource aws_launch_template, ce qui permet de créer un Launch Template
resource "aws_launch_template" "nextcloud" {
  name_prefix            = "${local.name}-nextcloud-lt"
  image_id               = data.aws_ami.nextcloud.id            # Utiliser l'image la plus récente correspondant au pattern "ymontagnier-*-nextcloud-*"
  instance_type          = "t3.micro"                           # Type d'instance                 
  key_name               = aws_key_pair.nextcloud.key_name      # Utiliser la paire de clés nextcloud
  vpc_security_group_ids = [aws_security_group.nextcloud_sg.id] # Utiliser le groupe de sécurité nextcloud_sg
  user_data              = local.nextcloud_userdata

  # Définition des tags pour les instances créés à partir de ce Launch Template
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name  = "${local.name}-nextcloud-instance"
      Owner = local.user
    }
  }

  # Définition des tags pour les volumes créés à partir de ce Launch Template
  tag_specifications {
    resource_type = "volume"
    tags = {
      Name  = "${local.name}-nextcloud-volume"
      Owner = local.user
    }
  }
}

# l'ASG permet de gérer automatiquement le nombre d'instances en fonction de la charge
# L'ASG est configuré pour utiliser un Target Group pour la vérification de l'état de santé des instances
# L'ASG est configuré pour utiliser un Load Balancer pour la vérification de l'état de santé des instances 
# L'ASG est configuré pour utiliser les subnets privés pour le déploiement des instances

# Cette ressource définit un Auto Scaling Group (ASG) qui utilise le Launch Template précédemment créé dans sa version la plus récente
resource "aws_autoscaling_group" "nextcloud" {
  name                = "${local.name}-nextcloud-asg"
  desired_capacity    = 1                                    # Nombre d'instances souhaité
  min_size            = 1                                    # Nombre minimum d'instances
  max_size            = 1                                    # Nombre maximum d'instances
  vpc_zone_identifier = [for s in aws_subnet.private : s.id] # Subnets privés

  # Utiliser le Launch Template pour créer les instances
  launch_template {
    id      = aws_launch_template.nextcloud.id
    version = "$Latest"
  }

  health_check_type         = "ELB"                               # Utiliser le Load Balancer pour la vérification de l'état de santé des instances
  health_check_grace_period = 300                                 # Délai entre le démarrage de l'instance et le début des vérifications de l'état de santé
  target_group_arns         = [aws_lb_target_group.nextcloud.arn] # Attacher les instances au Target Group du Load Balancer

  # Définition des tags pour l'Auto Scaling Group
  tag {
    key                 = "Owner"
    value               = local.user
    propagate_at_launch = false
  }

  tag {
    key                 = "Name"
    value               = "${local.name}-nextcloud-asg"
    propagate_at_launch = false
  }
}

data "aws_instances" "nextcloud_asg" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [aws_autoscaling_group.nextcloud.name]
  }
}

output "asg_instances_nextcloud_private_ips" {
  value = data.aws_instances.nextcloud_asg.private_ips
}