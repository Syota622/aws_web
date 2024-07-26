package auth

import (
	"context"
	"encoding/json"
	"errors"
	"os"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/cognitoidentityprovider"
)

var CognitoClient *cognitoidentityprovider.Client

type CognitoConfig struct {
	ClientID   string `json:"clientId"`
	UserPoolID string `json:"userPoolId"`
}

func InitCognitoClient() error {
	// 環境変数からJSON文字列を取得
	cognitoConfigJSON := os.Getenv("ENVIRONMENT")

	// JSON文字列をCognitoConfig構造体にパース
	var cognitoConfig CognitoConfig
	if err := json.Unmarshal([]byte(cognitoConfigJSON), &cognitoConfig); err != nil {
		return errors.New("Cognito設定情報のパースに失敗しました: " + err.Error())
	}

	if cognitoConfig.ClientID == "" || cognitoConfig.UserPoolID == "" {
		return errors.New("ENVIRONMENT 環境変数に ClientID と UserPoolID を設定してください")
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
