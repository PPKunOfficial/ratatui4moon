///|
/// u16 坐标域上限（上游 `u16::MAX`）喵。
///
/// 本包坐标以 `Int` 承装，但保留上游 u16 饱和语义：一切边界计算
/// 不得越过 65535，`Rect::new`/`offset`/`resize` 等负责钳制喵。
pub const MAX_COORD : Int = 65535

///|
/// 矩形区域：终端坐标系以左上角为原点，x 向右、y 向下喵。
///
/// `Rect::new` 保证宽高与 u16 上限自洽（右/下边界不越 `MAX_COORD`）；
/// 直接字面量构造不受此约束，消费方一律经由边界方法（`right` 等）读取喵。
pub(all) struct Rect {
  x : Int
  y : Int
  width : Int
  height : Int
} derive(Eq, Debug)

///|
/// 创建矩形：宽高按 u16 上限饱和截断，负值优雅钳为 0（上游 `Rect::new`）喵。
pub fn Rect::new(x : Int, y : Int, width : Int, height : Int) -> Rect {
  let x = x.clamp(min=0, max=MAX_COORD)
  let y = y.clamp(min=0, max=MAX_COORD)
  let width = if width > MAX_COORD - x {
    MAX_COORD - x
  } else if width < 0 {
    0
  } else {
    width
  }
  let height = if height > MAX_COORD - y {
    MAX_COORD - y
  } else if height < 0 {
    0
  } else {
    height
  }
  { x, y, width, height }
}

///|
/// Display 语义（上游 `3x4+1+2` 格式）喵。
pub fn Rect::to_display(self : Rect) -> String {
  "\{self.width}x\{self.height}+\{self.x}+\{self.y}"
}

///|
/// 面积（上游以 u32 承装，这里用 Int64 防溢出）喵。
pub fn Rect::area(self : Rect) -> Int64 {
  self.width.to_int64() * self.height.to_int64()
}

///|
/// 宽或高非正即视为空区域喵。
pub fn Rect::is_empty(self : Rect) -> Bool {
  self.width <= 0 || self.height <= 0
}

///|
/// 左边界坐标（上游 `Rect::left`）喵。
pub fn Rect::left(self : Rect) -> Int {
  self.x
}

///|
/// 右边界（不含），第一条区域外坐标，饱和不出 u16 域（上游 `Rect::right`）喵。
pub fn Rect::right(self : Rect) -> Int {
  shift_clamped(self.x, self.width.to_int64(), MAX_COORD)
}

///|
/// 上边界坐标（上游 `Rect::top`）喵。
pub fn Rect::top(self : Rect) -> Int {
  self.y
}

///|
/// 下边界（不含），第一条区域外坐标，饱和不出 u16 域（上游 `Rect::bottom`）喵。
pub fn Rect::bottom(self : Rect) -> Int {
  shift_clamped(self.y, self.height.to_int64(), MAX_COORD)
}

///|
/// 四边各收 `margin`，收不下退化为零区域（上游 `Rect::inner`）喵。
pub fn Rect::inner(self : Rect, margin : Margin) -> Rect {
  let doubled_horizontal = margin.horizontal * 2
  let doubled_vertical = margin.vertical * 2
  if self.width < doubled_horizontal || self.height < doubled_vertical {
    Rect::new(0, 0, 0, 0)
  } else {
    Rect::new(
      shift_clamped(self.x, margin.horizontal.to_int64(), MAX_COORD),
      shift_clamped(self.y, margin.vertical.to_int64(), MAX_COORD),
      self.width - doubled_horizontal,
      self.height - doubled_vertical,
    )
  }
}

///|
/// 四边各扩 `margin`，越出 u16 域时截断（尺寸随之变小，上游 `Rect::outer`）喵。
pub fn Rect::outer(self : Rect, margin : Margin) -> Rect {
  let x = shift_clamped(self.x, -margin.horizontal.to_int64(), MAX_COORD)
  let y = shift_clamped(self.y, -margin.vertical.to_int64(), MAX_COORD)
  let width = shift_clamped(
      self.right(),
      margin.horizontal.to_int64(),
      MAX_COORD,
    ) -
    x
  let height = shift_clamped(
      self.bottom(),
      margin.vertical.to_int64(),
      MAX_COORD,
    ) -
    y
  Rect::new(x, y, width, height)
}

///|
/// 整体平移不改尺寸，右/下边界不出 u16 域（上游 `Rect::offset`）喵。
pub fn Rect::offset(self : Rect, offset : Offset) -> Rect {
  Rect::new(
    shift_clamped(self.x, offset.x.to_int64(), MAX_COORD - self.width),
    shift_clamped(self.y, offset.y.to_int64(), MAX_COORD - self.height),
    self.width,
    self.height,
  )
}

///|
/// `rect + offset`（上游 `Add<Offset> for Rect`）喵。
pub fn Rect::op_add(self : Rect, offset : Offset) -> Rect {
  self.offset(offset)
}

///|
/// `offset + rect`（上游 `Add<Rect> for Offset`）喵。
pub fn Offset::op_add(self : Offset, rect : Rect) -> Rect {
  rect.offset(self)
}

///|
/// `rect - offset`（上游 `Sub<Offset> for Rect`；不能退化为
/// `self + (-offset)`——`Offset::MIN` 取负会溢出，故直接以 Int64 反向位移）喵。
pub fn Rect::op_sub(self : Rect, offset : Offset) -> Rect {
  Rect::new(
    shift_clamped(self.x, -offset.x.to_int64(), MAX_COORD - self.width),
    shift_clamped(self.y, -offset.y.to_int64(), MAX_COORD - self.height),
    self.width,
    self.height,
  )
}

