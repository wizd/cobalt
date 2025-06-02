# Cobalt 构建和部署指南

本指南说明如何构建 Cobalt Web 前端镜像并发布到 Docker Hub，然后使用镜像进行部署。

## 🚀 快速开始

### 1. 构建并推送到 Docker Hub

```bash
# 使用默认配置构建和推送
./build-and-push.sh

# 指定版本标签
./build-and-push.sh v11.0

# 指定版本和 Docker Hub 用户名
./build-and-push.sh v11.0 your-dockerhub-username
```

### 2. 部署到生产环境

```bash
# 使用 Docker Hub 镜像部署（生产环境）
docker-compose up -d

# 或指定配置文件
docker-compose -f docker-compose.yml up -d
```

### 3. 本地开发和测试

```bash
# 使用本地构建部署（开发环境）
docker-compose -f docker-compose.dev.yml up -d
```

## 📋 详细说明

### 构建脚本 (`build-and-push.sh`)

#### 功能特性
- ✅ 自动检查 Docker 环境
- ✅ 检查 Docker Hub 登录状态
- ✅ 支持自定义构建参数
- ✅ 多平台构建支持 (linux/amd64)
- ✅ 自动创建 latest 标签
- ✅ 彩色输出和进度显示

#### 使用方法

```bash
# 基本用法
./build-and-push.sh [版本标签] [Docker Hub用户名]

# 示例
./build-and-push.sh                    # 使用默认值
./build-and-push.sh latest             # 指定标签
./build-and-push.sh v11.0 myusername   # 指定标签和用户名
```

#### 环境变量

构建时可以设置以下环境变量：

```bash
# 设置 API 地址
export WEB_DEFAULT_API="https://your-api.example.com"

# 设置域名
export WEB_HOST="your-web.example.com"

# 然后运行构建
./build-and-push.sh
```

### Docker Compose 配置

#### 生产环境 (`docker-compose.yml`)
- 使用 Docker Hub 预构建镜像
- 优化的生产环境配置
- Coolify 兼容标签

#### 开发环境 (`docker-compose.dev.yml`)
- 本地构建镜像
- 开发友好的配置
- 本地 URL 配置

### 镜像标签策略

- `latest`: 最新稳定版本
- `v11.0`, `v11.1`: 语义化版本号
- `dev`, `beta`: 开发和测试版本

## 🔧 高级配置

### 自定义构建参数

修改 `build-and-push.sh` 中的默认值：

```bash
# 默认配置
DEFAULT_TAG="latest"
DEFAULT_REGISTRY="wizdy"
DEFAULT_IMAGE_NAME="cobalt-web"
```

### 多架构构建

```bash
# 构建多架构镜像
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --file Dockerfile.web \
    --tag wizdy/cobalt-web:latest \
    --build-arg WEB_DEFAULT_API="https://download.cohook.com" \
    --build-arg WEB_HOST="cobalt.cohook.com" \
    --push \
    .
```

### CI/CD 集成

在 GitHub Actions 或其他 CI/CD 中使用：

```yaml
- name: Build and Push Docker Image
  run: |
    export WEB_DEFAULT_API="${{ secrets.API_URL }}"
    export WEB_HOST="${{ secrets.WEB_HOST }}"
    ./build-and-push.sh ${{ github.ref_name }}
```

## 🛠️ 故障排除

### 常见问题

1. **Docker Hub 登录失败**
   ```bash
   docker login
   ```

2. **构建权限错误**
   ```bash
   sudo usermod -aG docker $USER
   # 然后重新登录
   ```

3. **镜像太大**
   - 检查 .dockerignore 文件
   - 使用 multi-stage build
   - 清理构建缓存

4. **构建失败**
   ```bash
   # 清理缓存重新构建
   docker system prune -f
   ./build-and-push.sh
   ```

### 调试命令

```bash
# 查看镜像详情
docker inspect wizdy/cobalt-web:latest

# 查看镜像历史
docker history wizdy/cobalt-web:latest

# 进入容器调试
docker run -it wizdy/cobalt-web:latest sh

# 查看构建日志
docker build --no-cache --progress=plain -f Dockerfile.web .
```

## 📊 监控和维护

### 镜像管理

```bash
# 查看本地镜像
docker images wizdy/cobalt-web

# 清理旧镜像
docker image prune -f

# 查看镜像大小
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

### 更新策略

1. **开发环境**: 使用 `docker-compose.dev.yml` 进行本地测试
2. **构建镜像**: 使用 `build-and-push.sh` 构建新版本
3. **生产部署**: 更新 `docker-compose.yml` 中的镜像标签
4. **版本回滚**: 如有问题，快速回滚到之前的镜像标签

### 自动化构建

考虑设置：
- Git tag 触发的自动构建
- 定期安全更新
- 依赖版本监控
- 镜像漏洞扫描

## 🔗 相关文档

- [Coolify 部署指南](COOLIFY_DEPLOYMENT.md)
- [环境变量配置](env.example)
- [Docker 官方文档](https://docs.docker.com/)
- [Docker Hub](https://hub.docker.com/) 