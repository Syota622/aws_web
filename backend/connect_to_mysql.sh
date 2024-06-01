#!/bin/sh

# JSON形式の環境変数からデータベース接続情報を抽出
DB_HOST=$(echo $DB_CONFIG | jq -r .DB_HOST)
DB_USER=$(echo $DB_CONFIG | jq -r .DB_USER)
DB_PASSWORD=$(echo $DB_CONFIG | jq -r .DB_PASSWORD)
DB_NAME=$(echo $DB_CONFIG | jq -r .DB_NAME)
DB_PORT=$(echo $DB_CONFIG | jq -r .DB_PORT)

# MySQLに接続
mysql -h ${DB_HOST} -u ${DB_USER} -p${DB_PASSWORD} -P ${DB_PORT} ${DB_NAME}
