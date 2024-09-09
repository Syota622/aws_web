#!/bin/bash

# 設定
BACKEND_ECS_CLUSTER_NAME="learn-backend-ecs-cluster-prod"
BACKEND_ECS_SERVICE_NAME="learn-backend-ecs-service-prod"
CONTAINER_NAME="learn-container-prod"

# 最新のタスクARNを取得
TASK_ARN=$(aws ecs list-tasks --cluster $BACKEND_ECS_CLUSTER_NAME --service-name $BACKEND_ECS_SERVICE_NAME --query 'taskArns[0]' --output text)

if [ -z "$TASK_ARN" ]; then
    echo "タスクが見つかりません。サービスが実行中であることを確認してください。"
    exit 1
fi

# タスクARNからタスクIDを抽出
TASK_ID=$(echo $TASK_ARN | awk -F "/" '{print $3}')

echo "接続するタスクID: $TASK_ID"

# ECS Executeコマンドを実行
aws ecs execute-command \
    --cluster $BACKEND_ECS_CLUSTER_NAME \
    --task $TASK_ID \
    --container $CONTAINER_NAME \
    --interactive \
    --command "sh"
