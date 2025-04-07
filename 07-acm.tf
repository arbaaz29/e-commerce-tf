//create aws managed certificates and validate them using DNS validation method
resource "aws_acm_certificate" "cstm_cert" {
  domain_name       = "midterms.spring-e-commerce.academy"
  validation_method = "DNS"
  validation_option {
    domain_name       = "midterms.spring-e-commerce.academy"
    validation_domain = "spring-e-commerce.academy"
  }
}
resource "aws_acm_certificate" "cert" {
  domain_name = "spring-e-commerce.academy"
  validation_method = "DNS"
  validation_option {
    domain_name       = "spring-e-commerce.academy"
    validation_domain = "spring-e-commerce.academy"
  }
}
