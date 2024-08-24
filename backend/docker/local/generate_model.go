package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"time"

	"gorm.io/driver/mysql"
	"gorm.io/gen"
	"gorm.io/gorm"
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
	if dbConfigJSON == "" {
		log.Fatal("環境変数 DB_CONFIG が設定されていません")
	}

	// JSON文字列をDBConfig構造体にパース
	var dbConfig DBConfig
	if err := json.Unmarshal([]byte(dbConfigJSON), &dbConfig); err != nil {
		log.Fatalf("データベース接続情報のパースに失敗しました: %v", err)
	}

	// 接続を試みるホスト名のリスト
	hosts := []string{dbConfig.DBHost, "localhost", "127.0.0.1"}

	var db *gorm.DB
	var err error

	for _, host := range hosts {
		// DSN (Data Source Name) 文字列の生成
		dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=utf8mb4&parseTime=True&loc=Local&timeout=5s",
			dbConfig.DBUser, dbConfig.DBPassword, host, dbConfig.DBPort, dbConfig.DBName)

		log.Printf("接続を試みています: %s", dsn)

		// データベース接続を試みる
		db, err = gorm.Open(mysql.Open(dsn), &gorm.Config{})
		if err == nil {
			log.Printf("接続成功: %s", host)
			break
		}

		log.Printf("接続失敗: %s, エラー: %v", host, err)
		time.Sleep(time.Second) // 次の試行前に少し待機
	}

	if err != nil {
		log.Fatalf("すべての接続試行が失敗しました。最後のエラー: %v", err)
	}

	// Generator設定
	g := gen.NewGenerator(gen.Config{
		OutPath: "infra/model",
		Mode:    gen.WithoutContext | gen.WithDefaultQuery | gen.WithQueryInterface,
	})

	// データベースを使用
	g.UseDB(db)

	// モデル生成
	g.GenerateAllTable()

	// コード生成
	g.Execute()

	log.Println("モデル生成が完了しました")
}
