///|
/// ANSI 转义序列构造与 SGR 增量协议喵。
///
/// 终端呈现的转义原语集中在此，严禁上层散落手拼 ANSI 字串。
/// 原语源自 Nonoka `tui/ansi.mbt`，在此升级为 cell 粒度协议喵。

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
/// 单元格样式切换的 SGR 增量喵。
///
/// `prev` 是上一单元格样式（帧首传 `None`）；样式未变化返回空串，
/// 回到默认样式发射 RESET，进入非默认样式发射"RESET + 逐项设置"。
/// 帧首（`None`）遇到默认样式同样返回空串，保证无样式帧零 SGR 噪音喵。
pub fn sgr_transition(next : @core.Style, prev : @core.Style?) -> String {
  let unchanged = match prev {
    Some(p) => p == next
    None => next.is_default()
  }
  if unchanged {
    return ""
  }
  if next.is_default() {
    return RESET
  }
  let out = StringBuilder()
  out.write_string(RESET)
  if next.bold {
    out.write_string(csi("1", "m"))
  }
  match next.fg {
    Some(c) => out.write_string(csi("\{c.fg_code()}", "m"))
    None => ()
  }
  out.to_string()
}

///|
/// 把一帧变化单元格渲染为 ANSI 串喵。
///
/// 行主序遍历：光标位置不连续时发射绝对定位（1-based）；样式经
/// `sgr_transition` 增量切换；帧末若停留在非默认样式态则以 RESET 收束，
/// 保证帧边界无样式泄漏喵。
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
    let s = sgr_transition(c.style, prev_style)
    if !s.is_empty() {
      out.write_string(s)
    }
    out.write_char(c.ch)
    prev_style = Some(c.style)
  }
  match prev_style {
    Some(s) => if !s.is_default() { out.write_string(RESET) }
    None => ()
  }
  out.to_string()
}
