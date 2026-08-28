///|
/// 字符网格缓冲与帧差分引擎喵。
///
/// Buffer 是 TUI 的画布：widget 只负责往网格里写字符，终端呈现由
/// backend 层消费差分完成。本文件零 I/O，纯数据结构 + 纯函数喵。
///
/// 差分方向对位上游：`prev.diff(next)` 产出"把 prev 更新为 next"的
/// 最小单元格序列（上游 `Buffer::diff`/`BufferDiff`）喵。

///|
/// 字符网格缓冲：尺寸创建后固定，行主序存储，索引 = `y * width + x` 喵。
///
/// 结构体为引用语义，`cells` 中的 Cell 即真实单元格——`mut_cell`
/// 取出的引用可直接原地修改（对位上游 `cell_mut`/`IndexMut`）喵。
pub(all) struct Buffer {
  mut area : Rect
  mut cells : Array[Cell]
} derive(Eq, Debug)

///|
/// 创建与 `area` 等尺寸的全空白缓冲（上游 `Buffer::empty`）喵。
pub fn Buffer::empty(area : Rect) -> Buffer {
  Buffer::filled(area, Cell::empty())
}

///|
/// `Buffer::empty` 的别名（上游 0.29 旧名 `Buffer::new`，保留调用形）喵。
pub fn Buffer::new(area : Rect) -> Buffer {
  Buffer::empty(area)
}

///|
/// 创建以给定单元格填充的缓冲（上游 `Buffer::filled`）喵。
///
/// Cell 为引用语义，必须逐格克隆，禁止共享同一引用喵。
pub fn Buffer::filled(area : Rect, cell : Cell) -> Buffer {
  let cells : Array[Cell] = []
  for _ in 0..<(area.width * area.height) {
    cells.push(Cell::of_cell(cell))
  }
  { area, cells }
}

///|
/// 以若干行文本创建缓冲：宽度取各行最大宽，行高即行数
/// （上游 `Buffer::with_lines`）喵。
pub fn Buffer::with_lines(lines : Array[String]) -> Buffer {
  let line_objs : Array[Line] = []
  for line in lines {
    line_objs.push(Line::raw(line))
  }
  Buffer::with_lines_of(line_objs)
}

///|
/// 以带样式的行创建缓冲（上游 `with_lines` 的 `Into<Line>` 形态）喵。
pub fn Buffer::with_lines_of(lines : Array[Line]) -> Buffer {
  let mut width = 0
  for line in lines {
    let w = line.width()
    if w > width {
      width = w
    }
  }
  let height = lines.length()
  let buffer = Buffer::empty(Rect::new(0, 0, width, height))
  for y, line in lines {
    ignore(buffer.set_line(0, y, line, width))
  }
  buffer
}

///|
/// 坐标是否落在缓冲区域内喵。
pub fn Buffer::in_bounds(self : Buffer, x : Int, y : Int) -> Bool {
  self.area.contains(Position::new(x, y))
}

///|
/// 读单元格；越界返回独立空白单元格（优雅裁剪，不炸喵）。
///
/// 区域内返回的是单元格本体引用，读取方不应修改喵。
pub fn Buffer::get(self : Buffer, x : Int, y : Int) -> Cell {
  match self.cell(x, y) {
    Some(cell) => cell
    None => Cell::empty()
  }
}

///|
/// 安全读单元格：区域内返回引用，越界返回 `None`
/// （上游 `Buffer::cell`）喵。
pub fn Buffer::cell(self : Buffer, x : Int, y : Int) -> Cell? {
  if !self.in_bounds(x, y) {
    return None
  }
  let idx = (y - self.area.y) * self.area.width + (x - self.area.x)
  Some(self.cells[idx])
}

///|
/// 以坐标点安全读单元格（上游 `cell` 的 `Into<Position>` 形态）喵。
pub fn Buffer::cell_at(self : Buffer, position : Position) -> Cell? {
  self.cell(position.x, position.y)
}

///|
/// 取单元格引用用于原地修改；越界返回 `None`
/// （上游 `Buffer::cell_mut`/`IndexMut`）喵。
pub fn Buffer::mut_cell(self : Buffer, x : Int, y : Int) -> Cell? {
  self.cell(x, y)
}

///|
/// 坐标 → 行主序索引；越界属程序员错误，`guard!` 断言
/// （上游 `Buffer::index_of`）喵。
pub fn Buffer::index_of(self : Buffer, x : Int, y : Int) -> Int {
  guard! self.in_bounds(x, y)
  (y - self.area.y) * self.area.width + (x - self.area.x)
}

