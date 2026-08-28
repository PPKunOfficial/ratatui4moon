///|
/// Borders / BorderType 单元测试：复刻 ratatui-v0.30.2
/// `widgets/borders.rs` 测试清单喵。
///
/// `FromStr` 解析（strum）与 const 语境登记待复刻喵。

///|
/// 上游 test_borders_debug：Debug 呈现（NONE/单名/多名/ALL）喵。
test "Borders::to_debug" {
  inspect(Borders::empty().to_debug(), content="NONE")
  inspect(Borders::top().to_debug(), content="TOP")
  inspect(Borders::bottom().to_debug(), content="BOTTOM")
  inspect(Borders::left().to_debug(), content="LEFT")
  inspect(Borders::right().to_debug(), content="RIGHT")
  inspect(Borders::all().to_debug(), content="ALL")
  inspect(
    Borders::top().union(Borders::bottom()).to_debug(),
    content="TOP | BOTTOM",
  )
}

///|
/// 位运算语义：insert/remove/contains/intersects喵。
test "Borders 位运算" {
  let both = Borders::top().union(Borders::bottom())
  inspect(both.contains(Borders::top()), content="true")
  inspect(both.contains(Borders::left()), content="false")
  inspect(both.intersects(Borders::left()), content="false")
  inspect(both.intersects(Borders::top()), content="true")
  @debug.assert_eq(both.remove(Borders::top()), Borders::bottom())
  inspect(Borders::empty().is_empty(), content="true")
}

///|
/// 上游 border_type_to_string：Display 呈现为变体名喵。
test "BorderType::to_display" {
  inspect(BorderType::Plain.to_display(), content="Plain")
  inspect(BorderType::Rounded.to_display(), content="Rounded")
  inspect(BorderType::Double.to_display(), content="Double")
  inspect(BorderType::Thick.to_display(), content="Thick")
}

///|
/// 上游 border_type_to_string：全部 12 变体 Display 喵。
test "BorderType 全变体 Display" {
  inspect(BorderType::Plain.to_display(), content="Plain")
  inspect(BorderType::Rounded.to_display(), content="Rounded")
  inspect(BorderType::Double.to_display(), content="Double")
  inspect(BorderType::Thick.to_display(), content="Thick")
  inspect(
    BorderType::LightDoubleDashed.to_display(),
    content="LightDoubleDashed",
  )
  inspect(
    BorderType::HeavyDoubleDashed.to_display(),
    content="HeavyDoubleDashed",
  )
  inspect(
    BorderType::LightTripleDashed.to_display(),
    content="LightTripleDashed",
  )
  inspect(
    BorderType::HeavyTripleDashed.to_display(),
    content="HeavyTripleDashed",
  )
  inspect(
    BorderType::LightQuadrupleDashed.to_display(),
    content="LightQuadrupleDashed",
  )
  inspect(
    BorderType::HeavyQuadrupleDashed.to_display(),
    content="HeavyQuadrupleDashed",
  )
  inspect(BorderType::QuadrantInside.to_display(), content="QuadrantInside")
  inspect(BorderType::QuadrantOutside.to_display(), content="QuadrantOutside")
}

///|
/// 上游 border_type_from_str：变体名解析与非法输入喵。
test "BorderType::from_str" {
  @debug.assert_eq(BorderType::from_str("Plain"), Some(BorderType::Plain))
  @debug.assert_eq(BorderType::from_str("Rounded"), Some(BorderType::Rounded))
  @debug.assert_eq(
    BorderType::from_str("QuadrantOutside"),
    Some(BorderType::QuadrantOutside),
  )
  inspect(BorderType::from_str("plain") is None, content="true")
  inspect(BorderType::from_str("") is None, content="true")
}

///|
/// 上游 border_set_from_line_set：虚线集的角保持基线型、线体换虚线喵。
test "虚线边框集构造" {
  let set = BorderType::LightDoubleDashed.to_border_set()
  @debug.assert_eq(set.top_left, "┌")
  @debug.assert_eq(set.horizontal_top, "╌")
  @debug.assert_eq(set.vertical_left, "╎")
  let heavy = BorderType::HeavyDoubleDashed.to_border_set()
  @debug.assert_eq(heavy.top_left, "┏")
  @debug.assert_eq(heavy.horizontal_top, "╍")
  @debug.assert_eq(heavy.vertical_left, "╏")
}
