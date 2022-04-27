resource "aws_s3_bucket" "helm" {
  #checkov:skip=CKV_AWS_144:Cross-region replication not required
  #checkov:skip=CKV_AWS_21:Versioning not required
  #checkov:skip=CKV_AWS_18:Access logging not required
  #checkov:skip=CKV_AWS_145:Encryption
  #checkov:skip=CKV_AWS_19:Encryption

  bucket = "${var.environment}-helm-charts"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.eks.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = var.tags
}