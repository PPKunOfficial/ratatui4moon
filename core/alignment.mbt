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
