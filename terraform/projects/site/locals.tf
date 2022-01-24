locals {
  s3_origin_id = "cloudfront-distribution-origin-${var.domain_name}.s3.amazonaws.com${local.public_dir_with_leading_slash}"

  public_dir_with_leading_slash = "${length(var.public_dir) > 0 ? "/${var.public_dir}" : ""}"
  static_website_routing_rules = <<EOF
[{
    "Condition": {
        "KeyPrefixEquals": "${var.public_dir}/${var.public_dir}/"
    },
    "Redirect": {
        "Protocol": "https",
        "HostName": "${var.domain_name}",
        "ReplaceKeyPrefixWith": "",
        "HttpRedirectCode": "301"
    }
}]
EOF

}

data "aws_ssm_parameter" "secret" {
  name = var.secret_name
}
