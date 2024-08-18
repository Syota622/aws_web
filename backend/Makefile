MIGRATE_PATH = /app/db/migrations
MYSQL_DB = myapp
MYSQL_USER = root
MYSQL_PASSWORD = password
MYSQL_HOST = db
MYSQL_PORT = 3306

migrate-create:
	@echo "migrate create"
	@docker compose run --rm web sh -c "migrate create -ext sql -dir $(MIGRATE_PATH) -seq $(NAME)"

migrate-up:
	@echo "migrate up"
	@docker compose run --rm web sh -c "migrate -path $(MIGRATE_PATH) \
		-database 'mysql://$(MYSQL_USER):$(MYSQL_PASSWORD)@tcp($(MYSQL_HOST):$(MYSQL_PORT))/$(MYSQL_DB)' \
		-verbose up $(VERSION)"

migrate-down:
	@echo "migrate down"
	@docker compose run --rm web sh -c "migrate -path /app/db/migrations  \
	-source file://${MIGRATE_PATH}  \
	-database 'mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST_DOCKER}:${MYSQL_PORT}/${MYSQL_DB}?sslmode=disable' down $(VERSION)"

migrate-version:
	@echo "migrate version"
	@docker compose run --rm web sh -c "migrate -path /app/db/migrations  \
	-source file://${MIGRATE_PATH}  \
	-database 'mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST_DOCKER}:${MYSQL_PORT}/${MYSQL_DB}?sslmode=disable' version"

migrate-force:
	@echo "migrate force"
	@docker compose run --rm web sh -c "migrate -path /app/db/migrations  \
	-source file://${MIGRATE_PATH}  \
	-database 'mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST_DOCKER}:${MYSQL_PORT}/${MYSQL_DB}?sslmode=disable' force $(VERSION)"

# マイグレーションの状態確認
migrate-status:
	@echo "migrate force"
	@docker compose run --rm web sh -c "migrate -path /app/db/migrations  \
	-source file://${MIGRATE_PATH}  \
	-database 'mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST_DOCKER}:${MYSQL_PORT}/${MYSQL_DB}?sslmode=disable' status"

# -ext	マイグレーションファイルの拡張子
# -dir	マイグレーションファイルを作成する場所
# -seq	マイグレーションファイルの名前