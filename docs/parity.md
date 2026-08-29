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
| `layout/position.rs` | `core/position.mbt` | ✅ | `±Offset` 算术（`op_add`/`op_sub` 饱和钳制）与 `to_display` 全量 |
| `layout/size.rs` / `margin.rs` / `offset.rs` | 同名 `.mbt` | ✅ | 上游本无 FromStr；`Display` 以 `to_display` 对位 |
| `layout/alignment.rs` | `core/alignment.mbt` | ✅ | Horizontal/Vertical 全变体 + to_display/from_str（strum 对位）|
| `layout/constraint.rs` | `core/constraint.mbt` | ✅ | apply/from_* 构造器/Display 全量；u32::MAX 极端用例按 Int 域折算 |
| `layout/direction.rs` / `flex.rs` | `core/direction.mbt` + `core/flex.mbt` | ✅ | — |
| `layout/layout.rs` | `layout/` 包 | ✅ | kasuari 一次性求解子集（`Solver::new → add_constraint → fetch_changes`，**Double/f64 精度，与上游 f64 一致**）+ Layout 约束体系/strengths/Flex/Spacing 全落；上游 split 全部 22 组参数矩阵（679 case，含 letters 391）+ docstring 示例 + edge_cases + 不变量测试全量复刻；`skip(1).tuples()` 非重叠单调对（overlap 通道）等语义差异经 kasuari 参照实测校准 |
| `kasuari` (上游 `kasuari 0.4.12`/`cassowary`) | `kasuari/` 包 | ✅ | `nonoka/kasuari4moon` 完整移植 vendored（solver.rs 864 行全量，含增量编辑/约束增删/dual simplex，Strength/Variable/Term/Expression/Constraint/Row/Symbol 全量，22 测全绿，f64 精度与上游一致） |
| `buffer/buffer.rs` | `core/buffer.mbt` | ✅ | `with_lines` 的 Into 泛型形态（有 `with_lines_of`）；Debug 全功能 |
| `buffer/cell.rs` | `core/cell.mbt` | ✅ | — |
| `buffer/cell_width.rs` | `Cell::cell_width` + `core/width.mbt` | ✅ | unicode-width 0.2.2（Unicode 17.0）全量三层查找表机械搬运至 `unicode/` 包，状态机（VS16/ZWJ emoji 序列/区域指示符/连字组合）纯 MoonBit 移植；`set_stringn`/`styled_graphemes` 按扩展图形簇切分；上游 emoji 测试（renders_emoji×4/diff 尾列两条）全量补齐 |
| `buffer/diff.rs` | `Buffer::diff` | ✅ | `BufferDiff` 独立迭代器形态（行为等价 Array 输出） |
| `buffer/assert.rs` | `core/buffer_assert.mbt` | ✅ | `assert_buffer_eq` 宏以 raise 函数对位（MoonBit 无宏，登记）；3 条测试复刻（should_panic 以 try/catch 承载） |
| `style.rs`（Style/Modifier） | `core/style.mbt` | ✅ | stylize 速记糖（见 stylize 行） |
| `style/color.rs` | `core/color.mbt` | ✅ | palette/anstyle 转换单列 |
| `style/stylize.rs` | `core/stylize.mbt` | ✅ | Style 级速记全量；Cell/Line 等类型速记由 set_style/patch_style 组合覆盖 |
| `style/palette*` | `core/palette_material.mbt` + `palette_tailwind.mbt` + `palette_conversion.mbt` | ✅ | Material 19 组（16 含强调色）+ Tailwind 22 组全表机械搬运 + Srgb/LinSrgb→Color 传递函数（上游 2 条测试复刻 + 文档示例锚定）；`palette` crate 的 HSL/HSLuv 类型 ratatui 源码未引用，不在复刻面 |
| `style/anstyle.rs` | `core/anstyle.mbt` | ✅ | 最小等价类型（AnsiColor/Ansi256Color/RgbColor/Effects/AnStyle）+ 全部转换与 14 条测试复刻；Reset 转换的 panic 以 fail() 对位（消息逐字一致，登记） |
| `text/span.rs` / `line.rs` | `core/text.mbt` | ✅ | Into/Cow/Collect 构造糖（Rust 语法层） |
| `text/text.rs` | `core/text_container.mbt` | ✅ | Into/Iterator 语法糖 |
| `text/masked.rs` | `core/masked.mbt` | ✅ | — |
| `text/grapheme.rs` | `core/grapheme.mbt` | ✅ | StyledGrapheme 全量（new/is_whitespace/styled 四测）；图形簇细分随 `unicode/` 落位（unicode-segmentation 1.13.3 的 GB3–GB999 状态机移植，`Span::styled_graphemes` 以扩展图形簇切分） |
| `symbols/border.rs` | `core/border.mbt` | ✅ | 十六集合全量（含 McGugan ONE_EIGHTH_WIDE/TALL、PROPORTIONAL_WIDE/TALL、FULL/EMPTY）+ 上游 render 快照测试逐条复刻 |
| `symbols/merge.rs` | `core/merge.mbt` | ✅ | — |
| `symbols/line.rs` | `core/line_symbol.mbt` | ✅ | 49 常量 + `LineSet` 十集合全量 |
| `symbols/block.rs` | `core/block_symbol.mbt` | ✅ | 八级填充常量 + `BlockSet` 三/九级集合 |
| `symbols/bar.rs` | `core/bar_symbol.mbt` | ✅ | 八级底对齐柱常量 + `BarSet` 三/九级集合 |
| `symbols/shade.rs` | `core/shade_symbol.mbt` | ✅ | 五级明暗常量 |
| `symbols/scrollbar.rs` | `core/scrollbar_symbol.mbt` | ✅ | 四组 track/thumb/begin/end 集合 |
| `symbols/marker.rs`（含 `symbols::DOT`） | `core/marker.mbt` | ✅ | 九变体 Marker + name/from_str（strum 对位）+ 两条上游测试 |
| `symbols/braille.rs` | `core/braille_symbol.mbt` | ✅ | 256 项行主序位图表 + 位映射抽检（上游无内联测试，补锚定） |
| `symbols/half_block.rs` | `core/half_block_symbol.mbt` | ✅ | UPPER/LOWER/FULL 三常量（上游无内联测试，补锚定） |
| `symbols/pixel.rs` | `core/pixel_symbol.mbt` | ✅ | QUADRANTS/SEXTANTS/OCTANTS 三表 + 端点抽检（上游无内联测试，补锚定） |
| `terminal/*`（Frame/Buffers/Viewport/Init/Render/Resize/Cursor/Inline） | `terminal/` 包 | ✅ | Terminal/Frame/CompletedFrame/Viewport/TerminalOptions + 双缓冲 flush/swap/clear 四族 + draw 管线 + autoresize/resize（含行内重排）+ 光标状态机 + `insert_before` 族（分块直写/滚动下推/清屏重绘语义，scrolling-regions 为上游 feature 门控路径不复刻并登记）+ 40 条测试复刻（buffers 12/viewport 1/terminal.backend 3/cursor 3/resize 6/init 5/render 6/inline compute+insert_before 8/工程锚定 4 中归并）；`TtyBackend` 已接 `tty@0.3.0`（`Terminal::new(TtyBackend::new())` 直驱真机） |
| `widgets/widget.rs` / `stateful_widget.rs` | `core/widget.mbt` + `core/stateful_widget.mbt` | ✅ | Widget trait（Span/Line/Text/String/Block/Paragraph 实现）；StatefulWidget 以 Stateful[W,S] 状态打包形式化（MoonBit 无关联类型，所有权偏差登记） |
| `backend.rs` + `backend/test.rs` | `backend/` 包 | ✅ | Backend trait 完整契约（draw/光标四件/clear 两件/size/window_size/flush/append_lines）+ ClearType/WindowSize + TestBackend 全形态（主/回滚缓冲/光标/append_lines 滚动/缓冲视图）+ `TtyBackend`（`backend/tty_backend.mbt`，`tty@0.3.0` 同步 ANSI 直写 + `window_size` 同步 `ioctl` 失败 `raise`（上游对齐，无 80×24 估算），`enter_raw_mode` 管理，1 测冒烟）+ 上游 test.rs 测试清单复刻中（ClearType 2 条 + 主体行为测试经 terminal 包 34 条承载）；`last_ansi` 录帧为本库扩展 |

