package main

import (
	"encoding/json"
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"

	"golang/handlers"
	"golang/models"
)

// DBConfig はデータベース接続情報を保持する構造体です
type DBConfig struct {
	DBHost     string `json:"DB_HOST"`
	DBName     string `json:"DB_NAME"`
	DBPassword string `json:"DB_PASSWORD"`
	DBPort     string `json:"DB_PORT"`
	DBUser     string `json:"DB_USER"`
}

func main() {
	// 環境変数からJSON文字列を取得
	dbConfigJSON := os.Getenv("DB_CONFIG")

	// JSON文字列をDBConfig構造体にパース
	var dbConfig DBConfig
	if err := json.Unmarshal([]byte(dbConfigJSON), &dbConfig); err != nil {
		log.Fatalf("Failed to parse DB config JSON: %v", err)
	}

	// DSN (Data Source Name) 文字列の生成
	dsn := dbConfig.DBUser + ":" + dbConfig.DBPassword + "@tcp(" + dbConfig.DBHost + ":" + dbConfig.DBPort + ")/" + dbConfig.DBName + "?charset=utf8mb4&parseTime=True&loc=Local"

	// データベースに接続
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
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
