///|
/// 样式与颜色模型喵。
///
/// Style 表达**增量样式**：`fg`/`bg` 为 `None` 表示"不改变"，修饰符分
/// `add_modifier`（要叠加的）与 `sub_modifier`（要移除的）两个方向；
/// 施加到 Cell 时按 patch 语义合并而非整体替换（上游 `style::Style`）喵。

///|
/// 文本修饰位标志（上游 `style::Modifier`，u16 bitflags）喵。
///
/// 位序对位 SGR 码 1–9：加粗/暗淡/斜体/下划线/慢闪/快闪/反显/隐藏/删除线。
/// 不可变值语义：`insert`/`remove` 返回新值喵。
pub(all) struct Modifier {
  bits : UInt16
} derive(Eq, Debug)

///|
/// 以位域构造修饰符（包私有底座）喵。
fn Modifier::of_bits(bits : UInt16) -> Modifier {
  { bits, }
}

///|
/// 空修饰符（上游 `Modifier::empty`）喵。
pub fn Modifier::empty() -> Modifier {
  Modifier::of_bits(0)
}

///|
/// 全部修饰位（上游 `Modifier::all`）喵。
pub fn Modifier::all() -> Modifier {
  Modifier::of_bits(511)
}

///|
/// 加粗（SGR 1）喵。
pub fn Modifier::bold() -> Modifier {
  Modifier::of_bits(1)
}

///|
/// 暗淡（SGR 2）喵。
pub fn Modifier::dim() -> Modifier {
  Modifier::of_bits(2)
}

///|
/// 斜体（SGR 3）喵。
pub fn Modifier::italic() -> Modifier {
  Modifier::of_bits(4)
}

///|
/// 下划线（SGR 4）喵。
pub fn Modifier::underlined() -> Modifier {
  Modifier::of_bits(8)
}

///|
/// 慢闪（SGR 5）喵。
pub fn Modifier::slow_blink() -> Modifier {
  Modifier::of_bits(16)
}

///|
/// 快闪（SGR 6）喵。
pub fn Modifier::rapid_blink() -> Modifier {
  Modifier::of_bits(32)
}

///|
/// 反显（SGR 7）喵。
pub fn Modifier::reversed() -> Modifier {
  Modifier::of_bits(64)
}

///|
/// 隐藏（SGR 8）喵。
pub fn Modifier::hidden() -> Modifier {
  Modifier::of_bits(128)
}

///|
/// 删除线（SGR 9）喵。
pub fn Modifier::crossed_out() -> Modifier {
  Modifier::of_bits(256)
}

///|
/// 叠加修饰位（上游 `Modifier::insert`）喵。
pub fn Modifier::insert(self : Modifier, other : Modifier) -> Modifier {
  Modifier::of_bits(self.bits.lor(other.bits))
}

///|
/// 移除修饰位（上游 `Modifier::remove`）喵。
pub fn Modifier::remove(self : Modifier, other : Modifier) -> Modifier {
  Modifier::of_bits(self.bits.land(other.bits.lnot()))
}

///|
/// 位并集（上游 `Modifier::union`）喵。
pub fn Modifier::union(self : Modifier, other : Modifier) -> Modifier {
  self.insert(other)
}

///|
/// 位差集（上游 `Modifier::difference`）喵。
pub fn Modifier::difference(self : Modifier, other : Modifier) -> Modifier {
  self.remove(other)
}

///|
/// 位交集（上游 `Modifier::intersection`）喵。
pub fn Modifier::intersection(self : Modifier, other : Modifier) -> Modifier {
  Modifier::of_bits(self.bits.land(other.bits))
}

///|
/// 是否含有 `other` 的全部位（上游 `Modifier::contains`）喵。
pub fn Modifier::contains(self : Modifier, other : Modifier) -> Bool {
  self.bits.land(other.bits) == other.bits
}

///|
/// 是否与 `other` 有任一公共位（上游 `Modifier::intersects`）喵。
pub fn Modifier::intersects(self : Modifier, other : Modifier) -> Bool {
  !self.bits.land(other.bits).equal(0)
}

///|
/// 是否为空（上游 `Modifier::is_empty`）喵。
pub fn Modifier::is_empty(self : Modifier) -> Bool {
  self.bits.equal(0)
}

