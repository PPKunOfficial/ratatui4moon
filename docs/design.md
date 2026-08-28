# ratatui4moon 设计文档

> 本文是仓库设计的唯一真相源：定位、架构、关键决策（ADR）、测试策略与路线图。
> 代码与本文不一致时，先改文档或先改代码，二者必须同步喵。

## 1. 定位与生态位

MoonBit 生态的终端技术栈现状：

| 层 | 现有方案 | 缺口 |
|---|---|---|
| 低层终端原语 | `moonbit-community/tty`（raw mode/尺寸/输入事件，unix+win32 C stub） | 已有，不自研 |
| vDOM/响应式框架 | `mizchi/tui`（virtual DOM + flexbox/grid + 组件库） | 已有 |
| **immediate-mode 框架** | —— | **本库填补的空位** |

ratatui4moon 坐"ratatui 位"：cell 网格 Buffer + 无状态 widget + 差分 ANSI 输出。
与 vDOM 路线（mizchi/tui）是**互补而非竞争**：两套范式服务不同偏好的消费者喵。

**硬边界**：不引入 Bun/Node 运行时；不走 FFI（含 kasuari/Yoga/OpenTUI 等一切
C/Rust/Zig 库）；纯 MoonBit native 静态编译单二进制。

## 2. 关键决策记录 (ADR)

### ADR-1 纯 MoonBit，拒绝 FFI 中间态

背景：曾评估"先做 ratatui 壳、底下 kasuari 走 FFI、日后转纯 MoonBit"的渐进路线，
**否决**。理由：

1. ratatui 对 kasuari 的用法已被源码证实为**一次性建模求解**（每次 `Solver::new()`
   → `add_constraint` × N → `fetch_changes()` 一次，无 `suggest_value`/增量编辑/
   约束删除）——需要的算法子集远小于完整 kasuari；
2. FFI 站的产物（C API 设计、opaque handle、panic 边界、静态库构建矩阵、
   marshaling 胶水）在转纯 MoonBit 时**全部丢弃**，纯移植的产物全部保留；
3. MoonBit 不传递链接参数，发布库要求下游手动配 link flags 是生态毒药
   （OneBit-TUI 实证：30 下载、停更）。

结论：布局求解的演进走"trait 缝"而非"FFI 缝"（见 ADR-3）。

### ADR-2 immediate-mode，非 vDOM

widget 是无状态值：`render(area, buf)` 即画即走，每帧全量绘制进 Buffer，
差分后输出。可测试性（快照断言）与简单性优先于声明式便利。

### ADR-3 布局三阶段演进，求解器永远在 trait 缝后面

```
trait LayoutSolver {  solve(area: Rect, constraints: Array[Constraint]) -> Array[Rect]  }
```

1. **v0.1–v0.2**：线性分区（纯算术）。agent UI（转录区 + composer + 状态栏）
   是固定纵向结构，不需要通用求解器；
2. **需要弹性时**：简化分配器（百分比/比例/最小最大的启发式分配）；
3. **真需要通用约束求解时**：纯 MoonBit 移植 kasuari 的**一次性求解子集**
   （完整 kasuari 实测 3,295 行，核心 `solver.rs` 825 行；剔除增量编辑与
   约束删除机械），以独立包 `<user>/cassowary` 发布，slot 进同一 trait。
   测试断言从第一天起用 ±1px 容差，未来换实现零成本。

### ADR-4 平台 FFI 外包给 `moonbit-community/tty`

真终端后端不自写 C stub，依赖 tty 包（unix/win32 双实现、kitty 键盘协议、
bracketed paste、鼠标解析全有）。防御措施：`Backend` trait 隔离，tty 停更
时 fork 的爆炸半径收敛在 backend 包内。代价：传递依赖 `moonbitlang/async`。

### ADR-5 黄金快照为主测试形式

渲染正确性 = 精确 ANSI 字符串断言（`inspect!` 快照）。布局等未来浮点路径
用容差断言。参考资源：上游 ratatui 的内联测试是免费的行为规格库，
实现一个模块就翻译对应断言（工作法见 ADR-7）。

### ADR-6 上游参照基线：pinned 快照，不追活分支

上游 ratatui 迭代很快，行为规格必须锚定一个不动点喵：

- 参照仓库：`/Users/pp/projects/ratatui`（浅克隆，detached HEAD），
  固定 tag **`ratatui-v0.30.2`**（commit `e665c36c`，2026-06-19 发布）；
- 复刻测试与对照实现一律以该检出为准；上游出新 release 时由维护者
  显式更新固定点并复查受影响测试，禁止在会话中随手 `git pull` 漂移喵；
- 上游 v0.30 起拆分为 workspace（`ratatui-core`/`ratatui-widgets`），
  本库的 `core/` 对位 `ratatui-core/src/{layout,style,buffer,text}`，
  `widgets/` 对位 `ratatui-widgets` 喵。

### ADR-7 单测复刻 TDD 工作法

1. **先测后码**：为每个上游模块逐条复刻内联测试（测试名保留上游
   对应关系注释），快照断言走 `inspect`/`@debug.assert_eq`，再写实现
   使其转绿；快照只经 `moon test --update` 生成，禁止手改喵；
