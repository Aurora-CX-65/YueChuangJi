# 阅创集API接口文档

## 概述

阅创集是一个创作与阅读一体化平台，提供完整的RESTful API接口供前端调用。本文档基于最新的代码实现，包含所有已实现的接口功能。

**基础信息：**
- 基础URL: `http://localhost:8080`
- API版本: v2.0.0
- 认证方式: JWT Bearer Token + Spring Security
- 数据格式: JSON
- 文档更新时间: 2025-10-20

## 认证说明

除了公开接口外，所有API都需要在请求头中携带JWT Token：

```
Authorization: Bearer {your-jwt-token}
```

系统采用基于角色的权限控制（RBAC），主要角色包括：
- **USER**: 普通用户
- **AUTHOR**: 作者（具有内容创建权限）
- **EDITOR**: 编辑（具有内容审核权限）
- **ADMIN**: 管理员（具有所有权限）

## 统一响应格式

所有API响应都遵循统一格式：

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {},
  "timestamp": 1760700624525
}
```

**响应码说明：**
- 200: 操作成功
- 201: 未授权访问
- 400: 请求参数错误
- 403: 权限不足
- 404: 资源不存在
- 409: 资源冲突
- 429: 请求频率过高
- 500: 服务器内部错误

## API接口目录

### 接口模块概览

| 模块 | 路径前缀 | 描述 | 接口数量 |
|------|----------|------|----------|
| 1. 认证管理 | `/api/auth` | 用户登录、注册、密码重置等 | 6个 |
| 2. 用户管理 | `/api/users` | 用户信息、关注、收藏等 | 16个 |
| 3. 书籍管理 | `/api/books` | 书籍CRUD、搜索、点赞收藏等 | 15个 |
| 4. 章节管理 | `/api/chapters` | 章节CRUD、发布管理等 | 8个 |
| 5. AI功能 | `/api/ai` | 自动纠错、续写、建议等 | 6个 |
| 6. 评论管理 | `/api/comments` | 评论CRUD、点赞等 | 6个 |
| 7. 分类管理 | `/api/categories` | 分类查询、层级管理等 | 4个 |
| 8. 标签管理 | `/api/tags` | 标签查询、搜索、热门推荐等 | 5个 |
| 9. 文件上传 | `/api/files` | 文件上传、删除、管理等 | 7个 |
| 10. 通知管理 | `/api/notifications` | 通知CRUD、设置管理等 | 15个 |
| 11. 审核管理 | `/api/review` | 内容审核、审核流程等 | 6个 |
| 12. 管理员功能 | `/api/admin` | 后台管理、系统设置等 | 20个 |

**总计**: 114个API接口

## API接口列表

### 1. 认证接口 (/api/auth)

#### 1.1 用户登录
- **接口**: `POST /api/auth/login`
- **描述**: 用户通过用户名/邮箱和密码登录系统
- **请求参数**:
```json
{
  "username": "testuser",
  "password": "password123"
}
```
- **响应示例**:
```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiJ9...",
    "tokenType": "Bearer",
    "expiresIn": 86400,
    "user": {
      "id": 1,
      "username": "testuser",
      "nickname": "测试用户",
      "role": "USER"
    }
  }
}
```

#### 1.2 用户注册
- **接口**: `POST /api/auth/register`
- **描述**: 新用户注册账号
- **请求参数**:
```json
{
  "username": "testuser",
  "email": "test@example.com",
  "password": "password123",
  "nickname": "测试用户",
  "emailCode": "123456"
}
```
- **响应示例**:
```json
{
  "code": 200,
  "message": "注册成功",
  "data": true
}
```

#### 1.3 用户登出
- **接口**: `POST /api/auth/logout`
- **描述**: 用户退出登录
- **认证**: 需要JWT Token
- **响应示例**:
```json
{
  "code": 200,
  "message": "登出成功",
  "data": true
}
```

#### 1.4 刷新令牌
- **接口**: `POST /api/auth/refresh`
- **描述**: 使用刷新令牌获取新的访问令牌
- **请求参数**: `refreshToken` (query parameter)
- **响应示例**: 同登录响应

#### 1.5 发送邮箱验证码
- **接口**: `POST /api/auth/send-email-code`
- **描述**: 发送邮箱验证码用于注册或重置密码
- **请求参数**:
```json
{
  "email": "test@example.com",
  "type": "register"
}
```

#### 1.6 验证邮箱验证码
- **接口**: `POST /api/auth/verify-email-code`
- **描述**: 验证邮箱验证码是否正确
- **请求参数**: email, code, type (query parameters)

#### 1.7 重置密码
- **接口**: `POST /api/auth/reset-password`
- **描述**: 通过邮箱验证码重置用户密码
- **请求参数**:
```json
{
  "email": "test@example.com",
  "code": "123456",
  "newPassword": "newpassword123",
  "confirmPassword": "newpassword123"
}
```

#### 1.8 验证邮箱
- **接口**: `POST /api/auth/verify-email`
- **描述**: 验证用户邮箱地址
- **请求参数**: email, code (query parameters)

#### 1.9 检查用户名可用性
- **接口**: `GET /api/auth/check-username`
- **描述**: 检查用户名是否已被使用
- **请求参数**: username (query parameter)

#### 1.10 检查邮箱可用性
- **接口**: `GET /api/auth/check-email`
- **描述**: 检查邮箱是否已被注册
- **请求参数**: email (query parameter)

### 2. 用户管理接口 (/api/users)

#### 2.1 获取当前用户信息
- **接口**: `GET /api/users/profile`
- **描述**: 获取当前登录用户的详细信息
- **认证**: 需要JWT Token
- **响应示例**:
```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "id": 1,
    "username": "testuser",
    "email": "test@example.com",
    "nickname": "测试用户",
    "avatar": "/static/images/default-avatar.png",
    "bio": "这是一个测试用户",
    "role": "USER",
    "status": "ACTIVE",
    "createdTime": "2025-01-01T00:00:00",
    "stats": {
      "followingCount": 10,
      "followersCount": 5,
      "bookCount": 3,
      "totalWordCount": 50000
    }
  }
}
```

#### 2.2 根据用户ID获取用户信息
- **接口**: `GET /api/users/{userId}`
- **描述**: 根据用户ID获取用户的公开信息
- **路径参数**: userId - 用户ID
- **响应示例**: 同上（不包含敏感信息如邮箱）

#### 2.3 根据用户名获取用户信息
- **接口**: `GET /api/users/username/{username}`
- **描述**: 根据用户名获取用户的公开信息
- **路径参数**: username - 用户名

#### 2.4 更新用户信息
- **接口**: `PUT /api/users/profile`
- **描述**: 更新当前用户的个人信息
- **认证**: 需要JWT Token
- **请求参数**:
```json
{
  "nickname": "新昵称",
  "bio": "个人简介",
  "avatar": "/uploads/avatar.jpg"
}
```

#### 2.5 上传用户头像
- **接口**: `POST /api/users/avatar`
- **描述**: 上传并更新用户头像
- **认证**: 需要JWT Token
- **请求**: multipart/form-data
- **参数**: file (图片文件)
- **响应**: 返回头像URL

#### 2.6 关注用户
- **接口**: `POST /api/users/{userId}/follow`
- **描述**: 关注指定用户
- **认证**: 需要JWT Token
- **路径参数**: userId - 被关注用户ID

#### 2.7 取消关注用户
- **接口**: `DELETE /api/users/{userId}/follow`
- **描述**: 取消关注指定用户
- **认证**: 需要JWT Token
- **路径参数**: userId - 被取消关注用户ID

#### 2.8 检查关注状态
- **接口**: `GET /api/users/{userId}/follow/status`
- **描述**: 检查当前用户是否已关注指定用户
- **认证**: 需要JWT Token
- **路径参数**: userId - 用户ID

#### 2.9 获取用户关注列表
- **接口**: `GET /api/users/{userId}/following`
- **描述**: 获取用户的关注列表
- **查询参数**: page (页码), size (每页大小)
- **响应**: 分页的用户列表

#### 2.10 获取用户粉丝列表
- **接口**: `GET /api/users/{userId}/followers`
- **描述**: 获取用户的粉丝列表
- **查询参数**: page, size

#### 2.11 获取用户统计信息
- **接口**: `GET /api/users/{userId}/stats`
- **描述**: 获取用户的统计信息（关注数、粉丝数等）
- **路径参数**: userId - 用户ID

#### 2.12 搜索用户
- **接口**: `GET /api/users/search`
- **描述**: 根据关键词搜索用户
- **查询参数**: keyword (搜索关键词), page, size

#### 2.13 获取当前用户关注列表
- **接口**: `GET /api/users/following`
- **描述**: 获取当前登录用户的关注列表
- **认证**: 需要JWT Token
- **查询参数**: page, size

#### 2.14 获取当前用户粉丝列表
- **接口**: `GET /api/users/followers`
- **描述**: 获取当前登录用户的粉丝列表
- **认证**: 需要JWT Token
- **查询参数**: page, size

#### 2.15 获取当前用户收藏书籍列表（书架）
- **接口**: `GET /api/users/favorites`
- **描述**: 获取当前登录用户的书架（收藏的书籍列表）- **推荐使用此接口**
- **认证**: 需要JWT Token
- **查询参数**: page (页码，默认1), size (每页大小，默认10)
- **响应示例**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "records": [
      {
        "id": 1,
        "title": "测试书籍",
        "description": "书籍描述",
        "coverImage": "/uploads/cover.jpg",
        "authorUsername": "author1",
        "categoryName": "小说",
        "status": "published",
        "wordCount": 50000,
        "viewCount": 1000,
        "likeCount": 100,
        "favoriteCount": 50,
        "isLiked": false,
        "isFavorited": true,
        "createdAt": "2025-01-01T00:00:00"
      }
    ],
    "total": 1,
    "current": 1,
    "size": 10
  }
}
```

