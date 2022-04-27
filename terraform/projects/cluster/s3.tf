resource "aws_s3_bucket" "helm" {
  #checkov:skip=CKV_AWS_144:Cross-region replication not required
  #checkov:skip=CKV_AWS_21:Versioning not required
  #checkov:skip=CKV_AWS_18:Access logging not required
  #checkov:skip=CKV_AWS_145:Encryption
  #checkov:skip=CKV_AWS_19:Encryption
  #checkov:skip=CKV2_AWS_6:Skip public access block

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

resource "aws_s3_bucket_public_access_block" "helm" {
  bucket              = aws_s3_bucket.helm.id
  block_public_acls   = true
  block_public_policy = true
}
