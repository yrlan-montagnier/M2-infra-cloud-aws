# Scaling Policies
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${local.name}-nextcloud-scaleout"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.nextcloud.name
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${local.name}-nextcloud-scalein"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.nextcloud.name
}