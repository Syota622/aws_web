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
	log.Println("Starting database migration handler")

	// 環境変数から接続情報を取得
	dbURL := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s",
		os.Getenv("DB_USER"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_HOST"),
		os.Getenv("DB_PORT"),
		os.Getenv("DB_NAME"))

	log.Printf("Database connection URL: %s://*****@%s:%s/%s",
		os.Getenv("DB_USER"),
		os.Getenv("DB_HOST"),
		os.Getenv("DB_PORT"),
		os.Getenv("DB_NAME"))

	// マイグレーションインスタンスの作成
	log.Println("Creating migration instance")
	m, err := migrate.New(
		"file:///var/task/migrations",
		fmt.Sprintf("mysql://%s", dbURL))
	if err != nil {
		log.Printf("Error creating migrate instance: %v", err)
		return fmt.Errorf("error creating migrate instance: %v", err)
	}

	// 現在のバージョンを取得
	version, dirty, err := m.Version()
	if err != nil {
		log.Printf("Error getting current migration version: %v", err)
	} else {
		log.Printf("Current migration version: %d, Dirty: %v", version, dirty)
	}

	// マイグレーションの実行（最新バージョンまで）
	log.Println("Starting database migration")
	err = m.Up()
	if err != nil {
		if err == migrate.ErrNoChange {
			log.Println("No migration changes required")
			return nil
		}
		log.Printf("Error migrating database: %v", err)
		return fmt.Errorf("error migrating database: %v", err)
	}

	// 最終的なバージョンを取得
	finalVersion, finalDirty, err := m.Version()
	if err != nil {
		log.Printf("Error getting final migration version: %v", err)
	} else {
		log.Printf("Final migration version: %d, Dirty: %v", finalVersion, finalDirty)
	}

	log.Println("Database migration completed successfully")
	return nil
}

func main() {
	log.Println("Starting Lambda function")
	lambda.Start(handler)
}
