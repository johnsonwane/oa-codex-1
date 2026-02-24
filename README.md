# 培训项目协作 OA 系统（PHP7.4 + MySQL + Apache + HBuilderX + UniApp v3）

本项目是同一分支 (`work`) 持续迭代的 dev 版本，当前已包含：

- **后端**：PHP 7.4 语法兼容，原生 API 网关
- **数据库**：MySQL 8（基础表 + 扩展表）
- **Web**：Apache（rewrite + vhost 示例）
- **前端**：
  - HBuilderX 可直接打开的 Web 管理台页面
  - UniApp v3 多端页面骨架（App/H5/小程序）

---

## 1. 核心能力（本次补齐）

### 1.1 更细 RBAC（按 `role_permission` 动态拦截）

后端新增动态鉴权：

- 按 `module_code + page_code + action` 检查 `role_permission`。
- 动作映射：
  - `GET -> can_view`
  - `POST -> can_create`
  - `PUT -> can_edit`
  - `DELETE -> can_delete`
- 数据范围按 `data_scope` 应用：
  - `ALL` 全量
  - `COMPANY` 公司级
  - `DEPT` 部门级（可用时）
  - `SELF` 本人级（按 `creator_id/sales_id/...` 自动识别）

接口：

- `GET /permissions/check?module_code=...&page_code=...&action=...`

### 1.2 流程审批（采购/费用/发票）

新增审批 API：

- `GET /approvals/pending`
- `POST /approvals/purchase?id={id}`
- `POST /approvals/expense?id={id}`
- `POST /approvals/invoice?id={id}`

请求体示例：

```json
{ "action": "approve" }
```

或

```json
{ "action": "reject" }
```

### 1.3 顾问/交付看板与图表

新增：

- `GET /dashboard/consultant`
- `GET /dashboard/delivery`

前端已显示趋势条形图（7日趋势）和关键统计卡片。

### 1.4 文件上传、操作日志、消息通知

- 文件上传：`POST /upload`（`multipart/form-data`，字段名 `file`）
- 操作日志：`GET /logs/operation`
- 消息通知：
  - `GET /notifications/my`
  - `POST /notifications/read?id={id}`

> 为支持日志与通知，请执行扩展 SQL：`oa-system/backend/sql/schema_ext.sql`

### 1.5 UniApp v3 多端页面（App/H5/小程序）

新增目录：`oa-system/uniapp-v3`

- `pages/login/login.vue`
- `pages/dashboard/dashboard.vue`
- `pages.json` / `manifest.json` / `App.vue` / `main.js`

可直接用 HBuilderX 打开该目录进行多端运行。

---

## 2. 目录结构

```text
.
├── schema.sql
├── 数据结构设计文档.md
└── oa-system
    ├── backend
    │   ├── config/config.php
    │   ├── public/index.php
    │   ├── public/.htaccess
    │   ├── src/{Auth.php,Database.php,Response.php}
    │   ├── sql/schema_ext.sql
    │   └── storage/uploads/
    ├── frontend/index.html
    ├── uniapp-v3/
    │   ├── App.vue
    │   ├── main.js
    │   ├── pages.json
    │   ├── manifest.json
    │   └── pages/
    │       ├── login/login.vue
    │       └── dashboard/dashboard.vue
    └── docs/apache-vhost.conf
```

---

## 3. 初始化数据库

```bash
mysql -u root -p < schema.sql
mysql -u root -p < oa-system/backend/sql/schema_ext.sql
```

基础库名：`oa_codex`。

---

## 4. 后端配置

默认配置文件：`oa-system/backend/config/config.php`

支持环境变量覆盖：

- `DB_HOST`
- `DB_PORT`
- `DB_NAME`
- `DB_USER`
- `DB_PASS`
- `JWT_SECRET`

---

## 5. Apache 部署（按你当前线上目录）

参考：`oa-system/docs/apache-vhost.conf`

当前约定：

- 前端域名根目录：`https://oac.hahahaxinli.com`
- 前端 FTP 目录：`/opt/webapps/oac.hahahaxinli.com/frontend`
- 后端接口入口：`https://oac.hahahaxinli.com`（不再使用 `/api` 路径）
- 后端 FTP 目录：`/opt/webapps/oac.hahahaxinli.com/backend`
- 仅监听 443（HTTPS）

证书配置：

```apache
SSLEngine on
SSLCertificateFile /opt/cert/oac.hahahaxinli.com.crt
SSLCertificateKeyFile /opt/cert/oac.hahahaxinli.com.key
SSLCertificateChainFile /opt/cert/root_bundle.crt
```

说明：

- 前端访问静态页面：`/` 下直接打开 `index.html`。
- 后端接口统一走物理目录入口（例如 `/login`、`/dashboard/summary`、`/approvals/pending`）。
- 已取消 `/api` 路由前缀，改为多个物理文件夹入口。

---

## 6. 快速验证账号

来自种子数据：

- `boss_hg`（老板）
- `consult_hg`（顾问）
- `delivery_hg`（交付）

密码：示例账号可用任意值（演示环境兼容处理）。
