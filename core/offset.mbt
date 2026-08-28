///|
/// 矩形/坐标的平移量（上游 `layout::Offset`）喵。
///
/// 正值向右/下移动，负值向左/上移动。域为 i32（与 MoonBit `Int` 同域），
/// 消费方（`Rect::offset` 等）负责按目标坐标域饱和钳制喵。
pub(all) struct Offset {
  x : Int
  y : Int
} derive(Eq, Debug)

///|
/// 创建平移量喵。
pub fn Offset::new(x : Int, y : Int) -> Offset {
  { x, y }
}

///|
/// 零平移（上游 `Offset::ZERO`）喵。
pub fn Offset::zero() -> Offset {
  Offset::new(0, 0)
}

///|
/// i32 域最小平移（上游 `Offset::MIN`）喵。
pub fn Offset::min() -> Offset {
  Offset::new(-2147483648, -2147483648)
}

///|
/// i32 域最大平移（上游 `Offset::MAX`）喵。
pub fn Offset::max() -> Offset {
  Offset::new(2147483647, 2147483647)
}

///|
/// 从坐标点构造平移量（上游 `From<Position> for Offset`）喵。
pub fn Offset::of_position(position : Position) -> Offset {
  Offset::new(position.x, position.y)
}
