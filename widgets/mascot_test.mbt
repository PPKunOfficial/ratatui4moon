// 上游 `mascot.rs` 内联测试逐条复刻喵。

///|
/// 上游 `new_mascot` 喵。
test "Mascot 缺省眼睛状态" {
  let mascot = RatatuiMascot::new()
  @debug.assert_eq(mascot.eye_state, MascotEyeColor::Default)
}

///|
/// 上游 `set_eye_color`：眨眼后眼睛格背景为 196 号索引色喵。
test "Mascot 设眨眼颜色" {
  let buf = @core.Buffer::empty(@core.Rect::new(0, 0, 32, 16))
  let mascot = RatatuiMascot::new().set_eye(MascotEyeColor::Red)
  mascot.render(buf.area, buf)
  @debug.assert_eq(mascot.eye_state, MascotEyeColor::Red)
  @debug.assert_eq(buf.get(21, 5).bg, @core.Indexed(196))
}

///|
/// 上游 `render_mascot`：32x16 全幅渲染，符号序列与期望逐格一致喵。
test "Mascot 全幅渲染快照" {
  let mascot = RatatuiMascot::new()
  let buf = @core.Buffer::empty(@core.Rect::new(0, 0, 32, 16))
  mascot.render(buf.area, buf)
  inspect(buf.area.as_size().width, content="32")
  inspect(buf.area.as_size().height, content="16")
  @debug.assert_eq(buf.get(21, 5).bg, @core.Indexed(236))
  let actual = StringBuilder()
  for cell in buf.cells {
    actual.write_string(cell.symbol())
  }
  let expected_buf = @core.Buffer::with_lines([
    "             ▄▄███              ", "           ▄███████             ",
    "         ▄█████████             ", "        ████████████            ",
    "        ▀███████████▀   ▄▄██████",
    "              ▀███▀▄█▀▀████████ ", "            ▄▄▄▄▀▄████████████  ",
    "           ████████████████     ", "           ▀███▀██████████      ",
    "         ▄▀▀▄   █████████       ", "       ▄▀ ▄  ▀▄▀█████████       ",
    "     ▄▀  ▀▀    ▀▄▀███████       ", "   ▄▀      ▄▄    ▀▄▀█████████   ",
    " ▄▀         ▀▀     ▀▄▀██▀  ███  ", "█                    ▀▄▀  ▄██   ",
    " ▀▄                    ▀▄▀█     ",
  ])
  let expected = StringBuilder()
  for cell in expected_buf.cells {
    expected.write_string(cell.symbol())
  }
  assert_eq(actual.to_string(), expected.to_string())
}

///|
/// 上游 `render_in_minimal_buffer`：1x1 缓冲不 panic 喵。
test "Mascot 极小缓冲渲染" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 1, 1))
  let mascot = RatatuiMascot::new()
  mascot.render(buffer.area, buffer)
  assert_eq(buffer, @core.Buffer::with_lines([" "]))
}

///|
/// 上游 `render_in_zero_size_buffer`：零尺寸缓冲不 panic 喵。
test "Mascot 零尺寸缓冲渲染" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 0, 0))
  let mascot = RatatuiMascot::new()
  mascot.render(buffer.area, buffer)
}
