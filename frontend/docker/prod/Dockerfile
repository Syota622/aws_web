# ビルドステージ
FROM node:18-alpine AS builder

WORKDIR /app

# 必要な依存関係をインストール
RUN apk add --no-cache libc6-compat

# パッケージファイルをコピーして依存関係をインストール
COPY package*.json ./
RUN npm install

# ソースコードをコピーしてビルド
COPY . .
RUN npm run build

# 実行ステージ
FROM node:18-alpine AS runner

WORKDIR /app

# 必要な依存関係をインストール
RUN apk add --no-cache libc6-compat

# ビルド成果物をコピー
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# アプリケーションを起動
CMD ["npm", "start"]
