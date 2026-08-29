// 矩形 Shape（上游 `canvas/rectangle.rs`）喵。

///|
/// 矩形（上游 `canvas::Rectangle`）：以左下角定位，尺寸为世界坐标
/// 而非终端格喵。
pub(all) struct CanvasRectangle {
  x : Double
  y : Double
  width : Double
  height : Double
  color : @core.Color
} derive(Eq, Debug)

///|
/// 新建矩形（上游 `Rectangle::new`）喵。
pub fn CanvasRectangle::new(
  x : Double,
  y : Double,
  width : Double,
  height : Double,
  color : @core.Color,
) -> CanvasRectangle {
  { x, y, width, height, color }
}

///|
/// Shape 实现：四条 CanvasLine 描边（上游 `impl Shape for Rectangle`）喵。
pub impl Shape for CanvasRectangle with fn draw(self, painter) {
  let lines = [
    CanvasLine::new(self.x, self.y, self.x, self.y + self.height, self.color),
    CanvasLine::new(
      self.x,
      self.y + self.height,
      self.x + self.width,
      self.y + self.height,
      self.color,
    ),
    CanvasLine::new(
      self.x + self.width,
      self.y,
      self.x + self.width,
      self.y + self.height,
      self.color,
    ),
    CanvasLine::new(self.x, self.y, self.x + self.width, self.y, self.color),
  ]
  for line in lines {
    line.draw(painter)
  }
}
