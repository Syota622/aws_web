# S3 バケットを作成して 設定ファイルを保存
resource "aws_s3_bucket" "backend_config" {
  bucket = "${var.pj}-backend-config-${var.env}"
}

# S3 バケットにオブジェクトをアップロード
resource "aws_s3_object" "firelens_config" {
  bucket = aws_s3_bucket.backend_config.id
  key    = "firelens/fluent-bit.conf"
  source = "${path.module}/firelens/fluent-bit.conf"  # ローカルのファイルパスを指定
  etag   = filemd5("${path.module}/firelens/fluent-bit.conf")
}
