package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"golang/models"

	"github.com/google/uuid"
)

// SignUpHandler はユーザー登録を行うハンドラ
func SignUpHandler(c *gin.Context, db *gorm.DB) {
	var input struct {
		Username string `json:"username" binding:"required"`
		Email    string `json:"email" binding:"required,email"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "リクエストの形式が正しくありません", "details": err.Error()})
		return
	}

	// ユーザーの作成
	user := models.User{
		ID:       uuid.New().String(),
		Username: input.Username,
		Email:    input.Email,
	}

	if err := db.Create(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "ユーザーの作成に失敗", "details": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "ユーザーの作成に成功", "user": user})
}
