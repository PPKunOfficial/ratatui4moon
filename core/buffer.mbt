///|
/// 字符网格缓冲与帧差分引擎喵。
///
/// Buffer 是 TUI 的画布：widget 只负责往网格里写字符，终端呈现由
/// backend 层消费差分完成。本文件零 I/O，纯数据结构 + 纯函数喵。

///|
/// 终端单元格：一个显示字符 + 样式喵。
pub(all) struct Cell {
  ch : Char
  style : Style
} derive(Eq, Debug)

///|
/// 空白单元格（空格 + 默认样式）喵。
pub fn Cell::empty() -> Cell {
  { ch: ' ', style: Style::default() }
}

///|
/// 字符网格缓冲：尺寸创建后固定，行主序存储，索引 = `y * width + x` 喵。
pub(all) struct Buffer {
  area : Rect
  cells : Array[Cell]
}

///|
/// 创建与 `area` 等尺寸的全空白缓冲喵。
pub fn Buffer::new(area : Rect) -> Buffer {
  { area, cells: Array::make(area.width * area.height, Cell::empty()) }
}

///|
/// 坐标是否落在缓冲区域内喵。
pub fn Buffer::in_bounds(self : Buffer, x : Int, y : Int) -> Bool {
  x >= self.area.x &&
  x < self.area.right() &&
  y >= self.area.y &&
  y < self.area.bottom()
}

///|
/// 写入单字符 + 样式；越界坐标静默忽略（渲染器天然裁剪，不炸喵）。
pub fn Buffer::set_cell(
  self : Buffer,
  x : Int,
  y : Int,
  ch : Char,
  style : Style,
) -> Unit {
  if !self.in_bounds(x, y) {
    return
  }
  let idx = (y - self.area.y) * self.area.width + (x - self.area.x)
  self.cells[idx] = { ch, style }
}

///|
/// 读取单元格；越界返回空白单元格喵。
pub fn Buffer::get(self : Buffer, x : Int, y : Int) -> Cell {
  if !self.in_bounds(x, y) {
    return Cell::empty()
  }
  let idx = (y - self.area.y) * self.area.width + (x - self.area.x)
  self.cells[idx]
}

///|
/// 从 `(x, y)` 起按"一字符一列"写入字符串（统一 `style`），越界自动裁剪喵。
///
/// CJK 双宽字符的列宽计算属于 `unicode` 层职责：接入前调用方保证传入
/// 已按显示宽度预处理的文本；接入后由 `unicode` 提供折行与列推进喵。
pub fn Buffer::set_string(
  self : Buffer,
  x : Int,
  y : Int,
  text : String,
  style : Style,
) -> Unit {
  let mut col = x
  for ch in text {
    self.set_cell(col, y, ch, style)
    col += 1
  }
}

///|
/// 与上一帧比较，产出变化单元格列表（绝对坐标 + 新值），行主序喵。
///
/// 两缓冲尺寸不一致属调用方错误，`guard!` 触发内部断言（程序员错误，
/// 非用户错误，不适用 raise 通道喵）。
pub fn Buffer::diff(self : Buffer, prev : Buffer) -> Array[(Int, Int, Cell)] {
  guard! prev.area == self.area
  let changes : Array[(Int, Int, Cell)] = []
  let w = self.area.width
  for i in 0..<self.cells.length() {
    let cur = self.cells[i]
    if cur != prev.cells[i] {
      changes.push((self.area.x + i % w, self.area.y + i / w, cur))
    }
  }
  changes
}
