// 上游 `logo.rs` 内联测试逐条复刻：rstest 参数矩阵以数组循环承载喵。

///|
/// 上游 `new_size`（tiny/small 两组）喵。
test "Logo 按尺寸构造" {
  let cases = [RatatuiLogoSize::Tiny, RatatuiLogoSize::Small]
  for size in cases {
    let logo = RatatuiLogo::new(size)
    @debug.assert_eq(logo.size, size)
  }
}

///|
/// 上游 `default_logo_is_tiny` 喵。
test "Logo 缺省 Tiny" {
  let logo = RatatuiLogo::default()
  @debug.assert_eq(logo.size, RatatuiLogoSize::Tiny)
}

///|
/// 上游 `set_logo_size_to_small` 喵。
test "Logo 设为 Small" {
  let logo = RatatuiLogo::default().size(RatatuiLogoSize::Small)
  @debug.assert_eq(logo.size, RatatuiLogoSize::Small)
}

///|
/// 上游 `tiny_logo_constant` 喵。
test "Logo tiny 常量构造" {
  let logo = RatatuiLogo::tiny()
  @debug.assert_eq(logo.size, RatatuiLogoSize::Tiny)
}

///|
/// 上游 `small_logo_constant` 喵。
test "Logo small 常量构造" {
  let logo = RatatuiLogo::small()
  @debug.assert_eq(logo.size, RatatuiLogoSize::Small)
}

///|
/// 上游 `render_tiny`：15x2 全幅渲染喵。
test "Logo Tiny 渲染快照" {
  let buf = @core.Buffer::empty(@core.Rect::new(0, 0, 15, 2))
  RatatuiLogo::tiny().render(buf.area, buf)
  assert_eq(
    buf,
    @core.Buffer::with_lines([
      "▛▚▗▀▖▜▘▞▚▝▛▐ ▌▌", "▛▚▐▀▌▐ ▛▜ ▌▝▄▘▌",
    ]),
  )
}

///|
/// 上游 `render_small`：27x2 全幅渲染喵。
test "Logo Small 渲染快照" {
  let buf = @core.Buffer::empty(@core.Rect::new(0, 0, 27, 2))
  RatatuiLogo::small().render(buf.area, buf)
  assert_eq(
    buf,
    @core.Buffer::with_lines([
      "█▀▀▄ ▄▀▀▄▝▜▛▘▄▀▀▄▝▜▛▘█  █ █",
      "█▀▀▄ █▀▀█ ▐▌ █▀▀█ ▐▌ ▀▄▄▀ █",
    ]),
  )
}

///|
/// 上游 `render_in_minimal_buffer`：1x1 缓冲截取首字符（tiny/small
/// 两组）喵。
test "Logo 极小缓冲渲染" {
  let cases = [
    (RatatuiLogoSize::Tiny, @core.Buffer::with_lines(["▛"])),
    (RatatuiLogoSize::Small, @core.Buffer::with_lines(["█"])),
  ]
  for case in cases {
    let (size, expected) = case
    let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 1, 1))
    RatatuiLogo::new(size).render(buffer.area, buffer)
    assert_eq(buffer, expected)
  }
}

///|
/// 上游 `render_in_zero_size_buffer`：零尺寸缓冲不 panic（tiny/small
/// 两组）喵。
test "Logo 零尺寸缓冲渲染" {
  for size in [RatatuiLogoSize::Tiny, RatatuiLogoSize::Small] {
    let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 0, 0))
    RatatuiLogo::new(size).render(buffer.area, buffer)
  }
}
