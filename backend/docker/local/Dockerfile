### ビルド用ステージ ###
FROM golang:1.22-alpine as builder

WORKDIR /app
COPY go.mod ./
COPY go.sum ./
RUN go mod download

# プロジェクト全体をコピー
COPY . .

# CGoを無効化してビルド
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -o main .

### 開発用ステージ ###
FROM golang:1.22-alpine as development

# バッケージのインストール
RUN apk update
RUN apk add vim git mysql-client jq

# /appに移動
WORKDIR /app

# builderからmainをコピー
COPY --from=builder /app/main .

# 環境変数を読み込んでMySQLに接続するスクリプトを追加
COPY connect_to_mysql.sh /app/connect_to_mysql.sh
RUN chmod +x /app/connect_to_mysql.sh

# migrateツールのインストール
RUN go install -tags 'mysql' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

# gormのツールのインストール
RUN go install gorm.io/gen/tools/gentool@latest

# airのインストール
RUN go install github.com/cosmtrek/air@v1.44.0
CMD ["air"]
