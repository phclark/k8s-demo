resource "aws_s3_bucket" "static_website" {
  bucket = var.domain_name

  website {
    index_document = "index.html"
    error_document = "error.html"

    routing_rules = length(var.public_dir) > 0 ? local.static_website_routing_rules : ""
  }

  tags = merge( { "Name": "${var.domain_name}-static_website"}, var.tags)
}

resource "aws_s3_bucket_policy" "static_website_read_with_secret" {
  bucket = "${aws_s3_bucket.static_website.id}"
  policy = "${data.aws_iam_policy_document.static_website_read_with_secret.json}"
}

resource "aws_s3_bucket" "redirect" {
  count = length(var.redirects)

  bucket = var.redirects[count.index]

  website {
    redirect_all_requests_to = "https://${var.domain_name}"
  }

  tags = merge( { "Name": "${var.redirects[count.index]}-redirect" }, var.tags)
}