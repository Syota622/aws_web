# RoadmapHub URL設計

## 認証関連
- サインアップ: `/signup`
- ログイン: `/login`
- ログアウト: `/logout`

## ホーム画面
- ホーム（ロードマップ一覧）: `/`
- ロードマップ検索: `/search`

## ロードマップ関連
- ロードマップ作成: `/roadmaps/create`
- ロードマップ詳細表示: `/roadmaps/:id`
- ロードマップ編集: `/roadmaps/:id/edit`
- ロードマップ削除: `/roadmaps/:id/delete`

## ステップ管理
- ステップ作成: `/roadmaps/:id/steps/create`
- ステップ編集: `/roadmaps/:id/steps/:stepId/edit`
- ステップ削除: `/roadmaps/:id/steps/:stepId/delete`

## ユーザープロフィール
- プロフィール表示: `/users/:username`
- プロフィール編集: `/users/:username/edit`
- ユーザーのロードマップ一覧: `/users/:username/roadmaps`

## フォロー関連
- フォロー中のユーザー一覧: `/users/:username/following`
- フォロワー一覧: `/users/:username/followers`

## レビュー
- レビュー一覧（ロードマップ詳細ページ内）: `/roadmaps/:id#reviews`
- レビュー投稿（ロードマップ詳細ページ内）: `/roadmaps/:id#write-review`

## その他
- About（アプリケーションについて）: `/about`
- 利用規約: `/terms`
- プライバシーポリシー: `/privacy`

## API エンドポイント
- GraphQL API: `/api/graphql`

注意事項:
1. `:id`、`:stepId`、`:username` はそれぞれ動的なパラメータを表します。
2. 実際のルーティングはフロントエンドフレームワーク（Next.js）で管理されます。
3. API呼び出しは全てGraphQLエンドポイントを通じて行われます。
4. #記号を使用しているURLは、同一ページ内の特定セクションへのアンカーリンクを示します。
