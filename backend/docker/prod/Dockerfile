### ビルド用ステージ ###
FROM golang:1.22-alpine as builder

WORKDIR /app
COPY . .
# COPY go.mod ./
# COPY go.sum ./
RUN go mod download

# プロジェクト全体をコピー
COPY . .

# CGoを無効化してビルド
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -o main .

### 本番用ステージ ###
FROM alpine:3.19.1 as production

# アップデートとvim,gitのインストール
RUN apk update && apk add vim git

WORKDIR /app

COPY --from=builder /app/main .

CMD ["./main"]
