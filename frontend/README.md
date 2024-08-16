# docker compose
docker-compose up -d
docker-compose up --build -d

# npm
npm install @apollo/client graphql
npm install lucide-react
npm install --save-dev @types/json5
npm install -g npm@10.8.2

# ローカルによる検証
APIは、localhostではなく、host.docker.internalを使う
https://qiita.com/moko_Swallows/items/f69631db9c7de83910a3
