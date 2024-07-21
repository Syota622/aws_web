package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"

	"github.com/99designs/gqlgen/graphql/handler"
	"github.com/99designs/gqlgen/graphql/playground"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"

	"golang/auth"
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

// graphqlHandler はGraphQLのハンドラを返す関数です
func graphqlHandler(srv *handler.Server) gin.HandlerFunc {
	return func(c *gin.Context) {
		srv.ServeHTTP(c.Writer, c.Request)
	}
}

// playgroundHandler はGraphQL Playgroundのハンドラを返す関数です
func playgroundHandler() gin.HandlerFunc {
	h := playground.Handler("GraphQL playground", "/query")
	return func(c *gin.Context) {
		c.Header("Content-Type", "text/html; charset=utf-8")
		h.ServeHTTP(c.Writer, c.Request)
	}
}

func main() {
	// Cognitoクライアントの初期化
	if err := auth.InitCognitoClient(); err != nil {
		log.Fatalf("Cognitoクライアントの初期化に失敗しました: %v", err)
	}

	// 環境変数からJSON文字列を取得
	dbConfigJSON := os.Getenv("DB_CONFIG")

	// JSON文字列をDBConfig構造体にパース
	var dbConfig DBConfig
	if err := json.Unmarshal([]byte(dbConfigJSON), &dbConfig); err != nil {
		log.Fatalf("データベース接続情報のパースに失敗しました: %v", err)
	}

	// DSN (Data Source Name) 文字列の生成
	dsn := dbConfig.DBUser + ":" + dbConfig.DBPassword + "@tcp(" + dbConfig.DBHost + ":" + dbConfig.DBPort + ")/" + dbConfig.DBName + "?charset=utf8mb4&parseTime=True&loc=Local"

	// データベース接続部分
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatalf("データベース接続に失敗しました: %v", err)
	}

	// 通常のAutoMigrate
	if err := db.AutoMigrate(&models.User{}); err != nil {
		log.Fatalf("AutoMigrateに失敗しました: %v", err)
	}

	// Ginのルーターを作成
	r := gin.Default()

	// CORS設定
	config := cors.DefaultConfig()
	config.AllowAllOrigins = true
	config.AllowHeaders = append(config.AllowHeaders, "Authorization")
	r.Use(cors.New(config))

	// Resolverの初期化
	resolver := &graph.Resolver{
		DB: db,
	}

	// GraphQLのエンドポイントとプレイグラウンドのハンドラを設定
	srv := handler.NewDefaultServer(generated.NewExecutableSchema(generated.Config{Resolvers: resolver}))
	r.POST("/query", graphqlHandler(srv))
	r.GET("/graphiql", playgroundHandler())

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
