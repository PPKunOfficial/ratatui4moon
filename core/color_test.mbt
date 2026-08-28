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

///|
/// 上游 from_ansi_color：命名色与别名/分隔符容错喵。
test "Color::from_str 命名与别名" {
  @debug.assert_eq(Color::from_str("reset"), Some(Reset))
  @debug.assert_eq(Color::from_str("black"), Some(Black))
  @debug.assert_eq(Color::from_str("red"), Some(Red))
  @debug.assert_eq(Color::from_str("green"), Some(Green))
  @debug.assert_eq(Color::from_str("yellow"), Some(Yellow))
  @debug.assert_eq(Color::from_str("blue"), Some(Blue))
  @debug.assert_eq(Color::from_str("magenta"), Some(Magenta))
  @debug.assert_eq(Color::from_str("cyan"), Some(Cyan))
  @debug.assert_eq(Color::from_str("gray"), Some(Gray))
  @debug.assert_eq(Color::from_str("darkgray"), Some(DarkGray))
  @debug.assert_eq(Color::from_str("lightred"), Some(LightRed))
  @debug.assert_eq(Color::from_str("lightgreen"), Some(LightGreen))
  @debug.assert_eq(Color::from_str("lightyellow"), Some(LightYellow))
  @debug.assert_eq(Color::from_str("lightblue"), Some(LightBlue))
  @debug.assert_eq(Color::from_str("lightmagenta"), Some(LightMagenta))
  @debug.assert_eq(Color::from_str("lightcyan"), Some(LightCyan))
  @debug.assert_eq(Color::from_str("white"), Some(White))
  // 别名喵
  @debug.assert_eq(Color::from_str("lightblack"), Some(DarkGray))
  @debug.assert_eq(Color::from_str("lightwhite"), Some(White))
  @debug.assert_eq(Color::from_str("lightgray"), Some(White))
  // silver = grey = gray 喵
  @debug.assert_eq(Color::from_str("grey"), Some(Gray))
  @debug.assert_eq(Color::from_str("silver"), Some(Gray))
  // 空格分隔被忽略喵
  @debug.assert_eq(Color::from_str("light black"), Some(DarkGray))
  @debug.assert_eq(Color::from_str("light white"), Some(White))
  @debug.assert_eq(Color::from_str("light gray"), Some(White))
  // 连字符被忽略喵
  @debug.assert_eq(Color::from_str("light-black"), Some(DarkGray))
  @debug.assert_eq(Color::from_str("light-white"), Some(White))
  @debug.assert_eq(Color::from_str("light-gray"), Some(White))
  // 下划线被忽略喵
  @debug.assert_eq(Color::from_str("light_black"), Some(DarkGray))
  @debug.assert_eq(Color::from_str("light_white"), Some(White))
  @debug.assert_eq(Color::from_str("light_gray"), Some(White))
  // bright = light 喵
  @debug.assert_eq(Color::from_str("bright-black"), Some(DarkGray))
  @debug.assert_eq(Color::from_str("bright-white"), Some(White))
  @debug.assert_eq(Color::from_str("brightblack"), Some(DarkGray))
  @debug.assert_eq(Color::from_str("brightwhite"), Some(White))
}

///|
/// 上游 from_rgb_color / from_indexed_color喵。
test "Color::from_str 真彩与索引" {
  @debug.assert_eq(Color::from_str("#FF0000"), Some(Color::Rgb(255, 0, 0)))
  @debug.assert_eq(Color::from_str("10"), Some(Color::Indexed(10)))
}

///|
/// 上游 from_invalid_colors：非法输入全部拒绝喵。
test "Color::from_str 非法输入" {
  let bad_colors = [
    "invalid_color", "abcdef0", " bcdefa", "#abcdef00", "#1🦀2", "resets", "lightblackk",
  ]
  for bad in bad_colors {
    inspect(Color::from_str(bad) is None, content="true")
  }
}
