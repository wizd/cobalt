#!/bin/bash

# Cobalt Web Docker 构建和推送脚本
# 用法: ./build-and-push.sh [版本标签] [Docker Hub用户名]

set -e

# 默认配置
DEFAULT_TAG="latest"
DEFAULT_REGISTRY="wizdy"
DEFAULT_IMAGE_NAME="cobalt-web"

# 参数处理
TAG=${1:-$DEFAULT_TAG}
REGISTRY=${2:-$DEFAULT_REGISTRY}
IMAGE_NAME="$REGISTRY/$DEFAULT_IMAGE_NAME"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Cobalt Web Docker 构建和推送脚本 ===${NC}"
echo -e "${YELLOW}镜像名称: ${IMAGE_NAME}:${TAG}${NC}"
echo ""

# 检查 Docker 是否运行
if ! docker info &> /dev/null; then
    echo -e "${RED}错误: Docker 未运行或无权限访问${NC}"
    exit 1
fi

# 检查是否已登录 Docker Hub
echo -e "${BLUE}检查 Docker Hub 登录状态...${NC}"
if ! docker info | grep -q "Username"; then
    echo -e "${YELLOW}请先登录 Docker Hub:${NC}"
    docker login
fi

# 构建参数
WEB_DEFAULT_API=${WEB_DEFAULT_API:-"https://download.cohook.com"}
WEB_HOST=${WEB_HOST:-"cobalt.cohook.com"}

echo -e "${BLUE}构建参数:${NC}"
echo -e "  WEB_DEFAULT_API: ${WEB_DEFAULT_API}"
echo -e "  WEB_HOST: ${WEB_HOST}"
echo ""

# 构建镜像
echo -e "${BLUE}开始构建 Docker 镜像...${NC}"
docker build \
    --file Dockerfile.web \
    --tag "${IMAGE_NAME}:${TAG}" \
    --build-arg WEB_DEFAULT_API="${WEB_DEFAULT_API}" \
    --build-arg WEB_HOST="${WEB_HOST}" \
    --platform linux/amd64 \
    .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ 镜像构建成功${NC}"
else
    echo -e "${RED}✗ 镜像构建失败${NC}"
    exit 1
fi

# 如果不是 latest 标签，也创建一个 latest 标签
if [ "$TAG" != "latest" ]; then
    echo -e "${BLUE}创建 latest 标签...${NC}"
    docker tag "${IMAGE_NAME}:${TAG}" "${IMAGE_NAME}:latest"
fi

# 推送镜像
echo -e "${BLUE}推送镜像到 Docker Hub...${NC}"
docker push "${IMAGE_NAME}:${TAG}"

if [ "$TAG" != "latest" ]; then
    docker push "${IMAGE_NAME}:latest"
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ 镜像推送成功${NC}"
else
    echo -e "${RED}✗ 镜像推送失败${NC}"
    exit 1
fi

# 显示镜像信息
echo ""
echo -e "${GREEN}=== 构建完成 ===${NC}"
echo -e "${YELLOW}镜像信息:${NC}"
docker images "${IMAGE_NAME}" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"

echo ""
echo -e "${YELLOW}使用方法:${NC}"
echo -e "在 docker-compose.yml 中使用: ${BLUE}image: ${IMAGE_NAME}:${TAG}${NC}"
echo ""
echo -e "${GREEN}推送的镜像:${NC}"
echo -e "  - ${IMAGE_NAME}:${TAG}"
if [ "$TAG" != "latest" ]; then
    echo -e "  - ${IMAGE_NAME}:latest"
fi 