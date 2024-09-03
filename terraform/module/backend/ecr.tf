### Elastic Container Registry
resource "aws_ecr_repository" "private_repository" {
  name                 = "${var.pj}-private-repository-${var.env}"
  image_tag_mutability = "MUTABLE"
  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.pj}-private-repository-${var.env}"
  }
}

resource "aws_ecr_lifecycle_policy" "private_repository_policy" {
  repository = aws_ecr_repository.private_repository.name
  policy     = <<POLICY
    {
      "rules": [
        {
          "rulePriority": 1,
          "description": "Expire images older than 1 day",
          "selection": {
            "tagStatus": "any",
            "countType": "imageCountMoreThan",
            "countNumber": 7
          },
          "action": {
            "type": "expire"
          }
        }
      ]
    }
  POLICY
}
