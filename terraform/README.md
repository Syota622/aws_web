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

# Cognito
新規にユーザーを作成
```sh
aws cognito-idp admin-create-user \
  --user-pool-id ap-northeast-1_????? \
  --username testuser \
  --temporary-password Passw0rd! \
  --user-attributes Name=email,Value=testuser@gmail.com Name=email_verified,Value=true \
  --region ap-northeast-1
```
パスワードを永続的に設定し、ユーザーステータスを "CONFIRMED" に変更する
```sh
aws cognito-idp admin-set-user-password \
  --user-pool-id ap-northeast-1_????? \
  --username testuser@gmail.com \
  --password Passw0rd! \
  --permanent \
  --region ap-northeast-1
```
Cognitoのログイン
```sh
aws cognito-idp initiate-auth \
  --auth-flow USER_PASSWORD_AUTH \
  --client-id ??????? \
  --auth-parameters USERNAME=testuser,PASSWORD=Passw0rd! \
  --region ap-northeast-1
```
