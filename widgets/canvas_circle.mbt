// 圆形 Shape（上游 `canvas/circle.rs`）喵。

///|
/// 圆（上游 `canvas::Circle`）：圆心 + 半径 + 颜色，按 1° 步进描点喵。
pub(all) struct Circle {
  x : Double
  y : Double
  radius : Double
  color : @core.Color
} derive(Eq, Debug)

///|
/// 新建圆（上游 `Circle::new`）喵。
pub fn Circle::new(
  x : Double,
  y : Double,
  radius : Double,
  color : @core.Color,
) -> Circle {
  { x, y, radius, color }
}

///|
/// Shape 实现（上游 `impl Shape for Circle`）：上游 `mul_add` 融合
/// 乘加以 `radius * cos + x` 顺序等价承载喵。
pub impl Shape for Circle with fn draw(self, painter) {
  for angle in 0..<360 {
    let radians = angle.to_double() * @math.PI / 180.0
    let circle_x = self.radius * @math.cos(radians) + self.x
    let circle_y = self.radius * @math.sin(radians) + self.y
    match painter.get_point(circle_x, circle_y) {
      Some((x, y)) => painter.paint(x, y, self.color)
      None => ()
    }
  }
}
