# go
go get -u github.com/gin-gonic/gin
RUN go get -u gorm.io/gorm
RUN go get -u gorm.io/driver/mysql
RUN go get -u golang.org/x/crypto/bcrypt
go get github.com/joho/godotenv

# docker compose
docker-compose up --build

# Curl
