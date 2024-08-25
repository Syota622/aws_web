package main

import (
	"context"
	"fmt"
	"log"
	"os"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/mysql"
	_ "github.com/golang-migrate/migrate/v4/source/file"
)

func handler(ctx context.Context) error {
	log.Println("Starting database migration")

	// 環境変数から接続情報を取得
	dbURL := fmt.Sprintf("mysql://%s:%s@tcp(%s:%s)/%s",
		os.Getenv("DB_USERNAME"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_HOST"),
		os.Getenv("DB_PORT"),
		os.Getenv("DB_NAME"))

	log.Println("Creating migration instance")
	// マイグレーションインスタンスの作成
	m, err := migrate.New(
		"file:///var/task/migrations",
		dbURL)
	if err != nil {
		log.Printf("Error creating migrate instance: %v", err)
		return fmt.Errorf("error creating migrate instance: %v", err)
	}

	log.Println("Running database migration")
	// マイグレーションの実行（最新バージョンまで）
	err = m.Up()
	if err != nil && err != migrate.ErrNoChange {
		log.Printf("Error migrating database: %v", err)
		return fmt.Errorf("error migrating database: %v", err)
	}

	log.Println("Database migration completed successfully")
	return nil
}

func main() {
	lambda.Start(handler)
}
