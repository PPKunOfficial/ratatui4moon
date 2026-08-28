///|
/// Cell 单元测试：复刻 ratatui-v0.30.2 `buffer/cell.rs` 测试清单，
/// 并迁移上游 `style.rs` 文档中"样式施加到 Cell"的两则示例喵。
///
/// `merge_symbol`（Box Drawing 合并，symbols/merge 模块）与
/// `append_symbol`（包私有，无独立消费方）暂不复刻喵。

///|
/// 上游 new：新单元格为 Reset 色无修饰喵。
test "Cell::of 构造" {
  @debug.assert_eq(Cell::of("あ"), {
    symbol: "あ",
    fg: Reset,
    bg: Reset,
    modifier: Modifier::empty(),
    diff_option: CellDiffOption::None,
  })
}

///|
/// 上游 empty/default：空单元格符号为空格喵。
test "Cell::empty 空格" {
  inspect(Cell::empty().symbol(), content=" ")
  inspect(Cell::of(" ").symbol(), content=" ")
}

///|
/// 上游 set_symbol：多字节与 ZWJ 组合字符原样存储喵。
test "Cell::set_symbol" {
  let cell = Cell::empty()
  cell.set_symbol("あ")
  inspect(cell.symbol(), content="あ")
  cell.set_symbol("👨‍👩‍👧‍👦")
  inspect(cell.symbol(), content="👨‍👩‍👧‍👦")
}

///|
/// 上游 set_char：单字符写入喵。
test "Cell::set_char" {
  let cell = Cell::empty()
  cell.set_char('あ')
  inspect(cell.symbol(), content="あ")
}

///|
/// 上游 set_fg/set_bg喵。
test "Cell::set_fg 与 set_bg" {
  let cell = Cell::empty()
  cell.set_fg(Red)
  @debug.assert_eq(cell.fg, Red)
  cell.set_bg(Red)
  @debug.assert_eq(cell.bg, Red)
}

///|
/// 上游 set_style：颜色覆盖 + 修饰位折叠喵。
test "Cell::set_style" {
  let cell = Cell::empty()
  cell.set_style(Style::new().fg(Red).bg(Blue))
  @debug.assert_eq(cell.fg, Red)
  @debug.assert_eq(cell.bg, Blue)
}

///|
/// 上游 set_skip（0.30 起为 set_diff_option(Skip)）喵。
test "Cell::set_diff_option Skip" {
  let cell = Cell::empty()
  cell.set_diff_option(CellDiffOption::Skip)
  @debug.assert_eq(cell.diff_option, CellDiffOption::Skip)
}

///|
/// 上游 set_always_update喵。
test "Cell::set_diff_option AlwaysUpdate" {
  let cell = Cell::empty()
  cell.set_diff_option(CellDiffOption::AlwaysUpdate)
  @debug.assert_eq(cell.diff_option, CellDiffOption::AlwaysUpdate)
}

///|
/// 上游 reset：复位到空白态喵。
test "Cell::reset" {
  let cell = Cell::empty()
  cell.set_symbol("あ")
  cell.set_fg(Red)
  cell.set_bg(Blue)
  cell.set_diff_option(CellDiffOption::Skip)
  cell.reset()
  inspect(cell.symbol(), content=" ")
  @debug.assert_eq(cell.fg, Reset)
  @debug.assert_eq(cell.bg, Reset)
  @debug.assert_eq(cell.diff_option, CellDiffOption::None)
}

///|
/// 上游 style：读出样式快照（fg/bg 均为 Some）喵。
test "Cell::style 快照" {
  @debug.assert_eq(Cell::empty().style(), {
    fg: Some(Reset),
    bg: Some(Reset),
    add_modifier: Modifier::empty(),
    sub_modifier: Modifier::empty(),
  })
}

///|
/// 上游 cell_eq/cell_ne：同符号等、异符号不等喵。
test "Cell 相等性" {
  inspect(Cell::of("あ") == Cell::of("あ"), content="true")
  inspect(Cell::of("あ") == Cell::of("い"), content="false")
  // 空格态等价：构造路径不同但语义一致喵
  inspect(Cell::of(" ") == Cell::empty(), content="true")
}

///|
/// 上游 Style 文档示例（第一个）：多份样式按序施加到单元格的
/// 累积效果（fg Yellow、bg Red、修饰剩 BOLD|UNDERLINED）喵。
test "Cell::set_style 增量累积" {
  let cell = Cell::empty()
  cell.set_style(
    Style::new()
    .fg(Blue)
    .add_modifier(Modifier::bold().insert(Modifier::italic())),
  )
  cell.set_style(Style::new().bg(Red).add_modifier(Modifier::underlined()))
  cell.set_style(Style::new().fg(Yellow).remove_modifier(Modifier::italic()))
  let style = cell.style()
  @debug.assert_eq(style.fg, Some(Yellow))
  @debug.assert_eq(style.bg, Some(Red))
  @debug.assert_eq(
    style.add_modifier,
    Modifier::bold().insert(Modifier::underlined()),
  )
  inspect(style.sub_modifier.is_empty(), content="true")
}

///|
/// 上游 Style 文档示例（reset）：reset 样式清空修饰并复位颜色喵。
test "Cell::set_style reset 复位" {
  let cell = Cell::empty()
  cell.set_style(
    Style::new()
    .fg(Blue)
    .add_modifier(Modifier::bold().insert(Modifier::italic())),
  )
  cell.set_style(Style::reset().fg(Yellow))
  let style = cell.style()
  @debug.assert_eq(style.fg, Some(Yellow))
  @debug.assert_eq(style.bg, Some(Reset))
  inspect(style.add_modifier.is_empty(), content="true")
}

///|
/// cell_width：自然宽度与 ForcedWidth 覆盖喵。
test "Cell::cell_width" {
  inspect(Cell::of("a").cell_width(), content="1")
  inspect(Cell::of("你").cell_width(), content="2")
  let cell = Cell::of("a")
  cell.set_diff_option(CellDiffOption::ForcedWidth(4))
  inspect(cell.cell_width(), content="4")
  cell.set_diff_option(CellDiffOption::ForcedWidth(0))
  // 非法 0 宽兜底钳为 1（上游 NonZeroU16 语义）喵
  inspect(cell.cell_width(), content="1")
}
