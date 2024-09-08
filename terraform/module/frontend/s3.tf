# # S3(Set IAM policy to allow ALB to write access logs to S3 buckets)
# resource "aws_s3_bucket" "alb_logs" {
#   bucket = "${var.pj}-alb-logs-${var.env}"
# }

# # public access enabled
# resource "aws_s3_bucket_public_access_block" "alb_logs" {
#   bucket                  = aws_s3_bucket.alb_logs.id
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# resource "aws_s3_bucket_versioning" "alb_logs" {
#   bucket = aws_s3_bucket.alb_logs.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
#   bucket = aws_s3_bucket.alb_logs.id

#   rule {
#     id     = "log_expiration"
#     status = "Enabled"

#     expiration {
#       days = 90
#     }
#   }
# }

# # IAM policy for ALB to write logs to the S3 bucket
# data "aws_iam_policy_document" "alb_logs" {
#   statement {
#     effect = "Allow"
#     principals {
#       type        = "AWS"
#       identifiers = ["arn:aws:iam::582318560864:root"] # elb account id(https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html#attach-bucket-policy)
#     }
#     actions   = ["s3:PutObject"]
#     resources = ["arn:aws:s3:::${aws_s3_bucket.alb_logs.bucket}/*"]
#   }
# }

# # Apply the IAM policy to the S3 bucket
# resource "aws_s3_bucket_policy" "alb_logs" {
#   bucket = aws_s3_bucket.alb_logs.id
#   policy = data.aws_iam_policy_document.alb_logs.json
# }
