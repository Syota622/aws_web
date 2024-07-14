# infra-learn
infra-learn

# terraform import(moduleの場合)
terraform import module.tf_backend.aws_dynamodb_table.terraform_state_lock learn-terraform-lock-prod
terraform import module.tf_backend.aws_s3_bucket.terraform_tfstate_s3 learn-terraform-tfstate-prod
terraform import module.tf_backend.aws_s3_bucket_ownership_controls.tfstate_s3_acl learn-terraform-tfstate-prod
terraform import module.tf_backend.aws_s3_bucket_public_access_block.tfstate_s3_private learn-terraform-tfstate-prod
terraform import module.tf_backend.aws_s3_bucket_server_side_encryption_configuration.tfstate_s3_encryption learn-terraform-tfstate-prod
terraform import module.tf_backend.aws_s3_bucket_versioning.tfstate_s3_versioning learn-terraform-tfstate-prod

# ローカルからECSへのログイン方法（ECS Exec）
aws ecs execute-command --cluster learn-ecs-cluster-prod --task 598479cd4ffd4eae9ee864580bef4b50 --container learn-container-prod --interactive --command "sh"
