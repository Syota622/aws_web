# docker compose
docker-compose build --no-cache
docker-compose up -d
docker-compose up --build
docker compose exec web sh
docker compose exec db mysql -u root -D myapp -ppassword

# go
go get -u github.com/gin-gonic/gin
RUN go get -u gorm.io/gorm
RUN go get -u gorm.io/driver/mysql
RUN go get -u golang.org/x/crypto/bcrypt
go get github.com/joho/godotenv 
go get -u github.com/99designs/gqlgen
go get github.com/99designs/gqlgen/graphql/handler/transport@v0.17.49
go get github.com/99designs/gqlgen@v0.17.49
go get github.com/99designs/gqlgen/codegen/config@v0.17.49
go get github.com/99designs/gqlgen/internal/imports@v0.17.49
go get github.com/gin-contrib/cors
go get github.com/aws/aws-sdk-go-v2/config 
go get github.com/aws/aws-sdk-go-v2/service/cognitoidentityprovider

# GraphQL
1. graph/schema/*.graphql ファイルを更新
2. go run -mod=mod github.com/99designs/gqlgen generate

# go: モジュールトラブルシューティング
- rm go.mod go.sum
- go mod init golang
- go get ./...
- go mod tidy

# curl
```sh
curl -X POST http://localhost:8080/signup \
    -H "Content-Type: application/json" \
    -H "X-Custom-Header: YourSecretValue111" \
    -d '{
        "username": "testuser100",
        "password": "password100",
        "email": "testuser100@example.com"
    }'

curl -X POST https://api.mokokero.com/signup \
    -H "Content-Type: application/json" \
    -d '{
        "username": "testuser",
        "password": "password123",
        "email": "testuser@example.com"
    }'

curl -X POST http://localhost:8080/query \
-H "Content-Type: application/json" \
-d '{
  "query": "mutation($input: LoginInput!) { login(input: $input) { token user { id username email } errors { field message } } }",
  "variables": {
    "input": {
      "email": "testuser100@example.com",
      "password": "password100"
    }
  }
}'
```

# graphql
```graphql
mutation Login($input: LoginInput!) {
  login(input: $input) {
    token
    user {
      id
      username
      email
    }
    errors {
      field
      message
    }
  }
}
# variables
{
  "input": {
    "email": "testuser1@example.com",
    "password": "password1"
  }
}
```

# 参考記事
- ディレクトリ構成が非常に役にたつ
https://qiita.com/WebEngrChild/items/d9b87944235c5220ae5b

- ドメイン駆動設計(DDD)
https://service.shiftinc.jp/column/4654/

- Goで学ぶClean Architecture入門
https://qiita.com/arakawa_moriyuki/items/59ce00542d5859d60a2d

- CleanArchitectureとドメイン駆動設計の違い
https://qiita.com/tominagaaaaaa/items/d3b4f96f21dadcac790a
