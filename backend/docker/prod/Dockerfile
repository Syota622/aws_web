### ビルド用ステージ ###
FROM golang:1.22-alpine as builder

WORKDIR /app

# 必要なファイルをコピー
COPY backend/go.mod ./
COPY backend/go.sum ./

# 依存関係をダウンロード
RUN go mod download

# プロジェクト全体をコピー
COPY backend/. .

# CGoを無効化してビルド
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -o main .

### 本番用ステージ ###
FROM alpine:3.19.1 as production

# バッケージのインストール
RUN apk update
RUN apk add vim git mysql-client jq

WORKDIR /app

COPY --from=builder /app/main .

# 環境変数を読み込んでMySQLに接続するスクリプトを追加
COPY connect_to_mysql.sh /usr/local/bin/connect_to_mysql.sh
RUN chmod +x /usr/local/bin/connect_to_mysql.sh

CMD ["./main"]
