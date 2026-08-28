///|
/// 单元格差分指令（上游 `buffer::CellDiffOption`）喵。
///
/// `None` 正常差分；`Skip` 差分时跳过（图形协议占位等）；
/// `AlwaysUpdate` 无条件上报（外部渲染管线可能覆写同一区域）；
/// `ForcedWidth` 强制列宽（转义序列占位宽度与符号自然宽度不符时用，
/// 上游以 NonZeroU16 承装，这里约定 ≥1，`Cell::cell_width` 兜底钳制）喵。
pub(all) enum CellDiffOption {
  None
  Skip
  AlwaysUpdate
  ForcedWidth(Int)
} derive(Eq, Debug)

///|
/// 终端单元格：一个符号（字形簇）+ 前景/背景色 + 修饰位 + 差分指令喵。
///
/// 上游 `symbol` 为 `Option<CompactString>` 且相等性把 `None` 与 `" "`
/// 视为同态；这里以空串表示空格态，`symbol()` 统一返回 `" "`，
/// 等价性由 `set_symbol` 的归一化保证喵。
pub(all) struct Cell {
  mut symbol : String
  mut fg : Color
  mut bg : Color
  mut modifier : Modifier
  mut diff_option : CellDiffOption
} derive(Eq, Debug)

///|
/// 以符号创建单元格（上游 `Cell::new`）喵。
pub fn Cell::of(symbol : String) -> Cell {
  {
    symbol: normalize_symbol(symbol),
    fg: Reset,
    bg: Reset,
    modifier: Modifier::empty(),
    diff_option: CellDiffOption::None,
  }
}

///|
/// 空白单元格（空格 + Reset 色 + 无修饰，上游 `Cell::EMPTY`）喵。
pub fn Cell::empty() -> Cell {
  Cell::of(" ")
}

///|
/// 从既有单元格复制（结构体为引用语义，填充/克隆必须逐字段拷贝）喵。
pub fn Cell::of_cell(other : Cell) -> Cell {
  {
    symbol: other.symbol,
    fg: other.fg,
    bg: other.bg,
    modifier: other.modifier,
    diff_option: other.diff_option,
  }
}

///|
/// 读符号：空格态统一返回 `" "`（上游 `Cell::symbol`）喵。
pub fn Cell::symbol(self : Cell) -> String {
  if self.symbol == "" {
    " "
  } else {
    self.symbol
  }
}

///|
/// 写符号；单空格归一化为空格态（上游 `Cell::set_symbol`）喵。
pub fn Cell::set_symbol(self : Cell, symbol : String) -> Unit {
  self.symbol = normalize_symbol(symbol)
}

///|
/// 追加符号到既有符号之后（上游 `Cell::append_symbol`）喵。
///
/// 供零宽字形并入单元格使用；空格态（空串）追加后不含前导空格，
/// 与上游 `None` 态行为一致喵。
pub fn Cell::append_symbol(self : Cell, symbol : String) -> Unit {
  self.symbol = self.symbol + symbol
}

///|
/// 写单字符（上游 `Cell::set_char`）喵。
pub fn Cell::set_char(self : Cell, ch : Char) -> Unit {
  self.set_symbol(ch.to_string())
}

///|
/// 设前景色（上游 `Cell::set_fg`）喵。
pub fn Cell::set_fg(self : Cell, color : Color) -> Unit {
  self.fg = color
}

///|
/// 设背景色（上游 `Cell::set_bg`）喵。
pub fn Cell::set_bg(self : Cell, color : Color) -> Unit {
  self.bg = color
}

///|
/// 施加增量样式：颜色非 `None` 才覆盖，修饰位按 add/remove 折叠
/// （上游 `Cell::set_style`，注意与 `Style::patch` 的 sub 跟踪不同）喵。
pub fn Cell::set_style(self : Cell, style : Style) -> Unit {
  match style.fg {
    Some(c) => self.fg = c
    None => ()
  }
  match style.bg {
    Some(c) => self.bg = c
    None => ()
  }
  self.modifier = self.modifier
    .insert(style.add_modifier)
    .remove(style.sub_modifier)
}

///|
/// 读出当前样式快照（上游 `Cell::style`，sub 方向恒空）喵。
pub fn Cell::style(self : Cell) -> Style {
  {
    fg: Some(self.fg),
    bg: Some(self.bg),
    add_modifier: self.modifier,
    sub_modifier: Modifier::empty(),
  }
}

///|
/// 设差分指令（上游 `Cell::set_diff_option`）喵。
pub fn Cell::set_diff_option(self : Cell, option : CellDiffOption) -> Unit {
  self.diff_option = option
}

///|
/// 复位到空白态（上游 `Cell::reset`）喵。
pub fn Cell::reset(self : Cell) -> Unit {
  self.symbol = ""
  self.fg = Reset
  self.bg = Reset
  self.modifier = Modifier::empty()
  self.diff_option = CellDiffOption::None
}

///|
/// 单元格列宽：`ForcedWidth` 优先（钳到 ≥1），否则按符号自然宽度
/// （上游 `CellWidth for Cell`）喵。
pub fn Cell::cell_width(self : Cell) -> Int {
  match self.diff_option {
    ForcedWidth(w) => if w < 1 { 1 } else { w }
    _ => symbol_width(self.symbol())
  }
}

///|
/// 单空格归一化为空格态（包私有，等价性的关键）喵。
fn normalize_symbol(symbol : String) -> String {
  if symbol == " " {
    ""
  } else {
    symbol
  }
}
