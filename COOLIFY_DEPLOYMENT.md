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
- **镜像**: `wizdy/cobalt-web:latest` (Docker Hub 预构建镜像)
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

#### Web 服务配置
```yaml
# 现在使用 Docker Hub 镜像，无需构建参数
image: wizdy/cobalt-web:latest
```

> **注意**: Web 服务现在使用预构建的 Docker Hub 镜像，构建时的环境变量 (`WEB_DEFAULT_API`, `WEB_HOST`) 已经内置到镜像中。

## Coolify 部署步骤

### 1. 创建项目
在 Coolify 中创建新项目并连接到 Git 仓库。

### 2. 选择部署方式

#### 方式 A: 使用预构建镜像（推荐）
```bash
# 直接使用 Docker Hub 镜像部署
docker-compose up -d
```

**优势:**
- ✅ 部署速度快
- ✅ 减少服务器资源消耗
- ✅ 稳定的预构建镜像
- ✅ 无需在服务器上构建

#### 方式 B: 本地构建（开发环境）
```bash
# 使用本地构建版本
docker-compose -f docker-compose.dev.yml up -d
```

### 3. 构建自定义镜像（可选）

如果需要自定义配置，可以构建自己的镜像：

```bash
# 1. 克隆代码到本地
git clone <your-repo-url>
cd cobalt

# 2. 设置环境变量（可选）
export WEB_DEFAULT_API="https://your-api.example.com"
export WEB_HOST="your-web.example.com"

# 3. 构建并推送到 Docker Hub
./build-and-push.sh v11.0 your-dockerhub-username

# 4. 更新 docker-compose.yml
# 将镜像改为: your-dockerhub-username/cobalt-web:v11.0
```

### 4. 域名配置
- API 服务: `download.cohook.com`
- Web 服务: `cobalt.cohook.com`

确保这些域名指向您的 VPS IP 地址。

## 高级配置

### Docker 构建特性

#### Web 前端构建
- **预构建镜像**: 使用 Docker Hub 上的 `wizdy/cobalt-web:latest`
- **多阶段构建**: 使用 Node.js 构建，Nginx 运行
- **版本信息**: 包含 .git 目录用于版本追踪和调试
- **静态优化**: 预编译的 SvelteKit 静态文件
- **缓存优化**: 使用 pnpm 缓存加速构建

#### 镜像管理
- **生产镜像**: `wizdy/cobalt-web:latest`
- **版本镜像**: `wizdy/cobalt-web:v11.0`
- **自定义镜像**: 使用 `build-and-push.sh` 构建

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

1. **Web 镜像拉取失败**
   - 检查网络连接到 Docker Hub
   - 确认镜像标签存在: `docker pull wizdy/cobalt-web:latest`
   - 尝试使用代理或镜像源

2. **镜像版本问题**
   - 检查使用的镜像标签是否正确
   - 更新到最新版本: 修改 `docker-compose.yml` 中的标签

3. **自定义镜像构建失败**
   - 检查 `WEB_DEFAULT_API` 是否正确设置
   - 确保所有依赖都已安装
   - 验证 .git 目录是否存在（版本信息需要）

4. **API 连接问题**
   - 验证 API 服务是否运行在正确端口
   - 检查防火墙设置

5. **CORS 错误**
   - 确保 API 服务器的 CORS 配置允许 Web 域名

6. **构建缓存问题**
   - 清理 Docker 构建缓存: `docker builder prune`
   - 强制重新构建: `docker-compose build --no-cache cobalt-web`

### 日志查看
```bash
# 查看服务日志
docker-compose logs cobalt-api
docker-compose logs cobalt-web

# 实时跟踪日志
docker-compose logs -f cobalt-web

# 查看镜像拉取日志
docker pull wizdy/cobalt-web:latest

# 查看本地构建日志（如果使用 dev 版本）
docker-compose -f docker-compose.dev.yml build cobalt-web
```

## 性能优化

### 部署性能
- **快速部署**: 使用预构建镜像，无需在服务器构建
- **镜像缓存**: Docker Hub 镜像分层缓存
- **网络优化**: 选择就近的 Docker Hub 镜像源

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

### 镜像安全
- **官方源**: 使用 Docker Hub 官方镜像源
- **签名验证**: 验证镜像签名和校验和
- **定期更新**: 定期更新镜像到最新版本
- **漏洞扫描**: 使用 Docker Scout 或其他工具扫描漏洞

### 网络安全
- 服务间通信通过 Docker 网络
- 仅必要端口暴露给外部

### 内容安全策略
Web 服务配置了严格的 CSP 头，符合 Cobalt 的安全要求。

### Git 目录安全
- .git 目录仅用于版本信息，不暴露给外部访问
- Nginx 配置阻止对隐藏文件的访问

### 更新策略
- **API**: 使用官方镜像，定期更新
- **Web**: 使用 Docker Hub 预构建镜像，或自行构建
- **版本控制**: 使用明确的镜像标签而非 `latest`

## 监控建议

### 镜像监控
- 镜像拉取状态和时间
- 镜像大小和层数
- 镜像更新频率

### 服务监控
建议设置以下监控：
- 服务健康状态
- 响应时间
- 资源使用情况
- 错误率
- 部署状态和时间

可以集成 Grafana、Prometheus 或其他监控解决方案。

## 相关文档

- [构建和部署指南](BUILD_AND_DEPLOY.md)
- [环境变量配置](env.example)
- [Docker Hub 镜像](https://hub.docker.com/r/wizdy/cobalt-web)
- [开发环境配置](docker-compose.dev.yml) 