#### 2.16 获取指定用户收藏书籍列表
- **接口**: `GET /api/users/{userId}/favorites`
- **描述**: 获取指定用户的书架（收藏的书籍列表）
- **路径参数**: userId - 用户ID
- **查询参数**: page (页码，默认1), size (每页大小，默认10)
- **响应示例**: 同上

### 3. 书籍管理接口 (/api/books)

#### 3.1 创建书籍
- **接口**: `POST /api/books`
- **描述**: 创建新的书籍
- **认证**: 需要JWT Token + CONTENT_CREATE权限
- **请求参数**:
```json
{
  "title": "书籍标题",
  "description": "书籍描述",
  "categoryId": 1,
  "tagIds": [1, 2, 3],
  "coverImage": "/uploads/cover.jpg"
}
```

#### 3.2 根据ID获取书籍详情
- **接口**: `GET /api/books/{bookId}`
- **描述**: 根据书籍ID获取书籍的详细信息
- **路径参数**: bookId - 书籍ID
- **功能**: 自动增加阅读量（已登录用户）
- **响应示例**:
```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "id": 1,
    "title": "测试书籍",
    "description": "书籍描述",
    "coverImage": "/static/images/default-book-cover.png",
    "author": {
      "id": 1,
      "nickname": "作者昵称",
      "avatar": "/uploads/avatar.jpg"
    },
    "category": {
      "id": 1,
      "name": "小说"
    },
    "tags": [
      {"id": 1, "name": "都市"},
      {"id": 2, "name": "言情"}
    ],
    "status": "PUBLISHED",
    "wordCount": 50000,
    "chapterCount": 10,
    "viewCount": 1000,
    "likeCount": 100,
    "favoriteCount": 50,
    "isLiked": false,
    "isFavorited": false,
    "createdTime": "2025-01-01T00:00:00",
    "updatedTime": "2025-01-01T00:00:00"
  }
}
```

