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
	log.Println("データベースマイグレーションハンドラーを開始します")

	// SecretsManagerから接続情報を取得
	secretID := os.Getenv("SECRETS_MANAGER_SECRET_ARN")
	dbConfig, err := getDBConfigFromSecretsManager(secretID)
	if err != nil {
		log.Printf("Secrets Managerからのデータベース設定取得エラー: %v", err)
		return fmt.Errorf("secrets managerからのデータベース設定取得エラー: %v", err)
	}

	// データベース接続URLの構築
	dbURL := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s",
		dbConfig.User,
		dbConfig.Password,
		dbConfig.Host,
		dbConfig.Port,
		dbConfig.Name)

	log.Printf("データベース接続URL: %s://*****@%s:%s/%s",
		dbConfig.User,
		dbConfig.Host,
		dbConfig.Port,
		dbConfig.Name)

	// マイグレーションインスタンスの作成
	log.Println("マイグレーションインスタンスを作成中")
	m, err := migrate.New(
		"file:///var/task/migrations",
		fmt.Sprintf("mysql://%s", dbURL))
	if err != nil {
		log.Printf("マイグレーションインスタンス作成エラー: %v", err)
		return fmt.Errorf("マイグレーションインスタンス作成エラー: %v", err)
	}

	// 現在のバージョンを取得
	version, dirty, err := m.Version()
	if err != nil && err != migrate.ErrNilVersion {
		log.Printf("現在のマイグレーションバージョン取得エラー: %v", err)
	} else {
		log.Printf("現在のマイグレーションバージョン: %d, ダーティ状態: %v", version, dirty)
	}

	// マイグレーションの実行（最新バージョンまで）
	log.Println("データベースマイグレーションを開始します")
	err = m.Up()
	if err != nil {
		if err == migrate.ErrNoChange {
			log.Println("マイグレーションの変更は必要ありません")
			return nil
		}
		log.Printf("データベースマイグレーションエラー: %v", err)
		return fmt.Errorf("データベースマイグレーションエラー: %v", err)
	}

	// 最終的なバージョンを取得
	finalVersion, finalDirty, err := m.Version()
	if err != nil {
		log.Printf("最終マイグレーションバージョン取得エラー: %v", err)
	} else {
		log.Printf("最終マイグレーションバージョン: %d, ダーティ状態: %v", finalVersion, finalDirty)
	}

	log.Println("データベースマイグレーションが正常に完了しました")
	return nil
}

// SecretsManagerから接続情報を取得
func getDBConfigFromSecretsManager(secretID string) (*DBConfig, error) {
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String("ap-northeast-1"), // リージョンを適切に設定してください
	})
	if err != nil {
		return nil, fmt.Errorf("AWSセッション作成エラー: %v", err)
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
	log.Println("Lambda関数を開始します")
	lambda.Start(handler)
}
