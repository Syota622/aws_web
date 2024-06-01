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

# アップデートとvim,git, mysql-clientのインストール
RUN apk update && apk add vim git mysql-client

# /appに移動
WORKDIR /app

# builderからmainをコピー
COPY --from=builder /app/main .

# airのインストール
RUN go install github.com/cosmtrek/air@latest
CMD ["air"]