#### 3.3 更新书籍信息
- **接口**: `PUT /api/books/{bookId}`
- **描述**: 更新指定书籍的信息
- **认证**: 需要JWT Token + CONTENT_EDIT权限
- **路径参数**: bookId - 书籍ID

#### 3.4 删除书籍
- **接口**: `DELETE /api/books/{bookId}`
- **描述**: 删除指定的书籍
- **认证**: 需要JWT Token + CONTENT_EDIT权限
- **路径参数**: bookId - 书籍ID

#### 3.5 获取书籍列表
- **接口**: `GET /api/books`
- **描述**: 支持分页、关键词搜索、分类筛选的书籍列表查询
- **查询参数**:
  - page: 页码 (默认1)
  - size: 每页大小 (默认10)
  - keyword: 搜索关键词
  - categoryId: 分类ID
  - status: 书籍状态
- **响应**: 分页的书籍列表

#### 3.6 复杂搜索书籍
- **接口**: `POST /api/books/search`
- **描述**: 支持复杂条件的书籍搜索
- **请求参数**: BookSearchRequest对象

#### 3.7 根据作者获取书籍列表
- **接口**: `GET /api/books/author/{authorId}`
- **描述**: 根据作者ID获取其所有书籍
- **路径参数**: authorId - 作者ID
- **查询参数**: page, size

#### 3.8 根据分类获取书籍列表
- **接口**: `GET /api/books/category/{categoryId}`
- **描述**: 根据分类ID获取该分类下的所有书籍
- **路径参数**: categoryId - 分类ID
- **查询参数**: page, size

#### 3.9 根据标签获取书籍列表
- **接口**: `GET /api/books/tags`
- **描述**: 根据标签ID列表获取相关书籍
- **查询参数**: tagIds (标签ID列表), page, size

#### 3.10 点赞书籍
- **接口**: `POST /api/books/{bookId}/like`
- **描述**: 为指定书籍点赞
- **认证**: 需要JWT Token
- **路径参数**: bookId - 书籍ID

#### 3.11 取消点赞书籍
- **接口**: `DELETE /api/books/{bookId}/like`
- **描述**: 取消对指定书籍的点赞
- **认证**: 需要JWT Token
- **路径参数**: bookId - 书籍ID

#### 3.12 检查点赞状态
- **接口**: `GET /api/books/{bookId}/like/status`
- **描述**: 检查当前用户是否已点赞指定书籍
- **路径参数**: bookId - 书籍ID

#### 3.13 收藏书籍
- **接口**: `POST /api/books/{bookId}/favorite`
- **描述**: 将指定书籍添加到收藏夹
- **认证**: 需要JWT Token
- **路径参数**: bookId - 书籍ID

#### 3.14 取消收藏书籍
- **接口**: `DELETE /api/books/{bookId}/favorite`
- **描述**: 从收藏夹中移除指定书籍
- **认证**: 需要JWT Token
- **路径参数**: bookId - 书籍ID

#### 3.15 检查收藏状态
- **接口**: `GET /api/books/{bookId}/favorite/status`
- **描述**: 检查当前用户是否已收藏指定书籍
- **路径参数**: bookId - 书籍ID

#### 3.16 获取热门书籍
- **接口**: `GET /api/books/hot`
- **描述**: 获取热门书籍列表，按点赞数和阅读量排序
- **查询参数**: limit (限制数量，默认10)

#### 3.17 获取最新书籍
- **接口**: `GET /api/books/latest`
- **描述**: 获取最新发布的书籍列表
- **查询参数**: limit (限制数量，默认10)

#### 3.18 获取用户收藏书籍列表（备用接口）
- **接口**: `GET /api/books/favorites`
- **描述**: 获取当前用户收藏的书籍列表（书架）- 备用接口，推荐使用 `/api/users/favorites`
- **认证**: 需要JWT Token
- **查询参数**: page (页码，默认1), size (每页大小，默认10)
- **注意**: 此接口与 `GET /api/users/favorites` 功能相同，为保持兼容性而保留
- **响应示例**:
```json
{
  "code": 200,
  "message": "获取收藏列表成功",
  "data": {
    "records": [
      {
        "id": 1,
        "title": "测试书籍",
        "description": "书籍描述",
        "coverImage": "/uploads/cover.jpg",
        "authorUsername": "author1",
        "categoryName": "小说",
        "tags": [
          {"id": 1, "name": "都市"},
          {"id": 2, "name": "言情"}
        ],
        "status": "published",
        "wordCount": 50000,
        "chapterCount": 10,
        "viewCount": 1000,
        "likeCount": 100,
        "favoriteCount": 50,
        "isLiked": false,
        "isFavorited": true,
        "createdAt": "2025-01-01T00:00:00"
      }
    ],
    "total": 1,
    "current": 1,
    "size": 10
  }
}
```

#### 3.19 上传书籍封面
- **接口**: `POST /api/books/{bookId}/cover`
- **描述**: 上传并更新书籍封面图片
- **认证**: 需要JWT Token + CONTENT_EDIT权限
- **路径参数**: bookId - 书籍ID
- **请求**: multipart/form-data
- **参数**: file (封面文件)

### 4. 章节管理接口 (/api/chapters)

#### 4.1 创建章节
- **接口**: `POST /api/chapters`
- **描述**: 为指定书籍创建新章节
- **认证**: 需要JWT Token
- **请求参数**:
```json
{
  "bookId": 1,
  "title": "章节标题",
  "content": "章节内容",
  "orderNum": 1
}
```

