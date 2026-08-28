///|
/// Stylize 速记单元测试：复刻 ratatui-v0.30.2 `style/stylize.rs` 与
/// `style.rs` 中速记相关测试清单喵。
///
/// 上游 `Stylize` trait 对 Cell/Line/Span/Text 等类型的批量实现
/// 由 `set_style`/`patch_style` 组合覆盖，速记本体落在本文件喵。

///|
/// 上游 fg_can_be_stylized（16 组）喵。
test "前景色速记" {
  let cases = [
    (Style::new().black(), Color::Black),
    (Style::new().red(), Color::Red),
    (Style::new().green(), Color::Green),
    (Style::new().yellow(), Color::Yellow),
    (Style::new().blue(), Color::Blue),
    (Style::new().magenta(), Color::Magenta),
    (Style::new().cyan(), Color::Cyan),
    (Style::new().gray(), Color::Gray),
    (Style::new().dark_gray(), Color::DarkGray),
    (Style::new().light_red(), Color::LightRed),
    (Style::new().light_green(), Color::LightGreen),
    (Style::new().light_yellow(), Color::LightYellow),
    (Style::new().light_blue(), Color::LightBlue),
    (Style::new().light_magenta(), Color::LightMagenta),
    (Style::new().light_cyan(), Color::LightCyan),
    (Style::new().white(), Color::White),
  ]
  for case in cases {
    let (stylized, color) = case
    @debug.assert_eq(stylized, Style::new().fg(color))
  }
}

///|
/// 上游 bg_can_be_stylized（16 组）喵。
test "背景色速记" {
  let cases = [
    (Style::new().on_black(), Color::Black),
    (Style::new().on_red(), Color::Red),
    (Style::new().on_green(), Color::Green),
    (Style::new().on_yellow(), Color::Yellow),
    (Style::new().on_blue(), Color::Blue),
    (Style::new().on_magenta(), Color::Magenta),
    (Style::new().on_cyan(), Color::Cyan),
    (Style::new().on_gray(), Color::Gray),
    (Style::new().on_dark_gray(), Color::DarkGray),
    (Style::new().on_light_red(), Color::LightRed),
    (Style::new().on_light_green(), Color::LightGreen),
    (Style::new().on_light_yellow(), Color::LightYellow),
    (Style::new().on_light_blue(), Color::LightBlue),
    (Style::new().on_light_magenta(), Color::LightMagenta),
    (Style::new().on_light_cyan(), Color::LightCyan),
    (Style::new().on_white(), Color::White),
  ]
  for case in cases {
    let (stylized, color) = case
    @debug.assert_eq(stylized, Style::new().bg(color))
  }
}

///|
/// 上游 add_modifier_can_be_stylized（9 组）喵。
test "修饰位速记" {
  let cases = [
    (Style::new().bold(), Modifier::bold()),
    (Style::new().dim(), Modifier::dim()),
    (Style::new().italic(), Modifier::italic()),
    (Style::new().underlined(), Modifier::underlined()),
    (Style::new().slow_blink(), Modifier::slow_blink()),
    (Style::new().rapid_blink(), Modifier::rapid_blink()),
    (Style::new().reversed(), Modifier::reversed()),
    (Style::new().hidden(), Modifier::hidden()),
    (Style::new().crossed_out(), Modifier::crossed_out()),
  ]
  for case in cases {
    let (stylized, modifier) = case
    @debug.assert_eq(stylized, Style::new().add_modifier(modifier))
  }
}

///|
/// 上游 remove_modifier_can_be_stylized（9 组）喵。
test "否定修饰位速记" {
  let cases = [
    (Style::new().not_bold(), Modifier::bold()),
    (Style::new().not_dim(), Modifier::dim()),
    (Style::new().not_italic(), Modifier::italic()),
    (Style::new().not_underlined(), Modifier::underlined()),
    (Style::new().not_slow_blink(), Modifier::slow_blink()),
    (Style::new().not_rapid_blink(), Modifier::rapid_blink()),
    (Style::new().not_reversed(), Modifier::reversed()),
    (Style::new().not_hidden(), Modifier::hidden()),
    (Style::new().not_crossed_out(), Modifier::crossed_out()),
  ]
  for case in cases {
    let (stylized, modifier) = case
    @debug.assert_eq(stylized, Style::new().remove_modifier(modifier))
  }
}

///|
/// 上游 reset_can_be_stylized喵。
test "复位速记" {
  @debug.assert_eq(Style::new().reset_style(), Style::reset())
}

///|
/// 上游 style.rs debug 测试：速记链 Debug 呈现喵。
test "Style::to_debug 速记链" {
  inspect(Style::new().to_debug(), content="Style::new()")
  inspect(Style::new().red().to_debug(), content="Style::new().red()")
  inspect(Style::new().on_blue().to_debug(), content="Style::new().on_blue()")
  inspect(Style::new().bold().to_debug(), content="Style::new().bold()")
  inspect(
    Style::new().not_italic().to_debug(),
    content="Style::new().not_italic()",
  )
  inspect(
    Style::new()
    .red()
    .on_blue()
    .bold()
    .italic()
    .not_dim()
    .not_hidden()
    .to_debug(),
    content="Style::new().red().on_blue().bold().italic().not_dim().not_hidden()",
  )
}

///|
/// 上游 stylize_debug_foreground：命名色走速记、Reset/Indexed/Rgb
/// 走 `.fg(Color::…)` 显式形式喵。
test "Style::to_debug 前景显式形式" {
  inspect(
    Style::new().fg(Indexed(10)).to_debug(),
    content="Style::new().fg(Color::Indexed(10))",
  )
  inspect(
    Style::new().fg(Rgb(255, 0, 0)).to_debug(),
    content="Style::new().fg(Color::Rgb(255, 0, 0))",
  )
  inspect(
    Style::new().fg(Reset).to_debug(),
    content="Style::new().fg(Color::Reset)",
  )
}

///|
/// 上游 stylize_debug_background：背景形式喵。
test "Style::to_debug 背景显式形式" {
  inspect(
    Style::new().bg(Indexed(10)).to_debug(),
    content="Style::new().bg(Color::Indexed(10))",
  )
  inspect(
    Style::new().bg(Rgb(255, 0, 0)).to_debug(),
    content="Style::new().bg(Color::Rgb(255, 0, 0))",
  )
}
