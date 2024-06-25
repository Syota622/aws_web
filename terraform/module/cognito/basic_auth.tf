resource "aws_cognito_user_pool" "basic_access" {
  name                     = "${var.pj}-basic-auth"
  auto_verified_attributes = ["email"]
  deletion_protection      = "ACTIVE"
  username_attributes      = ["email"]

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true

    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }

  user_attribute_update_settings {
    attributes_require_verification_before_update = [
      "email",
    ]
  }

  username_configuration {
    case_sensitive = false
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }
}

resource "aws_cognito_user_pool_domain" "basic_access" {
  user_pool_id = aws_cognito_user_pool.basic_access.id
  domain       = "mokokero-internal"
}

resource "aws_cognito_user_pool_client" "basic_access" {
  name         = "${var.pj}-basic-${var.env}"
  user_pool_id = aws_cognito_user_pool.basic_access.id
  generate_secret     = true

  access_token_validity                = 60
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["openid"]
  auth_session_validity                = 3
  callback_urls = [
    "https://api.mokokero.com/oauth2/idpresponse",
    "https://learn-ecs-alb-prod-50152165.ap-northeast-1.elb.amazonaws.com/oauth2/idpresponse",
  ]
  enable_propagate_additional_user_context_data = false
  enable_token_revocation                       = true
  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]
  id_token_validity = 60
  logout_urls       = []

  prevent_user_existence_errors = "ENABLED"
  read_attributes = [
    "address",
    "birthdate",
    "email",
    "email_verified",
    "family_name",
    "gender",
    "given_name",
    "locale",
    "middle_name",
    "name",
    "nickname",
    "phone_number",
    "phone_number_verified",
    "picture",
    "preferred_username",
    "profile",
    "updated_at",
    "website",
    "zoneinfo",
  ]
  refresh_token_validity = 30
  supported_identity_providers = [
    "COGNITO",
  ]
  write_attributes = [
    "address",
    "birthdate",
    "email",
    "family_name",
    "gender",
    "given_name",
    "locale",
    "middle_name",
    "name",
    "nickname",
    "phone_number",
    "picture",
    "preferred_username",
    "profile",
    "updated_at",
    "website",
    "zoneinfo",
  ]

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

}
