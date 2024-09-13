# ビルド用ステージ
FROM node:18-alpine AS builder

WORKDIR /app

# 必要な依存関係をインストール
RUN apk add --no-cache libc6-compat

# npmのキャッシュディレクトリを設定
ENV npm_config_cache /tmp/npm-cache

# パッケージファイルのみをコピーして依存関係をインストール
COPY package*.json ./
RUN npm ci --no-cache

# 残りのファイルをコピーしてビルド
COPY . .
RUN npm run build

# 本番用ステージ
FROM node:18-alpine AS runner

WORKDIR /app

# 必要な依存関係をインストール
RUN apk add --no-cache libc6-compat

# ビルド成果物のみをコピー
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./

EXPOSE 3000

CMD ["npm", "start"]
