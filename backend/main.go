package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"

	"github.com/99designs/gqlgen/graphql/handler"
	"github.com/99designs/gqlgen/graphql/playground"
	"github.com/gin-gonic/gin"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"

	"golang/handlers"
	"golang/models"

	"golang/graph/generated"
	graph "golang/graph/resolver"
)

// DBConfig はデータベース接続情報を保持する構造体です
type DBConfig struct {
	DBHost     string `json:"DB_HOST"`
	DBName     string `json:"DB_NAME"`
	DBPassword string `json:"DB_PASSWORD"`
	DBPort     string `json:"DB_PORT"`
	DBUser     string `json:"DB_USER"`
}

// recoveryMiddleware はパニックを回復するミドルウェアです
func recoveryMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		defer func() {
			if r := recover(); r != nil {
				log.Printf("Recovered from panic: %v", r)
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Internal server error"})
			}
		}()
		c.Next()
	}
}

func main() {
	// 環境変数からJSON文字列を取得
	// DB_CONFIG={"DB_HOST":"1","DB_NAME":"2","DB_PASSWORD":"3","DB_PORT":"4","DB_USER":"5"}
	dbConfigJSON := os.Getenv("DB_CONFIG")

	// JSON文字列をDBConfig構造体にパース
	var dbConfig DBConfig
	if err := json.Unmarshal([]byte(dbConfigJSON), &dbConfig); err != nil {
		log.Fatalf("Failed to parse DB config JSON: %v", err)
	}

	// DSN (Data Source Name) 文字列の生成
	dsn := dbConfig.DBUser + ":" + dbConfig.DBPassword + "@tcp(" + dbConfig.DBHost + ":" + dbConfig.DBPort + ")/" + dbConfig.DBName + "?charset=utf8mb4&parseTime=True&loc=Local"

	// データベース接続部分
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		log.Fatalf("failed to connect database: %v", err)
	}

	// ユーザーモデルをマイグレーション
	db.AutoMigrate(&models.User{})

	// Ginのルーターを作成
	r := gin.Default()
	r.Use(recoveryMiddleware())

	// Resolverの初期化
	resolver := &graph.Resolver{
		DB: db,
	}

	// GraphQLのエンドポイントとプレイグラウンドのハンドラを設定
	srv := handler.NewDefaultServer(generated.NewExecutableSchema(generated.Config{Resolvers: resolver}))
	r.POST("/query", func(c *gin.Context) {
		srv.ServeHTTP(c.Writer, c.Request)
	})
	r.GET("/graphiql", func(c *gin.Context) {
		playground.Handler("GraphQL", "/query").ServeHTTP(c.Writer, c.Request)
	})

	// ルートハンドラを追加
	r.GET("/", func(c *gin.Context) {
		c.String(200, "Hello, World!")
	})

	// カスタムヘッダーをチェックするミドルウェア
	authMiddleware := func(c *gin.Context) {
		customHeader := c.GetHeader("X-Custom-Header")
		// 仮で設定したシークレット値と一致しない場合は403を返す。後ほど環境変数に置き換える
		if customHeader != "YourSecretValue" {
			c.AbortWithStatus(http.StatusForbidden)
			return
		}
		c.Next()
	}

	// /signupルートにのみミドルウェアを適用
	signupGroup := r.Group("/")
	signupGroup.Use(authMiddleware)
	signupGroup.POST("/signup", func(c *gin.Context) {
		handlers.SignUpHandler(c, db)
	})

	// サーバーをポート8080で開始
	r.Run(":8080")
}
