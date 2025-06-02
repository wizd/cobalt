# Cobalt API Docker 部署指南

## 📦 已创建的文件

- `docker-compose.yml` - Docker Compose 配置文件
- `deploy.sh` - 一键部署脚本

## 🚀 快速启动

### 方式一：使用部署脚本（推荐）
```bash
./deploy.sh
```

### 方式二：手动启动
```bash
# 拉取最新镜像
docker pull wizdy/cobalt-api:latest

# 启动服务
docker-compose up -d

# 查看运行状态
docker-compose ps
```

## 🔧 管理命令

```bash
# 查看实时日志
docker-compose logs -f cobalt-api

# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 更新到最新版本
docker pull wizdy/cobalt-api:latest
docker-compose up -d
```

## 🌐 访问服务

- API 服务地址: http://localhost:9000
- 健康检查: http://localhost:9000/api/serverInfo

## 📊 Docker Hub 镜像

- 镜像地址: `wizdy/cobalt-api:latest`
- 自动构建: 本地构建并推送

## 🛠️ 配置说明

Docker Compose 配置包含：
- 端口映射：9000:9000
- 自动重启策略
- 健康检查机制
- 独立网络配置

## 🔍 故障排除

1. **端口冲突**：修改 `docker-compose.yml` 中的端口映射
2. **镜像拉取失败**：检查网络连接和 Docker Hub 状态
3. **服务启动失败**：查看日志 `docker-compose logs cobalt-api` 