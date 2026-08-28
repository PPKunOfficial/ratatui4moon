///|
/// Margin 单元测试：复刻 ratatui-v0.30.2 `layout/margin.rs` 测试清单喵。

///|
/// 上游 margin_to_string：Display 格式 `水平x垂直` 喵。
test "Margin::to_display" {
  inspect(Margin::new(1, 2).to_display(), content="1x2")
}

///|
/// 上游 margin_new：字段原样落位喵。
test "Margin::new 构造" {
  @debug.assert_eq(Margin::new(1, 2), { horizontal: 1, vertical: 2 })
}

///|
/// 上游 from_u16：四边等宽喵。
test "Margin::uniform" {
  @debug.assert_eq(Margin::uniform(5), Margin::new(5, 5))
}
