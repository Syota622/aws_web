# DB マイグレーションLambda機能のビルドと適用手順

## 0. 前準備

1. `lambda/migrate` ディレクトリに移動します：
   ```
   cd lambda/migrate
   ```

2. go.modファイルを初期化します：
   ```
   go mod init db-migration-lambda
   ```

3. 依存関係をダウンロードし、go.sumファイルを生成します：
   ```
   go mod tidy
   ```

4. プロジェクトのルートディレクトリに戻ります：
   ```
   cd ../..
   ```

## 1. ECRへのプッシュ

1. AWS CLIを使用してECRにログインします（リージョンを適切に置き換えてください）：
   ```
   aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.ap-northeast-1.amazonaws.com
   ```

2. Dockerfileからイメージをビルドします：
   ```
   docker build -t learn-db-migration-lambda-prod -f lambda/migrate/Dockerfile .
   ```

3. イメージにタグを付けます：
   ```
   docker tag learn-db-migration-lambda-prod:latest 123456789012.dkr.ecr.ap-northeast-1.amazonaws.com/learn-db-migration-lambda-prod:latest
   ```

4. イメージをプッシュします：
   ```
   docker push 123456789012.dkr.ecr.ap-northeast-1.amazonaws.com/learn-db-migration-lambda-prod:latest
   ```

## 2. Lambda関数の更新（必要な場合）

ECRのイメージを更新した後、Lambda関数も更新する必要がある場合は以下の手順を実行します：

1. AWS CLIを使用してLambda関数を更新します：
   ```
   aws lambda update-function-code --function-name learn-db-migration-lambda-prod --image-uri 123456789012.dkr.ecr.ap-northeast-1.amazonaws.com/learn-db-migration-lambda-prod:latest
   ```

## 3. ローカルでのテスト
```
   docker run --rm -p 9000:8080 learn-db-migration-lambda-prod:latest
```

```
   curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'
```

[LambdaのDocker構築やローカルテスト:参考資料](https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/go-image.html#go-image-provided)
