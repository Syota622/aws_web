package models

import (
	"time"

	"gorm.io/gorm"
)

type User struct {
	gorm.Model
	Username  string `json:"username" gorm:"unique"`
	Password  string `json:"password"`
	Email     string `json:"email" gorm:"unique"`
	CreatedAt time.Time
	UpdatedAt time.Time
}
