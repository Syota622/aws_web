### マルチアカウント(dev, stg, prod))ドメインを利用する場合、権限を委譲する必要がある ###
# 参考: https://dev.classmethod.jp/articles/route53-transfer-hostedzones-2021/

### Route53 host zone ###
resource "aws_route53_zone" "learn_com" {
  name = "mokokero.com"
}

resource "aws_route53_record" "prod_record" {
  zone_id = aws_route53_zone.learn_com.zone_id
  name    = "api.mokokero.com"
  type    = "A"

  alias {
    name                   = var.alb_dns
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  allow_overwrite = true
  zone_id         = aws_route53_zone.learn_com.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 300
}
