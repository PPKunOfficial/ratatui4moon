///|
/// 布局方向（上游 `layout::Direction`）：切分轴，缺省纵向喵。
pub(all) enum Direction {
  Horizontal
  Vertical
} derive(Eq, Debug)

///|
/// Display 语义（上游 strum Display：变体名）喵。
pub fn Direction::to_display(self : Direction) -> String {
  match self {
    Horizontal => "Horizontal"
    Vertical => "Vertical"
  }
}

///|
/// 从变体名解析（上游 `FromStr`，大小写敏感）喵。
pub fn Direction::from_str(s : String) -> Direction? {
  match s {
    "Horizontal" => Some(Horizontal)
    "Vertical" => Some(Vertical)
    _ => None
  }
}

///|
/// 取垂直/水平互换的正交方向（上游 `Direction::perpendicular`）喵。
pub fn Direction::perpendicular(self : Direction) -> Direction {
  match self {
    Horizontal => Vertical
    Vertical => Horizontal
  }
}