///|
/// 行主序索引 → 坐标；越界属程序员错误，`guard!` 断言
/// （上游 `Buffer::pos_of`）喵。
pub fn Buffer::pos_of(self : Buffer, i : Int) -> (Int, Int) {
  guard! i >= 0 && i < self.cells.length()
  (self.area.x + i % self.area.width, self.area.y + i / self.area.width)
}

///|
/// 从 `(x, y)` 起写入符号序列（统一样式），按显示宽度推进列，
/// 越界与零宽/控制字符优雅裁剪（上游 `Buffer::set_string`）喵。
pub fn Buffer::set_string(
  self : Buffer,
  x : Int,
  y : Int,
  text : String,
  style : Style,
) -> Unit {
  ignore(self.set_stringn(x, y, text, 2147483647, style))
}

///|
/// 带列数上限的 `set_string`，返回写完后的 `(x, y)`
/// （上游 `Buffer::set_stringn`）喵。
///
/// 双宽符号占 2 列：符号落在首列，后续列 `reset()` 为空白（终端把
/// 尾列藏进字形，缓冲中保持空白态）喵。
pub fn Buffer::set_stringn(
  self : Buffer,
  x : Int,
  y : Int,
  text : String,
  max_width : Int,
  style : Style,
) -> (Int, Int) {
  let mut x = x
  let mut remaining = self.area.right() - x
  if remaining < 0 {
    remaining = 0
  }
  if remaining > max_width {
    remaining = max_width
  }
  for ch in text {
    if ch.to_int() < 0x20 || (ch.to_int() >= 0x7F && ch.to_int() < 0xA0) {
      continue
    }
    let width = char_display_width(ch)
    if width == 0 {
      continue
    }
    if width > remaining {
      break
    }
    remaining -= width
    match self.mut_cell(x, y) {
      Some(cell) => {
        cell.set_symbol(ch.to_string())
        cell.set_style(style)
      }
      None => ()
    }
    let next_symbol = x + width
    x += 1
    while x < next_symbol {
      match self.mut_cell(x, y) {
        Some(cell) => cell.reset()
        None => ()
      }
      x += 1
    }
  }
  (x, y)
}

///|
/// 写入一行：行级样式 patch 各 span 样式，受 `max_width` 截断，
/// 返回写完后的 `(x, y)`（上游 `Buffer::set_line`）喵。
pub fn Buffer::set_line(
  self : Buffer,
  x : Int,
  y : Int,
  line : Line,
  max_width : Int,
) -> (Int, Int) {
  let mut x = x
  let mut remaining = max_width
  for span in line.spans {
    if remaining == 0 {
      break
    }
    let pos = self.set_stringn(
      x,
      y,
      span.content,
      remaining,
      line.style.patch(span.style),
    )
    let w = pos.0 - x
    x = pos.0
    remaining -= w
    if remaining < 0 {
      remaining = 0
    }
  }
  (x, y)
}

///|
/// 写入单个 span，返回写完后的 `(x, y)`（上游 `Buffer::set_span`）喵。
pub fn Buffer::set_span(
  self : Buffer,
  x : Int,
  y : Int,
  span : Span,
  max_width : Int,
) -> (Int, Int) {
  self.set_stringn(x, y, span.content, max_width, span.style)
}

///|
/// 给区域内的单元格叠加样式，区域与缓冲求交后生效
/// （上游 `Buffer::set_style`）喵。
pub fn Buffer::set_style(self : Buffer, area : Rect, style : Style) -> Unit {
  let area = self.area.intersection(area)
  for y in area.top()..<area.bottom() {
    for x in area.left()..<area.right() {
      match self.mut_cell(x, y) {
        Some(cell) => cell.set_style(style)
        None => ()
      }
    }
  }
}

///|
/// 调整缓冲到新区域：内容按行主序截断或以空白补齐
/// （上游 `Buffer::resize`）喵。
pub fn Buffer::resize(self : Buffer, area : Rect) -> Unit {
  let length = area.width * area.height
  let cells : Array[Cell] = []
  for i in 0..<length {
    cells.push(
      if i < self.cells.length() {
        Cell::of_cell(self.cells[i])
      } else {
        Cell::empty()
      },
    )
  }
  self.cells = cells
  self.area = area
}

///|
/// 复位全部单元格（上游 `Buffer::reset`）喵。
pub fn Buffer::reset(self : Buffer) -> Unit {
  for cell in self.cells {
    cell.reset()
  }
}

