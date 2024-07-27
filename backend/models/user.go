package models

import (
	"time"

	"gorm.io/gorm"
)

type User struct {
	ID        string         `gorm:"type:varchar(36);primaryKey"`
	Username  string         `gorm:"type:varchar(255);uniqueIndex;not null"`
	Email     string         `gorm:"type:varchar(255);uniqueIndex;not null"`
	CreatedAt time.Time      `gorm:"type:datetime(3)"`
	UpdatedAt time.Time      `gorm:"type:datetime(3)"`
	DeletedAt gorm.DeletedAt `gorm:"type:datetime(3);index"`
}
