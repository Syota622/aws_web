# S3(Set IAM policy to allow ALB to write access logs to S3 buckets)
resource "aws_s3_bucket" "ecs_log_s3" {
  bucket = "${var.pj}-ecs-logs-${var.env}"
}

# public access enabled
resource "aws_s3_bucket_public_access_block" "ecs_log_s3" {
  bucket                  = aws_s3_bucket.ecs_log_s3.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "ecs_log_s3" {
  bucket = aws_s3_bucket.ecs_log_s3.id

  rule {
    id     = "log_expiration"
    status = "Enabled"

    expiration {
      days = 90
    }
  }
}