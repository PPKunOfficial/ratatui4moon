# Repository Guidelines

> 本文件是 ratatui4moon 仓库协作的**条约**：只陈述"应当怎么做"的规则与约定，不记录"当前怎么样"的现状。
> 仓库现状一律以 `docs/design.md` 设计文档与代码为准。
> **禁止条款**：不得写入任何实时性信息——测试/用例数量、用例清单、实测数据与结论、
> 探针/工程路径、修复记录等；此类内容一律放 `docs/` 对应文档或测试文件头注释。
> 发现本文件出现与规则无关的现状描述时，应将其改写为规则形态（或删除），并保证条款自身严谨准确。

@.agents/taste.md

@.agents/iron.md

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
- `_build/`：构建产物，禁止入库（已在 .gitignore 忽略）。

## 构建与测试契约 (Build & Test Contract)

- 提交前必须全绿：`moon fmt && moon info && moon check && moon test`，
  `.mbti` 接口摘要入库，diff 可见公开 API 变化喵。
- **黄金快照铁律**：一切渲染行为以 `inspect` 快照佐证；快照更新只走
  `moon test --update`，禁止手改 content 字符串；禁止静默改断言掩盖回归喵。
- 测试零真实终端、零网络、零 I/O：渲染链路 `widget → Buffer::diff →
  TestBackend → last_ansi` 全程确定性离线可跑喵。
- 平台库需要双平台 CI（Linux + Windows）后方称 v0.2 喵。

## 代码规范 (Code Conventions)

- 编码品味以 `@.agents/taste.md` 为准（源自 `mooncakes.io/docs/moonbitlang/core`
  与 `github.com/moonbitlang/core` 实地扒取的块式/显式/快照测试品味，
  并叠加本仓库七铁律加严），日常工作速查见
  `.agents/skills/moonbit-style/SKILL.md` 喵。
- 注释与文档（.md）统一使用中文，塔菲风格（活泼、直率、俏皮，句尾可带"喵"），
  同时必须保证技术表述准确严谨（不装傻、不模糊概念）。
- 最高优先级契约见 `@.agents/iron.md`（依赖方向、core 零 I/O、无 panic、
  黄金快照、即时模式、ANSI 出口唯一、扩展性纪律），任何改动不得破坏喵。
- 错误处理：渲染路径禁止 `abort`/`panic`，越界与退化输入优雅裁剪；
  `guard!` 仅限内部不变量断言喵。

## Git 提交规范 (Git Convention)

- 每完成一个独立的小模块或修复点即提交一次。
- 提交格式：`<emoji> <type>(<scope>): <技术性中文描述>`，句尾可带"喵"。
- 类型与 Gitmoji 映射：✨ feat / 🐛 fix / ⚡️ perf / 📝 docs / 🎨 style / 🔨 refactor / 🧪 test。
- 提交前必更文档：每次提交前必须根据本次改动同步更新受影响的 `docs/design.md`
  与 `README.mbt.md` 及相关注释/示例，确保文档与代码语义一致；
  文档未同步视为未达到提交条件喵。
