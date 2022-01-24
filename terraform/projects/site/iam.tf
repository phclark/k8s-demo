data "aws_iam_policy_document" "static_website_read_with_secret" {
  statement {
    sid       = "1"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static_website.arn}${local.public_dir_with_leading_slash}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test = "StringEquals"
      variable = "aws:UserAgent"
      values = ["${data.aws_ssm_parameter.secret.value}"]
    }
  }
}