///|
/// Direction / Flex 单元测试：复刻 ratatui-v0.30.2
/// `layout/direction.rs` 与 `layout/flex.rs` 测试清单喵。

///|
/// 上游 direction to_string：Display 呈现喵。
test "Direction::to_display" {
  inspect(Direction::Horizontal.to_display(), content="Horizontal")
  inspect(Direction::Vertical.to_display(), content="Vertical")
}

///|
/// 上游 direction from_str：变体名解析与非法输入喵。
test "Direction::from_str" {
  @debug.assert_eq(
    Direction::from_str("Horizontal"),
    Some(Direction::Horizontal),
  )
  @debug.assert_eq(Direction::from_str("Vertical"), Some(Direction::Vertical))
  inspect(Direction::from_str("") is None, content="true")
  inspect(Direction::from_str("horizontal") is None, content="true")
}

///|
/// 上游 perpendicular：正交方向互换喵。
test "Direction::perpendicular" {
  @debug.assert_eq(Direction::Horizontal.perpendicular(), Direction::Vertical)
  @debug.assert_eq(Direction::Vertical.perpendicular(), Direction::Horizontal)
}

///|
/// Flex 变体与缺省值（上游 flex.rs：enum 定义与 default）喵。
test "Flex 缺省与变体" {
  @debug.assert_eq(Flex::default(), Flex::Start)
  inspect(Flex::Legacy.to_display(), content="Legacy")
  inspect(Flex::SpaceBetween.to_display(), content="SpaceBetween")
  inspect(Flex::SpaceEvenly.to_display(), content="SpaceEvenly")
  inspect(Flex::SpaceAround.to_display(), content="SpaceAround")
}
