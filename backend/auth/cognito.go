package auth

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log"
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
	AWSRegion  string `json:"AWS_REGION"`
}

func InitCognitoClient() error {
	// 環境変数からJSON形式のCognito設定を取得
	envJSON := os.Getenv("ENVIRONMENT")
	if envJSON == "" {
		return errors.New("ENVIRONMENT 環境変数が設定されていません")
	}

	var cognitoConfig CognitoConfig
	if err := json.Unmarshal([]byte(envJSON), &cognitoConfig); err != nil {
		// デバッグ: JSON解析エラーの詳細をログに出力
		log.Printf("JSON解析エラー: %v", err)
		return fmt.Errorf("ENVIRONMENT 環境変数のJSONパースに失敗しました: %v", err)
	}

	CognitoClientID = cognitoConfig.ClientID
	CognitoUserPoolID = cognitoConfig.UserPoolID

	if CognitoClientID == "" || CognitoUserPoolID == "" {
		return errors.New("CognitoClientID または CognitoUserPoolID が空です")
	}

	if cognitoConfig.AWSRegion == "" {
		return errors.New("AWS_REGION が設定されていません")
	}

	// AWS SDK for Go v2 の設定をロード
	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion(cognitoConfig.AWSRegion),
	)
	if err != nil {
		return fmt.Errorf("AWS設定のロードに失敗しました: %v", err)
	}

	// cognitoidentityprovider: NewFromConfig で Cognito クライアントを初期化
	CognitoClient = cognitoidentityprovider.NewFromConfig(cfg)

	return nil
}
