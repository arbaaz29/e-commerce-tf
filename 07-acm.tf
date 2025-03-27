//import the certificate and use dns verification method
# resource "aws_acm_certificate" "cert" {
#   domain_name = "spring-e-commerce.academy"
#   validation_method = "DNS"
# }

# resource "aws_acm_certificate_validation" "cert" {
#   certificate_arn         = aws_acm_certificate.cert.arn
#   validation_record_fqdns = [for record in aws_route53_record.cert : record.fqdn]
# }

resource "aws_acm_certificate" "cstm_cert" {
  domain_name       = "midterms.spring-e-commerce.academy"
  validation_method = "DNS"

  validation_option {
    domain_name       = "midterms.spring-e-commerce.academy"
    validation_domain = "spring-e-commerce.academy"
  }
}


//import the certificate and use dns verification method
resource "aws_acm_certificate" "cert" {
  domain_name = "spring-e-commerce.academy"
  validation_method = "DNS"
  validation_option {
    domain_name       = "spring-e-commerce.academy"
    validation_domain = "spring-e-commerce.academy"
  }
}

# resource "aws_route53_record" "alb" {
#   zone_id = data.aws_route53_zone.spring.zone_id
#   name    = "spring-e-commerce.academy"
#   type    = "A"
#   allow_overwrite = true
  
#   alias {
#     name                   = aws_lb.alb.dns_name
#     zone_id                = aws_lb.alb.zone_id
#     evaluate_target_health = true
#   }
# }