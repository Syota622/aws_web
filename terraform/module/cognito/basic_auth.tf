# ユーザープール
resource "aws_cognito_user_pool" "basic_access" {

  name                     = "${var.pj}-basic-auth"
  deletion_protection      = "ACTIVE"  # 誤削除防止
  auto_verified_attributes = ["email"] # メールアドレスを自動検証
  username_attributes      = ["email"] # メールアドレスをユーザー名として使用

  # 管理者によるユーザー作成の設定
  admin_create_user_config {
    allow_admin_create_user_only = true # 管理者のみがユーザーを作成可能
  }

  # Cognito のデフォルトメール送信を使用
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # パスワードポリシーの設定
  password_policy {
    minimum_length                   = 8    # 最小8文字
    require_lowercase                = true # 小文字必須
    require_numbers                  = true # 数字必須
    require_symbols                  = true # 記号必須
    require_uppercase                = true # 大文字必須
    temporary_password_validity_days = 7    # 一時パスワードの有効期限は7日間
  }

  # ユーザー名の設定
  username_configuration {
    case_sensitive = false # ユーザー名の大文字小文字を区別しない
  }

  # ユーザー属性のスキーマ定義
  schema {
    attribute_data_type      = "String" # 文字列型
    developer_only_attribute = false    # 開発者専用属性ではない
    mutable                  = true     # 変更可能
    name                     = "email"  # 属性名は "email"
    required                 = true     # 必須属性

    # 文字列属性の制約
    string_attribute_constraints {
      max_length = "2048" # 最大長
      min_length = "0"    # 最小長
    }
  }

  # 既存の設定を維持するための追加設定
  lifecycle {
    ignore_changes = [
      schema
    ]
  }
}

# Cognito ユーザープールのドメイン設定
resource "aws_cognito_user_pool_domain" "basic_access" {

  user_pool_id = aws_cognito_user_pool.basic_access.id
  domain       = "learn-internal"
}

# Cognito ユーザープールクライアント
resource "aws_cognito_user_pool_client" "basic_access" {

  name         = "${var.pj}-backend-${var.env}"
  user_pool_id = aws_cognito_user_pool.basic_access.id

  generate_secret = true # クライアントシークレットを生成

  access_token_validity                = 60         # アクセストークンの有効期間（分）
  allowed_oauth_flows                  = ["code"]   # 許可する OAuth フロー
  allowed_oauth_flows_user_pool_client = true       # ユーザープールクライアントで OAuth フローを許可
  allowed_oauth_scopes                 = ["openid"] # 許可する OAuth スコープ
  auth_session_validity                = 3          # 認証セッションの有効期間（日）

  # コールバック URL（認証後のリダイレクト先）
  callback_urls = [
    local.basic_callback_urls[var.env],
    "https://${var.alb_dns}/oauth2/idpresponse"
  ]

  enable_token_revocation = true # トークンの取り消しを有効化

  # 明示的に許可する認証フロー
  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH", # リフレッシュトークンによる認証を許可
    "ALLOW_USER_SRP_AUTH",      # SRP (Secure Remote Password) 認証を許可
  ]

  id_token_validity = 60 # ID トークンの有効期間（分）

  prevent_user_existence_errors = "ENABLED"   # ユーザー存在エラーの防止を有効化
  refresh_token_validity        = 1           # リフレッシュトークンの有効期間（日）
  supported_identity_providers  = ["COGNITO"] # サポートするIDプロバイダ

  # トークンの有効期間の単位設定
  token_validity_units {
    access_token  = "minutes" # アクセストークンは分単位
    id_token      = "minutes" # ID トークンは分単位
    refresh_token = "days"    # リフレッシュトークンは日単位
  }
}
