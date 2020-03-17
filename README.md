# English Buoy

Learn English by reading YouTube subtitle article.

## Version

v1.4.11+1.4.11

- Fix save local cache error
- Fix some word failure get word wise data
- Always dim when YouTube player pause make sure play/loading button see clearly

v1.4.10+1.4.10

- Word wise
- Show loading animation when login
- Show server sad error

v1.4.09+1.4.09

- Fix check login bug
- Adjust explorer page

v1.4.08+1.4.08

- Add explorer

v1.4.07+1.4.07

- Make sure the same word in the different article show the same status
- Speedup filter by percent slider
- Add auto-scroll with playing config

v1.4.02+1.4.02

- Highlight current playing sentence

v1.4.01+1.4.01

- lots of bugs fixed
- Avoid cached video rebuild when adding a new article

v1.4.0+1.4.0

- Speed up almost everything
- Modify Theme
- Make filter percent work great

v1.3.18+v1.3.18

- Totally refactor
- Change logo

v1.2.17+v1.2.17

- Quick back not mastered words table
- Highlight word when finds in article
- Filter by percent(not done)
- Modify slider parameter
- Adjust table width

v1.2.16+v1.2.16

- Move settings and profile to the drawer
- When Youtube doesn't have en subtitle still need to remove loading item
- Even when loading new youtube video make sort works fine

v1.2.15+v1.2.15

- fix save local cache error

v1.2.14+v1.2.14

- fix dark mode malfunction

v1.2.13+v1.2.13

- fix bug: always autoplay while sliding to last/next whatever autoplay config is on or off
- remove memory cache
- make sure move to top when sliding to last/next
- make share Youtube video to Ebuoy is work fine while the app is closed

v1.2.12+v1.2.12
-In article detail, slider right / left will open last / next article
-no blank word filter need ignore-case
-pull down scroll refresh current article
-set refresh color
-Fix some google sign in bug

v1.2.11+v1.2.11

- Show loading item when adding new youtube
- Cache article and article list
- Make sharing is work while the app is closed
- Add not mastered words table at the begin and the end of the article
- Show progress animation when the tap login button
- Remove no need code

v1.2.10+v1.2.10

- If word length is 1, no need to learn
- Always get article details from the server for updates even if it is already cached
- Adjust top blank

v1.2.9+v1.2.9

- Successfully avoid Flutter bug make the app crash
- Make sure autoplay

v1.2.8+v1.2.8

- Default autoplay
- Avoid the flutter pit and reduce the number of crashes
- Don't sync the last article when restarting the app
- Remove jump to word config

v1.2.7+2

- Fix bug: sometimes google user doesn't have an avatar, avoid app throw error
- Fix bug: all words tag to learned but learned percent still not 100%
- Auto-add some example video to a new user
- Add how-to add YouTube to Ebuoy image tutorial

v1.2.7+1

- autoplay video and add autoplay config
- show spin when deleting the article

### v1.2.6+26

- 标记单词后，重新计算百分比
- 调整播放图标样式
- 修复关闭 search 按钮无法触发清空搜索内容的 bug
- 修复多个 0 大额数字无法显示的问题

### v1.2.5+25

- 删除列表条目时无需显示 loading
- 可以选择排序方式, 最新加入和接近掌握
- 百分比的方式显示掌握进度

### v1.2.4+24

- 修复滚动定位不准问题
- 添加删除文章功能
- 下拉刷新不再显示多余的 loading
- 扩大时间定位按钮可点击范围
- 修改后台数据结构, 按句子包裹传递数据. 修复一系列 bug

### v1.2.3+23

- 优化文章页标题, 保证对齐
- 播放定位点击响应:▶
- 通过分享唤醒 app 也能正确同步视频
- 调整滚动间距, 尽量命中

### v1.2.1+21

- fix can't auto scroll to shared youtube item

### 1.2.0+20

- 默认开启视频字幕
- 解决 Provider 带来的循环 build 问题
- 自动滚动到分享的条目
- 拆分 RichText 优化性能
- 取消文章内容页的浮动按钮, 通过标题在 youtube 打开
- 修复因为自动滚动影响到的下拉刷新

### 1.1.9+19

- 优化 YouTube 播放器暂停及播放特性
- bugifx: 实时未掌握单词数计算错误
- 点击句子前 ▷ 来视频跳转

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

## How to use

1. Open YouTube App find favorite video share to Ebuoy.
2. Watching video meanwhile reading subtitle article tag word to known/unknown.
