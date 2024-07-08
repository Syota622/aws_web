// graph/resolvers.go

package graph

import (
	"context"
	"golang/graph/model"
	"golang/models"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type Resolver struct {
	DB *gorm.DB
}

func (r *mutationResolver) Login(ctx context.Context, input model.LoginInput) (*model.LoginPayload, error) {
	var user models.User
	if err := r.DB.Where("email = ?", input.Email).First(&user).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			return &model.LoginPayload{
				Errors: []*model.Error{{Field: "email", Message: "Invalid email or password"}},
			}, nil
		}
		return nil, err
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(input.Password)); err != nil {
		return &model.LoginPayload{
			Errors: []*model.Error{{Field: "password", Message: "Invalid email or password"}},
		}, nil
	}

	// TODO: Implement JWT token generation
	token := "generated_jwt_token"

	return &model.LoginPayload{
		Token: &token,
		User: &model.User{
			ID:        user.ID,
			Username:  user.Username,
			Email:     user.Email,
			CreatedAt: user.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
			UpdatedAt: user.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
		},
	}, nil
}

// Mutation returns MutationResolver implementation.
func (r *Resolver) Mutation() MutationResolver { return &mutationResolver{r} }

type mutationResolver struct{ *Resolver }
