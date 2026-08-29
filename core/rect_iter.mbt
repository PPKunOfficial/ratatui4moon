// Rect 迭代器结构体形态（上游 `layout/rect/iter.rs`）：行/列/点位
// 的可反转游标迭代器，`Rect::rows()/columns()/positions()` 的
// Iter 版语义等价，此处补齐上游的结构体形态与双端迭代喵。

///|
/// 行迭代器（上游 `rect::iter::Rows`）喵。
pub(all) struct Rows {
  rect : Rect
  mut current_row_fwd : Int
  mut current_row_back : Int
  /// 是否处于 `.rev()` 适配态喵。
  mut rev : Bool
} derive(Eq, Debug)

///|
/// 新建行迭代器（上游 `Rows::new`）喵。
pub fn Rows::new(rect : Rect) -> Rows {
  { rect, current_row_fwd: rect.y, current_row_back: rect.bottom(), rev: false }
}

///|
/// 正向取行原始路径喵。
fn Rows::next_fwd(self : Rows) -> Rect? {
  if self.current_row_fwd >= self.current_row_back {
    return None
  }
  let row = Rect::new(self.rect.x, self.current_row_fwd, self.rect.width, 1)
  self.current_row_fwd += 1
  Some(row)
}

///|
/// 反向取行原始路径喵。
fn Rows::next_back_raw(self : Rows) -> Rect? {
  if self.current_row_back <= self.current_row_fwd {
    return None
  }
  self.current_row_back -= 1
  Some(Rect::new(self.rect.x, self.current_row_back, self.rect.width, 1))
}

///|
/// 取下一行（上游 `Iterator::next`；rev 态委托 `next_back`）喵。
pub fn Rows::next(self : Rows) -> Rect? {
  if self.rev {
    self.next_back_raw()
  } else {
    self.next_fwd()
  }
}

///|
/// 取上一行（上游 `DoubleEndedIterator::next_back`；rev 态委托
/// `next`）喵。
pub fn Rows::next_back(self : Rows) -> Rect? {
  if self.rev {
    self.next_fwd()
  } else {
    self.next_back_raw()
  }
}

///|
/// 反转迭代方向（上游 `.rev()`）喵。
pub fn Rows::rev(self : Rows) -> Rows {
  { ..self, rev: !self.rev }
}

///|
/// 跳过前 n 个元素（上游 `.skip(n)` 的急切承载）喵。
pub fn Rows::skip(self : Rows, n : Int) -> Rows {
  for _ in 0..<n {
    let _ = self.next()
  }
  self
}

///|
/// 剩余数量提示（上游 `size_hint`）喵。
pub fn Rows::size_hint(self : Rows) -> (Int, Int) {
  let start_count = (self.current_row_fwd - self.rect.top()).max(0)
  let end_count = (self.rect.bottom() - self.current_row_back).max(0)
  let count = (self.rect.height - start_count - end_count).max(0)
  (count, count)
}

///|
/// 列迭代器（上游 `rect::iter::Columns`）喵。
pub(all) struct Columns {
  rect : Rect
  mut current_column_fwd : Int
  mut current_column_back : Int
  /// 是否处于 `.rev()` 适配态喵。
  mut rev : Bool
} derive(Eq, Debug)

///|
/// 新建列迭代器（上游 `Columns::new`）喵。
pub fn Columns::new(rect : Rect) -> Columns {
  {
    rect,
    current_column_fwd: rect.x,
    current_column_back: rect.right(),
    rev: false,
  }
}

///|
/// 正向取列原始路径喵。
fn Columns::next_fwd(self : Columns) -> Rect? {
  if self.current_column_fwd >= self.current_column_back {
    return None
  }
  let column = Rect::new(
    self.current_column_fwd,
    self.rect.y,
    1,
    self.rect.height,
  )
  self.current_column_fwd += 1
  Some(column)
}

///|
/// 反向取列原始路径喵。
fn Columns::next_back_raw(self : Columns) -> Rect? {
  if self.current_column_back <= self.current_column_fwd {
    return None
  }
  self.current_column_back -= 1
  Some(Rect::new(self.current_column_back, self.rect.y, 1, self.rect.height))
}

///|
/// 取下一列（上游 `Iterator::next`；rev 态委托 `next_back`）喵。
pub fn Columns::next(self : Columns) -> Rect? {
  if self.rev {
    self.next_back_raw()
  } else {
    self.next_fwd()
  }
}

///|
/// 取上一列（上游 `DoubleEndedIterator::next_back`；rev 态委托
/// `next`）喵。
pub fn Columns::next_back(self : Columns) -> Rect? {
  if self.rev {
    self.next_fwd()
  } else {
    self.next_back_raw()
  }
}

///|
/// 剩余数量提示（上游 `size_hint`）喵。
pub fn Columns::size_hint(self : Columns) -> (Int, Int) {
  let start_count = (self.current_column_fwd - self.rect.left()).max(0)
  let end_count = (self.rect.right() - self.current_column_back).max(0)
  let count = (self.rect.width - start_count - end_count).max(0)
  (count, count)
}

///|
/// 反转迭代方向（上游 `.rev()`）喵。
pub fn Columns::rev(self : Columns) -> Columns {
  { ..self, rev: !self.rev }
}

///|
/// 跳过前 n 个元素（上游 `.skip(n)` 的急切承载）喵。
pub fn Columns::skip(self : Columns, n : Int) -> Columns {
  for _ in 0..<n {
    let _ = self.next()
  }
  self
}

///|
/// 点位迭代器（上游 `rect::iter::Positions`）喵。
pub(all) struct Positions {
  rect : Rect
  mut current_position : Position
} derive(Eq, Debug)

///|
/// 新建点位迭代器（上游 `Positions::new`）喵。
pub fn Positions::new(rect : Rect) -> Positions {
  { rect, current_position: Position::new(rect.x, rect.y) }
}

///|
/// 取下一点位（上游 `Iterator::next`）：先行后列喵。
pub fn Positions::next(self : Positions) -> Position? {
  if !self.rect.contains(self.current_position) {
    return None
  }
  let position = self.current_position
  self.current_position = {
    x: self.current_position.x + 1,
    y: self.current_position.y,
  }
  if self.current_position.x >= self.rect.right() {
    self.current_position = { x: self.rect.x, y: self.current_position.y + 1 }
  }
  Some(position)
}

///|
/// 剩余数量提示（上游 `size_hint`）喵。
pub fn Positions::size_hint(self : Positions) -> (Int, Int) {
  let row_count = (self.rect.bottom() - self.current_position.y).max(0)
  if row_count == 0 {
    return (0, 0)
  }
  let column_count = (self.rect.right() - self.current_position.x).max(0)
  let count = (row_count - 1) * self.rect.width + column_count
  (count, count)
}
