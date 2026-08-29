// `anstyle` crate 桥接（上游 `style/anstyle.rs`）：Ratatui 样式/颜色
// 与 anstyle 生态类型之间的转换喵。
//
// 载体折算登记：MoonBit 无 `anstyle` crate，本文件以最小等价类型
// （AnsiColor/Ansi256Color/RgbColor/AnStyleColor/Effects/AnStyle）
// 承载其语义，转换表逐条对位上游；上游 `From<Color> for
// anstyle::Color` 对 `Color::Reset` panic，按 fail!（Failure）对位，
// 消息逐字一致喵。

///|
/// 转换错误（上游 `TryFromColorError`）：目标类型与颜色类别不符喵。
pub(all) suberror TryFromColorError {
  Ansi256
  Ansi
  RgbColor
} derive(Eq, Debug)

///|
/// anstyle 4-bit 标准色（上游 `anstyle::AnsiColor`）喵。
pub(all) enum AnsiColor {
  Black
  Red
  Green
  Yellow
  Blue
  Magenta
  Cyan
  White
  BrightBlack
  BrightRed
  BrightGreen
  BrightYellow
  BrightBlue
  BrightMagenta
  BrightCyan
  BrightWhite
} derive(Eq, Debug)

///|
/// anstyle 256 色索引（上游 `anstyle::Ansi256Color`）喵。
pub(all) struct Ansi256Color {
  index : Int
} derive(Eq, Debug)

///|
/// anstyle 真彩色（上游 `anstyle::RgbColor`）喵。
pub(all) struct RgbColor {
  r : Int
  g : Int
  b : Int
} derive(Eq, Debug)

///|
/// anstyle 颜色（上游 `anstyle::Color`）喵。
pub(all) enum AnStyleColor {
  Ansi(AnsiColor)
  Ansi256(Ansi256Color)
  Rgb(RgbColor)
} derive(Eq, Debug)

///|
/// anstyle 效果位集（上游 `anstyle::Effects`）：位语义对位喵。
pub(all) struct Effects {
  bits : Int
} derive(Eq, Debug)

///|
pub fn Effects::new() -> Effects {
  { bits: 0 }
}

///|
pub fn Effects::bold() -> Effects {
  { bits: 1 }
}

///|
pub fn Effects::dimmed() -> Effects {
  { bits: 1 << 1 }
}

///|
pub fn Effects::italic() -> Effects {
  { bits: 1 << 2 }
}

///|
pub fn Effects::underline() -> Effects {
  { bits: 1 << 3 }
}

///|
pub fn Effects::double_underline() -> Effects {
  { bits: 1 << 4 }
}

///|
pub fn Effects::curly_underline() -> Effects {
  { bits: 1 << 5 }
}

///|
pub fn Effects::dotted_underline() -> Effects {
  { bits: 1 << 6 }
}

///|
pub fn Effects::dashed_underline() -> Effects {
  { bits: 1 << 7 }
}

///|
pub fn Effects::blink() -> Effects {
  { bits: 1 << 8 }
}

///|
pub fn Effects::invert() -> Effects {
  { bits: 1 << 9 }
}

///|
pub fn Effects::hidden() -> Effects {
  { bits: 1 << 10 }
}

///|
pub fn Effects::strikethrough() -> Effects {
  { bits: 1 << 11 }
}

///|
/// 位并集（上游 `Effects::\|`）喵。
pub fn Effects::union(self : Effects, other : Effects) -> Effects {
  { bits: self.bits.lor(other.bits) }
}

///|
/// 是否含有 other 的全部位（上游 `Effects::contains`）喵。
pub fn Effects::contains(self : Effects, other : Effects) -> Bool {
  self.bits.land(other.bits) == other.bits
}

///|
/// anstyle 样式（上游 `anstyle::Style`）喵。
pub(all) struct AnStyle {
  fg : AnStyleColor?
  bg : AnStyleColor?
  underline_color : AnStyleColor?
  effects : Effects
} derive(Eq, Debug)

///|
pub fn AnStyle::new() -> AnStyle {
  { fg: None, bg: None, underline_color: None, effects: Effects::new() }
}

///|
pub fn AnStyle::fg_color(self : AnStyle, color : AnStyleColor?) -> AnStyle {
  { ..self, fg: color }
}

