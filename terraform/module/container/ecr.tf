### Elastic Container Registry
resource "aws_ecr_repository" "private_repository" {
  name                 = "${var.pj}-private-repository"
  image_tag_mutability = "MUTABLE"
  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.pj}-private-repository"
  }
}
