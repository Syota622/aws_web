#!/bin/bash

# 設定
## バックエンド
BACKEND_ALB_NAME="learn-ecs-alb-prod"
BACKEND_ECS_CLUSTER_NAME="learn-backend-ecs-cluster-prod"
BACKEND_ECS_SERVICE_NAME="learn-backend-ecs-service-prod"
## フロントエンド
FRONTEND_ALB_NAME="learn-frontend-ecs-alb-prod"
FRONTEND_ECS_CLUSTER_NAME="learn-frontend-ecs-cluster-prod"
FRONTEND_ECS_SERVICE_NAME="learn-frontend-ecs-service-prod"
## Aurora
AURORA_CLUSTER_ID="learn-serverless-prod"
## 共通
MAX_ATTEMPTS=30
SLEEP_TIME=30

# バックエンド ALB の ARN を取得
echo "バックエンド ALB の ARN を取得中..."
BACKEND_ALB_ARN=$(aws elbv2 describe-load-balancers --names $BACKEND_ALB_NAME --query 'LoadBalancers[0].LoadBalancerArn' --output text)

# バックエンド ALB削除
echo "バックエンド ALBを削除中..."
aws elbv2 delete-load-balancer --load-balancer-arn $BACKEND_ALB_ARN

# フロントエンド ALB の ARN を取得
echo "フロントエンド ALB の ARN を取得中..."
FRONTEND_ALB_ARN=$(aws elbv2 describe-load-balancers --names $FRONTEND_ALB_NAME --query 'LoadBalancers[0].LoadBalancerArn' --output text)

# フロントエンド ALB削除
echo "フロントエンド ALBを削除中..."
aws elbv2 delete-load-balancer --load-balancer-arn $FRONTEND_ALB_ARN

# バックエンド ECSのタスク数を0に設定
echo "バックエンド ECSのタスク数を0に設定中..."
aws ecs update-service \
    --cluster $BACKEND_ECS_CLUSTER_NAME \
    --service $BACKEND_ECS_SERVICE_NAME \
    --desired-count 0 \
    > /dev/null 2>&1

# フロントエンド ECSのタスク数を0に設定
echo "フロントエンド ECSのタスク数を0に設定中..."
aws ecs update-service \
    --cluster $FRONTEND_ECS_CLUSTER_NAME \
    --service $FRONTEND_ECS_SERVICE_NAME \
    --desired-count 0 \
    > /dev/null 2>&1

# バックエンド ECSサービスの状態を確認
echo "バックエンド ECSサービスの状態を確認中..."
for (( i=1; i<=$MAX_ATTEMPTS; i++ )); do
    RUNNING_COUNT=$(aws ecs describe-services --cluster $BACKEND_ECS_CLUSTER_NAME --services $BACKEND_ECS_SERVICE_NAME --query 'services[0].runningCount' --output text)
    echo "試行 $i: 実行中のタスク数 - $RUNNING_COUNT"
    if [ "$RUNNING_COUNT" = "0" ]; then
        echo "バックエンド ECSサービスのタスクがすべて停止しました。"
        break
    elif [ $i -eq $MAX_ATTEMPTS ]; then
        echo "バックエンド ECSサービスの更新がタイムアウトしました。"
        exit 1
    fi
    sleep $SLEEP_TIME
done

# フロントエンド ECSサービスの状態を確認
echo "フロントエンド ECSサービスの状態を確認中..."
for (( i=1; i<=$MAX_ATTEMPTS; i++ )); do
    RUNNING_COUNT=$(aws ecs describe-services --cluster $FRONTEND_ECS_CLUSTER_NAME --services $FRONTEND_ECS_SERVICE_NAME --query 'services[0].runningCount' --output text)
    echo "試行 $i: 実行中のタスク数 - $RUNNING_COUNT"
    if [ "$RUNNING_COUNT" = "0" ]; then
        echo "フロントエンド ECSサービスのタスクがすべて停止しました。"
        break
    elif [ $i -eq $MAX_ATTEMPTS ]; then
        echo "フロントエンド ECSサービスの更新がタイムアウトしました。"
        exit 1
    fi
    sleep $SLEEP_TIME
done

# Auroraクラスターを停止
echo "Auroraクラスターを停止中..."
aws rds stop-db-cluster --db-cluster-identifier $AURORA_CLUSTER_ID > /dev/null 2>&1

echo "すべての操作が完了しました。"
