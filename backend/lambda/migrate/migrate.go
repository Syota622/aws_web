package main

import (
	"context"
	"fmt"
	"os"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/mysql"
	_ "github.com/golang-migrate/migrate/v4/source/file"
)

func handler(ctx context.Context) error {
	// 環境変数から接続情報を取得
	dbURL := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s",
		os.Getenv("DB_USER"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_HOST"),
		os.Getenv("DB_PORT"),
		os.Getenv("DB_NAME"))

	// マイグレーションインスタンスの作成
	m, err := migrate.New(
		"file:///var/task/migrations",
		fmt.Sprintf("mysql://%s", dbURL))
	if err != nil {
		return fmt.Errorf("error creating migrate instance: %v", err)
	}

	// マイグレーションの実行（最新バージョンまで）
	err = m.Up()
	if err != nil && err != migrate.ErrNoChange {
		return fmt.Errorf("error migrating database: %v", err)
	}

	return nil
}

func main() {
	lambda.Start(handler)
}
