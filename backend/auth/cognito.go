package auth

import (
	"context"
	"errors"
	"os"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/cognitoidentityprovider"
)

var CognitoClient *cognitoidentityprovider.Client
var CognitoClientID string
var CognitoUserPoolID string

func InitCognitoClient() error {
	// 環境変数から Cognito クライアントIDとユーザープールIDを取得
	CognitoClientID = os.Getenv("COGNITO_CLIENT_ID")
	CognitoUserPoolID = os.Getenv("COGNITO_USER_POOL_ID")

	if CognitoClientID == "" || CognitoUserPoolID == "" {
		return errors.New("COGNITO_CLIENT_ID と COGNITO_USER_POOL_ID 環境変数を設定してください")
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
