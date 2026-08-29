///|
/// 水平对齐（上游 `layout::Alignment`）喵。
pub(all) enum Alignment {
  Left
  Center
  Right
} derive(Eq, Debug)

///|
/// Display 语义（上游 `Left`/`Center`/`Right`）喵。
pub fn Alignment::to_display(self : Alignment) -> String {
  match self {
    Left => "Left"
    Center => "Center"
    Right => "Right"
  }
}

///|
/// 变体名解析（上游 strum `EnumString`：大小写敏感，未知输入落 None）喵。
pub fn Alignment::from_str(s : String) -> Alignment? {
  match s {
    "Left" => Some(Left)
    "Center" => Some(Center)
    "Right" => Some(Right)
    _ => None
  }
}

///|
/// 垂直对齐（上游 `layout::VerticalAlignment`）：与水平对齐互补，
/// 构成二维定位控制喵。
pub(all) enum VerticalAlignment {
  Top
  Center
  Bottom
} derive(Eq, Debug)

///|
/// 缺省垂直对齐（上游 `VerticalAlignment::default` = `Top`）喵。
pub fn VerticalAlignment::default() -> VerticalAlignment {
  Top
}

///|
/// Display 语义（上游 strum `Display`）喵。
pub fn VerticalAlignment::to_display(self : VerticalAlignment) -> String {
  match self {
    Top => "Top"
    Center => "Center"
    Bottom => "Bottom"
  }
}

///|
/// 变体名解析（上游 strum `EnumString`）喵。
pub fn VerticalAlignment::from_str(s : String) -> VerticalAlignment? {
  match s {
    "Top" => Some(Top)
    "Center" => Some(Center)
    "Bottom" => Some(Bottom)
    _ => None
  }
}