///|
pub fn AnStyle::bg_color(self : AnStyle, color : AnStyleColor?) -> AnStyle {
  { ..self, bg: color }
}

///|
pub fn AnStyle::underline_color(
  self : AnStyle,
  color : AnStyleColor?,
) -> AnStyle {
  { ..self, underline_color: color }
}

///|
pub fn AnStyle::effects(self : AnStyle, effects : Effects) -> AnStyle {
  { ..self, effects, }
}

///|
pub fn AnStyle::get_fg_color(self : AnStyle) -> AnStyleColor? {
  self.fg
}

///|
pub fn AnStyle::get_bg_color(self : AnStyle) -> AnStyleColor? {
  self.bg
}

///|
pub fn AnStyle::get_underline_color(self : AnStyle) -> AnStyleColor? {
  self.underline_color
}

///|
pub fn AnStyle::get_effects(self : AnStyle) -> Effects {
  self.effects
}

///|
/// `Ansi256Color` → `Color`（上游 `From<Ansi256Color> for Color`）喵。
pub fn Color::of_ansi256_color(color : Ansi256Color) -> Color {
  Indexed(color.index)
}

///|
/// `Color` → `Ansi256Color`（上游 `TryFrom<Color> for Ansi256Color`）：
/// 仅索引色可转喵。
pub fn Ansi256Color::try_from(
  color : Color,
) -> Result[Ansi256Color, TryFromColorError] {
  match color {
    Indexed(index) => Ok({ index, })
    _ => Err(Ansi256)
  }
}

///|
/// `AnsiColor` → `Color`（上游 `From<AnsiColor> for Color`）：
/// BrightBlack 映射 DarkGray、BrightWhite 映射 White 等逐条同构喵。
pub fn Color::of_ansi_color(value : AnsiColor) -> Color {
  match value {
    Black => Black
    Red => Red
    Green => Green
    Yellow => Yellow
    Blue => Blue
    Magenta => Magenta
    Cyan => Cyan
    White => Gray
    BrightBlack => DarkGray
    BrightRed => LightRed
    BrightGreen => LightGreen
    BrightYellow => LightYellow
    BrightBlue => LightBlue
    BrightMagenta => LightMagenta
    BrightCyan => LightCyan
    BrightWhite => White
  }
}

///|
/// `Color` → `AnsiColor`（上游 `TryFrom<Color> for AnsiColor`）：仅
/// 4-bit 色可转喵。
pub fn AnsiColor::try_from(
  color : Color,
) -> Result[AnsiColor, TryFromColorError] {
  match color {
    Black => Ok(Black)
    Red => Ok(Red)
    Green => Ok(Green)
    Yellow => Ok(Yellow)
    Blue => Ok(Blue)
    Magenta => Ok(Magenta)
    Cyan => Ok(Cyan)
    Gray => Ok(White)
    DarkGray => Ok(BrightBlack)
    LightRed => Ok(BrightRed)
    LightGreen => Ok(BrightGreen)
    LightYellow => Ok(BrightYellow)
    LightBlue => Ok(BrightBlue)
    LightMagenta => Ok(BrightMagenta)
    LightCyan => Ok(BrightCyan)
    White => Ok(BrightWhite)
    _ => Err(Ansi)
  }
}

///|
/// `RgbColor` → `Color`（上游 `From<RgbColor> for Color`）喵。
pub fn Color::of_rgb_color(color : RgbColor) -> Color {
  Rgb(color.r, color.g, color.b)
}

///|
/// `Color` → `RgbColor`（上游 `TryFrom<Color> for RgbColor`）：仅
/// 真彩色可转喵。
pub fn RgbColor::try_from(color : Color) -> Result[RgbColor, TryFromColorError] {
  match color {
    Rgb(red, green, blue) => Ok({ r: red, g: green, b: blue })
    _ => Err(RgbColor)
  }
}

///|
/// `AnStyleColor` → `Color`（上游 `From<anstyle::Color> for Color`）喵。
pub fn Color::of_an_style_color(color : AnStyleColor) -> Color {
  match color {
    Ansi(ansi_color) => Color::of_ansi_color(ansi_color)
    Ansi256(ansi256_color) => Color::of_ansi256_color(ansi256_color)
    Rgb(rgb_color) => Color::of_rgb_color(rgb_color)
  }
}