## ratatui-widgets

| 上游模块 | 状态 | 缺项 |
|---|---|---|
| `block.rs` + `block/padding.rs` | `widgets/block.mbt` | ◐ | Stylize 速记糖（样式经 set_style/patch_style 组合覆盖）|
| `block/shadow.rs` | `widgets/shadow.mbt` | ✅ | 五内联测试全量复刻（overlay/Symbol 矩阵/越界裁剪/Custom/Dimmed RGB 减半）；`Arc<dyn CellEffect>` 以注册表 + id 寻址承载（同一性 ≡ ptr_eq，登记）|
| `borders.rs` | ✅ | — |
| `reflow.rs`（WordWrapper/LineTruncator） | `widgets/reflow.mbt` | ✅ | 上游 21 条折行测试全量复刻；宽度用近似区间法（unicode/ 落位后升级） |
| `paragraph.rs` | `widgets/paragraph.mbt` | ✅ | 上游 29 条测试全量复刻（折行/截断/滚动/对齐/样式分层/CJK）；半宽浊点图形簇用例随 unicode/ |
| `list.rs` + `list/*` | `widgets/list.mbt` + `list_render.mbt` | ✅ | 状态化渲染全算法 + `tests/widgets_list.rs` 全部 8 条集成用例复刻（Terminal 层以直渲染等价承载） |
| `barchart.rs` + `barchart/{bar,bar_group}.rs` | `widgets/barchart.mbt` | ✅ | 内联 43 条 + `tests/widgets_barchart.rs` 2 条全量复刻（双方向/分组/组距/逐柱样式/值文本溢出双段样式/UTF-8 字节边界/CJK 值/u64 精度/issue 1928 回归） |
| `table.rs` + `table/{cell,row,highlight_spacing,state}.rs` | `widgets/table.mbt` | ✅ | 全类型与渲染管线（Layout 驱动列宽/跨列/选中滚动）；内联测试全量复刻（cell/row/config/state/render/选中矩阵/偏移滚动 #1179/column_count/极小缓冲）；`tests/widgets_table.rs` 集成 11 组 33 用例全量复刻（列宽四族/多行/占位策略/逐元素样式/偏移收敛）；column_widths+get_cell_area 包私有直测登记（渲染等价承载）；highlight_style 弃用构造器与百分比 panic 断言登记 |
| `tabs.rs` | `widgets/tabs.mbt` | ✅ | 13 条测试全量复刻（缺省样式/分隔符/内边距/选中矩阵/越界与取消/极小缓冲） |
| `gauge.rs` | `widgets/gauge.mbt` | ✅ | Gauge + LineGauge：内联 14 条 + `tests/widgets_gauge.rs` 5 条全量复刻（unicode 半格/样式叠加/超宽标签）；越界 `assert!` 按无 panic 铁律改饱和并登记；deprecated `line_set`/`gauge_style` 不复刻已登记 |
| `sparkline.rs` | `widgets/sparkline.mbt` | ✅ | 内联 22 条全量复刻（方向枚举/缺值柱/逐柱样式/双行 tick 分配/u64::MAX 整数精度）；Vec/Array/Slice 六条创建测试按 Array 形态合并登记；上游 u128 以 32 位半乘 + 128/64 逐位长除精确承载并另设进位路径加固用例 |
| `scrollbar.rs` | `widgets/scrollbar.mbt` | ✅ | 内联 26 条全量复刻（rstest 参数矩阵以循环承载：四方位/缺省符号/无轨道/底衬/箭头/自定义视口/极小轨道/#2582 回归）；包私有 `part_lengths` 直测以渲染等价承载已登记；状态机 prev/next/first/last/scroll 饱和语义全量 |
| `canvas.rs` + `canvas/{points,line,rectangle,circle,map,world}.rs` | `widgets/canvas.mbt` + `canvas_{points,line,rectangle,circle,map,world}.mbt` | ✅ | Grid 三形态（PatternGrid/CharGrid/HalfBlockGrid）+ Painter/Context + 层合成；五 Shape + world 低/高分辨率点集（6291 点机械搬运）；内联测试全量复刻（横竖/对角线 × 10 marker 矩阵/裁剪 Bresenham 17+20 组/圆/矩形 5 条/地图低高全幅/极小零尺寸缓冲）；`line-clipping 0.3.7` 纯 MoonBit 移植；usize 溢出探针以渲染等价承载登记；`tests/widgets_canvas.rs` 1 条集成用例复刻；HalfBlock 越界直写按无 panic 铁律改守卫登记 |
| `chart.rs` | `widgets/chart.mbt` | ✅ | Axis/Dataset/GraphType/LegendPosition/ChartLayout + 图例八方位置 `place` + X/Y 标签渲染管线全量；内联 22 条测试全量复刻（显隐约束/样式化/超宽标题/匿名数据集/图例样式补丁/长标题避让/溢出裁剪/八方位矩阵（含奇数余量 rstest）/Bar/叠加线条分层/Area 填充/极小零尺寸）；`Chart::layout` 包私有直测以渲染等价承载登记；`tests/widgets_chart.rs` 集成 8 条全量复刻（小区域矩阵/超长标签对齐 7 组/X·Y 对齐 3+3 组/零长边界/大数值域/空数据集/顶行样式归属） |
| `clear.rs` | `widgets/clear.mbt` | ✅ | 三条内联测试全量复刻（区域复位/部分越界/完全越界） |
| `fill.rs` | `widgets/fill.mbt` | ✅ | 七条内联测试全量复刻（符号样式/越界裁剪/非零原点/替换符号）；Cow 双形态按 String 合并登记 |
| `mascot.rs` | `widgets/mascot.mbt` + `mascot_data.mbt` | ✅ | RatatuiMascot/MascotEyeColor + 32x16 半块像素画布（数据机械搬运）+ 逐对行合成渲染 + 5 条上游测试全量复刻 |
| `calendar.rs` | `widgets/calendar.mbt` + `calendar_date.mbt` | ✅ | time crate 使用面（Date/Month/周日基准周数/按天加减）以纯 MoonBit 公历算术承载（civil_from_days 算法）；Monthly/DateStyler/CalendarEventStore 全量 + 7 条测试复刻；`today`（真实时钟）与 `test_today` 登记不复刻；包私有 `sunday_based_weeks` 以裸月历 height() 等价承载 |
| `logo.rs` | `widgets/logo.mbt` + `logo_data.mbt` | ✅ | RatatuiLogo/RatatuiLogoSize 两档字样（数据机械搬运）+ 8 条上游测试全量复刻（构造/缺省/快照/极小零尺寸缓冲） |

