package auth

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"os"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/cognitoidentityprovider"
)

var CognitoClient *cognitoidentityprovider.Client
var CognitoClientID string
var CognitoUserPoolID string

type CognitoConfig struct {
	ClientID   string `json:"clientId"`
	UserPoolID string `json:"userPoolId"`
}

func InitCognitoClient() error {
	// 環境変数からJSON形式のCognito設定を取得
	envJSON := os.Getenv("ENVIRONMENT")

	if envJSON == "" {
		return errors.New("ENVIRONMENT 環境変数が設定されていません")
	}

	var cognitoConfig CognitoConfig
	if err := json.Unmarshal([]byte(envJSON), &cognitoConfig); err != nil {
		return fmt.Errorf("ENVIRONMENT 環境変数のJSONパースに失敗しました: %v", err)
	}

	CognitoClientID = cognitoConfig.ClientID
	CognitoUserPoolID = cognitoConfig.UserPoolID

	if CognitoClientID == "" || CognitoUserPoolID == "" {
		return errors.New("CognitoClientID または CognitoUserPoolID が空です")
	}

	// AWS SDK for Go v2 の設定をロード
	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		return err
	}

	// cognitoidentityprovider: NewFromConfig で Cognito クライアントを初期化
	CognitoClient = cognitoidentityprovider.NewFromConfig(cfg)

	return nil
}

func GetDBConfig() (string, error) {
	dbConfig := os.Getenv("DB_CONFIG")
	if dbConfig == "" {
		return "", fmt.Errorf("DB_CONFIG が設定されていません")
	}
	return dbConfig, nil
}
