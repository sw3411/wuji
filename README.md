# 物迹（Wuji）— 个人物品管理与价值追踪 App

> 看见自己拥有什么，知道物品放在哪里，理解每一次消费的长期价值。

「物迹」是一款**本地优先**的个人物品管理 App：记录你买过什么、花了多少钱、放在哪里、用了多少天、每天摊多少钱、转卖后实际损耗多少。不需要注册登录，数据保存在本机，随时可备份迁移。

支持 Android / iOS，手机竖屏优先，兼容深色模式，界面为简体中文（架构已为国际化预留扩展点）。

## 功能列表

### 核心闭环（MVP 已实现）
- **物品管理**：添加 / 编辑 / 删除（软删除进回收站，默认保留 30 天，可恢复 / 永久删除）
- **物品信息**：封面图 + 多图 + 票据图、品牌、型号、数量、渠道、商家、订单号、标签、备注、保修（月数或截止日）
- **分类**：22 个内置分类（手机数码、家用电器、家具家装、服装……），支持自定义分类（图标 / 颜色 / 排序），系统分类只能隐藏不能删除
- **存放位置**：树状层级（家 → 卧室 → 衣柜 → 第二层），位置照片与说明，位置下物品统计，物品移动
- **状态管理**：使用中 / 闲置 / 收纳中 / 已借出 / 维修中 / 已消耗 / 已丢失 / 已丢弃 / 已转卖 / 已赠送（受控枚举）
- **价值计算**：使用天数、当前日均成本、转卖净收入、实际损耗、保值率（集中在 Calculator 服务，全部有单元测试）
- **转卖记录**：价格、日期、平台、运费、手续费、其他成本、买家备注；状态联动与事件自动记录
- **生命周期事件**：购买 / 移动 / 维修 / 保养 / 借出 / 归还 / 转卖 / 赠送 / 丢弃 / 丢失 / 自定义，详情页时间线展示
- **列表能力**：卡片 / 紧凑视图、搜索（名称 / 品牌 / 型号 / 备注 / 标签 / 位置）、分类 / 状态 / 位置 / 时间 / 价格区间筛选、收藏 / 已转卖 / 即将过保快速筛选、9 种排序、多选批量移动 / 改分类 / 删除；筛选条件持久保留
- **统计**：总览（历史 / 当前持有 / 回收 / 损耗）、分类占比饼图、月度趋势柱状图、日均成本 / 使用时长 / 保值率榜单、闲置统计；空数据不显示无意义图表
- **AI 能力**（预留 API，自行配置）：
  - 一句话添加物品（自然语言 → 结构化表单，确认后保存）
  - 一键总结当前物品与开支
  - 自然语言问答（“我最贵的东西是什么”）
- **备份恢复**：单文件 JSON 备份（含图片 base64）、版本与完整性校验、覆盖 / 合并两种恢复方式、恢复前自动临时备份
- **导出**：CSV 物品清单、JSON 完整备份（系统分享）
- **其他**：首次启动引导、表单草稿自动保存（App 被杀后可恢复）、深色模式、图片清理（只清理无引用图片）
- **数据安全**：AI API Key 存入系统钥匙串/Keystore（flutter_secure_storage，旧明文自动迁移）；回收站超期物品启动时自动清理；删除物品 5 秒内可撤销；超过 14 天未备份时首页提醒

### 第一版明确不做（架构已预留）
强制登录、云端账户、多人共享家庭、OCR 识别订单、电商订单自动导入、AI 自动识别物品图片、实时二手估值、社区、订阅付费。

## 设计说明

视觉方向：Claude 式暖色气质（米白 `#FAF6F0` / 暖黑背景、墨绿 `#2E6E5C` 主色、赤陶 `#B85C43` 点缀、低饱和状态色、16px 圆角轻描边卡片），核心数字使用等宽大数字排版（`AppTheme.bigNumber`）。

- **物品列表三种视图**：卡片（默认，信息全）/ 紧凑（WhatsApp 式高密度行）/ 橱窗（小红书式双列大图，适合收藏陈列），列表页右上角切换，默认视图可在设置中配置
- **详情页数据卡**：购买价格为主视觉（28px 大数字），持有天数/日均/保值率为次级指标分层展示
- **添加表单**：基础信息一屏完成，"更多信息"收进底部面板，按需展开，降低表单压迫感
- **AI 对话**：暖色气泡 + 生成中三点跳动动效

## 页面地图

