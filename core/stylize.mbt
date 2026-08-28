///|
/// 样式速记（上游 `style::Stylize` trait 对 `Style` 的实现面）：
/// 16 组前景色、16 组背景色、9 组修饰位与其否定形式喵。
///
/// 上游以宏为 Cell/Line/Span/Text 等多种类型批量实现速记；本库
/// 先落到 `Style`（其余类型经 `set_style`/`patch_style` 组合）喵。

///|
/// 前景色设为黑（上游 `.black()`）喵。
pub fn Style::black(self : Style) -> Style {
  self.fg(Black)
}

///|
/// 前景色设为红喵。
pub fn Style::red(self : Style) -> Style {
  self.fg(Red)
}

///|
/// 前景色设为绿喵。
pub fn Style::green(self : Style) -> Style {
  self.fg(Green)
}

///|
/// 前景色设为黄喵。
pub fn Style::yellow(self : Style) -> Style {
  self.fg(Yellow)
}

///|
/// 前景色设为蓝喵。
pub fn Style::blue(self : Style) -> Style {
  self.fg(Blue)
}

///|
/// 前景色设为品红喵。
pub fn Style::magenta(self : Style) -> Style {
  self.fg(Magenta)
}

///|
/// 前景色设为青喵。
pub fn Style::cyan(self : Style) -> Style {
  self.fg(Cyan)
}

///|
/// 前景色设为灰（银灰）喵。
pub fn Style::gray(self : Style) -> Style {
  self.fg(Gray)
}

///|
/// 前景色设为暗灰喵。
pub fn Style::dark_gray(self : Style) -> Style {
  self.fg(DarkGray)
}

///|
/// 前景色设为亮红喵。
pub fn Style::light_red(self : Style) -> Style {
  self.fg(LightRed)
}

///|
/// 前景色设为亮绿喵。
pub fn Style::light_green(self : Style) -> Style {
  self.fg(LightGreen)
}

///|
/// 前景色设为亮黄喵。
pub fn Style::light_yellow(self : Style) -> Style {
  self.fg(LightYellow)
}

///|
/// 前景色设为亮蓝喵。
pub fn Style::light_blue(self : Style) -> Style {
  self.fg(LightBlue)
}

///|
/// 前景色设为亮品红喵。
pub fn Style::light_magenta(self : Style) -> Style {
  self.fg(LightMagenta)
}

///|
/// 前景色设为亮青喵。
pub fn Style::light_cyan(self : Style) -> Style {
  self.fg(LightCyan)
}

///|
/// 前景色设为白（最亮白）喵。
pub fn Style::white(self : Style) -> Style {
  self.fg(White)
}

///|
/// 背景色速记（上游 `.on_*()` 系列）喵。
pub fn Style::on_black(self : Style) -> Style {
  self.bg(Black)
}

///|
/// 背景红喵。
pub fn Style::on_red(self : Style) -> Style {
  self.bg(Red)
}

///|
/// 背景绿喵。
pub fn Style::on_green(self : Style) -> Style {
  self.bg(Green)
}

///|
/// 背景黄喵。
pub fn Style::on_yellow(self : Style) -> Style {
  self.bg(Yellow)
}

///|
/// 背景蓝喵。
pub fn Style::on_blue(self : Style) -> Style {
  self.bg(Blue)
}

///|
/// 背景品红喵。
pub fn Style::on_magenta(self : Style) -> Style {
  self.bg(Magenta)
}

///|
/// 背景青喵。
pub fn Style::on_cyan(self : Style) -> Style {
  self.bg(Cyan)
}

///|
/// 背景灰喵。
pub fn Style::on_gray(self : Style) -> Style {
  self.bg(Gray)
}

///|
/// 背景暗灰喵。
pub fn Style::on_dark_gray(self : Style) -> Style {
  self.bg(DarkGray)
}

///|
/// 背景亮红喵。
pub fn Style::on_light_red(self : Style) -> Style {
  self.bg(LightRed)
}

///|
/// 背景亮绿喵。
pub fn Style::on_light_green(self : Style) -> Style {
  self.bg(LightGreen)
}

///|
/// 背景亮黄喵。
pub fn Style::on_light_yellow(self : Style) -> Style {
  self.bg(LightYellow)
}

///|
/// 背景亮蓝喵。
pub fn Style::on_light_blue(self : Style) -> Style {
  self.bg(LightBlue)
}

///|
/// 背景亮品红喵。
pub fn Style::on_light_magenta(self : Style) -> Style {
  self.bg(LightMagenta)
}

///|
/// 背景亮青喵。
pub fn Style::on_light_cyan(self : Style) -> Style {
  self.bg(LightCyan)
}

///|
/// 背景白喵。
pub fn Style::on_white(self : Style) -> Style {
  self.bg(White)
}

///|
/// 修饰位速记（上游 `.bold()` 系列）喵。
pub fn Style::bold(self : Style) -> Style {
  self.add_modifier(Modifier::bold())
}

///|
/// 暗淡喵。
pub fn Style::dim(self : Style) -> Style {
  self.add_modifier(Modifier::dim())
}