#### 4.2 根据ID获取章节详情
- **接口**: `GET /api/chapters/{chapterId}`
- **描述**: 根据章节ID获取章节的详细信息
- **路径参数**: chapterId - 章节ID
- **功能**: 自动增加阅读量（已登录用户）
- **响应示例**:
```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "id": 1,
    "title": "第一章 开始",
    "content": "章节内容...",
    "bookId": 1,
    "bookTitle": "书籍标题",
    "authorId": 1,
    "authorName": "作者昵称",
    "orderNum": 1,
    "wordCount": 2000,
    "viewCount": 500,
    "status": "PUBLISHED",
    "createdTime": "2025-01-01T00:00:00",
    "updatedTime": "2025-01-01T00:00:00"
  }
}
```

#### 4.3 更新章节信息
- **接口**: `PUT /api/chapters/{chapterId}`
- **描述**: 更新指定章节的信息
- **认证**: 需要JWT Token (仅作者可操作)
- **路径参数**: chapterId - 章节ID

#### 4.4 删除章节
- **接口**: `DELETE /api/chapters/{chapterId}`
- **描述**: 删除指定的章节
- **认证**: 需要JWT Token (仅作者可操作)
- **路径参数**: chapterId - 章节ID

#### 4.5 获取书籍章节列表
- **接口**: `GET /api/chapters/book/{bookId}`
- **描述**: 根据书籍ID获取章节列表，支持分页查询和章节排序
- **路径参数**: bookId - 书籍ID
- **查询参数**: page (页码，默认1), size (每页大小，默认10)
- **响应**: 分页的章节列表

#### 4.6 发布章节
- **接口**: `POST /api/chapters/{chapterId}/publish`
- **描述**: 将章节状态更新为已发布
- **认证**: 需要JWT Token (仅作者可操作)
- **路径参数**: chapterId - 章节ID

#### 4.7 取消发布章节
- **接口**: `POST /api/chapters/{chapterId}/unpublish`
- **描述**: 将章节状态更新为草稿
- **认证**: 需要JWT Token (仅作者可操作)
- **路径参数**: chapterId - 章节ID

### 5. AI功能接口 (/api/ai)

**注意**: 所有AI功能接口都有频率限制（每用户每分钟最多20次调用）

#### 5.1 自动纠错
- **接口**: `POST /api/ai/auto-correct`
- **描述**: 使用AI对文本内容进行自动纠错
- **认证**: 需要JWT Token
- **频率限制**: 20次/分钟
- **请求参数**:
```json
{
  "content": "需要纠错的文本内容"
}
```
- **响应示例**:
```json
{
  "code": 200,
  "message": "自动纠错完成",
  "data": "纠错后的文本内容"
}
```

#### 5.2 内容续写
- **接口**: `POST /api/ai/content-continue`
- **描述**: 使用AI对文本内容进行续写
- **认证**: 需要JWT Token
- **频率限制**: 20次/分钟
- **请求参数**:
```json
{
  "content": "已有内容",
  "wordCount": 500
}
```
- **响应示例**:
```json
{
  "code": 200,
  "message": "内容续写完成",
  "data": "续写后的内容"
}
```

#### 5.3 情节建议
- **接口**: `POST /api/ai/plot-suggest`
- **描述**: 使用AI为故事情节提供建议
- **认证**: 需要JWT Token
- **频率限制**: 20次/分钟
- **请求参数**:
```json
{
  "content": "当前情节描述"
}
```
- **响应示例**:
```json
{
  "code": 200,
  "message": "情节建议生成完成",
  "data": "AI生成的情节建议"
}
```

#### 5.4 人物发展建议
- **接口**: `POST /api/ai/character-develop`
- **描述**: 使用AI为人物发展提供建议
- **认证**: 需要JWT Token
- **频率限制**: 20次/分钟
- **请求参数**:
```json
{
  "content": "人物描述和背景"
}
```
- **响应示例**:
```json
{
  "code": 200,
  "message": "人物发展建议生成完成",
  "data": "AI生成的人物发展建议"
}
```

#### 5.5 获取AI使用记录
- **接口**: `GET /api/ai/usage-logs`
- **描述**: 获取当前用户的AI功能使用记录
- **认证**: 需要JWT Token
- **查询参数**: page (页码), size (每页大小)
- **响应**: 分页的使用记录列表

#### 5.6 获取AI使用统计
- **接口**: `GET /api/ai/usage-stats`
- **描述**: 获取当前用户AI功能使用统计
- **认证**: 需要JWT Token
- **响应示例**:
```json
{
  "code": 200,
  "message": "获取使用统计成功",
  "data": {
    "totalCalls": 150,
    "todayCalls": 10,
    "remainingCalls": 10,
    "functionStats": {
      "autoCorrect": 50,
      "contentContinue": 40,
      "plotSuggest": 35,
      "characterDevelop": 25
    }
  }
}
```

### 6. 评论管理接口 (/api/comments)

#### 6.1 获取书籍评论列表
- **接口**: `GET /api/comments/book/{bookId}`
- **描述**: 分页获取指定书籍的评论列表
- **路径参数**: bookId - 书籍ID
- **查询参数**: page (页码), size (每页大小)
- **响应**: 分页的评论列表

#### 6.2 添加评论
- **接口**: `POST /api/comments/book/{bookId}`
- **描述**: 为指定书籍添加评论
- **认证**: 需要JWT Token
- **路径参数**: bookId - 书籍ID
- **请求参数**:
```json
{
  "content": "评论内容",
  "rating": 5
}
```

#### 6.3 更新评论
- **接口**: `PUT /api/comments/{commentId}`
- **描述**: 更新指定评论的内容
- **认证**: 需要JWT Token (仅评论作者可操作)
- **路径参数**: commentId - 评论ID

#### 6.4 删除评论
- **接口**: `DELETE /api/comments/{commentId}`
- **描述**: 删除指定的评论
- **认证**: 需要JWT Token (仅评论作者可操作)
- **路径参数**: commentId - 评论ID

