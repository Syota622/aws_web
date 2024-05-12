### state lock用のDynamoDB ###
resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "${var.pj}-terraform-lock-${var.env}"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "${var.pj}-terraform-lock-${var.env}"
  }

}
