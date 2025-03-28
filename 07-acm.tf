# ✅ 1. Self-Signed 인증서 생성
resource "tls_private_key" "example" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "example" {
  private_key_pem = tls_private_key.example.private_key_pem

  subject {
    common_name  = "midterms.spring-e-commerce.academy"
    organization = "Example Org"
  }

  validity_period_hours = 8760  # 1년짜리 인증서
  is_ca_certificate     = false

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]
}

resource "aws_acm_certificate" "self_signed_cert" {
  private_key      = tls_private_key.example.private_key_pem
  certificate_body = tls_self_signed_cert.example.cert_pem
}

//import the certificate and use dns verification method
# resource "aws_acm_certificate" "cert" {
#   domain_name = "spring-e-commerce.academy"
#   validation_method = "DNS"
# }

# resource "aws_acm_certificate_validation" "cert" {
#   certificate_arn         = aws_acm_certificate.cert.arn
#   validation_record_fqdns = [for record in aws_route53_record.cert : record.fqdn]
# }

# resource "aws_acm_certificate" "cstm_cert" {
#   domain_name       = "midterms.spring-e-commerce.academy"
#   validation_method = "DNS"

#   validation_option {
#     domain_name       = "midterms.spring-e-commerce.academy"
#     validation_domain = "spring-e-commerce.academy"
#   }
# }


//import the certificate and use dns verification method
# resource "aws_acm_certificate" "cert" {
#   domain_name = "spring-e-commerce.academy"
#   validation_method = "DNS"
#   validation_option {
#     domain_name       = "spring-e-commerce.academy"
#     validation_domain = "spring-e-commerce.academy"
#  }
# }

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