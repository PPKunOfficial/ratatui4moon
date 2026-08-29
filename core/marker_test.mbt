// 上游 `symbols/marker.rs` 内联测试逐条复刻（marker_tostring /
// marker_from_str），strum 的 Display/EnumString 以 name/from_str
// 关联函数对位喵。

///|
/// 上游 `marker_tostring`：Display 输出变体名，Custom 不带字符喵。
test "Marker::name 对位上游 Display" {
  inspect(Marker::default().name(), content="Dot")
  inspect(Marker::Dot.name(), content="Dot")
  inspect(Marker::Block.name(), content="Block")
  inspect(Marker::Bar.name(), content="Bar")
  inspect(Marker::Braille.name(), content="Braille")
  inspect(Marker::HalfBlock.name(), content="HalfBlock")
  inspect(Marker::Quadrant.name(), content="Quadrant")
  inspect(Marker::Sextant.name(), content="Sextant")
  inspect(Marker::Octant.name(), content="Octant")
  inspect(Marker::Custom('+').name(), content="Custom")
}

///|
/// 上游 `marker_from_str`：EnumString 大小写敏感解析，未知输入报错喵。
test "Marker::from_str 对位上游 EnumString" {
  @debug.assert_eq(Marker::from_str("Dot"), Some(Marker::Dot))
  @debug.assert_eq(Marker::from_str("Block"), Some(Marker::Block))
  @debug.assert_eq(Marker::from_str("Bar"), Some(Marker::Bar))
  @debug.assert_eq(Marker::from_str("Braille"), Some(Marker::Braille))
  @debug.assert_eq(Marker::from_str(""), None)
}

///|
/// 缺省值锚定：`Marker::default` = `Dot`（上游 derive `#[default]`）喵。
test "Marker::default 缺省 Dot" {
  inspect(Marker::default().name(), content="Dot")
}
