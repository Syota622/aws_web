package graph

import (
	"context"
	"errors"
	"fmt"
	"golang/graph/generated"
	"golang/graph/model"
	"golang/models"
	"log"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

// Login is the resolver for the login field.
func (r *mutationResolver) Login(ctx context.Context, input model.LoginInput) (*model.LoginPayload, error) {
	log.Printf("Login attempt for email: %s", input.Email)

	if r.DB == nil {
		log.Println("データベース接続が初期化されていません")
		return nil, fmt.Errorf("データベース接続が初期化されていません")
	}

	// バリデーション
	var user models.User
	if err := r.DB.Where("email = ?", input.Email).First(&user).Error; err != nil {
		log.Printf("Error finding user: %v", err)
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return &model.LoginPayload{
				Errors: []*model.Error{{Field: "email", Message: "メールアドレスまたはパスワードが正しくありません"}},
			}, nil
		}
		return nil, fmt.Errorf("database error: %v", err)
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(input.Password)); err != nil {
		log.Printf("Password mismatch for user: %s", input.Email)
		return &model.LoginPayload{
			Errors: []*model.Error{{Field: "password", Message: "メールアドレスまたはパスワードが正しくありません"}},
		}, nil
	}

	// JWTトークンを生成
	token := "generated_jwt_token"

	log.Printf("ログイン成功: %s", input.Email)
	return &model.LoginPayload{
		Token: &token,
		User: &model.User{
			ID:        user.ID, // IDフィールドを追加
			Username:  user.Username,
			Email:     user.Email,
			CreatedAt: user.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
			UpdatedAt: user.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
		},
	}, nil
}

// Mutation returns generated.MutationResolver implementation.
func (r *Resolver) Mutation() generated.MutationResolver { return &mutationResolver{r} }

type mutationResolver struct{ *Resolver }
