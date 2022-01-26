resource "aws_cloudfront_distribution" "cdn" {
  #checkov:skip=CKV_AWS_86:Skipped for demo purposes
  #checkov:skip=CKV_AWS_68:Skipped for demo purposes
  #checkov:skip=CKV_AWS_174:Skipped for demo purposes
  #checkov:skip=CKV2_AWS_32:Skipped for demo purposes

  origin {
    domain_name = "${aws_s3_bucket.static_website.website_endpoint}"
    origin_path = "${local.public_dir_with_leading_slash}"
    origin_id   = "${local.s3_origin_id}"

    custom_origin_config {
      http_port               = 80
      https_port              = 443
      origin_protocol_policy  = "http-only"
      origin_ssl_protocols    = ["TLSv1.2", "TLSv1.1", "TLSv1"]
    }

    custom_header {
      name  = "User-Agent"
      value = data.aws_ssm_parameter.secret.value
    }
  }

  comment             = "CDN for ${var.domain_name} S3 Bucket"
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = ["${var.domain_name}"]

  custom_error_response {
    error_code          = 403
    response_page_path  = "/error.html"
    response_code       = 404
  }

  custom_error_response {
    error_code          = 404
    response_page_path  = "/error.html"
    response_code       = 404
  }

  default_cache_behavior {
    target_origin_id = "${local.s3_origin_id}"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn       = "${var.cert_arn}"
    ssl_support_method        = "sni-only"
    minimum_protocol_version  = "TLSv1.1_2016"
  }

  tags = merge( { "Name": "${var.domain_name}-cdn"}, var.tags)
}

resource "aws_cloudfront_distribution" "redirect" {
  #checkov:skip=CKV2_AWS_32:Skipped for demo purposes
  count = "${length(var.redirects)}"

  origin {
    domain_name = "${element(aws_s3_bucket.redirect.*.website_endpoint, count.index)}"
    origin_id   = "cloudfront-distribution-origin-${element(var.redirects, count.index)}.s3.amazonaws.com"

    custom_origin_config {
      http_port               = 80
      https_port              = 443
      origin_protocol_policy  = "http-only"
      origin_ssl_protocols    = ["TLSv1.2", "TLSv1.1", "TLSv1"]
    }
  }

  comment         = "CDN for ${element(var.redirects, count.index)} S3 Bucket (redirect)"
  enabled         = true
  is_ipv6_enabled = true
  aliases         = ["${element(var.redirects, count.index)}"]

  default_cache_behavior {
    target_origin_id = "cloudfront-distribution-origin-${element(var.redirects, count.index)}.s3.amazonaws.com"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn       = "${var.cert_arn}"
    ssl_support_method        = "sni-only"
    minimum_protocol_version  = "TLSv1.1_2016"
  }

  tags = merge( { "Name": "${var.redirects[count.index]}-cdn_redirect" }, var.tags)
}