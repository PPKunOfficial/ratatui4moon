///|
/// 矩形区域：终端坐标系以左上角为原点，x 向右、y 向下喵。
///
/// `width`/`height` 为 0 或负数视为空区域；所有渲染路径对空区域优雅退化喵。
pub(all) struct Rect {
  x : Int
  y : Int
  width : Int
  height : Int
} derive(Eq, Debug)

///|
/// 创建矩形喵。
pub fn Rect::new(x : Int, y : Int, width : Int, height : Int) -> Rect {
  { x, y, width, height }
}

///|
/// 右边界（不含）喵。
pub fn Rect::right(self : Rect) -> Int {
  self.x + self.width
}

///|
/// 下边界（不含）喵。
pub fn Rect::bottom(self : Rect) -> Int {
  self.y + self.height
}

///|
/// 宽或高非正即视为空区域喵。
pub fn Rect::is_empty(self : Rect) -> Bool {
  self.width <= 0 || self.height <= 0
}
