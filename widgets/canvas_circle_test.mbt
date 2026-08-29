// 上游 `canvas/circle.rs` 内联测试复刻喵。

///|
/// 上游 `test_it_draws_a_circle`：盲文标记下的圆周描点喵。
test "Circle 盲文圆周描点" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 10, 5))
  let canvas = Canvas::default()
    .paint(ctx => ctx.draw(Circle::new(5.0, 2.0, 5.0, @core.Reset)))
    .marker(@core.Braille)
    .x_bounds((-10.0, 10.0))
    .y_bounds((-10.0, 10.0))
  canvas.render(buffer.area, buffer)
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "      ⣀⣀⣀ ", "     ⡞⠁ ⠈⢣", "     ⢇⡀ ⢀⡼", "      ⠉⠉⠉ ",
      "          ",
    ]),
  )
}