#### 6.5 点赞评论
- **接口**: `POST /api/comments/{commentId}/like`
- **描述**: 为指定评论点赞或取消点赞
- **认证**: 需要JWT Token
- **路径参数**: commentId - 评论ID

#### 6.6 获取用户在指定书籍的评论
- **接口**: `GET /api/comments/book/{bookId}/user-comment`
- **描述**: 获取当前用户在指定书籍下的评论
- **认证**: 需要JWT Token
- **路径参数**: bookId - 书籍ID

### 7. 分类管理接口 (/api/categories)

#### 7.1 获取分类列表
- **接口**: `GET /api/categories`
- **描述**: 获取所有启用状态的分类列表
- **响应示例**:
```json
{
  "code": 200,
  "message": "获取分类列表成功",
  "data": [
    {
      "id": 1,
      "name": "小说",
      "description": "各类小说作品",
      "parentId": null,
      "orderNum": 1,
      "status": "ACTIVE"
    }
  ]
}
```

#### 7.2 根据ID获取分类详情
- **接口**: `GET /api/categories/{categoryId}`
- **描述**: 根据分类ID获取分类的详细信息
- **路径参数**: categoryId - 分类ID

#### 7.3 获取根分类列表
- **接口**: `GET /api/categories/root`
- **描述**: 获取所有根分类（顶级分类）

#### 7.4 根据父分类ID获取子分类列表
- **接口**: `GET /api/categories/{parentId}/children`
- **描述**: 根据父分类ID获取其下的子分类列表
- **路径参数**: parentId - 父分类ID

### 8. 标签管理接口 (/api/tags)

#### 8.1 获取标签列表
- **接口**: `GET /api/tags`
- **描述**: 获取所有启用状态的标签列表

#### 8.2 根据ID获取标签详情
- **接口**: `GET /api/tags/{tagId}`
- **描述**: 根据标签ID获取标签的详细信息
- **路径参数**: tagId - 标签ID

#### 8.3 获取热门标签列表
- **接口**: `GET /api/tags/hot`
- **描述**: 获取使用次数最多的热门标签
- **查询参数**: limit (限制数量，默认20)

#### 8.4 根据书籍ID获取关联的标签列表
- **接口**: `GET /api/tags/book/{bookId}`
- **描述**: 根据书籍ID获取该书籍关联的所有标签
- **路径参数**: bookId - 书籍ID

#### 8.5 搜索标签
- **接口**: `GET /api/tags/search`
- **描述**: 根据关键词搜索标签
- **查询参数**: keyword (搜索关键词), limit (限制数量，默认10)

### 9. 文件上传接口 (/api/files)

#### 9.1 上传通用文件
- **接口**: `POST /api/files/upload`
- **描述**: 上传通用文件到指定分类
- **认证**: 需要JWT Token
- **请求**: multipart/form-data
- **参数**: 
  - file (文件)
  - category (文件分类)

#### 9.2 删除文件
- **接口**: `DELETE /api/files`
- **描述**: 删除指定的文件
- **认证**: 需要JWT Token
- **查询参数**: fileUrl (文件URL)

#### 9.3 批量删除文件
- **接口**: `DELETE /api/files/batch`
- **描述**: 批量删除多个文件
- **认证**: 需要JWT Token
- **请求参数**: 文件URL列表

#### 9.4 获取文件信息
- **接口**: `GET /api/files/info`
- **描述**: 获取指定文件的详细信息
- **查询参数**: fileUrl (文件URL)

#### 9.5 检查文件是否存在
- **接口**: `GET /api/files/exists`
- **描述**: 检查指定文件是否存在
- **查询参数**: fileUrl (文件URL)

#### 9.6 获取用户文件使用统计
- **接口**: `GET /api/files/usage-stats`
- **描述**: 获取当前用户的文件使用统计
- **认证**: 需要JWT Token

#### 9.7 清理过期文件
- **接口**: `POST /api/files/cleanup`
- **描述**: 清理指定天数前的过期文件（管理员功能）
- **认证**: 需要JWT Token + 管理员权限
- **查询参数**: daysOld (清理多少天前的文件，默认7)

### 10. 通知管理接口 (/api/notifications)

#### 10.1 获取通知列表
- **接口**: `GET /api/notifications`
- **描述**: 分页获取当前用户的通知列表
- **认证**: 需要JWT Token
- **查询参数**: page (页码), size (每页大小)
- **响应**: 分页的通知列表

#### 10.2 获取未读通知数
- **接口**: `GET /api/notifications/unread-count`
- **描述**: 获取当前用户的未读通知数量
- **认证**: 需要JWT Token

#### 10.3 标记通知已读
- **接口**: `PUT /api/notifications/{id}/read`
- **描述**: 将指定通知标记为已读状态
- **认证**: 需要JWT Token
- **路径参数**: id - 通知ID

#### 10.4 批量标记已读
- **接口**: `PUT /api/notifications/batch-read`
- **描述**: 批量将指定通知标记为已读状态
- **认证**: 需要JWT Token
- **请求参数**: 通知ID列表

#### 10.5 全部标记已读
- **接口**: `PUT /api/notifications/read-all`
- **描述**: 将当前用户所有未读通知标记为已读
- **认证**: 需要JWT Token

#### 10.6 删除通知
- **接口**: `DELETE /api/notifications/{id}`
- **描述**: 删除指定的通知
- **认证**: 需要JWT Token
- **路径参数**: id - 通知ID

#### 10.7 批量删除通知
- **接口**: `DELETE /api/notifications/batch-delete`
- **描述**: 批量删除指定的通知
- **认证**: 需要JWT Token
- **请求参数**: 通知ID列表

#### 10.8 清空所有通知
- **接口**: `DELETE /api/notifications/clear-all`
- **描述**: 清空当前用户的所有通知
- **认证**: 需要JWT Token

#### 10.9 获取通知设置
- **接口**: `GET /api/notifications/settings`
- **描述**: 获取当前用户的通知偏好设置
- **认证**: 需要JWT Token

