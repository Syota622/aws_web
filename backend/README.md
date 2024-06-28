# docker compose
docker-compose up --build
docker compose exec web sh
docker compose exec db mysql -u root -D myapp -ppassword

# Curl
```sh
curl -X POST http://localhost:8080/signup \
    -H "Content-Type: application/json" \
    -H "X-Custom-Header: YourSecretValue" \
    -d '{
        "username": "testuser1",
        "password": "password1",
        "email": "testuser1@example.com"
    }'
curl -X POST https://api.mokokero.com/signup \
    -H "Content-Type: application/json" \
    -d '{
        "username": "testuser",
        "password": "password123",
        "email": "testuser@example.com"
    }'
```

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

# GraphQL
1. schema.graphqls ファイルを更新
2. go run github.com/99designs/gqlgen generate
