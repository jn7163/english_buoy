# learnNGSL

利用 NGSL 来学习的 APP

## Change Log
### 1.1.9+19
- 优化 YouTube 播放器暂停及播放特性
- bugifx: 实时未掌握单词数计算错误
- 点击句子前▷来视频跳转

### 1.1.8+18
- bugfix: 修复单词点击错位问题
- bugfix: 播放器启用非 live 模式, 修正速度弹出框样式匹配问题
### 1.1.7+17
- youtube 视屏嵌入播放
- 优化弹出提示
### 1.1.6+16
- remove bus toast
- 状态管理升级为 Provider
- loading 计数器

### 1.1.5+15
- 缓存头像图片, 避免每次打开都去获取
- 同步完成分享的 youtube 后不再跳入详情, 只是高亮标题

### 1.1.4+14
- 解决第一次进入配置页面会自动跳回的问题
- 拆分标题栏目登录信息和设置按钮
- 添加夜间模式
- 统一 loading
- 拆分组件
### 1.1.3+13

- 拆分 loading
- 不要每次进入 article list 都后台取数, 0 时候才取
- 修复失效的接收分享插件

### 1.1.2+12

- 修改详情页的 top bar, 取消使用 app bar; 取消跳转按钮, 取消 oauth 按钮; 只显示 avatar 和 title
- 收到分享时, 一律先跳转到列表页, 再进入详情页, 保证返回按钮总是返回列表页

## 颜色的种类和定义

### 无需学习

`Colors.grey[600]`

![灰色](https://flutter.github.io/assets-for-api-docs/assets/material/Colors.grey.png)

### 等待学习
