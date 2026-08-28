///|
/// 矩形四边的留白量（上游 `layout::Margin`）喵。
///
/// `horizontal` 同时作用于左右两侧，`vertical` 同时作用于上下两侧；
/// `Rect::inner`/`Rect::outer` 的收缩与扩张按此语义翻倍计算喵。
pub(all) struct Margin {
  horizontal : Int
  vertical : Int
} derive(Eq, Debug)

///|
/// 创建留白喵。
pub fn Margin::new(horizontal : Int, vertical : Int) -> Margin {
  { horizontal, vertical }
}

///|
/// 四边等宽留白（上游 `From<u16> for Margin`）喵。
pub fn Margin::uniform(value : Int) -> Margin {
  Margin::new(value, value)
}

///|
/// Display 语义（上游 `1x2` 格式）喵。
pub fn Margin::to_display(self : Margin) -> String {
  "\{self.horizontal}x\{self.vertical}"
}
