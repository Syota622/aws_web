package main

import (
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"

	"golang/handlers"
	"golang/models"
)

func main() {
	// .envファイルを読み込み
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	// 環境変数からデータベース接続情報を取得
	dsn := os.Getenv("DB_USER") + ":" + os.Getenv("DB_PASSWORD") + "@tcp(" + os.Getenv("DB_HOST") + ":" + os.Getenv("DB_PORT") + ")/" + os.Getenv("DB_NAME") + "?charset=utf8mb4&parseTime=True&loc=Local"

	// データベースに接続
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	// ユーザーモデルをマイグレーション
	db.AutoMigrate(&models.User{})

	// Ginのルーターを作成
	r := gin.Default()

	// ハンドラにデータベース接続を渡す
	r.POST("/signup", func(c *gin.Context) {
		handlers.SignUpHandler(c, db)
	})

	// サーバーをポート8080で開始
	r.Run(":8080")
}
