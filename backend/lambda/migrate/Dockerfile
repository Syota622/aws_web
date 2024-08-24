# ビルドステージ
FROM golang:1.21.3 as build

WORKDIR /app

# Go modulesファイルをコピーし、依存関係をダウンロード
COPY lambda/migrate/go.mod lambda/migrate/go.sum ./
RUN go mod download

# マイグレーションコードをコピーしてビルド
COPY lambda/migrate/migrate.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -o main

# 実行ステージ
FROM public.ecr.aws/lambda/provided:al2023

# ビルドしたバイナリをLambdaのランタイムディレクトリにコピー
COPY --from=build /app/main ${LAMBDA_RUNTIME_DIR}/bootstrap

# マイグレーションファイルをタスクルートディレクトリにコピー
COPY db/migrations ${LAMBDA_TASK_ROOT}/migrations

# Lambdaハンドラーを指定
CMD [ "bootstrap" ]
