// Canvas 集成黄金用例：复刻 ratatui-v0.30.2
// `ratatui/tests/widgets_canvas.rs` 全部 1 条测试喵。
//
// 上游经 Terminal/TestBackend/assert_buffer 驱动；terminal 会话层
// 未复刻前以等价的"直渲染 + Buffer 全量比对"承载（被测行为一致）。

///|
/// 上游 `widgets_canvas_draw_labels`：世界坐标标签落位与背景/
/// 前景着色喵。
test "Canvas 标签绘制与着色" {
  let buf = @core.Buffer::empty(@core.Rect::new(0, 0, 5, 5))
  let canvas = Canvas::default()
    .background_color(@core.Yellow)
    .x_bounds((0.0, 5.0))
    .y_bounds((0.0, 5.0))
    .paint(ctx => {
      ctx.print(
        0.0,
        0.0,
        @core.Line::of_span(
          @core.Span::styled("test", @core.Style::new().fg(@core.Blue)),
        ),
      )
    })
  canvas.render(buf.area, buf)
  let expected = @core.Buffer::with_lines([
    "     ", "     ", "     ", "     ", "test ",
  ])
  for row in 0..<5 {
    for col in 0..<5 {
      match expected.mut_cell(col, row) {
        Some(cell) => cell.set_bg(@core.Yellow)
        None => ()
      }
    }
  }
  for col in 0..<4 {
    match expected.mut_cell(col, 4) {
      Some(cell) => cell.set_fg(@core.Blue)
      None => ()
    }
  }
  assert_eq(buf, expected)
}
