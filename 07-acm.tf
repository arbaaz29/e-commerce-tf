//import the certificate and use dns verification method

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
