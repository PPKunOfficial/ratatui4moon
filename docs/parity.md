# 对位清单（Parity Manifest）

> 目标：与上游 ratatui（pinned `ratatui-v0.30.2`，见 `docs/design.md` ADR-6）
> 功能一比一复刻。本清单逐模块映射上游文件与本库状态，是推进进度唯一
> 计量表；每次复刻提交必须同步更新本表喵。
>
> 状态：✅ 已复刻（测试逐条转绿）｜◐ 部分（缺项在行内列出）｜⬜ 未开始

## ratatui-core

| 上游模块 | 本库 | 状态 | 缺项 |
|---|---|---|---|
| `layout/rect.rs` + `rect/ops.rs` | `core/rect.mbt` + `rect_test.mbt` | ✅ | `iter.rs` 的 Rows/Columns/Positions 结构体形态（`rows`/`columns`/`positions` 已有 Iter 版） |
| `layout/position.rs` | `core/position.mbt` | ✅ | `Add<Position>`（Position+Position）糖 |
| `layout/size.rs` / `margin.rs` / `offset.rs` | 同名 `.mbt` | ✅ | FromStr 糖 |
| `layout/alignment.rs` | `core/alignment.mbt` | ◐ | `VerticalAlignment`、FromStr |
| `layout/constraint.rs` | `core/constraint.mbt` | ✅ | apply/from_* 构造器/Display 全量；u32::MAX 极端用例按 Int 域折算 |
| `layout/direction.rs` / `flex.rs` | `core/direction.mbt` + `core/flex.mbt` | ✅ | — |
| `layout/layout.rs` | `layout/` 包 | ✅ | kasuari 一次性求解子集（`Solver::new → add_constraint → fetch_changes`）+ Layout 约束体系/strengths/Flex/Spacing 全落；上游 split 全部 22 组参数矩阵（679 case，含 letters 391）+ docstring 示例 + edge_cases + 不变量测试全量复刻；`skip(1).tuples()` 非重叠单调对（overlap 通道）等语义差异经 kasuari 参照实测校准 |
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
| `symbols/line.rs` | `core/line_symbol.mbt` | ✅ | 49 常量 + `LineSet` 十集合全量 |
| `symbols/block.rs` | `core/block_symbol.mbt` | ✅ | 八级填充常量 + `BlockSet` 三/九级集合 |
| `symbols/bar.rs` | `core/bar_symbol.mbt` | ✅ | 八级底对齐柱常量 + `BarSet` 三/九级集合 |
| `symbols/shade.rs` | `core/shade_symbol.mbt` | ✅ | 五级明暗常量 |
| `symbols/scrollbar.rs` | `core/scrollbar_symbol.mbt` | ✅ | 四组 track/thumb/begin/end 集合 |
| `symbols/braille.rs` / `half_block.rs` / `marker.rs` / `pixel.rs` | — | ⬜ | 各符号常量表（Canvas 前置） |
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
| `list.rs` + `list/*` | `widgets/list.mbt` + `list_render.mbt` | ✅ | 状态化渲染全算法 + `tests/widgets_list.rs` 全部 8 条集成用例复刻（Terminal 层以直渲染等价承载） |
| `barchart.rs` + `barchart/{bar,bar_group}.rs` | `widgets/barchart.mbt` | ✅ | 内联 43 条 + `tests/widgets_barchart.rs` 2 条全量复刻（双方向/分组/组距/逐柱样式/值文本溢出双段样式/UTF-8 字节边界/CJK 值/u64 精度/issue 1928 回归） |
| `table.rs` + `table/{cell,row,highlight_spacing,state}.rs` | `widgets/table.mbt` | ◐ | TableCell/TableRow/TableState/Table 全类型与渲染管线（Layout 驱动列宽）；cell/row/state/render/选中矩阵/偏移滚动（issue #1179 回归）内联测试全绿；column_widths 模块对包私有 `get_column_widths`/`get_cell_area` 直测登记（渲染等价承载）；`tests/widgets_table.rs` 集成用例待复刻 |
| `tabs.rs` | `widgets/tabs.mbt` | ✅ | 13 条测试全量复刻（缺省样式/分隔符/内边距/选中矩阵/越界与取消/极小缓冲） |
| `gauge.rs` | `widgets/gauge.mbt` | ✅ | Gauge + LineGauge：内联 14 条 + `tests/widgets_gauge.rs` 5 条全量复刻（unicode 半格/样式叠加/超宽标签）；越界 `assert!` 按无 panic 铁律改饱和并登记；deprecated `line_set`/`gauge_style` 不复刻已登记 |
| `sparkline.rs` | `widgets/sparkline.mbt` | ✅ | 内联 22 条全量复刻（方向枚举/缺值柱/逐柱样式/双行 tick 分配/u64::MAX 整数精度）；Vec/Array/Slice 六条创建测试按 Array 形态合并登记；上游 u128 以 32 位半乘 + 128/64 逐位长除精确承载并另设进位路径加固用例 |
| `scrollbar.rs` | `widgets/scrollbar.mbt` | ✅ | 内联 26 条全量复刻（rstest 参数矩阵以循环承载：四方位/缺省符号/无轨道/底衬/箭头/自定义视口/极小轨道/#2582 回归）；包私有 `part_lengths` 直测以渲染等价承载已登记；状态机 prev/next/first/last/scroll 饱和语义全量 |
| `gauge.rs` | ⬜ | Gauge/GaugeStyle |
| `sparkline.rs` | ⬜ | Sparkline |
| `scrollbar.rs` | ⬜ | Scrollbar + Orientation |
| `chart.rs` / `barchart.rs` | ⬜ | 图表族 |
| `canvas.rs` + `canvas/*` | ⬜ | Canvas + shape（world 域名地图数据单列） |
| `clear.rs` | `widgets/clear.mbt` | ✅ | 三条内联测试全量复刻（区域复位/部分越界/完全越界） |
| `fill.rs` | `widgets/fill.mbt` | ✅ | 七条内联测试全量复刻（符号样式/越界裁剪/非零原点/替换符号）；Cow 双形态按 String 合并登记 |
| `calendar.rs` | ⬜ | 月历（time 依赖需评估） |
| `logo.rs` / `mascot.rs` | ⬜ | 徽标绘制 |

## 推进顺序（依赖驱动）

1. ✅ 文本基元（Span/Line/Alignment）→ Block 容器
2. ✅ `Text` 容器 → `symbols/merge` + `merge_borders` → stylize 速记 + Color FromStr
3. ✅ `reflow.rs`（WordWrapper/LineTruncator）+ 21 条折行测试
4. ✅ Paragraph（折行/截断/滚动/对齐/样式分层全语义）
5. ✅ Widget/StatefulWidget trait 形式化（Span/Line/Text/String/Block/Paragraph 实现；Stateful[W,S] 状态打包）
6. ✅ Widget/StatefulWidget trait 形式化 → List/Tabs/Gauge/LineGauge（单测与集成黄金用例全绿）
7. ✅ Sparkline/Scrollbar/Clear/Fill/BarChart + Layout 求解器（ADR-3 kasuari 子集，679 case 全绿）→ ▶ Table → Chart
8. Layout 数据类型（Constraint/Direction/Flex）→ cassowary 一次性求解子集（ADR-3）
9. 终端会话层（Frame/Buffers）→ TtyBackend（moonbit-community/tty）
10. Chart/BarChart/Canvas 族

## 完成判据

每模块以"上游内联测试逐条复刻转绿"为唯一验收标准；不可移植用例
（Rust 语法糖、should_panic、外部 crate 依赖）必须在测试文件头登记
原因，不允许静默缺失喵。
