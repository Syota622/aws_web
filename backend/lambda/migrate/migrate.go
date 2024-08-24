package main

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"strconv"

	"github.com/aws/aws-lambda-go/lambda"
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
	// Secrets Managerから接続情報を取得
	secretID := os.Getenv("SECRETS_MANAGER_SECRET_ID")
	dbConfig, err := getDBConfigFromSecretsManager(secretID)
	if err != nil {
		return fmt.Errorf("error getting DB config from Secrets Manager: %v", err)
	}

	// データベース接続URLの構築
	dbURL := fmt.Sprintf("mysql://%s:%s@tcp(%s:%s)/%s",
		dbConfig.Username,
		dbConfig.Password,
		dbConfig.Host,
		dbConfig.Port,
		dbConfig.DBName)

	// マイグレーションインスタンスの作成
	// 注意: パスを "/var/task/migrations" に変更
	m, err := migrate.New(
		"file:///var/task/migrations",
		dbURL)
	if err != nil {
		return fmt.Errorf("error creating migrate instance: %v", err)
	}

	// マイグレーションの実行
	version := os.Getenv("VERSION")
	if version == "" {
		err = m.Up()
		if err != nil && err != migrate.ErrNoChange {
			return fmt.Errorf("error migrating up: %v", err)
		}
	} else {
		versionUint, err := strconv.ParseUint(version, 10, 64)
		if err != nil {
			return fmt.Errorf("error parsing version: %v", err)
		}
		err = m.Migrate(uint(versionUint))
		if err != nil && err != migrate.ErrNoChange {
			return fmt.Errorf("error migrating to version %s: %v", version, err)
		}
	}

	return nil
}

// getDBConfigFromSecretsManager は、Secrets Managerからデータベース接続情報を取得します
func getDBConfigFromSecretsManager(secretID string) (*DBConfig, error) {
	sess := session.Must(session.NewSession())
	svc := secretsmanager.New(sess)

	input := &secretsmanager.GetSecretValueInput{
		SecretId: &secretID,
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
	lambda.Start(handler)
}
