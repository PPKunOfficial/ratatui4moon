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