| 页面 | 路由 | 说明 |
|---|---|---|
| 引导页 | `/onboarding` | 首次启动，4 页介绍 + 立即开始 / 导入备份 |
| 首页 | `/home` | 总览卡片、即将过保、长期闲置、常用位置、最近添加 |
| 物品列表 | `/items` | 搜索 / 筛选 / 排序 / 批量操作 |
| 添加 / 编辑物品 | `/item/new`、`/item/:id/edit` | 基础信息 + 更多信息（可展开），草稿自动保存 |
| 物品详情 | `/item/:id` | 核心数据卡、位置模块、时间线、底部快捷操作 |
| 位置管理 | `/locations` | 树状位置、搜索、新增 / 编辑 / 删除（含迁移确认） |
| 位置详情 | `/locations/:id` | 路径、照片、子位置、物品列表 |
| 统计 | `/stats` | 总览 / 分类 / 趋势 / 使用价值 |
| 我的（设置） | `/profile` | 货币、渠道、视图、闲置天数、提醒、深色、数据管理 |
| 分类管理 | `/settings/categories` | 自定义分类增删改、排序、系统分类隐藏 |
| 回收站 | `/settings/trash` | 恢复 / 永久删除 / 清空 |
| AI 设置 | `/settings/ai` | API 地址 / Key / 模型，测试连接 |
| AI 一句话添加 | `/ai/quick-add` | 一句话 → 解析 → 表单确认保存 |
| AI 助手 | `/ai/chat` | 总结 + 问答对话 |
| 关于 | `/settings/about` | 版本与隐私说明 |

底部导航：**首页 / 物品 / ＋（中央圆钮：手动添加 / AI 一句话添加）/ 统计 / 我的**。

## 技术栈

| 用途 | 选型 | 说明 |
|---|---|---|
| 框架 | Flutter 3.32+ / Dart 3.8 | |
| 状态管理 | flutter_riverpod | |
| 路由 | go_router（StatefulShellRoute） | |
| 数据库 | Drift + sqlite3_flutter_libs | 类型安全 SQL ORM，schema 版本迁移 |
| 图片 | image_picker（拍照 / 相册，内置压缩参数） | 保存到 App 私有目录 |
| 格式化 | intl | 日期 / 货币 / 本地化 |
| 图表 | fl_chart | 饼图 / 柱状图 |
| 分享导出 | share_plus、file_picker | 备份导出 / 导入 |
| 通知 | flutter_local_notifications + timezone | 保修到期提醒（保存物品自动调度，恢复备份后重排） |
| 密钥存储 | flutter_secure_storage | AI API Key 存入钥匙串/Keystore（minSdk 23+） |
| AI | http（OpenAI 兼容 `/chat/completions`） | OpenAI / DeepSeek / GLM / Ollama 通用 |

与原始建议的差异：未使用 freezed / json_serializable（领域模型采用手写 `copyWith` + `toJson/fromJson`，减少代码生成复杂度，Drift 仍使用 build_runner）。金额全部使用**最小货币单位（分）整数**存储，杜绝浮点精度问题。

## 项目架构

```
lib/
  app/                  应用层：主题、路由、Provider 装配、底部导航、全局设置
  core/
    ai/                 AI：配置、OpenAI 兼容客户端、Prompt 模板、解析服务
    constants/          产品名、内置分类等常量（集中配置）
    notifications/      本地通知服务
    utils/              金额、日期格式化
  data/
    db/                 Drift 表定义与数据库（行 ↔ 领域对象映射）
    repositories/       Item/Location/Category/Sale/Settings 仓库 + 备份服务
  domain/
    models/             纯数据模型（Item、Location、Category、SaleRecord、ItemEvent、枚举）
    services/           业务计算：ItemCalculator、StatisticsService、ItemFilter
  features/
    onboarding/ home/ items/ locations/ statistics/ settings/ ai/
  shared/widgets/       通用组件（空状态、状态徽标、指标卡等）
```

分层原则：**页面不写业务计算**——天数 / 日均成本 / 保值率全部走 `ItemCalculator`，统计口径全部走 `StatisticsService`，筛选排序走 `applyItemFilter`；仓库负责持久化，Provider 负责状态装配。

## 数据库结构（ER）

```
items ─┬─> categories.id        （冗余 categoryName 快照，分类改各不影响历史记录）
       ├─> locations.id         （冗余 locationName / locationImagePath）
       └─< sale_records.item_id （一件物品最多一条转卖记录）
       └─< item_events.item_id  （一件物品多条生命周期事件）
locations.parent_id ─> locations.id   （树状自关联）
settings(key, value)                  （键值设置：偏好、AI 配置、筛选器、草稿）
```

