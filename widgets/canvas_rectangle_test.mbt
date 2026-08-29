// 上游 `canvas/rectangle.rs` 内联测试逐条复刻喵。

///|
/// 渲染辅助：10x10 边界内画满幅红矩形喵。
fn rectangle_render_with(
  marker : @core.Marker,
  rect : @core.Rect,
) -> @core.Buffer {
  let buffer = @core.Buffer::empty(rect)
  let canvas = Canvas::default()
    .marker(marker)
    .x_bounds((0.0, 10.0))
    .y_bounds((0.0, 10.0))
    .paint(ctx => {
      ctx.draw(CanvasRectangle::new(0.0, 0.0, 10.0, 10.0, @core.Red))
    })
  canvas.render(buffer.area, buffer)
  buffer
}

///|
/// 上游 `draw_block_lines`：Block 标记整格覆盖 + 背景着色喵。
test "Rectangle Block 描边" {
  let expected = @core.Buffer::with_lines([
    "██████████", "█        █", "█        █", "█        █",
    "█        █", "█        █", "█        █", "█        █", "█        █",
    "██████████",
  ])
  let rect = @core.Rect::new(0, 0, 10, 10)
  expected.set_style(rect, @core.Style::new().fg(@core.Red).bg(@core.Red))
  expected.set_style(rect.inner(@core.Margin::new(1, 1)), @core.Style::reset())
  let rendered = rectangle_render_with(@core.Block, rect)
  assert_eq(expected, rendered)
}

///|
/// 上游 `draw_half_block_lines`：HalfBlock 上下半块双色承载喵。
test "Rectangle HalfBlock 描边" {
  let expected = @core.Buffer::with_lines([
    "█▀▀▀▀▀▀▀▀█", "█        █", "█        █", "█        █",
    "█        █", "█        █", "█        █", "█        █", "█        █",
    "█▄▄▄▄▄▄▄▄█",
  ])
  let rect = @core.Rect::new(0, 0, 10, 10)
  expected.set_style(rect, @core.Style::new().fg(@core.Red).bg(@core.Red))
  expected.set_style(
    rect.inner(@core.Margin::new(1, 0)),
    @core.Style::reset().fg(@core.Red),
  )
  expected.set_style(rect.inner(@core.Margin::new(1, 1)), @core.Style::reset())
  let rendered = rectangle_render_with(@core.HalfBlock, rect)
  assert_eq(expected, rendered)
}

///|
/// 上游 `draw_braille_lines`：双层矩形嵌套，逐层前景色喵。
test "Rectangle Braille 嵌套描边" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 10, 10))
  let canvas = Canvas::default()
    .marker(@core.Braille)
    .x_bounds((0.0, 20.0))
    .y_bounds((0.0, 20.0))
    .paint(ctx => {
      // 外圈矩形喵。
      ctx.draw(CanvasRectangle::new(0.0, 0.0, 20.0, 20.0, @core.Red))
      // 内圈矩形喵。
      ctx.draw(CanvasRectangle::new(4.0, 4.0, 12.0, 12.0, @core.Green))
    })
  canvas.render(buffer.area, buffer)
  let expected = @core.Buffer::with_lines([
    "⡏⠉⠉⠉⠉⠉⠉⠉⠉⢹", "⡇        ⢸", "⡇ ⡏⠉⠉⠉⠉⢹ ⢸",
    "⡇ ⡇    ⢸ ⢸", "⡇ ⡇    ⢸ ⢸", "⡇ ⡇    ⢸ ⢸", "⡇ ⡇    ⢸ ⢸",
    "⡇ ⣇⣀⣀⣀⣀⣸ ⢸", "⡇        ⢸", "⣇⣀⣀⣀⣀⣀⣀⣀⣀⣸",
  ])
  expected.set_style(buffer.area, @core.Style::new().fg(@core.Red))
  expected.set_style(
    buffer.area.inner(@core.Margin::new(1, 1)),
    @core.Style::reset(),
  )
  expected.set_style(
    buffer.area.inner(@core.Margin::new(2, 2)),
    @core.Style::new().fg(@core.Green),
  )
  expected.set_style(
    buffer.area.inner(@core.Margin::new(3, 3)),
    @core.Style::reset(),
  )
  assert_eq(buffer, expected)
}

///|
/// 上游 `draw_x_lines`：Custom('×') 喵。
test "Rectangle 自定义 × 描边" {
  let expected = @core.Buffer::with_lines([
    "××××××××××", "×        ×", "×        ×", "×        ×", "×        ×",
    "×        ×", "×        ×", "×        ×", "×        ×", "××××××××××",
  ])
  let rect = @core.Rect::new(0, 0, 10, 10)
  expected.set_style(rect, @core.Style::new().fg(@core.Red))
  expected.set_style(
    rect.inner(@core.Margin::new(1, 0)),
    @core.Style::reset().fg(@core.Red),
  )
  expected.set_style(rect.inner(@core.Margin::new(1, 1)), @core.Style::reset())
  let rendered = rectangle_render_with(@core.Custom('×'), rect)
  assert_eq(expected, rendered)
}

///|
/// 上游 `draw_plus_lines`：Custom('+') 喵。
test "Rectangle 自定义 + 描边" {
  let expected = @core.Buffer::with_lines([
    "++++++++++", "+        +", "+        +", "+        +", "+        +", "+        +",
    "+        +", "+        +", "+        +", "++++++++++",
  ])
  let rect = @core.Rect::new(0, 0, 10, 10)
  expected.set_style(rect, @core.Style::new().fg(@core.Red))
  expected.set_style(
    rect.inner(@core.Margin::new(1, 0)),
    @core.Style::reset().fg(@core.Red),
  )
  expected.set_style(rect.inner(@core.Margin::new(1, 1)), @core.Style::reset())
  let rendered = rectangle_render_with(@core.Custom('+'), rect)
  assert_eq(expected, rendered)
}
