// 散点 Shape（上游 `canvas/points.rs`）喵。

///|
/// 一组散点（上游 `canvas::Points`）：逐点经 Painter 折算涂色喵。
pub(all) struct Points {
  coords : Array[(Double, Double)]
  color : @core.Color
} derive(Eq, Debug)

///|
/// 新建散点（上游 `Points::new`）喵。
pub fn Points::new(
  coords : Array[(Double, Double)],
  color : @core.Color,
) -> Points {
  { coords, color }
}

///|
/// Shape 实现（上游 `impl Shape for Points`）喵。
pub impl Shape for Points with fn draw(self, painter) {
  for point in self.coords {
    let (x, y) = point
    match painter.get_point(x, y) {
      Some((gx, gy)) => painter.paint(gx, gy, self.color)
      None => ()
    }
  }
}
