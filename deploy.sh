#!/bin/bash

# Cobalt API 部署脚本

echo "🚀 正在启动 Cobalt API 服务..."

# 检查 Docker 是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ 错误: Docker 服务未运行，请先启动 Docker"
    exit 1
fi

# 拉取最新镜像
echo "📦 正在拉取最新镜像..."
docker pull wizdy/cobalt-api:latest

# 启动服务
echo "🔧 正在启动服务..."
docker-compose up -d

# 检查服务状态
echo "🔍 检查服务状态..."
sleep 5
docker-compose ps

echo "✅ 部署完成！"
echo "🌐 API 服务地址: http://localhost:9000"
echo "📊 查看日志: docker-compose logs -f cobalt-api"
echo "🛑 停止服务: docker-compose down" 