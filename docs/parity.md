# 对位清单（Parity Manifest）

> 目标：与上游 ratatui（pinned `ratatui-v0.30.2`，见 `docs/design.md` ADR-6）
> 功能一比一复刻。本清单逐模块映射上游文件与本库状态，是推进进度唯一
> 计量表；每次复刻提交必须同步更新本表喵。
>
> 状态：✅ 已复刻（测试逐条转绿）｜◐ 部分（缺项在行内列出）｜⬜ 未开始

## ratatui-core

| 上游模块 | 本库 | 状态 | 缺项 |
|---|---|---|---|
| `layout/rect.rs` + `rect/ops.rs` | `core/rect.mbt` + `rect_test.mbt` | ✅ | `positions()`/`iter.rs` 的 Rows/Columns 结构体细化（`rows`/`columns` 已有 Iter 版） |
| `layout/position.rs` | `core/position.mbt` | ✅ | `Add<Position>`（Position+Position）糖 |
| `layout/size.rs` / `margin.rs` / `offset.rs` | 同名 `.mbt` | ✅ | FromStr 糖 |
| `layout/alignment.rs` | `core/alignment.mbt` | ◐ | `VerticalAlignment`、FromStr |
| `layout/constraint.rs` | `core/constraint.mbt` | ✅ | apply/from_* 构造器/Display 全量；u32::MAX 极端用例按 Int 域折算 |
| `layout/direction.rs` / `flex.rs` | `core/direction.mbt` + `core/flex.mbt` | ✅ | — |
| `layout/layout.rs` | — | ⬜ | Layout + cassowary 求解（ADR-3：纯 MoonBit 一次性求解子集，最大单体工程） |
| `buffer/buffer.rs` | `core/buffer.mbt` | ✅ | `with_lines` 的 Into 泛型形态（有 `with_lines_of`）；Debug 全功能 |
| `buffer/cell.rs` | `core/cell.mbt` | ✅ | — |
| `buffer/cell_width.rs` | `Cell::cell_width` + `core/width.mbt` | ◐ | 宽度表为近似区间法（unicode/ 全量表待迁） |
| `buffer/diff.rs` | `Buffer::diff` | ✅ | `BufferDiff` 独立迭代器形态（行为等价 Array 输出） |
| `buffer/assert.rs` | — | ⬜ | BufferAssert 测试辅助 |
| `style.rs`（Style/Modifier） | `core/style.mbt` | ✅ | stylize 速记糖（见 stylize 行） |
| `style/color.rs` | `core/color.mbt` | ✅ | palette/anstyle 转换单列 |
| `style/stylize.rs` | `core/stylize.mbt` | ✅ | Style 级速记全量；Cell/Line 等类型速记由 set_style/patch_style 组合覆盖 |
| `style/palette*` | — | ⬜ | Material/Tailwind 色板 + HSL/HSLuv 转换 |
| `style/anstyle.rs` | — | ⬜ | anstyle crate 桥接（MoonBit 无此 crate，按语义复刻转换） |
| `text/span.rs` / `line.rs` | `core/text.mbt` | ✅ | Into/Cow/Collect 构造糖（Rust 语法层） |
| `text/text.rs` | `core/text_container.mbt` | ✅ | Into/Iterator 语法糖 |
| `text/masked.rs` | `core/masked.mbt` | ✅ | — |
| `text/grapheme.rs` | `core/grapheme.mbt` | ◐ | 图形簇细分（逐码点近似，unicode/ 落位后升级） |
| `symbols/border.rs` | `core/border.mbt` | ◐ | 缺 ONE_EIGHTH/PROPORTIONAL/FULL/EMPTY 填充集（随 Canvas） |
| `symbols/merge.rs` | `core/merge.mbt` | ✅ | — |
| `symbols/line.rs` / `bar.rs` / `block.rs` / `braille.rs` / `half_block.rs` / `marker.rs` / `pixel.rs` / `scrollbar.rs` / `shade.rs` | — | ⬜ | 各符号常量表（Canvas/Chart/Scrollbar 前置） |
| `terminal/*`（Frame/Buffers/Viewport/Inline/Init/Render/Resize/Cursor） | — | ⬜ | 终端会话层（本库 backend 包对位其 TestBackend 部分） |
| `widgets/widget.rs` / `stateful_widget.rs` | `core/widget.mbt` + `core/stateful_widget.mbt` | ✅ | Widget trait（Span/Line/Text/String/Block/Paragraph 实现）；StatefulWidget 以 Stateful[W,S] 状态打包形式化（MoonBit 无关联类型，所有权偏差登记） |
| `backend.rs` + `backend/test.rs` | `backend/` 包（自有 Backend trait + TestBackend） | ◐ | 本库 trait 只含 `draw`，终端原语随 TtyBackend 扩契约 |

## ratatui-widgets

| 上游模块 | 状态 | 缺项 |
|---|---|---|
| `block.rs` + `block/padding.rs` | ◐ | `shadow`、Stylize 糖 |
| `block/shadow.rs` | ⬜ | Shadow/Dimmed 渲染 |
| `borders.rs` | ✅ | — |
| `reflow.rs`（WordWrapper/LineTruncator） | `widgets/reflow.mbt` | ✅ | 上游 21 条折行测试全量复刻；宽度用近似区间法（unicode/ 落位后升级） |
| `paragraph.rs` | `widgets/paragraph.mbt` | ✅ | 上游 29 条测试全量复刻（折行/截断/滚动/对齐/样式分层/CJK）；半宽浊点图形簇用例随 unicode/ |
| `list.rs` + `list/*` | ⬜ | List + ListState |
| `table.rs` + `table/*` | ⬜ | Table + Row/Cell/State |
| `tabs.rs` | ⬜ | Tabs |
| `gauge.rs` | ⬜ | Gauge/GaugeStyle |
| `sparkline.rs` | ⬜ | Sparkline |
| `scrollbar.rs` | ⬜ | Scrollbar + Orientation |
| `chart.rs` / `barchart.rs` | ⬜ | 图表族 |
| `canvas.rs` + `canvas/*` | ⬜ | Canvas + shape（world 域名地图数据单列） |
| `clear.rs` / `fill.rs` | ⬜ | Clear/Fill |
| `calendar.rs` | ⬜ | 月历（time 依赖需评估） |
| `logo.rs` / `mascot.rs` | ⬜ | 徽标绘制 |

## 推进顺序（依赖驱动）

1. ✅ 文本基元（Span/Line/Alignment）→ Block 容器
2. ✅ `Text` 容器 → `symbols/merge` + `merge_borders` → stylize 速记 + Color FromStr
3. ✅ `reflow.rs`（WordWrapper/LineTruncator）+ 21 条折行测试
4. ✅ Paragraph（折行/截断/滚动/对齐/样式分层全语义）
5. ▶ Widget/StatefulWidget trait 形式化 → List/Tabs/Gauge/Sparkline/Scrollbar
4. Widget/StatefulWidget trait 形式化 → List/Tabs/Gauge/Sparkline/Scrollbar
5. Layout 数据类型（Constraint/Direction/Flex）→ cassowary 一次性求解子集（ADR-3）
6. 终端会话层（Frame/Buffers）→ TtyBackend（moonbit-community/tty）
7. Table/Chart/BarChart/Canvas 族

## 完成判据

每模块以"上游内联测试逐条复刻转绿"为唯一验收标准；不可移植用例
（Rust 语法糖、should_panic、外部 crate 依赖）必须在测试文件头登记
原因，不允许静默缺失喵。
