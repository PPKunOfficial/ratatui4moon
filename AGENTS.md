# Repository Guidelines

> 本文件是 ratatui4moon 仓库的**条约**：只陈述"应当怎么做"的规则与约定。
> 仓库现状以 `docs/design.md` 与代码为准。编码品味与 Nonoka 家族一致
> （块式 `///|`、显式构造、`inspect!` 快照、中文塔菲注释），不再重复全文喵。

## 项目方针 (Project Focus)

- 目标：为 MoonBit 生态填补 **immediate-mode TUI 框架层**——ratatui 式
  cell 网格双缓冲 + 无状态 widget + 黄金 ANSI 快照测试。纯 MoonBit，
  **零 FFI、零 Bun**，native 后端静态编译单二进制喵。
- 第一消费方是 Nonoka（终端 coding agent），dogfooding 优先于大而全喵。

## 目录与放置约定 (Directory Contract)

- `core/`：依赖树叶子。Rect/Style/Cell/Buffer/差分，纯数据结构 + 纯函数，
  **零依赖、零 I/O**，禁止 import 本 module 其他包喵。
- `backend/`：`Backend` trait、`TestBackend`、ANSI 发射引擎。只依赖 `core`。
  未来一切平台接触（tty/终端原语）收敛于此喵。
- `widgets/`：无状态 widget。只依赖 `core`（**不得依赖 backend**，渲染输出
  是 Buffer 不是 ANSI 喵）。
- `widgets/test/` 等黑盒测试包：只依赖被测包与 `backend` 的公开 API，
  用 `for "test"` 导入喵。
- 规划中：`unicode/`（宽度表与折行）、`layout/`（线性布局 → 弹性分配器）。
  新职责新开 `<职责>/` 目录配 `moon.pkg`，禁止堆进既有包喵。

## 构建与测试契约 (Build & Test Contract)

- 提交前必须全绿：`moon fmt && moon info && moon check && moon test`，
  `.mbti` 接口摘要入库，diff 可见公开 API 变化喵。
- **黄金快照铁律**：一切渲染行为以 `inspect!` 快照佐证；快照更新只走
  `moon test --update`，禁止手改 content 字符串；禁止静默改断言掩盖回归喵。
- 测试零真实终端、零网络、零 I/O：渲染链路 `widget → Buffer::diff →
  TestBackend → last_ansi` 全程确定性离线可跑喵。
- 平台库需要双平台 CI（Linux + Windows）后方称 v0.2 喵。

## 代码规范 (Code Conventions)

- 无 panic 原则：渲染路径禁止 `abort`/`panic`，越界一律优雅裁剪；
  仅"调用方破坏内部不变量"（如 `diff` 尺寸不一致）允许 `guard!` 断言喵。
- widget 无状态：`render(area, buf)` 即画即走，禁止 retained 树与
  响应式订阅（那是 vDOM 路线的领域喵）。
- ANSI 转义只能出自 `backend/ansi.mbt`，上层禁止手拼转义字串喵。
- 可后加字段一律 `T?` / 带默认值；对外枚举一律 `pub(all)`，消费者
  `match` 必带通配分支喵。

## Git 提交规范 (Git Convention)

- 每完成一个独立模块或修复点即提交一次。
- 格式：`<emoji> <type>(<scope>): <技术性中文描述>`，句尾可带"喵"。
- 映射：✨ feat / 🐛 fix / ⚡️ perf / 📝 docs / 🎨 style / 🔨 refactor / 🧪 test。
- 提交前必更 `docs/design.md` 与 README，文档未同步视为未达提交条件喵。
