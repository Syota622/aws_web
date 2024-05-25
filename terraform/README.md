# infra-learn
infra-learn

# terraform import(moduleの場合)
terraform import module.tf_backend.aws_dynamodb_table.terraform_state_lock learn-terraform-lock-prod
terraform import module.tf_backend.aws_s3_bucket.terraform_tfstate_s3 learn-terraform-tfstate-prod
terraform import module.tf_backend.aws_s3_bucket_ownership_controls.tfstate_s3_acl learn-terraform-tfstate-prod
terraform import module.tf_backend.aws_s3_bucket_public_access_block.tfstate_s3_private learn-terraform-tfstate-prod
terraform import module.tf_backend.aws_s3_bucket_server_side_encryption_configuration.tfstate_s3_encryption learn-terraform-tfstate-prod
terraform import module.tf_backend.aws_s3_bucket_versioning.tfstate_s3_versioning learn-terraform-tfstate-prod

aws s3 cp s3://learn-terraform-tfstate-prod/terraform.tfstate .

# 手動構築したAWSサービス
- Route53
- ACM
- SecretsManager