## 推进顺序（依赖驱动）

> 9'. TtyBackend 落位结论（本轮）：`moonbit-community/tty@0.3.0` 已接，
> 采用 **同步 ANSI 直写桥**（`Backend` 保持同步，`frame_to_ansi` + `@utf8.encode` + `moonbitlang_async_write` 直写 fd 1（Unix）/`GetStdHandle`（Windows），`window_size` 同步 `ioctl` 失败 `raise`（无 80×24 估算），`Tty::write` 的 async 路径仅用于输入查询，渲染不经异步锁），`TtyBackend::new() -> TtyBackend raise` 进入 raw mode，`draw([])` 空内容在 `moon test` 无污染，770 测全绿喵。

1. ✅ 文本基元（Span/Line/Alignment）→ Block 容器
2. ✅ `Text` 容器 → `symbols/merge` + `merge_borders` → stylize 速记 + Color FromStr
3. ✅ `reflow.rs`（WordWrapper/LineTruncator）+ 21 条折行测试
4. ✅ Paragraph（折行/截断/滚动/对齐/样式分层全语义）
5. ✅ Widget/StatefulWidget trait 形式化（Span/Line/Text/String/Block/Paragraph 实现；Stateful[W,S] 状态打包）
6. ✅ Widget/StatefulWidget trait 形式化 → List/Tabs/Gauge/LineGauge（单测与集成黄金用例全绿）
7. ✅ Sparkline/Scrollbar/Clear/Fill/BarChart + Layout 求解器（ADR-3 kasuari 子集 Double/f64，679 case 全绿）+ `kasuari/` 完整求解器 vendored（22 测全绿）→ Table → Chart（symbols marker/braille/half_block/pixel 前置 + Canvas 全族先行落地）
8. ✅ Layout 数据类型（Constraint/Direction/Flex）→ cassowary 一次性求解子集（ADR-3）
9. ✅ 终端会话层（Frame/Buffers）→ `TtyBackend`（`tty@0.3.0` 同步桥，`Terminal::new(&TtyBackend::new())` 直驱真机）
10. ✅ Chart/BarChart/Canvas 族（Canvas 已随 Chart 先行收官）

## 完成判据

每模块以"上游内联测试逐条复刻转绿"为唯一验收标准；不可移植用例
（Rust 语法糖、should_panic、外部 crate 依赖）必须在测试文件头登记
原因，不允许静默缺失喵。
