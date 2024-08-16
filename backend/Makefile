MIGRATE_PATH = infra/db/migrations
MYSQL_DB = db
MYSQL_USER = mysql
MYSQL_PASSWORD = Passw0rd
MYSQL_HOST = 0.0.0.0
MYSQL_PORT = 5432
MYSQL_HOST_DOCKER = db

migrate-create:
	@echo "migrate create"
	@docker compose run --rm web sh -c "migrate -path /app/infra/db/migrations create -ext sql -dir infra/db/migrations -seq $(NAME)"

migrate-up:
	@echo "migrate up"
	@docker compose run --rm web sh -c "migrate -path /app/infra/db/migrations \
	  -source file://${MIGRATE_PATH} -database  \
		'mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST_DOCKER}:${MYSQL_PORT}/${MYSQL_DB}?sslmode=disable' -verbose up $(VERSION)"

migrate-down:
	@echo "migrate down"
	@docker compose run --rm web sh -c "migrate -path /app/infra/db/migrations  \
	-source file://${MIGRATE_PATH}  \
	-database 'mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST_DOCKER}:${MYSQL_PORT}/${MYSQL_DB}?sslmode=disable' down $(VERSION)"

migrate-version:
	@echo "migrate version"
	@docker compose run --rm web sh -c "migrate -path /app/infra/db/migrations  \
	-source file://${MIGRATE_PATH}  \
	-database 'mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST_DOCKER}:${MYSQL_PORT}/${MYSQL_DB}?sslmode=disable' version"

migrate-force:
	@echo "migrate force"
	@docker compose run --rm web sh -c "migrate -path /app/infra/db/migrations  \
	-source file://${MIGRATE_PATH}  \
	-database 'mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST_DOCKER}:${MYSQL_PORT}/${MYSQL_DB}?sslmode=disable' force $(VERSION)"

# マイグレーションの状態確認
migrate-status:
	@echo "migrate force"
	@docker compose run --rm web sh -c "migrate -path /app/infra/db/migrations  \
	-source file://${MIGRATE_PATH}  \
	-database 'mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST_DOCKER}:${MYSQL_PORT}/${MYSQL_DB}?sslmode=disable' status"

# -ext	マイグレーションファイルの拡張子
# -dir	マイグレーションファイルを作成する場所
# -seq	マイグレーションファイルの名前