#### 10.10 更新通知设置
- **接口**: `PUT /api/notifications/settings`
- **描述**: 更新当前用户的通知偏好设置
- **认证**: 需要JWT Token

#### 10.11 获取通知统计
- **接口**: `GET /api/notifications/stats`
- **描述**: 获取当前用户的通知统计信息
- **认证**: 需要JWT Token

#### 10.12 创建系统通知
- **接口**: `POST /api/notifications/system`
- **描述**: 创建系统通知（管理员和编辑功能）
- **认证**: 需要JWT Token + NOTIFICATION_SEND权限
- **请求参数**:
```json
{
  "title": "通知标题",
  "content": "通知内容",
  "targetUserIds": [1, 2, 3],
  "type": "system",
  "relatedId": 123
}
```

#### 10.13 获取通知详情
- **接口**: `GET /api/notifications/{id}`
- **描述**: 获取指定通知的详细信息
- **认证**: 需要JWT Token
- **路径参数**: id - 通知ID

#### 10.14 获取实时通知信息
- **接口**: `GET /api/notifications/realtime-info`
- **描述**: 获取当前用户的实时通知状态信息
- **认证**: 需要JWT Token

#### 10.15 测试通知功能
- **接口**: `POST /api/notifications/test`
- **描述**: 发送一条测试通知验证功能是否正常
- **认证**: 需要JWT Token

### 11. 审核管理接口 (/api/review)

**注意**: 审核功能需要CONTENT_REVIEW权限或EDITOR/ADMIN角色

#### 11.1 获取待审核书籍列表
- **接口**: `GET /api/review/books/pending`
- **描述**: 获取状态为待审核的书籍列表
- **认证**: 需要CONTENT_REVIEW权限
- **查询参数**: page (页码), size (每页大小)

#### 11.2 审核通过书籍
- **接口**: `POST /api/review/books/{bookId}/approve`
- **描述**: 将书籍状态设置为已发布
- **认证**: 需要CONTENT_REVIEW权限
- **路径参数**: bookId - 书籍ID
- **请求参数**:
```json
{
  "comment": "审核意见（可选）"
}
```

#### 11.3 审核拒绝书籍
- **接口**: `POST /api/review/books/{bookId}/reject`
- **描述**: 拒绝书籍发布并提供审核意见
- **认证**: 需要CONTENT_REVIEW权限
- **路径参数**: bookId - 书籍ID
- **请求参数**:
```json
{
  "comment": "审核意见（必填）"
}
```

#### 11.4 获取待审核章节列表
- **接口**: `GET /api/review/chapters/pending`
- **描述**: 获取状态为待审核的章节列表
- **认证**: 需要CONTENT_REVIEW权限
- **查询参数**: page (页码), size (每页大小)

#### 11.5 审核通过章节
- **接口**: `POST /api/review/chapters/{chapterId}/approve`
- **描述**: 将章节状态设置为已发布
- **认证**: 需要CONTENT_REVIEW权限
- **路径参数**: chapterId - 章节ID

#### 11.6 审核拒绝章节
- **接口**: `POST /api/review/chapters/{chapterId}/reject`
- **描述**: 拒绝章节发布并提供审核意见
- **认证**: 需要CONTENT_REVIEW权限
- **路径参数**: chapterId - 章节ID

### 12. 管理员功能接口 (/api/admin)

**注意**: 所有管理员接口都需要ADMIN角色权限

#### 12.1 审核管理

##### 12.1.1 获取待审核内容列表
- **接口**: `GET /api/admin/review/items`
- **描述**: 获取需要审核的内容列表
- **查询参数**: page, size, type (审核类型), status (审核状态)

##### 12.1.2 获取审核项目详情
- **接口**: `GET /api/admin/review/items/{id}`
- **描述**: 获取指定审核项目的详细信息
- **路径参数**: id - 审核项目ID

##### 12.1.3 审核通过
- **接口**: `POST /api/admin/review/items/{id}/approve`
- **描述**: 审核通过指定项目
- **路径参数**: id - 审核项目ID

##### 12.1.4 审核拒绝
- **接口**: `POST /api/admin/review/items/{id}/reject`
- **描述**: 审核拒绝指定项目
- **路径参数**: id - 审核项目ID

##### 12.1.5 批量审核
- **接口**: `POST /api/admin/review/batch`
- **描述**: 批量处理审核项目
- **请求参数**:
```json
{
  "itemIds": [1, 2, 3],
  "result": "approve",
  "comment": "批量审核意见"
}
```

##### 12.1.6 获取审核历史
- **接口**: `GET /api/admin/review/history`
- **描述**: 获取历史审核记录
- **查询参数**: page, size, type (审核类型)

##### 12.1.7 获取审核统计
- **接口**: `GET /api/admin/review/stats`
- **描述**: 获取审核相关的统计数据

##### 12.1.8 获取作者申请列表
- **接口**: `GET /api/admin/author-applications`
- **描述**: 获取用户的作者身份申请列表
- **查询参数**: page, size, status (申请状态)

#### 12.2 用户管理

##### 12.2.1 获取用户列表
- **接口**: `GET /api/admin/users`
- **描述**: 获取系统用户列表
- **查询参数**: page, size, keyword (搜索关键词), status (用户状态), role (用户角色)

##### 12.2.2 获取用户详情
- **接口**: `GET /api/admin/users/{id}`
- **描述**: 获取指定用户的详细信息
- **路径参数**: id - 用户ID

##### 12.2.3 更新用户状态
- **接口**: `PUT /api/admin/users/{id}/status`
- **描述**: 更新用户的账户状态
- **路径参数**: id - 用户ID
- **请求参数**:
```json
{
  "status": "ACTIVE",
  "reason": "状态变更原因"
}
```

