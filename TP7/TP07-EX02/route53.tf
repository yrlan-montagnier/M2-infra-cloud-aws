# Get the Route53 zone ID for the training subdomain
data "aws_route53_zone" "training" {
  name = "training.akiros.it"
}

# Create a Route53 record for the ALB
resource "aws_route53_record" "nextcloud" {
  zone_id = data.aws_route53_zone.training.zone_id
  name    = "nextcloud-${local.user}"
  type    = "A"
  alias {
    name                   = aws_lb.nextcloud.dns_name
    zone_id                = aws_lb.nextcloud.zone_id
    evaluate_target_health = true
  }
}

output "nextcloud_fqdn" {
  value = aws_route53_record.nextcloud.fqdn
}