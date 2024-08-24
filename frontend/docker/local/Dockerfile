# ビルド用ステージ
FROM node:18-alpine as builder

WORKDIR /app

# パッケージファイルのみをコピーして依存関係をインストール
COPY package*.json ./
RUN npm ci --no-cache

# 残りのファイルをコピーしてビルド
COPY . .
RUN npm run build

# 本番用ステージ
FROM node:18-alpine

WORKDIR /app

# ビルド成果物のみをコピー
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./

EXPOSE 3000

CMD ["npm", "start"]
