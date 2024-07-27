package auth

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"strings"

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
	// すべての環境変数をログに出力（機密情報に注意）
	log.Println("環境変数一覧:")
	for _, env := range os.Environ() {
		parts := strings.SplitN(env, "=", 2)
		if len(parts) == 2 {
			// 値の一部を隠してログ出力
			log.Printf("%s=%s...", parts[0], parts[1][:min(len(parts[1]), 4)])
		}
	}

	// ENVIRONMENT 変数の取得
	envJSON := os.Getenv("ENVIRONMENT")
	if envJSON == "" {
		return fmt.Errorf("ENVIRONMENT 環境変数が設定されていません")
	}

	log.Printf("ENVIRONMENT 変数の長さ: %d", len(envJSON))
	// 最初の数文字だけをログ出力（機密情報の保護のため）
	log.Printf("ENVIRONMENT 変数の先頭: %s...", envJSON[:min(len(envJSON), 20)])

	var cognitoConfig CognitoConfig
	err := json.Unmarshal([]byte(envJSON), &cognitoConfig)
	if err != nil {
		return fmt.Errorf("ENVIRONMENT 環境変数のJSONパースに失敗しました: %v", err)
	}

	CognitoClientID = cognitoConfig.ClientID
	CognitoUserPoolID = cognitoConfig.UserPoolID

	if CognitoClientID == "" || CognitoUserPoolID == "" {
		return fmt.Errorf("CognitoClientID または CognitoUserPoolID が空です")
	}

	if cognitoConfig.AWSRegion == "" {
		return fmt.Errorf("AWS_REGION が設定されていません")
	}

	// AWS SDK の設定
	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion(cognitoConfig.AWSRegion),
	)
	if err != nil {
		return fmt.Errorf("AWS設定のロードに失敗しました: %v", err)
	}

	CognitoClient = cognitoidentityprovider.NewFromConfig(cfg)

	log.Printf("Cognito Client initialized with ClientID: %s..., UserPoolID: %s..., Region: %s",
		CognitoClientID[:min(len(CognitoClientID), 4)],
		CognitoUserPoolID[:min(len(CognitoUserPoolID), 4)],
		cognitoConfig.AWSRegion)

	return nil
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
