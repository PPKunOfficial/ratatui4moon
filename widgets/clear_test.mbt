///|
/// Clear 单元测试：复刻 ratatui-v0.30.2 `widgets/clear.rs` 内联测试清单喵。

///|
/// 上游 render：区域内格子复位、区域外保留喵。
test "Clear 清空区域" {
  let buffer = @core.Buffer::with_lines([
    "xxxxxxxxxxxxxxx", "xxxxxxxxxxxxxxx", "xxxxxxxxxxxxxxx", "xxxxxxxxxxxxxxx", "xxxxxxxxxxxxxxx",
    "xxxxxxxxxxxxxxx", "xxxxxxxxxxxxxxx",
  ])
  Clear::new().render(@core.Rect::new(1, 2, 3, 4), buffer)
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "xxxxxxxxxxxxxxx", "xxxxxxxxxxxxxxx", "x   xxxxxxxxxxx", "x   xxxxxxxxxxx",
      "x   xxxxxxxxxxx", "x   xxxxxxxxxxx", "xxxxxxxxxxxxxxx",
    ]),
  )
}

///|
/// 上游 render_partially_out_of_bounds：越界部分裁剪到缓冲喵。
test "Clear 部分越界裁剪" {
  let buffer = @core.Buffer::with_lines([
    "xxxxxxxxxxxxxxx", "xxxxxxxxxxxxxxx", "xxxxxxxxxxxxxxx", "xxxxxxxxxxxxxxx", "xxxxxxxxxxxxxxx",
    "xxxxxxxxxxxxxxx", "xxxxxxxxxxxxxxx",
  ])
  Clear::new().render(@core.Rect::new(2, 0, 100, 100), buffer)
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "xx             ", "xx             ", "xx             ", "xx             ",
      "xx             ", "xx             ", "xx             ",
    ]),
  )
}

///|
/// 上游 render_fully_out_of_bounds：完全越界为无操作喵。
test "Clear 完全越界无操作" {
  let buffer = @core.Buffer::with_lines([
    "xxxxxxxxxxxxxxx", "xxxxxxxxxxxxxxx", "xxxxxxxxxxxxxxx", "xxxxxxxxxxxxxxx", "xxxxxxxxxxxxxxx",
    "xxxxxxxxxxxxxxx", "xxxxxxxxxxxxxxx",
  ])
  Clear::new().render(@core.Rect::new(100, 0, 100, 100), buffer)
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "xxxxxxxxxxxxxxx", "xxxxxxxxxxxxxxx", "xxxxxxxxxxxxxxx", "xxxxxxxxxxxxxxx",
      "xxxxxxxxxxxxxxx", "xxxxxxxxxxxxxxx", "xxxxxxxxxxxxxxx",
    ]),
  )
}
