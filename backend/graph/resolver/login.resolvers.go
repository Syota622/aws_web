package graph

// This file will be automatically regenerated based on the schema, any resolver implementations
// will be copied through when generating and any unknown code will be moved to the end.
// Code generated by github.com/99designs/gqlgen version v0.17.49

import (
	"context"
	"fmt"
	"golang/auth"
	"golang/graph/generated"
	"golang/graph/model"
	"log"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/cognitoidentityprovider"
	"github.com/aws/aws-sdk-go-v2/service/cognitoidentityprovider/types"
)

// Login is the resolver for the login field.
func (r *mutationResolver) Login(ctx context.Context, input model.LoginInput) (*model.LoginPayload, error) {
	log.Printf("Login attempt for email: %s", input.Email)
	log.Printf("Using Cognito Client ID: %s", auth.CognitoClientID)
	log.Printf("Using Cognito User Pool ID: %s", auth.CognitoUserPoolID)

	authInput := &cognitoidentityprovider.InitiateAuthInput{
		AuthFlow: types.AuthFlowTypeUserPasswordAuth,
		ClientId: aws.String(auth.CognitoClientID),
		AuthParameters: map[string]string{
			"USERNAME": input.Email,
			"PASSWORD": input.Password,
		},
	}

	authOutput, err := auth.CognitoClient.InitiateAuth(ctx, authInput)
	if err != nil {
		log.Printf("認証に失敗しました: %v", err)
		return &model.LoginPayload{
			Error: aws.String(fmt.Sprintf("認証に失敗しました: %v", err)),
		}, nil
	}

	userInput := &cognitoidentityprovider.GetUserInput{
		AccessToken: authOutput.AuthenticationResult.AccessToken,
	}

	userOutput, err := auth.CognitoClient.GetUser(ctx, userInput)
	if err != nil {
		log.Printf("Failed to get user info: %v", err)
		return &model.LoginPayload{
			Error: aws.String(fmt.Sprintf("ユーザー情報の取得に失敗しました: %v", err)),
		}, nil
	}

	var userID, email, username string
	for _, attr := range userOutput.UserAttributes {
		log.Printf("ユーザー属性: %s = %s", *attr.Name, *attr.Value)
		switch *attr.Name {
		case "sub":
			userID = *attr.Value
		case "email":
			email = *attr.Value
		case "preferred_username":
			username = *attr.Value
		}
	}

	log.Printf("Login successful for user: %s", email)
	return &model.LoginPayload{
		Token: aws.String(*authOutput.AuthenticationResult.IdToken),
		User: &model.User{
			ID:       userID,
			Username: username,
			Email:    email,
		},
	}, nil
}

// Mutation returns generated.MutationResolver implementation.
func (r *Resolver) Mutation() generated.MutationResolver { return &mutationResolver{r} }

type mutationResolver struct{ *Resolver }