///|
/// 改尺寸保位置，右/下边界饱和不出 u16 域（上游 `Rect::resize`）喵。
pub fn Rect::resize(self : Rect, size : Size) -> Rect {
  Rect::new(self.x, self.y, size.width, size.height)
}

///|
/// 并集外接矩形（上游 `Rect::union`）喵。
pub fn Rect::union(self : Rect, other : Rect) -> Rect {
  let x1 = if self.x < other.x { self.x } else { other.x }
  let y1 = if self.y < other.y { self.y } else { other.y }
  let x2 = if self.right() > other.right() {
    self.right()
  } else {
    other.right()
  }
  let y2 = if self.bottom() > other.bottom() {
    self.bottom()
  } else {
    other.bottom()
  }
  Rect::new(x1, y1, x2 - x1, y2 - y1)
}

///|
/// 交集；不相交时退化为零面积（上游 `Rect::intersection`）喵。
pub fn Rect::intersection(self : Rect, other : Rect) -> Rect {
  let x1 = if self.x > other.x { self.x } else { other.x }
  let y1 = if self.y > other.y { self.y } else { other.y }
  let x2 = if self.right() < other.right() {
    self.right()
  } else {
    other.right()
  }
  let y2 = if self.bottom() < other.bottom() {
    self.bottom()
  } else {
    other.bottom()
  }
  Rect::new(x1, y1, x2 - x1, y2 - y1)
}

///|
/// 两矩形是否相交（边界相接也算，上游 `Rect::intersects`）喵。
pub fn Rect::intersects(self : Rect, other : Rect) -> Bool {
  self.x < other.right() &&
  self.right() > other.x &&
  self.y < other.bottom() &&
  self.bottom() > other.y
}

///|
/// 点是否落在矩形内（含边界，上游 `Rect::contains`）喵。
pub fn Rect::contains(self : Rect, position : Position) -> Bool {
  position.x >= self.x &&
  position.x < self.right() &&
  position.y >= self.y &&
  position.y < self.bottom()
}

///|
/// 把自身夹进 `other`：宽高超限先压尺寸，位置越界整体平移
/// （与 `intersection` 的"原地裁剪"不同，上游 `Rect::clamp`）喵。
pub fn Rect::clamp(self : Rect, other : Rect) -> Rect {
  let width = if self.width < other.width { self.width } else { other.width }
  let height = if self.height < other.height {
    self.height
  } else {
    other.height
  }
  let x = self.x.clamp(
    min=other.x,
    max=shift_clamped(other.right(), -width.to_int64(), MAX_COORD),
  )
  let y = self.y.clamp(
    min=other.y,
    max=shift_clamped(other.bottom(), -height.to_int64(), MAX_COORD),
  )
  Rect::new(x, y, width, height)
}

///|
/// 按行切片（行高 1）的惰性迭代（上游 `Rect::rows`）喵。
pub fn Rect::rows(self : Rect) -> Iter[Rect] {
  let mut next_y = self.y
  Iter::new(() => {
    if next_y < self.bottom() {
      let row = Rect::new(self.x, next_y, self.width, 1)
      next_y += 1
      Some(row)
    } else {
      None
    }
  })
}

///|
/// 按列切片（列宽 1）的惰性迭代（上游 `Rect::columns`）喵。
pub fn Rect::columns(self : Rect) -> Iter[Rect] {
  let mut next_x = self.x
  Iter::new(() => {
    if next_x < self.right() {
      let column = Rect::new(next_x, self.y, 1, self.height)
      next_x += 1
      Some(column)
    } else {
      None
    }
  })
}

///|
/// 逐点惰性迭代：自上而下逐行、行内自左向右（上游 `Rect::positions`）喵。
pub fn Rect::positions(self : Rect) -> Iter[Position] {
  let mut next_y = self.y
  let mut next_x = self.x
  Iter::new(() => {
    if next_y >= self.bottom() {
      return None
    }
    let position = Position::new(next_x, next_y)
    next_x += 1
    if next_x >= self.right() {
      next_x = self.x
      next_y += 1
    }
    Some(position)
  })
}

///|
/// 取左上角坐标点（上游 `Rect::as_position`）喵。
pub fn Rect::as_position(self : Rect) -> Position {
  Position::new(self.x, self.y)
}

///|
/// 提取尺寸（上游 `Rect::as_size`）喵。
pub fn Rect::as_size(self : Rect) -> Size {
  Size::new(self.width, self.height)
}

///|
/// 从 (Position, Size) 组装（上游 `From<(Position, Size)> for Rect`）喵。
pub fn Rect::of_position_size(position : Position, size : Size) -> Rect {
  Rect::new(position.x, position.y, size.width, size.height)
}

///|
/// 以原点为左上角按尺寸组装（上游 `From<Size> for Rect`）喵。
pub fn Rect::of_size(size : Size) -> Rect {
  Rect::new(0, 0, size.width, size.height)
}

///|
/// 带饱和的位移：`base + delta` 钳在 `[0, cap]` 内，Int64 中转防 i32 溢出喵。
///
/// 包内边界计算的公共底座（包私有）：`delta` 可能是 `i32::MIN/MAX`
/// 或其取负，直接 Int 加法会回绕，必须先拓宽再钳制；`cap` 越界时钳回
/// `[0, MAX_COORD]` 喵。
fn shift_clamped(base : Int, delta : Int64, cap : Int) -> Int {
  let hi = cap.clamp(min=0, max=MAX_COORD).to_int64()
  let v = base.to_int64() + delta
  let clamped = if v < 0L { 0L } else if v > hi { hi } else { v }
  clamped.to_int()
}