///|
/// Debug 语义（上游手写 `impl Debug for Modifier`）：空为 `NONE`，
/// 否则为位名按位序以 ` | ` 连接喵。
pub fn Modifier::to_debug(self : Modifier) -> String {
  if self.is_empty() {
    return "NONE"
  }
  let names = [
    "BOLD", "DIM", "ITALIC", "UNDERLINED", "SLOW_BLINK", "RAPID_BLINK", "REVERSED",
    "HIDDEN", "CROSSED_OUT",
  ]
  let parts : Array[String] = []
  for i, name in names {
    if (self.bits >> i).land(1).equal(1) {
      parts.push(name)
    }
  }
  let out = StringBuilder()
  for i, part in parts {
    if i > 0 {
      out.write_string(" | ")
    }
    out.write_string(part)
  }
  out.to_string()
}

///|
/// 单元格/文本样式（上游 `style::Style`）喵。
///
/// 跨包构造走 `Style::new()` 与 builder 链（`fg`/`bg`/`add_modifier`），
/// 字面量仅在包内使用喵。
pub(all) struct Style {
  fg : Color?
  bg : Color?
  add_modifier : Modifier
  sub_modifier : Modifier
} derive(Eq, Debug)

///|
/// 空样式：不改变任何外观（上游 `Style::new`/`default`）喵。
pub fn Style::new() -> Style {
  {
    fg: None,
    bg: None,
    add_modifier: Modifier::empty(),
    sub_modifier: Modifier::empty(),
  }
}

///|
/// 空样式的别名，保留上游 `Style::default()` 调用形喵。
pub fn Style::default() -> Style {
  Style::new()
}

///|
/// 复位样式：颜色回归终端默认、移除全部修饰位（上游 `Style::reset`）喵。
pub fn Style::reset() -> Style {
  {
    fg: Some(Reset),
    bg: Some(Reset),
    add_modifier: Modifier::empty(),
    sub_modifier: Modifier::all(),
  }
}

///|
/// 设前景色（上游 `Style::fg`）喵。
pub fn Style::fg(self : Style, color : Color) -> Style {
  { ..self, fg: Some(color) }
}

///|
/// 设背景色（上游 `Style::bg`）喵。
pub fn Style::bg(self : Style, color : Color) -> Style {
  { ..self, bg: Some(color) }
}

///|
/// 叠加修饰位；与既有的 `sub_modifier` 互斥消解（上游 `Style::add_modifier`）喵。
pub fn Style::add_modifier(self : Style, modifier : Modifier) -> Style {
  {
    ..self,
    sub_modifier: self.sub_modifier.remove(modifier),
    add_modifier: self.add_modifier.insert(modifier),
  }
}

///|
/// 移除修饰位；与既有的 `add_modifier` 互斥消解（上游 `Style::remove_modifier`）喵。
pub fn Style::remove_modifier(self : Style, modifier : Modifier) -> Style {
  {
    ..self,
    add_modifier: self.add_modifier.remove(modifier),
    sub_modifier: self.sub_modifier.insert(modifier),
  }
}

///|
/// 合并另一份增量样式：颜色取 `other` 优先，修饰位按 add/sub 双向消解
/// （上游 `Style::patch`）喵。
///
/// 关键律：逐个 patch 等价于先合并再 patch（见 style_test）喵。
pub fn Style::patch(self : Style, other : Style) -> Style {
  let fg = match other.fg {
    Some(c) => Some(c)
    None => self.fg
  }
  let bg = match other.bg {
    Some(c) => Some(c)
    None => self.bg
  }
  {
    fg,
    bg,
    add_modifier: self.add_modifier
    .remove(other.sub_modifier)
    .insert(other.add_modifier),
    sub_modifier: self.sub_modifier
    .remove(other.add_modifier)
    .insert(other.sub_modifier),
  }
}

///|
/// 修饰位是否在生效（add 含有且未被 sub 抵消，上游 `Style::has_modifier`）喵。
pub fn Style::has_modifier(self : Style, modifier : Modifier) -> Bool {
  self.add_modifier.contains(modifier) && !self.sub_modifier.contains(modifier)
}

///|
/// 是否为"不改变任何外观"的空样式喵。
pub fn Style::is_default(self : Style) -> Bool {
  self.fg is None &&
  self.bg is None &&
  self.add_modifier.is_empty() &&
  self.sub_modifier.is_empty()
}