##### 12.2.4 更新用户角色
- **接口**: `PUT /api/admin/users/{id}/role`
- **描述**: 更新用户的权限角色
- **路径参数**: id - 用户ID
- **请求参数**:
```json
{
  "role": "EDITOR",
  "reason": "角色变更原因"
}
```

##### 12.2.5 重置用户密码
- **接口**: `POST /api/admin/users/{id}/reset-password`
- **描述**: 为指定用户重置密码
- **路径参数**: id - 用户ID
- **响应**: 返回新密码

#### 12.3 内容管理

##### 12.3.1 获取分类列表（管理员）
- **接口**: `GET /api/admin/categories`
- **描述**: 获取系统分类列表（管理员版本）
- **查询参数**: page, size

##### 12.3.2 创建分类
- **接口**: `POST /api/admin/categories`
- **描述**: 创建新的书籍分类

##### 12.3.3 更新分类
- **接口**: `PUT /api/admin/categories/{id}`
- **描述**: 更新指定分类信息
- **路径参数**: id - 分类ID

##### 12.3.4 删除分类
- **接口**: `DELETE /api/admin/categories/{id}`
- **描述**: 删除指定分类
- **路径参数**: id - 分类ID

##### 12.3.5 获取标签列表（管理员）
- **接口**: `GET /api/admin/tags`
- **描述**: 获取系统标签列表（管理员版本）
- **查询参数**: page, size

##### 12.3.6 创建标签
- **接口**: `POST /api/admin/tags`
- **描述**: 创建新的书籍标签

##### 12.3.7 更新标签
- **接口**: `PUT /api/admin/tags/{id}`
- **描述**: 更新指定标签信息
- **路径参数**: id - 标签ID

##### 12.3.8 删除标签
- **接口**: `DELETE /api/admin/tags/{id}`
- **描述**: 删除指定标签
- **路径参数**: id - 标签ID

#### 12.4 系统管理

##### 12.4.1 获取系统统计
- **接口**: `GET /api/admin/stats`
- **描述**: 获取系统运营统计数据

##### 12.4.2 获取系统设置
- **接口**: `GET /api/admin/settings`
- **描述**: 获取系统配置参数

##### 12.4.3 更新系统设置
- **接口**: `PUT /api/admin/settings`
- **描述**: 更新系统配置参数

##### 12.4.4 获取操作日志
- **接口**: `GET /api/admin/logs`
- **描述**: 获取系统操作日志记录
- **查询参数**: page, size, operation (操作类型), username (用户名)

## 错误处理

### 常见错误码

| 错误码 | 说明 | 解决方案 |
|--------|------|----------|
| 200 | 操作成功 | - |
| 201 | 未授权访问 | 检查JWT Token是否有效 |
| 400 | 请求参数错误 | 检查请求参数格式和必填项 |
| 403 | 权限不足 | 检查用户权限和角色 |
| 404 | 资源不存在 | 检查资源ID是否正确 |
| 409 | 资源冲突 | 检查是否存在重复数据 |
| 429 | 请求频率过高 | 降低请求频率，等待后重试 |
| 500 | 服务器内部错误 | 联系技术支持 |

### 错误响应示例

```json
{
  "code": 400,
  "message": "请求参数错误：用户名不能为空",
  "timestamp": 1760700624525
}
```

## 权限系统说明

### 角色定义
- **USER**: 普通用户，可以阅读、评论、点赞、收藏
- **AUTHOR**: 作者，具有内容创建和编辑权限
- **EDITOR**: 编辑，具有内容审核权限
- **ADMIN**: 管理员，具有所有权限

### 权限标识
- **CONTENT_CREATE**: 内容创建权限
- **CONTENT_EDIT**: 内容编辑权限
- **CONTENT_REVIEW**: 内容审核权限
- **NOTIFICATION_SEND**: 通知发送权限

### 权限验证
系统使用Spring Security的`@PreAuthorize`注解进行权限验证：
```java
@PreAuthorize("hasAuthority('CONTENT_CREATE') or hasRole('ADMIN')")
@PreAuthorize("hasRole('EDITOR')")
```

## 开发环境

### 本地开发
- **API地址**: `http://localhost:8080`
- **Swagger文档**: `http://localhost:8080/swagger-ui.html`
- **API文档**: `http://localhost:8080/v3/api-docs`

### 测试账号
- **普通用户**:
  - 用户名: `testuser`
  - 密码: `password123`
  - 邮箱: `test@example.com`

- **管理员账号**:
  - 用户名: `admin`
  - 密码: `admin123`
  - 邮箱: `admin@example.com`

## 注意事项

### 1. 认证和权限
- 大部分接口需要在请求头中携带有效的JWT Token
- 系统采用基于角色的权限控制（RBAC）
- 某些操作需要特定权限或角色

### 2. 分页查询
- 列表接口支持分页，默认每页10条记录
- 分页参数：page（页码，从1开始），size（每页大小）
- 响应格式统一为PageResult对象

### 3. 文件上传
- 支持的图片格式：jpg、jpeg、png、gif
- 文件大小限制：最大5MB
- 上传后返回文件访问URL

### 4. AI功能限制
- AI功能接口有调用频率限制：每用户每分钟最多20次
- 超出限制返回429错误码
- 建议在前端实现防抖和节流机制

### 5. 数据格式
- 所有时间字段采用ISO 8601格式
- 字符编码统一使用UTF-8
- 数值类型严格按照定义传递

### 6. 错误处理
- 统一的错误响应格式
- 详细的错误码和错误信息
- 建议前端实现统一的错误处理机制

### 7. 安全考虑
- 所有用户输入都经过验证和过滤
- 敏感操作需要权限验证
- 防止SQL注入和XSS攻击

## 接口使用示例

### 完整的用户操作流程示例

