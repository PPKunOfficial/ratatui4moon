///|
/// 尺寸：宽与高（上游 `layout::Size`）喵。
///
/// 只表达维度，不含位置；与 `Rect`/`Position` 组装出完整区域喵。
pub(all) struct Size {
  width : Int
  height : Int
} derive(Eq, Debug)

///|
/// 创建尺寸喵。
pub fn Size::new(width : Int, height : Int) -> Size {
  { width, height }
}

///|
/// 从 (宽, 高) 元组构造（上游 `From<(u16, u16)>`）喵。
pub fn Size::of_tuple(size : (Int, Int)) -> Size {
  Size::new(size.0, size.1)
}

///|
/// 拆成 (宽, 高) 元组（上游 `Into<(u16, u16)>`）喵。
pub fn Size::to_tuple(self : Size) -> (Int, Int) {
  (self.width, self.height)
}

///|
/// 从矩形提取尺寸（上游 `From<Rect> for Size`）喵。
pub fn Size::of_rect(rect : Rect) -> Size {
  Size::new(rect.width, rect.height)
}

///|
/// 面积（上游以 u32 承装，这里用 Int64 防溢出）喵。
pub fn Size::area(self : Size) -> Int64 {
  self.width.to_int64() * self.height.to_int64()
}

///|
/// Display 语义（上游 `10x20` 格式）喵。
pub fn Size::to_display(self : Size) -> String {
  "\{self.width}x\{self.height}"
}