///|
/// `Color` → `AnStyleColor`（上游 `From<Color> for anstyle::Color`）：
/// Reset 无 anstyle 等价物，显式报错喵。
pub fn Color::to_an_style_color(self : Color) -> AnStyleColor raise {
  match self {
    Reset => fail("Color::Reset has no equivalent in anstyle")
    Rgb(_, _, _) =>
      match RgbColor::try_from(self) {
        Ok(c) => Rgb(c)
        Err(e) => raise e
      }
    Indexed(_) =>
      match Ansi256Color::try_from(self) {
        Ok(c) => Ansi256(c)
        Err(e) => raise e
      }
    _ =>
      match AnsiColor::try_from(self) {
        Ok(c) => Ansi(c)
        Err(e) => raise e
      }
  }
}

///|
/// `Effects` → `Modifier`（上游 `From<Effects> for Modifier`）：五类
/// 下划线合并为 UNDERLINED 喵。
pub fn Modifier::of_effects(effect : Effects) -> Modifier {
  let mut modifier = Modifier::empty()
  if effect.contains(Effects::bold()) {
    modifier = modifier.insert(Modifier::bold())
  }
  if effect.contains(Effects::dimmed()) {
    modifier = modifier.insert(Modifier::dim())
  }
  if effect.contains(Effects::italic()) {
    modifier = modifier.insert(Modifier::italic())
  }
  let underlines = effect.contains(Effects::underline()) ||
    effect.contains(Effects::double_underline()) ||
    effect.contains(Effects::curly_underline()) ||
    effect.contains(Effects::dotted_underline()) ||
    effect.contains(Effects::dashed_underline())
  if underlines {
    modifier = modifier.insert(Modifier::underlined())
  }
  if effect.contains(Effects::blink()) {
    modifier = modifier.insert(Modifier::slow_blink())
  }
  if effect.contains(Effects::invert()) {
    modifier = modifier.insert(Modifier::reversed())
  }
  if effect.contains(Effects::hidden()) {
    modifier = modifier.insert(Modifier::hidden())
  }
  if effect.contains(Effects::strikethrough()) {
    modifier = modifier.insert(Modifier::crossed_out())
  }
  modifier
}

///|
/// `Modifier` → `Effects`（上游 `From<Modifier> for Effects`）：
/// SLOW/RAPID_BLINK 合并为 BLINK 喵。
pub fn Effects::of_modifier(modifier : Modifier) -> Effects {
  let mut effects = Effects::new()
  if modifier.contains(Modifier::bold()) {
    effects = effects.union(Effects::bold())
  }
  if modifier.contains(Modifier::dim()) {
    effects = effects.union(Effects::dimmed())
  }
  if modifier.contains(Modifier::italic()) {
    effects = effects.union(Effects::italic())
  }
  if modifier.contains(Modifier::underlined()) {
    effects = effects.union(Effects::underline())
  }
  let blink = modifier.contains(Modifier::slow_blink()) ||
    modifier.contains(Modifier::rapid_blink())
  if blink {
    effects = effects.union(Effects::blink())
  }
  if modifier.contains(Modifier::reversed()) {
    effects = effects.union(Effects::invert())
  }
  if modifier.contains(Modifier::hidden()) {
    effects = effects.union(Effects::hidden())
  }
  if modifier.contains(Modifier::crossed_out()) {
    effects = effects.union(Effects::strikethrough())
  }
  effects
}

///|
/// `AnStyle` → `Style`（上游 `From<anstyle::Style> for Style`）喵。
pub fn Style::of_an_style(style : AnStyle) -> Style {
  {
    fg: style.get_fg_color().map(Color::of_an_style_color),
    bg: style.get_bg_color().map(Color::of_an_style_color),
    add_modifier: Modifier::of_effects(style.get_effects()),
    sub_modifier: Modifier::empty(),
  }
}

///|
/// `Style` → `AnStyle`（上游 `From<Style> for anstyle::Style`）：
/// Reset 色会报错（同 `to_an_style_color`）喵。
pub fn Style::to_an_style(self : Style) -> AnStyle raise {
  let mut out = AnStyle::new()
  match self.fg {
    Some(fg) => out = out.fg_color(Some(fg.to_an_style_color()))
    None => ()
  }
  match self.bg {
    Some(bg) => out = out.bg_color(Some(bg.to_an_style_color()))
    None => ()
  }
  out = out.effects(Effects::of_modifier(self.add_modifier))
  out
}