///|
/// 合并另一块缓冲：区域取并集，`other` 的内容覆盖重叠部分
/// （上游 `Buffer::merge`）喵。
pub fn Buffer::merge(self : Buffer, other : Buffer) -> Unit {
  let area = self.area.union(other.area)
  let length = area.width * area.height
  let cells : Array[Cell] = []
  for _ in 0..<length {
    cells.push(Cell::empty())
  }
  let size = self.cells.length()
  for i2 in 0..<size {
    let i = size - 1 - i2
    let (x, y) = self.pos_of(i)
    let k = (y - area.y) * area.width + (x - area.x)
    cells[k] = Cell::of_cell(self.cells[i])
  }
  let other_size = other.cells.length()
  for i in 0..<other_size {
    let (x, y) = other.pos_of(i)
    let k = (y - area.y) * area.width + (x - area.x)
    cells[k] = Cell::of_cell(other.cells[i])
  }
  self.cells = cells
  self.area = area
}

///|
/// 与 `next` 比较，产出把自身更新为 `next` 的最小变化序列：
/// 绝对坐标 + 新单元格副本，行主序（上游 `Buffer::diff`）喵。
///
/// 两缓冲 x/y/width 不一致属调用方错误，`guard!` 断言（程序员错误，
/// 非用户错误，不适用 raise 通道）；高度取两者较小值喵。
///
/// 差分状态机忠实复刻上游 `BufferDiff`：多宽字形吞掉尾列（不再对
/// 藏进字形的列发无谓更新）；宽字形收窄时若旧字形的样式在空白上
/// 可见（背景色/反显/下划线/闪烁/删除线），强刷整段尾列以清除
/// 终端残留（CJK 渲染回归的根源修复）喵。
pub fn Buffer::diff(self : Buffer, next : Buffer) -> Array[(Int, Int, Cell)] {
  guard! self.area.x == next.area.x &&
    self.area.y == next.area.y &&
    self.area.width == next.area.width
  let changes : Array[(Int, Int, Cell)] = []
  let len = if self.cells.length() < next.cells.length() {
    self.cells.length()
  } else {
    next.cells.length()
  }
  let w = self.area.width
  // 空白上样式可见的修饰位（上游 VISIBLE_ON_BLANK）
  let visible_on_blank = Modifier::reversed()
    .union(Modifier::underlined())
    .union(Modifier::slow_blink())
    .union(Modifier::rapid_blink())
    .union(Modifier::crossed_out())
  let mut pos = 0
  let mut has_trailing = false
  let mut trailing_next = 0
  let mut trailing_end = 0
  let mut trailing_force = false
  fn emit(i : Int) -> Unit {
    changes.push(
      (self.area.x + i % w, self.area.y + i / w, Cell::of_cell(next.cells[i])),
    )
  }
  while pos < len {
    // 先清空挂起的尾列强刷队列
    if has_trailing {
      let mut j = trailing_next
      while j < trailing_end {
        let cell = next.cells[j]
        let idx = j
        let cell_width = if cell.cell_width() < 1 {
          1
        } else {
          cell.cell_width()
        }
        j += cell_width
        let end2 = if trailing_end > j { trailing_end } else { j }
        trailing_end = if end2 < len { end2 } else { len }
        if !is_skip_option(cell.diff_option) &&
          (trailing_force || self.cells[idx].symbol() != cell.symbol()) {
          emit(idx)
        }
      }
      pos = if trailing_end < len { trailing_end } else { len }
      has_trailing = false
      continue
    }
    let i = pos
    pos += 1
    let current = next.cells[i]
    let previous = self.cells[i]
    match current.diff_option {
      CellDiffOption::Skip => ()
      CellDiffOption::ForcedWidth(width) => {
        let extra = if width < 1 { 0 } else { width - 1 }
        pos += extra
        if current != previous {
          emit(i)
        }
      }
      CellDiffOption::None =>
        if current == previous {
          // 相等也要吞掉多宽字形的尾列
          let cell_width = current.cell_width()
          pos += if cell_width > 1 { cell_width - 1 } else { 0 }
        } else {
          pos += diff_advance(self, next, i, visible_on_blank, emit, fn(
            t_next,
            t_end,
            force,
          ) {
            has_trailing = true
            trailing_next = t_next
            trailing_end = t_end
            trailing_force = force
          })
        }
      CellDiffOption::AlwaysUpdate =>
        pos += diff_advance(self, next, i, visible_on_blank, emit, fn(
          t_next,
          t_end,
          force,
        ) {
          has_trailing = true
          trailing_next = t_next
          trailing_end = t_end
          trailing_force = force
        })
    }
  }
  changes
}