///|
/// 斜体喵。
pub fn Style::italic(self : Style) -> Style {
  self.add_modifier(Modifier::italic())
}

///|
/// 下划线喵。
pub fn Style::underlined(self : Style) -> Style {
  self.add_modifier(Modifier::underlined())
}

///|
/// 慢闪喵。
pub fn Style::slow_blink(self : Style) -> Style {
  self.add_modifier(Modifier::slow_blink())
}

///|
/// 快闪喵。
pub fn Style::rapid_blink(self : Style) -> Style {
  self.add_modifier(Modifier::rapid_blink())
}

///|
/// 反显喵。
pub fn Style::reversed(self : Style) -> Style {
  self.add_modifier(Modifier::reversed())
}

///|
/// 隐藏喵。
pub fn Style::hidden(self : Style) -> Style {
  self.add_modifier(Modifier::hidden())
}

///|
/// 删除线喵。
pub fn Style::crossed_out(self : Style) -> Style {
  self.add_modifier(Modifier::crossed_out())
}

///|
/// 否定修饰位速记（上游 `.not_*()` 系列，进入 sub 方向）喵。
pub fn Style::not_bold(self : Style) -> Style {
  self.remove_modifier(Modifier::bold())
}

///|
/// 取消暗淡喵。
pub fn Style::not_dim(self : Style) -> Style {
  self.remove_modifier(Modifier::dim())
}

///|
/// 取消斜体喵。
pub fn Style::not_italic(self : Style) -> Style {
  self.remove_modifier(Modifier::italic())
}

///|
/// 取消下划线喵。
pub fn Style::not_underlined(self : Style) -> Style {
  self.remove_modifier(Modifier::underlined())
}

///|
/// 取消慢闪喵。
pub fn Style::not_slow_blink(self : Style) -> Style {
  self.remove_modifier(Modifier::slow_blink())
}

///|
/// 取消快闪喵。
pub fn Style::not_rapid_blink(self : Style) -> Style {
  self.remove_modifier(Modifier::rapid_blink())
}

///|
/// 取消反显喵。
pub fn Style::not_reversed(self : Style) -> Style {
  self.remove_modifier(Modifier::reversed())
}

///|
/// 取消隐藏喵。
pub fn Style::not_hidden(self : Style) -> Style {
  self.remove_modifier(Modifier::hidden())
}

///|
/// 取消删除线喵。
pub fn Style::not_crossed_out(self : Style) -> Style {
  self.remove_modifier(Modifier::crossed_out())
}

///|
/// 复位速记（上游 `Stylize::reset`）喵。
pub fn Style::reset_style(self : Style) -> Style {
  Style::reset()
}

///|
/// Debug 语义（上游 `impl Debug for Style`，经 `fmt_stylize`）：
/// 以可粘贴的速记链呈现，如 `Style::new().red().on_blue().bold()`；
/// 命名色用速记，`Reset`/`Indexed`/`Rgb` 用 `.fg(Color::…)` 形式喵。
pub fn Style::to_debug(self : Style) -> String {
  let out = StringBuilder()
  out.write_string("Style::new()")
  match self.fg {
    Some(c) => out.write_string(debug_color(c, true))
    None => ()
  }
  match self.bg {
    Some(c) => out.write_string(debug_color(c, false))
    None => ()
  }
  let names = [
    "bold()", "dim()", "italic()", "underlined()", "slow_blink()", "rapid_blink()",
    "reversed()", "hidden()", "crossed_out()",
  ]
  for i, name in names {
    if (self.add_modifier.bits >> i).land(1).equal(1) {
      out.write_string(".")
      out.write_string(name)
    }
  }
  for i, name in names {
    if (self.sub_modifier.bits >> i).land(1).equal(1) {
      out.write_string(".not_")
      out.write_string(name)
    }
  }
  out.to_string()
}

///|
/// 颜色的速记呈现（上游 `ColorDebug`，包私有）喵。
fn debug_color(color : Color, foreground : Bool) -> String {
  match color {
    Reset => ".fg(Color::Reset)"
    Indexed(i) =>
      if foreground {
        ".fg(Color::Indexed(\{i}))"
      } else {
        ".bg(Color::Indexed(\{i}))"
      }
    Rgb(r, g, b) =>
      if foreground {
        ".fg(Color::Rgb(\{r}, \{g}, \{b}))"
      } else {
        ".bg(Color::Rgb(\{r}, \{g}, \{b}))"
      }
    _ => {
      let name = match color {
        Black => "black"
        Red => "red"
        Green => "green"
        Yellow => "yellow"
        Blue => "blue"
        Magenta => "magenta"
        Cyan => "cyan"
        Gray => "gray"
        DarkGray => "dark_gray"
        LightRed => "light_red"
        LightGreen => "light_green"
        LightYellow => "light_yellow"
        LightBlue => "light_blue"
        LightMagenta => "light_magenta"
        LightCyan => "light_cyan"
        White => "white"
        _ => "reset"
      }
      if foreground {
        ".\{name}()"
      } else {
        ".on_\{name}()"
      }
    }
  }
}
