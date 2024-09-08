#!/bin/bash

# 設定
## Aurora
AURORA_CLUSTER_ID="learn-serverless-prod"
## バックエンド
BACKEND_ECS_CLUSTER_NAME="learn-backend-ecs-cluster-prod"
BACKEND_ECS_SERVICE_NAME="learn-backend-ecs-service-prod"
## フロントエンド
FRONTEND_ECS_CLUSTER_NAME="learn-frontend-ecs-cluster-prod"
FRONTEND_ECS_SERVICE_NAME="learn-frontend-ecs-service-prod"
## 共通
MAX_ATTEMPTS=30
SLEEP_TIME=30
SCRIPT_DIR=~/Desktop/HC/aws_web
TERRAFORM_DIR=$SCRIPT_DIR/terraform/env/prod

# 現在のディレクトリを保存
CURRENT_DIR=$(pwd)

# Terraform Applyの実行
echo "Terraform Applyを実行中..."
cd "$TERRAFORM_DIR" || exit 1
terraform init
terraform apply -auto-approve

# 元のディレクトリに戻る
cd "$CURRENT_DIR" || exit 1

# Auroraクラスターを起動
echo "Auroraクラスターを起動中..."
aws rds start-db-cluster --db-cluster-identifier $AURORA_CLUSTER_ID > /dev/null 2>&1

# Auroraクラスターの状態を確認
echo "Auroraクラスターの状態を確認中..."
for (( i=1; i<=$MAX_ATTEMPTS; i++ )); do
    STATUS=$(aws rds describe-db-clusters --db-cluster-identifier $AURORA_CLUSTER_ID --query 'DBClusters[0].Status' --output text)
    echo "試行 $i: ステータス - $STATUS"
    if [ "$STATUS" = "available" ]; then
        echo "Auroraクラスターが利用可能になりました。"
        break
    elif [ $i -eq $MAX_ATTEMPTS ]; then
        echo "Auroraクラスターの起動がタイムアウトしました。"
        exit 1
    fi
    sleep $SLEEP_TIME
done

# バックエンド ECSのタスク数を1に設定（出力を抑制）
echo "バックエンド ECSのタスク数を1に設定中..."
aws ecs update-service \
    --cluster $BACKEND_ECS_CLUSTER_NAME \
    --service $BACKEND_ECS_SERVICE_NAME \
    --desired-count 1 \
    > /dev/null 2>&1

# フロントエンド ECSのタスク数を1に設定（出力を抑制）
echo "フロントエンド ECSのタスク数を1に設定中..."
aws ecs update-service \
    --cluster $FRONTEND_ECS_CLUSTER_NAME \
    --service $FRONTEND_ECS_SERVICE_NAME \
    --desired-count 1 \
    > /dev/null 2>&1

# バックエンド ECSサービスの状態を確認
echo "バックエンド ECSサービスの状態を確認中..."
for (( i=1; i<=$MAX_ATTEMPTS; i++ )); do
    RUNNING_COUNT=$(aws ecs describe-services --cluster $BACKEND_ECS_CLUSTER_NAME --services $BACKEND_ECS_SERVICE_NAME --query 'services[0].runningCount' --output text)
    DESIRED_COUNT=$(aws ecs describe-services --cluster $BACKEND_ECS_CLUSTER_NAME --services $BACKEND_ECS_SERVICE_NAME --query 'services[0].desiredCount' --output text)
    echo "試行 $i: 実行中のタスク数 - $RUNNING_COUNT, 希望するタスク数 - $DESIRED_COUNT"
    if [ "$RUNNING_COUNT" = "$DESIRED_COUNT" ]; then
        echo "ECSサービスが希望する状態になりました。"
        break
    elif [ $i -eq $MAX_ATTEMPTS ]; then
        echo "ECSサービスの更新がタイムアウトしました。"
        exit 1
    fi
    sleep $SLEEP_TIME
done

# フロントエンド ECSサービスの状態を確認
echo "フロントエンド ECSサービスの状態を確認中..."
for (( i=1; i<=$MAX_ATTEMPTS; i++ )); do
    RUNNING_COUNT=$(aws ecs describe-services --cluster $FRONTEND_ECS_CLUSTER_NAME --services $FRONTEND_ECS_SERVICE_NAME --query 'services[0].runningCount' --output text)
    DESIRED_COUNT=$(aws ecs describe-services --cluster $FRONTEND_ECS_CLUSTER_NAME --services $FRONTEND_ECS_SERVICE_NAME --query 'services[0].desiredCount' --output text)
    echo "試行 $i: 実行中のタスク数 - $RUNNING_COUNT, 希望するタスク数 - $DESIRED_COUNT"
    if [ "$RUNNING_COUNT" = "$DESIRED_COUNT" ]; then
        echo "ECSサービスが希望する状態になりました。"
        break
    elif [ $i -eq $MAX_ATTEMPTS ]; then
        echo "ECSサービスの更新がタイムアウトしました。"
        exit 1
    fi
    sleep $SLEEP_TIME
done

echo "すべての操作が完了しました。"
