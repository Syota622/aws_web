# go
go get -u github.com/gin-gonic/gin
RUN go get -u gorm.io/gorm
RUN go get -u gorm.io/driver/mysql
RUN go get -u golang.org/x/crypto/bcrypt
go get github.com/joho/godotenv

# docker compose
docker-compose up --build
docker compose exec db mysql -u root -D myapp -ppassword

# Curl
```sh
curl -X POST http://localhost:8080/signup \
    -H "Content-Type: application/json" \
    -d '{
        "username": "testuser",
        "password": "password123",
        "email": "testuser@example.com"
    }'
curl -X POST https://api.mokokero.com/signup \
    -H "Content-Type: application/json" \
    -d '{
        "username": "testuser",
        "password": "password123",
        "email": "testuser@example.com"
    }'
```
