// 世界地图 Shape（上游 `canvas/map.rs`）：EPSG:4326 坐标系下的
// 大陆轮廓散点绘制，数据表单列于 canvas_world.mbt 喵。

///|
/// 地图分辨率（上游 `MapResolution`）：低约 1166 点，高约 5125 点
/// （高分辨率建议配盲文标记）喵。
pub(all) enum MapResolution {
  Low
  High
} derive(Eq, Debug)

///|
/// 缺省分辨率（上游 `MapResolution::default` = `Low`）喵。
pub fn MapResolution::default() -> MapResolution {
  Low
}

///|
/// 变体名（上游 strum `Display`）喵。
pub fn MapResolution::name(self : MapResolution) -> String {
  match self {
    Low => "Low"
    High => "High"
  }
}

///|
/// 变体名解析（上游 strum `EnumString`）喵。
pub fn MapResolution::from_str(s : String) -> MapResolution? {
  match s {
    "Low" => Some(Low)
    "High" => Some(High)
    _ => None
  }
}

///|
/// 取对应分辨率点集（上游 `MapResolution::data`）喵。
fn MapResolution::data(self : MapResolution) -> Array[(Double, Double)] {
  match self {
    Low => world_low_resolution
    High => world_high_resolution
  }
}

///|
/// 世界地图（上游 `canvas::Map`）喵。
pub(all) struct CanvasMap {
  resolution : MapResolution
  color : @core.Color
} derive(Eq, Debug)

///|
/// 缺省地图（上游 `Map::default`：低分辨率 + Reset 色）喵。
pub fn CanvasMap::default() -> CanvasMap {
  { resolution: Low, color: @core.Reset }
}

///|
/// Shape 实现（上游 `impl Shape for Map`）喵。
pub impl Shape for CanvasMap with fn draw(self, painter) {
  for point in self.resolution.data() {
    let (x, y) = point
    match painter.get_point(x, y) {
      Some((gx, gy)) => painter.paint(gx, gy, self.color)
      None => ()
    }
  }
}
