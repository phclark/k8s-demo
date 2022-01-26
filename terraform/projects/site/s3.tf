resource "aws_kms_key" "s3" {
  description             = "S3 Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = var.tags
}


resource "aws_s3_bucket" "static_website" {
  #checkov:skip=CKV_AWS_144:Cross-region replication not required
  #checkov:skip=CKV_AWS_21:Versioning not required
  #checkov:skip=CKV_AWS_18:Access logging not required
  bucket = var.domain_name

  website {
    index_document = "index.html"
    error_document = "error.html"

    routing_rules = length(var.public_dir) > 0 ? local.static_website_routing_rules : ""
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = merge( { "Name": "${var.domain_name}-static_website"}, var.tags)
}

resource "aws_s3_bucket_public_access_block" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls   = true
  block_public_policy = true
  restrict_public_buckets = true
  ignore_public_acls=true
}

resource "aws_s3_bucket_policy" "static_website_read_with_secret" {
  bucket = "${aws_s3_bucket.static_website.id}"
  policy = "${data.aws_iam_policy_document.static_website_read_with_secret.json}"
}

resource "aws_s3_bucket" "redirect" {
  #checkov:skip=CKV_AWS_144:Cross-region replication not required
  #checkov:skip=CKV_AWS_21:Versioning not required
  #checkov:skip=CKV_AWS_18:Access logging not required
  count = length(var.redirects)

  bucket = var.redirects[count.index]

  website {
    redirect_all_requests_to = "https://${var.domain_name}"
  }

  tags = merge( { "Name": "${var.redirects[count.index]}-redirect" }, var.tags)
}

resource "aws_s3_bucket_public_access_block" "redirect" {
  bucket = aws_s3_bucket.redirect.id

  block_public_acls   = true
  block_public_policy = true
  restrict_public_buckets = true
  ignore_public_acls=true
}