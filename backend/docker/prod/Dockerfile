### ビルド用ステージ ###
FROM golang:1.22-alpine as builder

WORKDIR /app

# プロジェクト全体をコピー
COPY backend/go.mod backend/go.sum ./
RUN go mod download

COPY backend/. .

# CGoを無効化してビルド
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -ldflags="-s -w" -o main .

### 本番用ステージ ###
FROM alpine:3.19.1 as production

# 必要なパッケージのインストールとキャッシュのクリア
RUN apk update && apk add --no-cache mysql-client jq

WORKDIR /app

COPY --from=builder /app/main .

# 環境変数を読み込んでMySQLに接続するスクリプトを追加
COPY backend/connect_to_mysql.sh /app/connect_to_mysql.sh
RUN chmod +x /app/connect_to_mysql.sh

CMD ["./main"]