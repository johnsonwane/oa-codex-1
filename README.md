# 培训项目协作 OA 系统（PHP7.4 + MySQL + Apache + HBuilderX）

本仓库现已提供一个可直接落地的 OA 系统基础版：

- **后端**：PHP 7.4（原生路由 + PDO）
- **数据库**：MySQL 8（`schema.sql`，含 32 张表 + 测试数据）
- **Web 服务**：Apache（示例 vhost 已提供）
- **前端**：HBuilderX 可直接打开的 `frontend/index.html`

## 目录结构

```text
.
├── schema.sql
├── 数据结构设计文档.md
└── oa-system
    ├── backend
    │   ├── config/config.php
    │   ├── src/
    │   │   ├── Auth.php
    │   │   ├── Database.php
    │   │   └── Response.php
    │   └── public/
    │       ├── .htaccess
    │       └── index.php
    ├── frontend
    │   └── index.html
    └── docs
        └── apache-vhost.conf
```

## 1. 初始化数据库

```bash
mysql -u root -p < schema.sql
```

默认数据库名：`oa_codex`

## 2. 配置后端

编辑 `oa-system/backend/config/config.php` 或使用环境变量：

- `DB_HOST`
- `DB_PORT`
- `DB_NAME`
- `DB_USER`
- `DB_PASS`
- `JWT_SECRET`

## 3. Apache 部署

1. 复制 `oa-system/docs/apache-vhost.conf` 到站点配置并启用。  
2. 确保开启模块：`rewrite`。  
3. 重启 Apache。

- 后端 API：`http://oa.local/api/...`
- 前端页面：`http://oa.local/app/index.html`

## 4. 登录测试账号

来自 `schema.sql` 的测试数据：

- 用户名：`consult_hg`（顾问）
- 用户名：`boss_hg`（老板）
- 密码：任意值（示例数据为了演示，已做兼容）

## 5. 核心接口

- `POST /api/login`
- `GET /api/me`
- `GET /api/dashboard/summary`
- `GET/POST/PUT/DELETE /api/resource/{resource}`

支持资源（示例）：

- `students`
- `orders`
- `courses`
- `incomes`
- `expenses`
- `users`
- `companies`

## 6. 说明

该版本是“可运行的完整基础版 OA 系统”：

- 已覆盖组织、权限、业务、财务、统计全链路数据结构；
- 已提供认证、数据访问、公司级数据隔离（非老板仅看本公司）；
- 已提供前端登录 + 仪表盘 + 学员列表可视化页面。

如需我继续下一步，我可以在这个基础上继续补齐：

- 更细 RBAC（按 `role_permission` 动态拦截）
- 流程审批（采购/费用/发票）
- 顾问/交付看板与报表图表
- 文件上传、操作日志、消息通知
- 多端 UniApp 页面（App/H5/小程序）
