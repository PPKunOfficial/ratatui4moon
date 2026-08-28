///|
/// ANSI 转义序列构造与 SGR 增量协议喵。
///
/// 终端呈现的转义原语集中在此，严禁上层散落手拼 ANSI 字串。
/// 颜色（含 Reset/Rgb/Indexed）与修饰位的 SGR 参数映射也在本文件
/// 完成——core 只持有数据模型，不碰终端语义喵。

///|
/// ANSI 转义引导符（ESC）喵。
pub const ESCAPE : String = "\u{1b}"

///|
/// 重置全部样式的 CSI 序列喵。
pub const RESET : String = "\u{1b}[0m"

///|
/// 拼一个完整 CSI 序列喵，例如 `csi("2", "K")` 得到清整行序列。
pub fn csi(params : String, code : String) -> String {
  "\{ESCAPE}[\{params}\{code}"
}

///|
/// 光标绝对定位序列（1-based 行;列）喵。
pub fn cursor_to(row : Int, col : Int) -> String {
  csi("\{row};\{col}", "H")
}

///|
/// 终端底噪基线样式：未着色单元格的等价形态（前景/背景均为 Reset、
/// 无修饰位）。帧首以它为参照、帧末与它比较收束，保证无样式帧零
/// SGR 噪音喵。
fn baseline_style() -> @core.Style {
  {
    fg: Some(@core.Color::Reset),
    bg: Some(@core.Color::Reset),
    add_modifier: @core.Modifier::empty(),
    sub_modifier: @core.Modifier::empty(),
  }
}

///|
/// 样式归一化：`None` 颜色视同终端默认（Reset），供增量比较对齐喵。
fn normalize_style(style : @core.Style) -> @core.Style {
  let fg = match style.fg {
    Some(c) => Some(c)
    None => Some(@core.Color::Reset)
  }
  let bg = match style.bg {
    Some(c) => Some(c)
    None => Some(@core.Color::Reset)
  }
  { ..style, fg, bg }
}

///|
/// 颜色的 SGR 参数串（不含 CSI 引导与结尾 `m`）喵。
///
/// 命名色对位 ANSI 色表：暗色 30+`n`/40+`n`，亮色 90+`n`/100+`n`；
/// `Reset` 用 39/49；`Rgb` 走 38;2;/48;2; 真彩色，`Indexed` 走
/// 38;5;/48;5; 索引色喵。
fn sgr_color_params(color : @core.Color, foreground : Bool) -> String {
  let base = if foreground { 30 } else { 40 }
  match color {
    @core.Color::Reset => if foreground { "39" } else { "49" }
    @core.Color::Black => "\{base}"
    @core.Color::Red => "\{base + 1}"
    @core.Color::Green => "\{base + 2}"
    @core.Color::Yellow => "\{base + 3}"
    @core.Color::Blue => "\{base + 4}"
    @core.Color::Magenta => "\{base + 5}"
    @core.Color::Cyan => "\{base + 6}"
    @core.Color::Gray => "\{base + 7}"
    @core.Color::DarkGray => "\{base + 60}"
    @core.Color::LightRed => "\{base + 61}"
    @core.Color::LightGreen => "\{base + 62}"
    @core.Color::LightYellow => "\{base + 63}"
    @core.Color::LightBlue => "\{base + 64}"
    @core.Color::LightMagenta => "\{base + 65}"
    @core.Color::LightCyan => "\{base + 66}"
    @core.Color::White => "\{base + 67}"
    @core.Color::Rgb(r, g, b) =>
      if foreground {
        "38;2;\{r};\{g};\{b}"
      } else {
        "48;2;\{r};\{g};\{b}"
      }
    @core.Color::Indexed(i) =>
      if foreground {
        "38;5;\{i}"
      } else {
        "48;5;\{i}"
      }
  }
}

///|
/// 修饰位的 SGR 参数串（位序升序对应 SGR 1–9，空位返回空串）喵。
///
/// 仅映射 `add_modifier` 方向：cell 侧样式恒无 `sub_modifier`，
/// 移除走 RESET 路径（帧协议的"回到基线"）喵。
fn sgr_modifier_params(modifier : @core.Modifier) -> String {
  let codes = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
  let out = StringBuilder()
  let mut first = true
  for i, code in codes {
    if (modifier.bits >> i).land(1).equal(1) {
      if !first {
        out.write_string(";")
      }
      first = false
      out.write_string(code)
    }
  }
  out.to_string()
}

///|
/// 单元格样式切换的 SGR 增量喵。
///
/// `prev` 是上一单元格样式（帧首传 `None`，按基线处理）；协议：
/// 无变化返回空串 → 回到基线发射 RESET → 进入非基线样式发射
/// "RESET + 修饰位 + 与基线有差异的颜色项"，未变化属性不重复发射喵。
pub fn sgr_transition(next : @core.Style, prev : @core.Style?) -> String {
  let next = normalize_style(next)
  let base = match prev {
    Some(p) => normalize_style(p)
    None => baseline_style()
  }
  if next == base {
    return ""
  }
  if next == baseline_style() {
    return RESET
  }
  let out = StringBuilder()
  out.write_string(RESET)
  let modifiers = sgr_modifier_params(next.add_modifier)
  if !modifiers.is_empty() {
    out.write_string(csi(modifiers, "m"))
  }
  if next.fg != base.fg {
    let color = match next.fg {
      Some(c) => c
      None => @core.Color::Reset
    }
    out.write_string(csi(sgr_color_params(color, true), "m"))
  }
  if next.bg != base.bg {
    let color = match next.bg {
      Some(c) => c
      None => @core.Color::Reset
    }
    out.write_string(csi(sgr_color_params(color, false), "m"))
  }
  out.to_string()
}

///|
/// 把一帧变化单元格渲染为 ANSI 串喵。
///
/// 行主序遍历：光标位置不连续时发射绝对定位（1-based）；样式经
/// `sgr_transition` 增量切换；帧末若停留在非基线样式态则以 RESET
/// 收束，保证帧边界无样式泄漏喵。
pub fn frame_to_ansi(cells : Array[(Int, Int, @core.Cell)]) -> String {
  let out = StringBuilder()
  let mut cur_x = 0
  let mut cur_y = 0
  let mut cursor_valid = false
  let mut prev_style : @core.Style? = None
  for cell in cells {
    let (x, y, c) = cell
    if !cursor_valid || x != cur_x + 1 || y != cur_y {
      out.write_string(cursor_to(y + 1, x + 1))
      cursor_valid = true
    }
    cur_x = x
    cur_y = y
    let s = sgr_transition(c.style(), prev_style)
    if !s.is_empty() {
      out.write_string(s)
    }
    out.write_string(c.symbol())
    prev_style = Some(c.style())
  }
  match prev_style {
    Some(s) =>
      if normalize_style(s) != baseline_style() {
        out.write_string(RESET)
      }
    None => ()
  }
  out.to_string()
}
