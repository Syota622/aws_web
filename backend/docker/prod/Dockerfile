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

# # 依存関係をダウンロード
# RUN go mod download

# CGoを無効化してビルド
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -ldflags="-s -w" main .
# RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -o main .
# RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -o /app -ldflags="-s -w" cmd/main.go

### 本番用ステージ ###
FROM alpine:3.19.1 as production

# バッケージのインストール
RUN apk update
RUN apk add vim git mysql-client jq

WORKDIR /app

COPY --from=builder /app/main .

# 環境変数を読み込んでMySQLに接続するスクリプトを追加
COPY backend/connect_to_mysql.sh /app/connect_to_mysql.sh
RUN chmod +x /app/connect_to_mysql.sh

CMD ["./main"]
