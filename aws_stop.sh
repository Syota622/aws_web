#!/bin/bash

# 設定
ALB_ARN="arn:aws:elasticloadbalancing:ap-northeast-1:235484765172:loadbalancer/app/learn-ecs-alb-prod/c9944f45c3036335"
ECS_CLUSTER_NAME="learn-ecs-cluster-prod"
ECS_SERVICE_NAME="learn-ecs-service-prod"
AURORA_CLUSTER_ID="learn-serverless-prod"
MAX_ATTEMPTS=30
SLEEP_TIME=30

# ALB削除
echo "ALBを削除中..."
aws elbv2 delete-load-balancer --load-balancer-arn $ALB_ARN

# ECSのタスク数を0に設定
echo "ECSのタスク数を0に設定中..."
aws ecs update-service \
    --cluster $ECS_CLUSTER_NAME \
    --service $ECS_SERVICE_NAME \
    --desired-count 0 \
    > /dev/null 2>&1

# ECSサービスの状態を確認
echo "ECSサービスの状態を確認中..."
for (( i=1; i<=$MAX_ATTEMPTS; i++ )); do
    RUNNING_COUNT=$(aws ecs describe-services --cluster $ECS_CLUSTER_NAME --services $ECS_SERVICE_NAME --query 'services[0].runningCount' --output text)
    echo "試行 $i: 実行中のタスク数 - $RUNNING_COUNT"
    if [ "$RUNNING_COUNT" = "0" ]; then
        echo "ECSサービスのタスクがすべて停止しました。"
        break
    elif [ $i -eq $MAX_ATTEMPTS ]; then
        echo "ECSサービスの更新がタイムアウトしました。"
        exit 1
    fi
    sleep $SLEEP_TIME
done

# Auroraクラスターを停止
echo "Auroraクラスターを停止中..."
aws rds stop-db-cluster --db-cluster-identifier $AURORA_CLUSTER_ID > /dev/null 2>&1

echo "すべての操作が完了しました。"