2. **数值模型**：坐标用 `Int` 承装，但完整保留上游 `u16` 饱和语义
   （`MAX_COORD = 65535`，`Rect::new`/`offset`/`resize` 等负责钳制；
   面积用 `Int64` 防 u16² 溢出）——u16 是上游的内存布局选择，
   饱和行为才是规格喵；
3. **不可移植用例显式登记**：依赖 Layout 求解器、unicode 宽表、
   `should_panic` 语义的测试在对应测试文件头注释登记为"待复刻"，
   随对应包落位补齐，不静默丢弃喵。

## 3. 分层架构与依赖方向

```
widgets/            无状态 widget（Block / Paragraph / List / Editor…）
   │ 只依赖 core
   ▼
core/               Rect · Position/Size/Margin/Offset · Style/Modifier/Color ·
                    Cell · Buffer · diff · Span/Line/Alignment/StyledGrapheme ·
                    近似宽度表  ← 依赖树叶，零 I/O
   ▲ 只依赖 core
   │
backend/            Backend trait · TestBackend · ANSI 引擎
   │ （未来）TtyBackend ← moonbit-community/tty ← moonbitlang/async
   ▼
widgets/test/ 等    黑盒快照包：依赖被测包 + backend 公开 API
```

规则：

- `core` 禁止 import 本 module 任何包；`widgets` 禁止依赖 `backend`
  （widget 的输出是 Buffer，不是 ANSI）；
- 差分方向对位上游 `BufferDiff`：`prev.diff(next)` 产出把 prev 更新为
  next 的最小变化序列；x/y/width 不一致为程序员错误（`guard!`），
  高度取较小值喵；
- Cell 的可变字段 + 引用语义是模型契约：Buffer 内的 Cell 即真实
  单元格，`mut_cell` 原地修改；`filled` 等批量构造必须逐格克隆，
  禁止共享同一引用喵；
- 一切终端转义出自 `backend/ansi.mbt`，上层禁止手拼；
- 当前 `Backend` 契约只含 `draw(frame)`；raw mode / 光标 / 尺寸 / async 输入
  在接入 tty 时扩契约，禁止为不存在的消费方预埋机制。

## 4. 测试策略

- **黄金 ANSI 快照**：`TestBackend` 录帧 + `frame_to_ansi` 精确串断言，
  快照更新只走 `moon test --update`，禁止手改 content；
- **上游单测复刻**：core 等模块的单元测试逐条复刻上游内联测试
  （ADR-7 工作法），结构体相等断言用 `@debug.assert_eq`（`Eq + Debug`
  派生），不给模型类型补 `Show`；
- 单元测试覆盖差分、裁剪、退化区域、非原点坐标等边界；
- 测试零真实终端、零网络、零 I/O，`moon test` 全绿方可提交；
- CI 目标：Linux + Windows 双平台（v0.2 前）。

## 5. unicode 计划

CJK 渲染是第一消费方（Nonoka）的刚需。v0.1 阶段 `core/width.mbt`
以近似区间法供宽（覆盖 CJK/全角/谚文/常见 Emoji 区间，控制与零宽
字符宽 0，换行符按上游 str 宽度语义记 1），已支撑 `set_stringn`
列推进、差分吞列与 `Span`/`Line` 的对齐渲染与截断；升级路径：

1. 迁入 `unicode/` 包并保留现有 API 语义（`char_display_width` /
   `symbol_width` / `truncate_start` 等）；
2. 数据表从 Rust `unicode-width` crate 机械搬运（east-asian width 全表 +
   零宽组合符区间 + VS16 emoji 序列），替换近似区间，并补齐依赖
   真实宽度的上游用例（emoji/ZWJ 图形簇/🇺🇸 regional indicator）；
3. Grapheme 簇细分（`unicode-segmentation` 对位）随全量表一并评估；
4. 折行引擎参考 ratatui `paragraph + reflow` 的行为规格翻译测试。

## 6. 路线图

- **v0.1（当前）**：core（Buffer/diff/Style）+ backend（trait/TestBackend/ANSI）
  + widgets（Block），黄金快照管线全绿 ✅
- **v0.2**：`unicode/` 宽度表全量搬运与折行；Paragraph；线性 `layout/`
  （`LayoutSolver` trait + LinearSolver）；`TtyBackend` 接入 tty 包；
  Linux + Windows CI
- **v0.3**：List / Scrollbar / 单行 Editor（历史、光标）；鼠标；kitty 键盘
  协议增强；IME 摸底（raw mode 下 CJK 输入是已知硬骨头，mizchi 以 cooked
  模式绕行，本库需独立评估方案）

**非目标**（写下来防蔓延）：cassowary 全量移植进本库、Yoga/flexbox 语义、
canvas/图片协议（kitty graphics）/3D、响应式 vDOM、Bun/Node 运行时。

## 7. 与 Nonoka 的关系

- Nonoka（`nonoka/nonoka`）是第一消费方与 dogfooding 场地：agent TUI 从
  行式渲染（其 `tui/` 包：DiffRenderer/Component）逐步迁移到本库 cell 架构；
- 可复用资产的迁移方向：`tui/width.mbt` → `unicode/`（升级为全量表），
  `tui/ansi.mbt` 原语 → `backend/ansi.mbt`（已迁入并升级为 cell 粒度）；
- Nonoka 的 `tui/` 行式包在本库 v0.2 具备替换能力后再退役，两套不长期并行。
