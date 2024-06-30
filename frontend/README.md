# npm
npm install @apollo/client graphql

# ローカルによる検証
ローカル(localhost:8080)のバックエンドのAPIは、コンテナネットワークの構築が必要なため、
ECSのAPIエンドポイントを利用する。
下記は、ローカルのバックエンドに対してAPIを実行した場合のエラーログである。
```log
frontend-app-1  |   networkError: TypeError: fetch failed
```
