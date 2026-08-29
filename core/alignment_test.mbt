///|
/// Alignment 单元测试：复刻 ratatui-v0.30.2 `layout/alignment.rs`
/// 测试清单喵。
///
/// `FromStr` 解析与 `VerticalAlignment`（暂无消费方，铁律 7）登记
/// 待复刻喵。

///|
/// 上游 alignment_to_string：Display 呈现喵。
test "Alignment::to_display" {
  inspect(Alignment::Left.to_display(), content="Left")
  inspect(Alignment::Center.to_display(), content="Center")
  inspect(Alignment::Right.to_display(), content="Right")
}

///|
/// 上游 `alignment_to_string` 喵。
test "Alignment Display" {
  inspect(Alignment::Left.to_display(), content="Left")
  inspect(Alignment::Center.to_display(), content="Center")
  inspect(Alignment::Right.to_display(), content="Right")
}

///|
/// 上游 `alignment_from_str` 喵。
test "Alignment EnumString" {
  @debug.assert_eq(Alignment::from_str("Left"), Some(Alignment::Left))
  @debug.assert_eq(Alignment::from_str("Center"), Some(Alignment::Center))
  @debug.assert_eq(Alignment::from_str("Right"), Some(Alignment::Right))
  @debug.assert_eq(Alignment::from_str(""), None)
}

///|
/// 上游 `vertical_alignment_to_string` 喵。
test "VerticalAlignment Display" {
  inspect(VerticalAlignment::Top.to_display(), content="Top")
  inspect(VerticalAlignment::Center.to_display(), content="Center")
  inspect(VerticalAlignment::Bottom.to_display(), content="Bottom")
}

///|
/// 上游 `vertical_alignment_from_str` 喵。
test "VerticalAlignment EnumString" {
  @debug.assert_eq(
    VerticalAlignment::from_str("Top"),
    Some(VerticalAlignment::Top),
  )
  @debug.assert_eq(
    VerticalAlignment::from_str("Center"),
    Some(VerticalAlignment::Center),
  )
  @debug.assert_eq(
    VerticalAlignment::from_str("Bottom"),
    Some(VerticalAlignment::Bottom),
  )
  @debug.assert_eq(VerticalAlignment::from_str(""), None)
}
