---
name: xiaohongshu-post
description: 在小红书创作服务平台发布笔记（长文/图文）。当用户提到小红书、发帖、发笔记、小红书草稿时触发。需要 Mac mini 节点的浏览器控制。
---

# 小红书发帖

通过 Mac mini 节点的 Chrome 浏览器操作小红书创作服务平台。

## 前置条件

- Mac mini 节点在线且浏览器代理已启动
- Chrome 已登录小红书创作服务平台（手动登录一次即可）
- OpenClaw Chrome 扩展已 attach 到目标 tab

## 发帖流程

### 1. 打开创作页面

```
browser open → https://creator.xiaohongshu.com/publish/publish
target=node, node=Ming 的Mac mini
```

记录返回的 `targetId`，后续所有操作都用这个 id。

### 2. 检查登录状态

snapshot 页面，确认能看到用户名（如"小红薯65D33122"）。若未登录，提示用户手动登录。

### 3. 选择笔记类型

页面顶部有 tab 切换：
- **上传视频** — 视频笔记
- **上传图文** — 图文笔记（需要图片）
- **写长文** — 纯文字长文（无需图片，适合测试）

点击对应 tab。注意：这些 generic 元素可能无法直接 click ref，用 evaluate 兜底：

```javascript
Array.from(document.querySelectorAll('div,span,a,p')).filter(e => e.textContent.trim() === '写长文' && e.children.length === 0)[0].click()
```

### 4. 创建新内容

- 长文模式：点击"新的创作"按钮
- 图文模式：需要先上传图片

### 5. 编辑内容

长文编辑器元素：
- **标题**: `textbox "输入标题"` — 限64字
- **正文**: 标题下方的 paragraph 区域（placeholder "粘贴到这里或输入文字"）
- **字数统计**: 底部显示

操作顺序：
1. click 标题输入框 → type 标题
2. click 正文区域 → type 正文内容（支持 `\n` 换行）

### 6. 保存或发布

- **暂存离开** — 保存到草稿箱（浏览器本地存储）
- 页面也会自动保存（底部显示"自动保存于 HH:MM"）
- 发布功能需要进一步确认（通常有"发布"按钮）

保存后页面会显示"保存成功"提示，草稿箱计数 +1。

## 注意事项

- **图片禁令**: 不要 screenshot，用 snapshot 获取页面结构
- **tab 连接不稳定**: 小红书页面可能导致 CDP 连接丢失（"tab not found"），解决方法：
  1. 重新 `browser stop` → `browser start`
  2. 请用户重新点击 Chrome 扩展 attach tab
  3. 用 `browser open` 打开新 tab
- **evaluate 语法**: 不支持 `const`/`let`/`var` 声明开头，用表达式或 `Array.from()` 等包裹
- **草稿存储**: 保存在浏览器本地，清除浏览器数据会丢失
