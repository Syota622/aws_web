package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"strconv"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/secretsmanager"
	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/mysql"
	_ "github.com/golang-migrate/migrate/v4/source/file"
)

// DBConfig は、データベース接続情報を保持する構造体です
type DBConfig struct {
	Username string `json:"username"`
	Password string `json:"password"`
	Host     string `json:"host"`
	Port     string `json:"port"`
	DBName   string `json:"dbname"`
}

func handler(ctx context.Context) error {
	log.Println("Handler function started")

	// Secrets Managerから接続情報を取得
	secretID := os.Getenv("SECRETS_MANAGER_SECRET_ARN")
	log.Printf("Attempting to get DB config from Secrets Manager. Secret ID: %s", secretID)
	dbConfig, err := getDBConfigFromSecretsManager(secretID)
	if err != nil {
		log.Printf("Error getting DB config from Secrets Manager: %v", err)
		return fmt.Errorf("error getting DB config from Secrets Manager: %v", err)
	}
	log.Println("Successfully retrieved DB config from Secrets Manager")

	// データベース接続URLの構築
	dbURL := fmt.Sprintf("mysql://%s:%s@tcp(%s:%s)/%s",
		dbConfig.Username,
		"[REDACTED]", // パスワードをログに出力しないよう注意
		dbConfig.Host,
		dbConfig.Port,
		dbConfig.DBName)
	log.Printf("Constructed DB URL: %s", dbURL)

	// マイグレーションインスタンスの作成
	log.Println("Creating migration instance")
	m, err := migrate.New(
		"file:///var/task/migrations",
		dbURL)
	if err != nil {
		log.Printf("Error creating migrate instance: %v", err)
		return fmt.Errorf("error creating migrate instance: %v", err)
	}
	log.Println("Successfully created migration instance")

	// マイグレーションの実行
	version := os.Getenv("VERSION")
	log.Printf("Migration version: %s", version)
	if version == "" {
		log.Println("Executing migration up")
		err = m.Up()
		if err != nil && err != migrate.ErrNoChange {
			log.Printf("Error migrating up: %v", err)
			return fmt.Errorf("error migrating up: %v", err)
		}
	} else {
		versionUint, err := strconv.ParseUint(version, 10, 64)
		if err != nil {
			log.Printf("Error parsing version: %v", err)
			return fmt.Errorf("error parsing version: %v", err)
		}
		log.Printf("Migrating to version: %d", versionUint)
		err = m.Migrate(uint(versionUint))
		if err != nil && err != migrate.ErrNoChange {
			log.Printf("Error migrating to version %s: %v", version, err)
			return fmt.Errorf("error migrating to version %s: %v", version, err)
		}
	}

	log.Println("Migration completed successfully")
	return nil
}

// getDBConfigFromSecretsManager は、Secrets Managerからデータベース接続情報を取得します
func getDBConfigFromSecretsManager(secretID string) (*DBConfig, error) {
	log.Println("Creating new AWS session")
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String("ap-northeast-1"), // リージョンを明示的に指定
	})
	if err != nil {
		log.Printf("Error creating AWS session: %v", err)
		return nil, fmt.Errorf("error creating AWS session: %v", err)
	}

	svc := secretsmanager.New(sess)

	log.Printf("Attempting to get secret value for ID: %s", secretID)
	input := &secretsmanager.GetSecretValueInput{
		SecretId: &secretID,
	}

	result, err := svc.GetSecretValue(input)
	if err != nil {
		log.Printf("Error getting secret value: %v", err)
		return nil, err
	}
	log.Println("Successfully retrieved secret value")

	var dbConfig DBConfig
	err = json.Unmarshal([]byte(*result.SecretString), &dbConfig)
	if err != nil {
		log.Printf("Error unmarshalling secret value: %v", err)
		return nil, err
	}
	log.Println("Successfully unmarshalled secret value")

	return &dbConfig, nil
}

func main() {
	log.Println("Starting Lambda function")
	lambda.Start(handler)
}
