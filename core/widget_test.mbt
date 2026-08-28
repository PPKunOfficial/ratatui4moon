///|
/// Widget / StatefulWidget trait 单元测试：复刻 ratatui-v0.30.2
/// `widgets/widget.rs` 与 `widgets/stateful_widget.rs` 测试清单喵。

///|
/// 上游 render_str：String 直接渲染（宽度截断到区域）喵。
test "Widget for String 渲染" {
  let buf = Buffer::empty(Rect::new(0, 0, 20, 1))
  Widget::render("hello world", buf.area, buf)
  @debug.assert_eq(buf, Buffer::with_lines(["hello world         "]))
}

///|
/// 上游 render_str_truncate：超宽内容按区域宽度截断喵。
test "Widget for String 截断" {
  let buf = Buffer::empty(Rect::new(0, 0, 20, 1))
  let area = Rect::new(buf.area.x, buf.area.y, 11, buf.area.height)
  Widget::render("hello world, just hello", area, buf)
  @debug.assert_eq(buf, Buffer::with_lines(["hello world         "]))
}