///|
/// 差分跳过判定：`Skip` 指令的单元格不上报（包私有）喵。
fn is_skip_option(option : CellDiffOption) -> Bool {
  match option {
    CellDiffOption::Skip => true
    _ => false
  }
}

///|
/// 差分主路径（非 Skip、需要评估上报的单元格）：处理多宽吞列与
/// 尾列强刷判定，上报该单元格，返回主循环需额外跳过的列数
/// （包私有）喵。
fn diff_advance(
  prev : Buffer,
  next : Buffer,
  i : Int,
  visible_on_blank : Modifier,
  emit : (Int) -> Unit,
  set_trailing : (Int, Int, Bool) -> Unit,
) -> Int {
  let len = if prev.cells.length() < next.cells.length() {
    prev.cells.length()
  } else {
    next.cells.length()
  }
  let current = next.cells[i]
  let previous = prev.cells[i]
  let cell_width = current.cell_width()
  let previous_width = previous.cell_width()
  let mut contains_vs16 = false
  if cell_width > 1 {
    for ch in current.symbol() {
      if ch.to_int() == 0xFE0F {
        contains_vs16 = true
        break
      }
    }
  }
  let mut skip_ahead = 0
  if contains_vs16 {
    // VS16 emoji：尾列由主循环旁路逐格复核，仅符号变化才上报
    let end = if i + cell_width < len { i + cell_width } else { len }
    set_trailing(i + 1, end, false)
  } else if cell_width > 1 {
    // 多宽字形：吞掉自身尾列
    skip_ahead = cell_width - 1
  } else if previous_width > cell_width &&
    (previous.bg != Reset || previous.modifier.intersects(visible_on_blank)) {
    // 旧宽字形的样式在空白上可见：终端可能残留样式，强刷整段尾列
    let end = if i + previous_width < len { i + previous_width } else { len }
    set_trailing(i + 1, end, true)
  } else {
    // 单宽字符，无需位置调整
  }
  emit(i)
  skip_ahead
}

///|
/// 缓冲的 Debug 呈现（上游手写 `impl Debug for Buffer`）：逐行内容 +
/// 变化点样式清单，多宽字形隐藏的尾列以注释标出喵。
pub fn Buffer::to_debug(self : Buffer) -> String {
  let out = StringBuilder()
  out.write_string("Buffer {\n")
  out.write_string(
    "    area: Rect { x: \{self.area.x}, y: \{self.area.y}, width: \{self.area.width}, height: \{self.area.height} }",
  )
  if self.area.is_empty() {
    out.write_string("\n}")
    return out.to_string()
  }
  out.write_string(",\n    content: [\n")
  let mut last_style : (Color, Color, Modifier)? = None
  let styles : Array[String] = []
  for y in 0..<self.area.height {
    let overwritten : Array[(Int, String)] = []
    let mut skip = 0
    out.write_string("        \"")
    for x in 0..<self.area.width {
      let cell = self.cells[y * self.area.width + x]
      let symbol = cell.symbol()
      if skip == 0 {
        out.write_string(symbol)
      } else {
        overwritten.push((x, symbol))
      }
      let width = symbol_width(symbol)
      skip = if width > skip { width } else { skip }
      if skip > 0 {
        skip -= 1
      }
      let style = (cell.fg, cell.bg, cell.modifier)
      let changed = match last_style {
        Some(s) => s != style
        None => true
      }
      if changed {
        last_style = Some(style)
        styles.push(
          "x: \{x}, y: \{y}, fg: \{cell.fg.to_display()}, bg: \{cell.bg.to_display()}, modifier: \{cell.modifier.to_debug()}",
        )
      }
    }
    out.write_string("\",")
    if overwritten.length() > 0 {
      out.write_string(" // hidden by multi-width symbols: [")
      for k, hidden in overwritten {
        if k > 0 {
          out.write_string(", ")
        }
        out.write_string("(\{hidden.0}, \"\{hidden.1}\")")
      }
      out.write_string("]")
    }
    out.write_string("\n")
  }
  out.write_string("    ],\n    styles: [\n")
  for s in styles {
    out.write_string("        \{s},\n")
  }
  out.write_string("    ]\n}")
  out.to_string()
}
