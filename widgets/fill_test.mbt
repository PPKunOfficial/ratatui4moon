///|
/// Fill 单元测试：复刻 ratatui-v0.30.2 `widgets/fill.rs` 内联测试清单喵。
///
/// 上游 `Fill::new` 的 `Cow<str>` 双形态在 MoonBit 统一为 `String`，
/// `accepts_owned_string_symbol` 与字面量形态合并承载喵。

///|
/// 上游 fills_area_with_symbol_and_style：符号铺区 + 样式逐格 patch 喵。
test "Fill 符号与样式填充" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 5, 3))
  Fill::new(".")
  .style(@core.Style::new().fg(@core.Color::Red))
  .render(@core.Rect::new(1, 1, 3, 1), buffer)
  let expected = @core.Buffer::with_lines(["     ", " ... ", "     "])
  for x in 1..<=3 {
    match expected.mut_cell(x, 1) {
      Some(cell) => cell.set_style(@core.Style::new().fg(@core.Color::Red))
      None => ()
    }
  }
  @debug.assert_eq(buffer, expected)
}

///|
/// 上游 clips_area_to_buffer：渲染区域越过缓冲右/下缘时裁剪喵。
test "Fill 越界裁剪" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 3, 2))
  Fill::new("x").render(@core.Rect::new(1, 1, 100, 100), buffer)
  assert_eq(buffer, @core.Buffer::with_lines(["   ", " xx"]))
}

///|
/// 上游 render_fully_out_of_bounds_is_noop：完全越界为无操作喵。
test "Fill 完全越界无操作" {
  let buffer = @core.Buffer::with_lines(["xxxxx", "xxxxx", "xxxxx"])
  Fill::new(".").render(@core.Rect::new(100, 100, 5, 5), buffer)
  assert_eq(buffer, @core.Buffer::with_lines(["xxxxx", "xxxxx", "xxxxx"]))
}

///|
/// 上游 renders_with_offset_buffer_area：非零原点缓冲求交正确喵。
test "Fill 非零原点缓冲" {
  let buffer = @core.Buffer::empty(@core.Rect::new(2, 2, 2, 2))
  Fill::new("#").render(@core.Rect::new(0, 0, 4, 4), buffer)
  let expected = @core.Buffer::empty(@core.Rect::new(2, 2, 2, 2))
  for y in 2..<4 {
    for x in 2..<4 {
      match expected.mut_cell(x, y) {
        Some(cell) => cell.set_symbol("#")
        None => ()
      }
    }
  }
  @debug.assert_eq(buffer, expected)
}

///|
/// 上游 stylize_shorthand_works：速记样式组合（本库经 style 构造
/// 等价承载）喵。
test "Fill 样式速记" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 2, 1))
  Fill::new("*")
  .style(@core.Style::new().blue().bold())
  .render(@core.Rect::new(0, 0, 2, 1), buffer)
  let expected = @core.Buffer::with_lines(["**"])
  for x in 0..<2 {
    match expected.mut_cell(x, 0) {
      Some(cell) =>
        cell.set_style(@core.Style::new().fg(@core.Color::Blue).bold())
      None => ()
    }
  }
  @debug.assert_eq(buffer, expected)
}

///|
/// 上游 accepts_owned_string_symbol + symbol_setter_replaces_symbol：
/// 符号替换喵。
test "Fill 替换符号" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 2, 1))
  Fill::new("a").symbol("•").render(@core.Rect::new(0, 0, 2, 1), buffer)
  assert_eq(buffer, @core.Buffer::with_lines(["••"]))
}
