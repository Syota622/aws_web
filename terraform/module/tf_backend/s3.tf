### tfstate用のS3バケット ###
resource "aws_s3_bucket" "terraform_tfstate_s3" {
  bucket = "${var.pj}-terraform-tfstate-${var.env}"

  tags = {
    Name = "${var.pj}-terraform-${var.env}"
  }

}
# public access enabled
resource "aws_s3_bucket_public_access_block" "tfstate_s3_private" {
  bucket                  = aws_s3_bucket.terraform_tfstate_s3.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
# versioning enabled
resource "aws_s3_bucket_versioning" "tfstate_s3_versioning" {
  bucket = aws_s3_bucket.terraform_tfstate_s3.id
  versioning_configuration {
    status = "Disabled"
  }
}
# encrypt
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate_s3_encryption" {
  bucket = aws_s3_bucket.terraform_tfstate_s3.id
  
  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
# acl disabled
resource "aws_s3_bucket_ownership_controls" "tfstate_s3_acl" {
  bucket = aws_s3_bucket.terraform_tfstate_s3.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}