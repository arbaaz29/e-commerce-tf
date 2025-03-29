data "aws_route53_zone" "spring" {
  name         = "spring-e-commerce.academy"
  private_zone = false
}

resource "aws_route53_record" "alb" {
  zone_id = data.aws_route53_zone.spring.zone_id
  name    = "midterms.spring-e-commerce.academy"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.alb.dns_name]
}

resource "aws_route53_record" "cert" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.spring.zone_id
}