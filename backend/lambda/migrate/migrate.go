package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/secretsmanager"
	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/mysql"
	_ "github.com/golang-migrate/migrate/v4/source/file"
)

type DBConfig struct {
	Host     string `json:"DB_HOST"`
	Name     string `json:"DB_NAME"`
	Password string `json:"DB_PASSWORD"`
	Port     string `json:"DB_PORT"`
	User     string `json:"DB_USER"`
}

func handler(ctx context.Context) error {
	log.Println("Starting database migration handler")

	// SecretsManagerから接続情報を取得
	secretID := os.Getenv("SECRETS_MANAGER_SECRET_ARN")
	dbConfig, err := getDBConfigFromSecretsManager(secretID)
	if err != nil {
		log.Printf("Error getting DB config from Secrets Manager: %v", err)
		return fmt.Errorf("error getting DB config from Secrets Manager: %v", err)
	}

	// データベース接続URLの構築
	dbURL := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s",
		dbConfig.User,
		dbConfig.Password,
		dbConfig.Host,
		dbConfig.Port,
		dbConfig.Name)

	log.Printf("Database connection URL: %s://*****@%s:%s/%s",
		dbConfig.User,
		dbConfig.Host,
		dbConfig.Port,
		dbConfig.Name)

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
	if err != nil && err != migrate.ErrNilVersion {
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

// SecretsManagerから接続情報を取得
func getDBConfigFromSecretsManager(secretID string) (*DBConfig, error) {
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String("ap-northeast-1"), // リージョンを適切に設定してください
	})
	if err != nil {
		return nil, fmt.Errorf("error creating AWS session: %v", err)
	}

	svc := secretsmanager.New(sess)

	input := &secretsmanager.GetSecretValueInput{
		SecretId: aws.String(secretID),
	}

	result, err := svc.GetSecretValue(input)
	if err != nil {
		return nil, err
	}

	var dbConfig DBConfig
	err = json.Unmarshal([]byte(*result.SecretString), &dbConfig)
	if err != nil {
		return nil, err
	}

	return &dbConfig, nil
}

func main() {
	log.Println("Starting Lambda function")
	lambda.Start(handler)
}
