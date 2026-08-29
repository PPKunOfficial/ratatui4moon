// 上游 `style/anstyle.rs` 内联测试逐条复刻（strum/anstyle 类型以
// 本包最小等价类型承载，见 anstyle.mbt 头登记）喵。

///|
/// 上游 `anstyle_to_color` 喵。
test "Ansi256Color → Color" {
  @debug.assert_eq(Color::of_ansi256_color({ index: 42 }), Indexed(42))
}

///|
/// 上游 `color_to_ansi256color` 喵。
test "Color → Ansi256Color 成功" {
  @debug.assert_eq(Ansi256Color::try_from(Indexed(42)), Ok({ index: 42 }))
}

///|
/// 上游 `color_to_ansi256color_error` 喵。
test "Color → Ansi256Color 失败" {
  @debug.assert_eq(Ansi256Color::try_from(Rgb(0, 0, 0)), Err(Ansi256))
}

///|
/// 上游 `ansi_color_to_color` 喵。
test "AnsiColor → Color" {
  @debug.assert_eq(Color::of_ansi_color(AnsiColor::Red), Red)
}

///|
/// 上游 `color_to_ansicolor` 喵。
test "Color → AnsiColor 成功" {
  @debug.assert_eq(AnsiColor::try_from(Red), Ok(AnsiColor::Red))
}

///|
/// 上游 `color_to_ansicolor_error` 喵。
test "Color → AnsiColor 失败" {
  @debug.assert_eq(AnsiColor::try_from(Rgb(0, 0, 0)), Err(Ansi))
}

///|
/// 上游 `rgb_color_to_color` 喵。
test "RgbColor → Color" {
  @debug.assert_eq(Color::of_rgb_color({ r: 255, g: 0, b: 0 }), Rgb(255, 0, 0))
}

///|
/// 上游 `color_to_rgbcolor` 喵。
test "Color → RgbColor 成功" {
  @debug.assert_eq(
    RgbColor::try_from(Rgb(255, 0, 0)),
    Ok({ r: 255, g: 0, b: 0 }),
  )
}

///|
/// 上游 `color_to_rgbcolor_error` 喵。
test "Color → RgbColor 失败" {
  @debug.assert_eq(RgbColor::try_from(Indexed(42)), Err(RgbColor))
}

///|
/// 上游 `effects_to_modifier` 喵。
test "Effects → Modifier" {
  let effects = Effects::new().union(Effects::bold()).union(Effects::italic())
  let modifier = Modifier::of_effects(effects)
  inspect(modifier.contains(Modifier::bold()), content="true")
  inspect(modifier.contains(Modifier::italic()), content="true")
}

///|
/// 上游 `modifier_to_effects` 喵。
test "Modifier → Effects" {
  let modifier = Modifier::empty()
    .insert(Modifier::bold())
    .insert(Modifier::italic())
  let effects = Effects::of_modifier(modifier)
  inspect(effects.contains(Effects::bold()), content="true")
  inspect(effects.contains(Effects::italic()), content="true")
}

///|
/// 上游 `anstyle_style_to_style` 喵。
test "AnStyle → Style" {
  let anstyle_style = AnStyle::new()
    .fg_color(Some(AnStyleColor::Ansi(AnsiColor::Red)))
    .bg_color(Some(AnStyleColor::Ansi(AnsiColor::Blue)))
    .underline_color(Some(AnStyleColor::Ansi(AnsiColor::Green)))
    .effects(Effects::new().union(Effects::bold()).union(Effects::italic()))
  let style = Style::of_an_style(anstyle_style)
  @debug.assert_eq(style.fg, Some(Red))
  @debug.assert_eq(style.bg, Some(Blue))
  inspect(style.add_modifier.contains(Modifier::bold()), content="true")
  inspect(style.add_modifier.contains(Modifier::italic()), content="true")
}

///|
/// 上游 `style_to_anstyle_style` 喵。
test "Style → AnStyle" {
  let style = {
    ..Style::new(),
    fg: Some(Color::Red),
    bg: Some(Color::Blue),
    add_modifier: Modifier::empty()
    .insert(Modifier::bold())
    .insert(Modifier::italic()),
  }
  let anstyle_style = style.to_an_style()
  @debug.assert_eq(
    anstyle_style.get_fg_color(),
    Some(AnStyleColor::Ansi(AnsiColor::Red)),
  )
  @debug.assert_eq(
    anstyle_style.get_bg_color(),
    Some(AnStyleColor::Ansi(AnsiColor::Blue)),
  )
  inspect(anstyle_style.get_effects().contains(Effects::bold()), content="true")
  inspect(
    anstyle_style.get_effects().contains(Effects::italic()),
    content="true",
  )
}

///|
/// 上游 `converting_reset_panics_explicitly`：Reset 无 anstyle 等价
/// 物，显式报错（panic 以 Failure 对位，消息逐字一致）喵。
test "Reset 转换显式报错" {
  let mut hit = false
  try {
    let _ = Color::Reset.to_an_style_color()
  } catch {
    Failure(text) => {
      hit = text.contains("Color::Reset has no equivalent in anstyle")
      inspect(hit, content="true")
    }
    _ => ()
  }
  inspect(hit, content="true")
}
