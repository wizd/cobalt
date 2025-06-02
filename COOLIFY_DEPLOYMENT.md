# Cobalt Coolify 部署指南

这个项目已经配置为在 Coolify 平台上进行完整部署，包括 API 后端和 Web 前端。

## 项目结构

- **cobalt-api**: Node.js Express API 服务器，端口 9000
- **cobalt-web**: SvelteKit 静态应用，通过 Nginx 提供服务，端口 3000

## 部署配置

### Docker Compose 服务

#### cobalt-api
- **镜像**: `wizdy/cobalt-api:latest`
- **端口**: 9000
- **域名**: `download.cohook.com`
- **功能**: 提供 API 服务，处理媒体下载请求

#### cobalt-web  
- **构建**: 本地 Dockerfile.web
- **端口**: 3000
- **域名**: `cobalt.cohook.com`
- **功能**: 前端界面，使用 Nginx 提供静态文件服务
- **特性**: 包含 .git 目录用于版本信息追踪

### 环境变量配置

#### API 服务环境变量
```yaml
environment:
  - NODE_ENV=production
  - API_URL=https://download.cohook.com
  - SERVICE_FQDN_COBALT_API_9000=download.cohook.com
```

#### Web 服务构建参数
```yaml
args:
  - WEB_DEFAULT_API=https://download.cohook.com
  - WEB_HOST=cobalt.cohook.com
  # - WEB_PLAUSIBLE_HOST=plausible.example.com  # 可选：分析服务
```

## Coolify 部署步骤

### 1. 创建项目
在 Coolify 中创建新项目并连接到 Git 仓库。

### 2. 配置环境变量
在项目设置中添加以下环境变量：

**必需变量:**
- `WEB_DEFAULT_API`: API 服务的完整 URL
- `WEB_HOST`: Web 前端的域名

**可选变量:**
- `WEB_PLAUSIBLE_HOST`: 如果使用 Plausible 分析

### 3. 域名配置
- API 服务: `download.cohook.com`
- Web 服务: `cobalt.cohook.com`

确保这些域名指向您的 VPS IP 地址。

### 4. 部署
```bash
# 部署整个 stack
docker-compose up -d

# 仅部署 API
docker-compose up -d cobalt-api

# 仅部署 Web
docker-compose up -d cobalt-web
```

## 高级配置

### Docker 构建特性

#### Web 前端构建
- **多阶段构建**: 使用 Node.js 构建，Nginx 运行
- **版本信息**: 包含 .git 目录用于版本追踪和调试
- **静态优化**: 预编译的 SvelteKit 静态文件
- **缓存优化**: 使用 pnpm 缓存加速构建

#### 构建优化
- 使用 Docker 构建缓存减少重复安装
- 分离构建和运行环境减小镜像大小
- 生产优化的静态资源压缩

### Nginx 配置
Web 服务使用自定义 nginx.conf 文件，包含：
- SvelteKit SPA 路由支持
- 安全头设置 (COOP, COEP, CSP)
- 静态资源缓存优化
- Gzip 压缩
- libav.js 工作器支持

### 健康检查
两个服务都配置了健康检查：
- API: 检查 `/api/serverInfo` 端点
- Web: 检查根路径 `/`

### Traefik 标签
配置了 Coolify/Traefik 标签用于：
- 自动 HTTPS
- 负载均衡
- 域名路由

## 故障排除

### 常见问题

1. **Web 构建失败**
   - 检查 `WEB_DEFAULT_API` 是否正确设置
   - 确保所有依赖都已安装
   - 验证 .git 目录是否存在（版本信息需要）

2. **API 连接问题**
   - 验证 API 服务是否运行在正确端口
   - 检查防火墙设置

3. **CORS 错误**
   - 确保 API 服务器的 CORS 配置允许 Web 域名

4. **构建缓存问题**
   - 清理 Docker 构建缓存: `docker builder prune`
   - 强制重新构建: `docker-compose build --no-cache cobalt-web`

### 日志查看
```bash
# 查看服务日志
docker-compose logs cobalt-api
docker-compose logs cobalt-web

# 实时跟踪日志
docker-compose logs -f cobalt-web

# 查看构建日志
docker-compose build cobalt-web
```

## 性能优化

### 构建性能
- 利用 Docker 层缓存
- 使用 pnpm 包管理器的缓存机制
- 多阶段构建减少最终镜像大小

### Nginx 优化
- 启用 Gzip 压缩
- 设置合适的缓存策略
- 优化静态资源交付

### 资源配置
根据预期流量调整容器资源限制：

```yaml
# 在 docker-compose.yml 中添加
deploy:
  resources:
    limits:
      memory: 512M
      cpus: '0.5'
```

## 安全考虑

### 网络安全
- 服务间通信通过 Docker 网络
- 仅必要端口暴露给外部

### 内容安全策略
Web 服务配置了严格的 CSP 头，符合 Cobalt 的安全要求。

### Git 目录安全
- .git 目录仅用于版本信息，不暴露给外部访问
- Nginx 配置阻止对隐藏文件的访问

### 更新策略
- API: 使用官方镜像，定期更新
- Web: 本地构建，从源代码构建最新版本

## 监控建议

建议设置以下监控：
- 服务健康状态
- 响应时间
- 资源使用情况
- 错误率
- 构建状态和时间

可以集成 Grafana、Prometheus 或其他监控解决方案。 