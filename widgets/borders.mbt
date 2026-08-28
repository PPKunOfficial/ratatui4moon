///|
/// 可见边框方位位标志（上游 `widgets::Borders`，u8 bitflags；这里以
/// UInt16 承载，与 Modifier 同法，无行为差异）喵。
pub(all) struct Borders {
  bits : UInt16
} derive(Eq, Debug)

///|
/// 以位域构造（包私有底座）喵。
fn Borders::of_bits(bits : UInt16) -> Borders {
  { bits, }
}

///|
/// 无边框（上游 `Borders::NONE`/`empty`）喵。
pub fn Borders::empty() -> Borders {
  Borders::of_bits(0)
}

///|
/// 四边全开（上游 `Borders::ALL`）喵。
pub fn Borders::all() -> Borders {
  Borders::of_bits(15)
}

///|
/// 上边（0b0001）喵。
pub fn Borders::top() -> Borders {
  Borders::of_bits(1)
}

///|
/// 右边（0b0010）喵。
pub fn Borders::right() -> Borders {
  Borders::of_bits(2)
}

///|
/// 下边（0b0100）喵。
pub fn Borders::bottom() -> Borders {
  Borders::of_bits(4)
}

///|
/// 左边（0b1000）喵。
pub fn Borders::left() -> Borders {
  Borders::of_bits(8)
}

///|
/// 叠加方位位（上游 `insert`/`|`）喵。
pub fn Borders::insert(self : Borders, other : Borders) -> Borders {
  Borders::of_bits(self.bits.lor(other.bits))
}

///|
/// 位并集（上游 `union`）喵。
pub fn Borders::union(self : Borders, other : Borders) -> Borders {
  self.insert(other)
}

///|
/// 移除方位位（上游 `remove`）喵。
pub fn Borders::remove(self : Borders, other : Borders) -> Borders {
  Borders::of_bits(self.bits.land(other.bits.lnot()))
}

///|
/// 是否含有 `other` 的全部方位（上游 `contains`）喵。
pub fn Borders::contains(self : Borders, other : Borders) -> Bool {
  self.bits.land(other.bits) == other.bits
}

///|
/// 是否与 `other` 有任一公共方位（上游 `intersects`）喵。
pub fn Borders::intersects(self : Borders, other : Borders) -> Bool {
  !self.bits.land(other.bits).equal(0)
}

///|
/// 是否无边框（上游 `is_empty`）喵。
pub fn Borders::is_empty(self : Borders) -> Bool {
  self.bits.equal(0)
}

///|
/// Debug 语义（上游 bitflags Debug）：空为 `NONE`、全量为 `ALL`，
/// 否则方位名按位序以 ` | ` 连接喵。
pub fn Borders::to_debug(self : Borders) -> String {
  if self.is_empty() {
    return "NONE"
  }
  if self.contains(Borders::all()) {
    return "ALL"
  }
  let names = ["TOP", "RIGHT", "BOTTOM", "LEFT"]
  let out = StringBuilder()
  let mut first = true
  for i, name in names {
    if (self.bits >> i).land(1).equal(1) {
      if !first {
        out.write_string(" | ")
      }
      first = false
      out.write_string(name)
    }
  }
  out.to_string()
}

///|
/// 边框线型（上游 `widgets::BorderType` 全部 12 变体）喵。
pub(all) enum BorderType {
  Plain
  Rounded
  Double
  Thick
  LightDoubleDashed
  HeavyDoubleDashed
  LightTripleDashed
  HeavyTripleDashed
  LightQuadrupleDashed
  HeavyQuadrupleDashed
  QuadrantInside
  QuadrantOutside
} derive(Eq, Debug)

///|
/// Display 语义（上游 strum Display：变体名）喵。
pub fn BorderType::to_display(self : BorderType) -> String {
  match self {
    Plain => "Plain"
    Rounded => "Rounded"
    Double => "Double"
    Thick => "Thick"
    LightDoubleDashed => "LightDoubleDashed"
    HeavyDoubleDashed => "HeavyDoubleDashed"
    LightTripleDashed => "LightTripleDashed"
    HeavyTripleDashed => "HeavyTripleDashed"
    LightQuadrupleDashed => "LightQuadrupleDashed"
    HeavyQuadrupleDashed => "HeavyQuadrupleDashed"
    QuadrantInside => "QuadrantInside"
    QuadrantOutside => "QuadrantOutside"
  }
}

///|
/// 从变体名解析线型（上游 `FromStr`，大小写敏感；包私有别名见
/// `BorderType::parse`）喵。
pub fn BorderType::from_str(s : String) -> BorderType? {
  match s {
    "Plain" => Some(Plain)
    "Rounded" => Some(Rounded)
    "Double" => Some(Double)
    "Thick" => Some(Thick)
    "LightDoubleDashed" => Some(LightDoubleDashed)
    "HeavyDoubleDashed" => Some(HeavyDoubleDashed)
    "LightTripleDashed" => Some(LightTripleDashed)
    "HeavyTripleDashed" => Some(HeavyTripleDashed)
    "LightQuadrupleDashed" => Some(LightQuadrupleDashed)
    "HeavyQuadrupleDashed" => Some(HeavyQuadrupleDashed)
    "QuadrantInside" => Some(QuadrantInside)
    "QuadrantOutside" => Some(QuadrantOutside)
    _ => None
  }
}

///|
/// 线型对应的符号集（上游 `BorderType::to_border_set`）喵。
pub fn BorderType::to_border_set(self : BorderType) -> @core.BorderSet {
  match self {
    Plain => @core.BorderSet::plain()
    Rounded => @core.BorderSet::rounded()
    Double => @core.BorderSet::double()
    Thick => @core.BorderSet::thick()
    LightDoubleDashed => @core.BorderSet::light_double_dashed()
    HeavyDoubleDashed => @core.BorderSet::heavy_double_dashed()
    LightTripleDashed => @core.BorderSet::light_triple_dashed()
    HeavyTripleDashed => @core.BorderSet::heavy_triple_dashed()
    LightQuadrupleDashed => @core.BorderSet::light_quadruple_dashed()
    HeavyQuadrupleDashed => @core.BorderSet::heavy_quadruple_dashed()
    QuadrantInside => @core.BorderSet::quadrant_inside()
    QuadrantOutside => @core.BorderSet::quadrant_outside()
  }
}