#### 1. 用户注册和登录流程
```javascript
// 1. 发送邮箱验证码
const sendCodeResponse = await fetch('/api/auth/send-email-code', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ email: 'user@example.com' })
});

// 2. 用户注册
const registerResponse = await fetch('/api/auth/register', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    username: 'testuser',
    email: 'user@example.com',
    password: 'password123',
    nickname: '测试用户',
    emailCode: '123456'
  })
});

// 3. 用户登录
const loginResponse = await fetch('/api/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    username: 'testuser',
    password: 'password123'
  })
});

const { data } = await loginResponse.json();
const token = data.accessToken;
```

#### 2. 书籍操作流程示例
```javascript
// 设置认证头
const authHeaders = {
  'Authorization': `Bearer ${token}`,
  'Content-Type': 'application/json'
};

// 1. 获取书籍列表
const booksResponse = await fetch('/api/books?page=1&size=10', {
  headers: authHeaders
});

// 2. 搜索书籍
const searchResponse = await fetch('/api/books/search?keyword=小说&page=1&size=10', {
  headers: authHeaders
});

// 3. 获取书籍详情
const bookDetailResponse = await fetch('/api/books/1', {
  headers: authHeaders
});

// 4. 收藏书籍
const favoriteResponse = await fetch('/api/books/1/favorite', {
  method: 'POST',
  headers: authHeaders
});

// 5. 获取用户收藏列表
const favoritesResponse = await fetch('/api/users/favorites?page=1&size=10', {
  headers: authHeaders
});
```

#### 3. AI功能使用示例
```javascript
// AI自动纠错
const correctResponse = await fetch('/api/ai/auto-correct', {
  method: 'POST',
  headers: authHeaders,
  body: JSON.stringify({
    content: '这是一段需要纠错的文本内容。'
  })
});

// AI内容续写
const continueResponse = await fetch('/api/ai/content-continue', {
  method: 'POST',
  headers: authHeaders,
  body: JSON.stringify({
    content: '故事的开头...',
    style: 'novel',
    length: 200
  })
});
```

### 最佳实践建议

#### 1. 错误处理
```javascript
async function apiCall(url, options) {
  try {
    const response = await fetch(url, options);
    const data = await response.json();
    
    if (data.code !== 200) {
      throw new Error(data.message || '请求失败');
    }
    
    return data.data;
  } catch (error) {
    console.error('API调用失败:', error);
    throw error;
  }
}
```

#### 2. Token管理
```javascript
class TokenManager {
  static getToken() {
    return localStorage.getItem('accessToken');
  }
  
  static setToken(token) {
    localStorage.setItem('accessToken', token);
  }
  
  static removeToken() {
    localStorage.removeItem('accessToken');
  }
  
  static isTokenExpired() {
    const token = this.getToken();
    if (!token) return true;
    
    try {
      const payload = JSON.parse(atob(token.split('.')[1]));
      return Date.now() >= payload.exp * 1000;
    } catch {
      return true;
    }
  }
}
```

#### 3. 请求拦截器
```javascript
// 统一的API请求封装
const api = {
  async request(url, options = {}) {
    const token = TokenManager.getToken();
    
    const config = {
      headers: {
        'Content-Type': 'application/json',
        ...(token && { 'Authorization': `Bearer ${token}` }),
        ...options.headers
      },
      ...options
    };
    
    const response = await fetch(url, config);
    const data = await response.json();
    
    // 处理token过期
    if (data.code === 401) {
      TokenManager.removeToken();
      window.location.href = '/login';
      return;
    }
    
    return data;
  }
};
```

## 更新日志

### v2.0.0 (2025-01-20)
- **新增功能**:
  - 完整的审核管理系统
  - 通知管理功能
  - 管理员后台功能
  - AI创作辅助功能
  - 评论系统
  - 文件上传管理
- **权限系统**:
  - 基于Spring Security的RBAC权限控制
  - 细粒度的权限验证
  - 多角色支持
- **API优化**:
  - 统一的响应格式
  - 完善的错误处理
  - 详细的接口文档
- **安全增强**:
  - JWT Token认证
  - 请求频率限制
  - 输入验证和过滤

### v1.0.0 (2025-01-01)
- 初始版本发布
- 完成用户认证、书籍管理、章节管理等核心功能
- 集成DeepSeek AI功能
- 支持文件上传和Swagger文档

## 快速导航

### 常用接口快速链接

**用户相关**:
- [用户登录](#11-用户登录) | [用户注册](#12-用户注册) | [获取用户信息](#21-获取当前用户信息)
- [关注用户](#26-关注用户) | [收藏书籍](#215-获取当前用户收藏书籍列表书架)

**书籍相关**:
- [获取书籍列表](#31-获取书籍列表) | [创建书籍](#32-创建书籍) | [书籍详情](#33-获取书籍详情)
- [搜索书籍](#35-搜索书籍) | [点赞书籍](#36-点赞书籍) | [收藏书籍](#38-收藏书籍)

**章节相关**:
- [获取章节列表](#41-获取书籍章节列表) | [创建章节](#42-创建章节) | [章节详情](#43-获取章节详情)

**AI功能**:
- [自动纠错](#51-自动纠错) | [内容续写](#52-内容续写) | [情节建议](#53-情节建议)

**管理功能**:
- [审核管理](#111-获取待审核书籍列表) | [用户管理](#121-审核管理) | [内容管理](#123-内容管理)

### 接口状态说明

- ✅ **已实现**: 接口已完全实现并测试通过
- 🔄 **开发中**: 接口正在开发或优化中
- ⚠️ **待优化**: 接口功能基本可用，但需要进一步优化
- ❌ **未实现**: 接口尚未实现

## 技术支持

如有问题或建议，请联系开发团队：
- 邮箱: dev@yuechuangji.com
- 文档更新时间: 2025-01-20
- API版本: v2.0.0
- 文档版本: v2.1.0

**相关文档**:
- [API更新日志](./API-更新日志.md)
- [后端接口实施规范](./阅创集后端接口实施规范.md)
- [接口差异分析报告](./后端接口差异分析报告.md)