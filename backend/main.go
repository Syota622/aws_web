package main

import (
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"

	"golang/handlers"
	"golang/models"
)

func main() {
	// 環境変数の読み込み
	dbUser := os.Getenv("DB_USER")
	dbPassword := os.Getenv("DB_PASSWORD")
	dbHost := os.Getenv("DB_HOST")
	dbPort := os.Getenv("DB_PORT")
	dbName := os.Getenv("DB_NAME")

	// デバッグ用に環境変数をログに出力
	log.Printf("DB_USER: %s, DB_PASSWORD: %s, DB_HOST: %s, DB_PORT: %s, DB_NAME: %s", dbUser, dbPassword, dbHost, dbPort, dbName)

	// DSN (Data Source Name) 文字列の生成
	dsn := dbUser + ":" + dbPassword + "@tcp(" + dbHost + ":" + dbPort + ")/" + dbName + "?charset=utf8mb4&parseTime=True&loc=Local"

	// // 環境変数からデータベース接続情報を取得
	// dsn := os.Getenv("DB_USER") + ":" + os.Getenv("DB_PASSWORD") + "@tcp(" + os.Getenv("DB_HOST") + ":" + os.Getenv("DB_PORT") + ")/" + os.Getenv("DB_NAME") + "?charset=utf8mb4&parseTime=True&loc=Local"

	// データベースに接続
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	// ユーザーモデルをマイグレーション
	db.AutoMigrate(&models.User{})

	// Ginのルーターを作成
	r := gin.Default()

	// ルートハンドラを追加
	r.GET("/", func(c *gin.Context) {
		c.String(200, "Hello, World!")
	})

	// サインアップハンドラにデータベース接続を渡す
	r.POST("/signup", func(c *gin.Context) {
		handlers.SignUpHandler(c, db)
	})

	// サーバーをポート8080で開始
	r.Run(":8080")
}
