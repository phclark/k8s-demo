resource "aws_route53_record" "alias" {
  count = "${length(var.zone_id) > 0 ? 1 : 0}"

  zone_id = "${var.zone_id}"
  name    = "${var.domain_name}"
  type    = "A"

  alias {
    name                    = "${aws_cloudfront_distribution.cdn.domain_name}"
    zone_id                 = "${aws_cloudfront_distribution.cdn.hosted_zone_id}"
    evaluate_target_health  = false
  }
}

resource "aws_route53_record" "redirect" {
  count = length(var.zone_id) > 0 ? length(var.redirects) : 0

  zone_id = var.zone_id
  name    = length(var.redirects) > 0 ? var.redirects[count.index] : ""
  type    = "A"

  alias {
    name                    = aws_cloudfront_distribution.redirect[count.index].domain_name
    zone_id                 = aws_cloudfront_distribution.redirect[count.index].hosted_zone_id
    evaluate_target_health  = false
  }
}