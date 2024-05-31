### Certificate Manager ###
resource "aws_acm_certificate" "cert" {
  domain_name               = "mokokero.com"
  subject_alternative_names = ["*.mokokero.com"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
