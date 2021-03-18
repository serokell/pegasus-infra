# We need to use us-east-1 region for AWS ACM resources, to make
# it work with CloudFront
# https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cnames-and-https-requirements.html#https-requirements-aws-region
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

# tls certificate managed by ACM
resource "aws_acm_certificate" "cert" {
  provider = aws.us-east-1

  domain_name               = "serokell.io"
  subject_alternative_names = ["*.serokell.io"]
  validation_method         = "DNS"
}

# dns records for verifying and renewing the certificate
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for opts in aws_acm_certificate.cert.domain_validation_options : opts.domain_name => {
      name   = opts.resource_record_name
      record = opts.resource_record_value
      type   = opts.resource_record_type
    }

    # terraform-aws provider generates duplicate records for wildcard domains,
    # use a filter to have only one record
    # https://github.com/hashicorp/terraform-provider-aws/issues/16913
    if opts.domain_name == "serokell.io"
  }

  zone_id = data.aws_route53_zone.serokell_io.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

# invokes certificate validation
resource "aws_acm_certificate_validation" "cert" {
  provider = aws.us-east-1

  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# cloudfront distribution serving serokell.io
resource "aws_cloudfront_distribution" "serokell_io" {
  enabled         = true
  is_ipv6_enabled = true

  # We serve *.serokell.io through CloudFront as well, because it allows us
  # to use AWS ACM for convenient certificate management
  aliases = ["serokell.io", "*.serokell.io"]

  origin {
    domain_name = "enif.pegasus.serokell.team"
    origin_id   = "origin-enif"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    # add custom 'X-From-CloudFront' header checked by the server
    custom_header {
      name  = "X-From-CloudFront"
      value = "indeed"
    }
  }

  default_cache_behavior {
    target_origin_id       = "origin-enif"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      # forward url query parameters and cookies
      query_string = true
      cookies {
        forward = "all"
      }

      # forward 'Host' header
      headers = ["Host"]
    }
  }

  # use certificate from ACM
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    minimum_protocol_version = "TLSv1.1_2016"
    ssl_support_method       = "sni-only"
  }

  # disable geo restriction
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

# ipv4 record for serokell.io
resource "aws_route53_record" "serokell_io_ipv4" {
  zone_id = data.aws_route53_zone.serokell_io.zone_id
  name    = "serokell.io"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.serokell_io.domain_name
    zone_id                = aws_cloudfront_distribution.serokell_io.hosted_zone_id
    evaluate_target_health = false
  }
}

# ipv6 record for serokell.io
resource "aws_route53_record" "serokell_io_ipv6" {
  zone_id = data.aws_route53_zone.serokell_io.zone_id
  name    = "serokell.io"
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.serokell_io.domain_name
    zone_id                = aws_cloudfront_distribution.serokell_io.hosted_zone_id
    evaluate_target_health = false
  }
}

# ipv4 record for *.serokell.io
resource "aws_route53_record" "serokell_io_wildcard_ipv4" {
  zone_id = data.aws_route53_zone.serokell_io.zone_id
  name    = "*.serokell.io"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.serokell_io.domain_name
    zone_id                = aws_cloudfront_distribution.serokell_io.hosted_zone_id
    evaluate_target_health = false
  }
}

# ipv6 record for *.serokell.io
resource "aws_route53_record" "serokell_io_wildcard_ipv6" {
  zone_id = data.aws_route53_zone.serokell_io.zone_id
  name    = "*.serokell.io"
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.serokell_io.domain_name
    zone_id                = aws_cloudfront_distribution.serokell_io.hosted_zone_id
    evaluate_target_health = false
  }
}
