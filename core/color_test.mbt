///|
/// Color 单元测试：复刻 ratatui-v0.30.2 `style/color.rs` 测试清单喵。
///
/// 上游 `FromStr` 解析（含别名/分隔符容错）、palette（HSL/HSLuv）转换
/// 与 serde 序列化属独立工具面，登记待复刻喵。

///|
/// 上游 from_u32：0xRRGGBB 拆分三通道喵。
test "Color::from_u32" {
  @debug.assert_eq(Color::from_u32(0x000000), Color::Rgb(0, 0, 0))
  @debug.assert_eq(Color::from_u32(0xFF0000), Color::Rgb(255, 0, 0))
  @debug.assert_eq(Color::from_u32(0x00FF00), Color::Rgb(0, 255, 0))
  @debug.assert_eq(Color::from_u32(0x0000FF), Color::Rgb(0, 0, 255))
  @debug.assert_eq(Color::from_u32(0xFFFFFF), Color::Rgb(255, 255, 255))
}

///|
/// 上游 display：命名色变体名 / Indexed 纯数字 / Rgb 十六进制喵。
test "Color::to_display" {
  inspect(Color::Black.to_display(), content="Black")
  inspect(Color::Red.to_display(), content="Red")
  inspect(Color::Green.to_display(), content="Green")
  inspect(Color::Yellow.to_display(), content="Yellow")
  inspect(Color::Blue.to_display(), content="Blue")
  inspect(Color::Magenta.to_display(), content="Magenta")
  inspect(Color::Cyan.to_display(), content="Cyan")
  inspect(Color::Gray.to_display(), content="Gray")
  inspect(Color::DarkGray.to_display(), content="DarkGray")
  inspect(Color::LightRed.to_display(), content="LightRed")
  inspect(Color::LightGreen.to_display(), content="LightGreen")
  inspect(Color::LightYellow.to_display(), content="LightYellow")
  inspect(Color::LightBlue.to_display(), content="LightBlue")
  inspect(Color::LightMagenta.to_display(), content="LightMagenta")
  inspect(Color::LightCyan.to_display(), content="LightCyan")
  inspect(Color::White.to_display(), content="White")
  inspect(Color::Indexed(10).to_display(), content="10")
  inspect(Color::Rgb(255, 0, 0).to_display(), content="#FF0000")
  inspect(Color::Reset.to_display(), content="Reset")
}

///|
/// Rgb 分量在 0–255 内裁剪（含低位十六进制补零）喵。
test "Color::Rgb 边界分量" {
  inspect(Color::Rgb(0, 15, 255).to_display(), content="#000FFF")
  // 0x12345 超出 24 位，按 RRGGBB 对齐后为 Rgb(0x01, 0x23, 0x45)
  @debug.assert_eq(
    Color::from_u32(0x12345).to_display(),
    Color::Rgb(1, 0x23, 0x45).to_display(),
  )
}
