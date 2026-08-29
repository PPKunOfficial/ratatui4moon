/// 数据点标记（上游 `symbols/marker.rs`）：Canvas/Chart 画点时选用的
/// 伪像素字符形态，从单格点（Dot）到 2x4 点阵（Braille/Octant）喵。
///
/// 上游 `symbols::DOT` 也定义于 marker.rs，随本文件一并对位喵。

///|
/// 圆点标记字符（上游 `symbols::DOT`）喵。
pub const DOT : String = "•"

///|
/// 标记形态（上游 `symbols::Marker`）：决定 Canvas 网格的伪像素
/// 分辨率与承载网格类型喵。
pub(all) enum Marker {
  /// 每格一点，圆点 `•`（上游 `Marker::Dot`，缺省）喵。
  Dot
  /// 每格一点，全块 `█`（上游 `Marker::Block`）喵。
  Block
  /// 每格一点，下半块 `▄`（上游 `Marker::Bar`）喵。
  Bar
  /// 盲文点阵，每格 2x4 伪像素（上游 `Marker::Braille`）喵。
  Braille
  /// 半块，每格 1x2 伪像素，支持前后景双色（上游 `Marker::HalfBlock`）喵。
  HalfBlock
  /// 象限块，每格 2x2 伪像素（上游 `Marker::Quadrant`）喵。
  Quadrant
  /// 六分块，每格 2x3 伪像素（上游 `Marker::Sextant`）喵。
  Sextant
  /// 八分块，每格 2x4 伪像素（上游 `Marker::Octant`）喵。
  Octant
  /// 自定义字符，每格一点（上游 `Marker::Custom(char)`）喵。
  Custom(Char)
} derive(Eq, Debug)

///|
/// 缺省标记（上游 `Marker::default` = `Dot`）喵。
pub fn Marker::default() -> Marker {
  Dot
}

///|
/// 变体名（上游 strum `Display`：`Custom` 不带载荷字符）喵。
pub fn Marker::name(self : Marker) -> String {
  match self {
    Dot => "Dot"
    Block => "Block"
    Bar => "Bar"
    Braille => "Braille"
    HalfBlock => "HalfBlock"
    Quadrant => "Quadrant"
    Sextant => "Sextant"
    Octant => "Octant"
    Custom(_) => "Custom"
  }
}

///|
/// 变体名解析（上游 strum `EnumString`：大小写敏感，未知输入落 None）喵。
pub fn Marker::from_str(s : String) -> Marker? {
  match s {
    "Dot" => Some(Dot)
    "Block" => Some(Block)
    "Bar" => Some(Bar)
    "Braille" => Some(Braille)
    "HalfBlock" => Some(HalfBlock)
    "Quadrant" => Some(Quadrant)
    "Sextant" => Some(Sextant)
    "Octant" => Some(Octant)
    _ => None
  }
}
