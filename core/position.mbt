///|
/// 终端上的一个点（上游 `layout::Position`）：x 向右、y 向下喵。
pub(all) struct Position {
  x : Int
  y : Int
} derive(Eq, Debug)

///|
/// 从 (x, y) 元组构造（上游 `From<(u16, u16)>`）喵。
pub fn Position::of_tuple(position : (Int, Int)) -> Position {
  Position::new(position.0, position.1)
}

///|
/// 创建坐标点喵。
pub fn Position::new(x : Int, y : Int) -> Position {
  { x, y }
}

///|
/// 拆成 (x, y) 元组（上游 `Into<(u16, u16)>`）喵。
pub fn Position::to_tuple(self : Position) -> (Int, Int) {
  (self.x, self.y)
}

///|
/// 从矩形取左上角坐标（上游 `From<Rect> for Position`）喵。
pub fn Position::of_rect(rect : Rect) -> Position {
  rect.as_position()
}

///|
/// Display 语义（上游 `(1, 2)` 格式）喵。
pub fn Position::to_display(self : Position) -> String {
  "(\{self.x}, \{self.y})"
}

///|
/// 平移坐标点，结果钳制在 u16 坐标域内（上游 `Position::offset`）喵。
pub fn Position::offset(self : Position, offset : Offset) -> Position {
  Position::new(
    shift_clamped(self.x, offset.x.to_int64(), MAX_COORD),
    shift_clamped(self.y, offset.y.to_int64(), MAX_COORD),
  )
}

///|
/// `position + offset`（上游 `Add<Offset> for Position`）喵。
pub fn Position::op_add(self : Position, offset : Offset) -> Position {
  self.offset(offset)
}

///|
/// `position - offset`（上游 `Sub<Offset> for Position`；`Offset::MIN`
/// 取负会溢出，直接以 Int64 反向位移喵）。
pub fn Position::op_sub(self : Position, offset : Offset) -> Position {
  Position::new(
    shift_clamped(self.x, -offset.x.to_int64(), MAX_COORD),
    shift_clamped(self.y, -offset.y.to_int64(), MAX_COORD),
  )
}
