///|
/// Offset 单元测试：复刻 ratatui-v0.30.2 `layout/offset.rs` 测试清单喵。

///|
/// 上游 new_sets_components：字段原样落位喵。
test "Offset::new 构造" {
  @debug.assert_eq(Offset::new(-3, 7), { x: -3, y: 7 })
}

///|
/// 上游 constants_match_expected_values：ZERO/MIN/MAX 常量喵。
test "Offset 常量" {
  @debug.assert_eq(Offset::zero(), Offset::new(0, 0))
  @debug.assert_eq(Offset::min(), Offset::new(-2147483648, -2147483648))
  @debug.assert_eq(Offset::max(), Offset::new(2147483647, 2147483647))
}

///|
/// 上游 from_position_converts_coordinates：坐标转平移量喵。
test "Offset::of_position" {
  @debug.assert_eq(Offset::of_position(Position::new(4, 9)), Offset::new(4, 9))
}
