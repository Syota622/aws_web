package migrations

import (
	"gorm.io/gorm"
)

func MigrateDB(db *gorm.DB) error {
	// // 一時的な UUID カラムを追加
	// if err := db.Exec("ALTER TABLE users ADD COLUMN temp_id VARCHAR(36)").Error; err != nil {
	// 	return err
	// }

	// // 既存の id を UUID に変換して temp_id に格納
	// if err := db.Exec("UPDATE users SET temp_id = UUID()").Error; err != nil {
	// 	return err
	// }

	// // 主キーと auto_increment を削除
	// if err := db.Exec("ALTER TABLE users DROP PRIMARY KEY, MODIFY id BIGINT NOT NULL").Error; err != nil {
	// 	return err
	// }

	// // id カラムを削除し、temp_id を id にリネーム
	// if err := db.Exec("ALTER TABLE users DROP COLUMN id, CHANGE COLUMN temp_id id VARCHAR(36) NOT NULL PRIMARY KEY").Error; err != nil {
	// 	return err
	// }

	// // 他のカラムの変更
	// if err := db.Migrator().AlterColumn(&models.User{}, "username"); err != nil {
	// 	return err
	// }
	// if err := db.Migrator().AlterColumn(&models.User{}, "email"); err != nil {
	// 	return err
	// }

	// // password カラムを削除
	// if err := db.Migrator().DropColumn(&models.User{}, "password"); err != nil {
	// 	return err
	// }

	return nil
}
