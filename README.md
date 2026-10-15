# EAX管理器 电脑版

一个 Windows 桌面漫画客户端：**搜索、看详情、下载到电脑、本地书架、内置阅读器**。
支持四个来源 —— **JM（禁漫）/ 哔咔 / EH / Pixiv**，结果汇总在同一个列表里，
下载下来的东西统一进本地书架，不区分来源。

> 本项目是纯客户端，不提供任何内容，也不托管任何图片。
>
> 这是**电脑版**的独立项目，版本号自己走（从 v1.0.0 起）。
> 手机版（Android）在另一个仓库，两边互不相干：[EAXMAX123/EAXManager](https://github.com/EAXMAX123/EAXManager)

## 下载

最新压缩包在 Releases：[EAXMAX123/EAXManager-PC/releases/latest](https://github.com/EAXMAX123/EAXManager-PC/releases/latest)

解压到任意文件夹，双击 `EAXManager.exe` 就能用，不用安装、不写注册表。
软件自己会检查新版本，联网时会提示，不用每次回来手动找。
仓库里保留每一个历史版本，出问题可以回滚。

## 版本

当前版本：**v1.0.0**（`buildNumber` = 1）。

电脑版是新开的项目，版本从 1.0.0 重新算起，跟手机版的 1.x 各走各的，
更新也是分开的：软件只检查电脑版的更新，不会把人指去下安卓包。

改版本号要动两处，保持一致：

1. `pubspec.yaml` → `version: <版本>+N`（N 每次 +1）
2. `lib/app_info.dart` → `version` / `buildNumber`

出包产物按 `EAXManager-PC-v<版本>.zip` 命名，旧版本保留不删，出问题可以回滚。

## 功能

### 搜索
- 一个搜索框搜全部：勾选要用的源（JM / 哔咔 / EH / Pixiv），一次拿到多家的结果
- JM 支持按 综合 / 作品 / 作者 / 标签 / 登场角色 检索
- 结果列表显示来源角标，能一眼看出哪条来自哪家
- 列表按窗口宽度自动换列数，拉伸窗口不会把封面拉变形

### 排行
- 一个页面看四家的榜单，第一行选源，下面两行跟着源变
- 时间档按源给：
  - JM：今日 / 本周 / 本月 / 全部时间
  - 哔咔：24小时 / 7天 / 30天
  - EH：昨日 / 本月 / 今年 / 全部时间
  - Pixiv：日榜 / 周榜 / 月榜
- 分类档也按源给（JM 有同人/单本/短篇/韩漫/美漫/3D/Cosplay/其他，Pixiv 有男性向/女性向/原创/新人/R18/AI）；
  哔咔和 EH 官方没有分类，这一行不显示
- 榜单里的作品和搜索出来的用法完全一样，能下载、能进书架、能加分类

### 收藏
- 顶部可切 JM / 哔咔，两边能同时登录，不用来回换账号
- 登录过一次之后会记住账号密码，会话掉了自动重登

### 识图
- 从电脑里选一张图，反查它出自哪一本：上传到 **SauceNAO** 和 **IQDB** 两个识图站，
  认出作品名、作者、出处后，点一下就能丢进四个源里搜
- 识图前自动裁掉四周的黑边 / 白边，再等比缩放
- 整图认不出来时，自动切上中下三段再各搜一遍（可关）
- 识图设置就在识图页里：API key、相似度门槛、分段重搜、是否查 IQDB
- 另有「用 Google Lens 搜」：软件只负责把图片传上去，结果页交给浏览器打开
  （Lens 的结果页是纯 JS 渲染的，Dart 解析不出来；这一步需要梯子）
- 识图时图片会上传给上述第三方服务，页面上写明了这一点

> 试过但接不进来的：TinEye（国内直连不通）、Yandex（对国内 IP 返回「服务建设中」）、
> ascii2d（Cloudflare 验证挡在外面）、百度识图与 Bing 视觉搜索（都要网页里算出来的令牌）。

### 下载
- 整本下载 / 单章下载
- 下载管理页：暂停、继续、重试、删除，可看进度和速度
- 下载完成弹系统通知（Windows 通知中心），点通知能直接跳到对应的书
- 每一本的下载目录可以单独配（见下）

### 书架
- 本地书架，显示每本下载进度，可按 创建顺序 / 文件大小 / 名称 排序
- 自定义分类：自己起名字，把下载好的书拖进分类里
- 「重新扫描本地文件」：认一遍磁盘上真实存在的文件夹，
  记录丢了的自动清掉、扫描到有图的自动挂回来

### 阅读
- 点开就能看：纵向滚动、双指/滚轮缩放、进度记忆、上一话 / 下一话
- 键盘：上下键、翻页键、空格翻页，Home / End 跳首尾，F11 全屏，Esc 退出
- 鼠标点到屏幕两侧也能翻页
- **单独开一个「阅读」窗口**：看本子不占主界面，标题栏的图钉能把它钉在最上层，
  窗口大小和位置会记住，下次打开还是那样

### 追更
- 订阅作品，后台定时检查新章节并推送通知
- 书架页「追更」标签可手动检查、取消订阅

### 设置
- 下载目录（**每个源可单独配**）、并发章节数、并发图片数、图片质量
- 代理地址（`http://` 与 `socks5://`）、自定义解析与自定义域名
- Pixiv 的数据镜像地址、图片反代域名、下载画质
- 账号：JM / 哔咔 / EH 各自登录；EH 用粘贴 Cookie 的方式，表站里站自己选
- 主题模式、主题色、背景图（内置文件浏览器选择）
- 追更开关与检查间隔
- 更新检查地址（默认就是本仓库的 `update.json`）

### 关于
- 分三块：**公告**（这个软件能做什么、每次更新改了什么）、**说明**（使用上的常见问题）、
  **关于**（交流群、赞助码）
- 右上角那颗胶囊点一下会换一种神态，右边的文字跟着一起换

## 下载目录

电脑上没有手机那种「公共目录」，默认落在**第一个存在的盘**下的 `EAX管理器` 里
（从 D: 开始找，D/E/F/G 都没有才退回用户目录），按源分开：

```
D:\EAX管理器\JM\<本子ID>\<章节号>\00001.jpg
D:\EAX管理器\Pica\...
D:\EAX管理器\EH\...
D:\EAX管理器\Pixiv\...
```

每个源在「设置 → 下载」里都能单独改目录，改完重启也不用重下，
书架和下载记录都跟着新目录走。

## 网络说明

四个源在国内的可达性差别很大，软件按下面策略处理：

| 源 | 是否需要梯子 | 是否需要登录 | 说明 |
| --- | --- | --- | --- |
| JM | 一般不需要 | 收藏夹需要 | 内置多条 API 线路，连不上会自动换 |
| 哔咔 | 需要（或加速器） | **搜索/榜单/收藏都需要登录** | 用**邮箱 + 密码**登录 |
| EH | **需要** | 不用登录就能搜能下 | 站点是 SNI 阻断，不挂梯子连不通 |
| Pixiv | 不需要 | 不需要 | 数据与图片走公共镜像，内置多个备用地址 |

- JM / 哔咔 / EH 的域名在国内存在 DNS 污染，工程内置了 DoH 解析与 IP 直连兜底
  （`lib/net/`），但**代理开关是用户自己的事**，软件不会替你翻墙。
- 反过来也要注意：挂着全局代理时，JM 和哔咔可能反而连不上，遇到就先关掉代理试试。
- 代理在「设置 → 代理地址」里填。

## 更新机制

- 软件联网后会去读本仓库的 `update.json`（`main` 分支根目录），比对版本号
- 国内直连 raw.githubusercontent 常常不通，所以会依次试 jsDelivr 镜像等几个入口，
  能拿到更新信息就算成功
- 发现新版本会提示，点「前往下载」时会先探一圈哪条线路能下
  （GitHub 的下载地址在国内常常直连不通，会自动挑一个能用的加速站再交给浏览器）
- 更新包**不会覆盖安装**，是让你手动解压新包，旧版本一直留着
- 只检查电脑版。手机版的更新挂在 `EAXMAX123/EAXManager`，两边互不影响

## 构建

需要 **Flutter**（本工程在 Flutter 3.47 / Dart 3.13 上开发）和
**Visual Studio 2022**（装「使用 C++ 的桌面开发」工作负载，Windows 桌面构建要用）。

```bash
flutter config --enable-windows-desktop
flutter pub get
flutter analyze
flutter test
flutter build windows --release
```

产物：`build\windows\x64\runner\Release\` 整个文件夹（里面有 `EAXManager.exe`、
`flutter_windows.dll`、`data\` 等，缺一个都跑不起来，**打包要整个文件夹一起压**）。

## 代码结构

```
lib/
  main.dart                入口（含主窗口的位置 / 大小记忆）
  app_info.dart            版本号、更新检查地址

  jm/                      纯 Dart 层，不依赖 Flutter，可单独跑测试
    jm_constants.dart        域名、密钥、分类/排序/时间映射、请求头
    jm_crypto.dart           token 签名、AES-256-ECB 响应解密
    jm_models.dart           数据模型（搜索项、本子、章节、收藏夹…）
    jm_exception.dart        异常分类与中文提示
    jm_client.dart           JM API 客户端：域名探测、搜索、详情、登录、收藏
    jm_scramble.dart         图片乱序还原算法
    jm_storage.dart          目录规划、图片列举、自然排序

  net/                     网络底层：DoH 解析、IP 直连、代理、错误归类
    doh_resolver.dart        DNS over HTTPS，绕开污染
    net_transport.dart       连接工厂（TLS / IP 直连 / 代理）
    net_ip_table.dart        IP 结果缓存
    net_error.dart           把底层异常翻译成人话

  source/                  四个来源的统一抽象
    image_search/            识图：SauceNAO / IQDB / Google Lens 客户端 + 图片预处理 + 编排
    comic_source.dart        统一接口：搜索 / 详情 / 章节 / 排行 / 收藏
    source_registry.dart     源注册表
    jm_source.dart           JM 适配
    chapter_downloader.dart  章节内并发下载 + 还原
    image_worker_pool.dart   图片处理线程池
    pica/                    哔咔适配（pica_client.dart / pica_source.dart）
    eh/                      EH 适配（eh_account / eh_client / eh_source）
    pixiv/                   Pixiv 适配（pixiv_client / pixiv_source）

  data/
    app_database.dart        sqflite：书架 / 下载任务 / 追更订阅 / 分类
    settings_store.dart      设置与账号的持久化
    app_docs.dart            公告与使用说明的文案

  services/
    local_library.dart       本地书架扫描与管理
    shelf_filter.dart        书架筛选与排序
    shelf_sizes.dart         书架体积统计
    reader_window.dart       阅读器独立窗口
    desktop_window.dart      主窗口的置顶 / 尺寸 / 位置
    reading_progress_writer.dart 阅读进度落盘
    notification_service.dart 系统通知（下载进度、完成、追更）
    platform_service.dart    平台差异（代理、用系统打开链接、播放视频）
    subscription_service.dart 追更检查
    update_service.dart      版本检查与下载地址选路

  state/
    app_services.dart        全局服务容器（单例 AppServices.I）
    download_manager.dart    下载队列调度
    result_feed.dart         搜索结果流

  ui/
    app.dart                 MaterialApp + 底部导航
    theme.dart               主题与背景（**想改外观改这里**）
    reader_launcher.dart     打开阅读窗口
    reader_window_app.dart   阅读窗口里的应用壳
    pages/                   搜索 / 排行 / 收藏 / 识图 / 详情 / 阅读器 / 书架 / 下载 / 设置 / 关于
    widgets/                 封面组件、列表行、分类选择器、来源角标、文件浏览器、
                             拟人化导航栏、看板娘、赞助胶囊

assets/
  app_icon.png             应用图标
  navigation/              底部导航 / 看板娘素材
  sponsor/                 赞助胶囊素材
  reward_code.png          赞助码
  qq_group_1077681089.jpg  交流群二维码
  easter_egg/              彩蛋视频的位置（视频几十兆，不进仓库，见目录里的 README）

test/                        单元测试（纯 Dart 部分）
tool/                        开发期用的探针脚本（抓接口、验证线路），不参与打包
```

## 免责声明

- 本工程仅供**个人学习与技术交流**使用，不提供、不存储、不传播任何内容。
- 所有内容均来自第三方站点，版权归各自作者所有。请勿用于商业用途。
- 使用本软件产生的任何后果由使用者自行承担。
- 如果你是权利人且认为本项目不妥，请提 Issue，会及时处理。

## 许可证

[AGPL-3.0](LICENSE)

选择 AGPL-3.0 的原因：本工程的图片还原与加解密算法移植自 **jmcomic**（MIT），
产品形态参考了 **JM-Cosmos II**（AGPL-3.0），采用同一族许可证最省事，
也和手机版保持一致。

如果你希望换成更宽松的 MIT，欢迎提 Issue 讨论。

## 致谢

见 [THANKS.md](THANKS.md)。