字段与软删除（`deletedAt`）细节见 `lib/data/db/tables.dart`。金额字段（`purchasePrice`、`salePrice`、运费、手续费等）均为 int 分。

## 环境要求

- Flutter 3.32 及以上稳定版（`flutter --version` 确认）
- Android：Android Studio + Android SDK（minSdk 21+）
- iOS：macOS + Xcode 15+（CocoaPods）

> 本机已安装 Flutter SDK 于 `/Users/luckincoffee/Documents/flutter`，使用前 `export PATH="/Users/luckincoffee/Documents/flutter/bin:$PATH"`。
> 本机未安装 Android SDK / 完整 Xcode / CocoaPods，原生 APK/IPA 打包需装齐上述工具后在真机环境执行；Dart 层已通过 analyze 与全部测试验证。

## 安装与运行

```bash
cd wuji
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # 生成 Drift 代码（仅开发时）
```

### Android

```bash
flutter run                    # 连接设备 / 模拟器
flutter build apk --release
flutter build appbundle --release
```

### iOS

```bash
cd ios && pod install && cd ..
flutter run
flutter build ipa --release    # 需要 Xcode 签名配置
```

> 首次打开 iOS 工程请在 Xcode 中设置 Bundle ID 与签名团队。

## 测试

```bash
flutter test                            # 全部测试
flutter test test/item_calculator_test.dart   # 核心计算
flutter analyze                         # 静态检查
```

测试覆盖：使用天数（未转卖 / 已转卖 / 当天）、日均成本、转卖盈利与亏损、保值率、保修状态、资产统计口径（各状态是否计入）、月度趋势、榜单、金额精度（0.1+0.2）、筛选与排序、序列化往返、深色模式组件渲染、日均收益文案等。

## AI 功能配置

1. 进入「我的 → AI 助手设置」
2. 填写：
   - **API 地址**：如 `https://api.openai.com/v1`、`https://api.deepseek.com/v1`、`https://open.bigmodel.cn/api/paas/v4`，本地 Ollama 填 `http://localhost:11434/v1`
   - **API Key**：你的密钥（仅保存在本机数据库）
   - **模型名称**：如 `gpt-4o-mini` / `deepseek-chat` / `glm-4-flash`
3. 点击「测试连接」验证，保存即可使用

隐私：AI 功能会把相关物品数据发送到**你配置的** API 服务商；不配置则完全不发送任何数据。

## 权限说明

| 权限 | 时机 |
|---|---|
| 相机 | 仅在添加物品选择“拍照”时 |
| 相册 | 仅在添加物品 / 票据 / 位置照片时 |
| 通知 | 仅在设置中开启保修 / 闲置提醒时 |

首次启动不会请求任何权限。

## 数据备份格式

备份为单个 JSON 文件（扩展名 `.wuji.json`）：

```json
{
  "app": "物迹",
  "format": "wuji-backup",
  "version": 1,
  "exportedAt": "…",
  "items": [...], "locations": [...], "categories": [...],
  "saleRecords": [...], "itemEvents": [...],
  "settings": {...},
  "images": { "文件名": "base64…" }
}
```

恢复时校验 `format` 与 `version`（高版本备份拒绝恢复），支持覆盖 / 合并；恢复前自动把当前数据写入临时备份，失败可回滚。

## 已知限制

- 备份文件包含图片 base64，物品很多时文件较大（几百 MB 级别导出较慢）
- AI 一句话添加依赖模型的 JSON 输出能力，弱模型可能解析失败（已做容错提取）
- 多币种支持按记录维度存储，统计页汇总仍按单一货币展示，不做汇率换算
- 通知提醒在 App 被强制结束后由系统调度，Android 部分厂商需允许自启动
- 平板为基础适配（布局可用，未做双栏优化）

## 后续路线图（不阻塞 MVP）

- 用户账号与云同步（端到端加密备份）
- 家庭空间与成员共享、多设备同步
- OCR 识别发票 / 订单截图、扫描条形码
- AI 识别照片自动填充分类 / 品牌
- 淘宝、京东等电商订单导入
- 二手平台估值与物品折旧模型
- 房间平面图位置可视化、搬家打包管理
- 收藏品价值变化曲线、家庭保险资产清单、灾害 / 失窃物品证明导出
- Web / 桌面端、多语言、多货币汇率换算

---

产品名称集中在 `lib/core/constants/app_info.dart`（`AppInfo.appName`），改一处即可全局生效。
