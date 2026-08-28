///|
/// Constraint 单元测试：复刻 ratatui-v0.30.2 `layout/constraint.rs`
/// 测试清单喵。
///
/// 上游 `Ratio(u32::MAX, 2)` 极端用例按 Int 域以 i32::MAX 折算
/// （数值模型见 ADR-7）。

///|
/// 上游 default：缺省 100% 喵。
test "Constraint::default" {
  @debug.assert_eq(Constraint::default(), Constraint::Percentage(100))
}

///|
/// 上游 to_string：Display 呈现喵。
test "Constraint::to_display" {
  inspect(Constraint::Percentage(50).to_display(), content="Percentage(50)")
  inspect(Constraint::Ratio(1, 2).to_display(), content="Ratio(1, 2)")
  inspect(Constraint::Length(10).to_display(), content="Length(10)")
  inspect(Constraint::Max(10).to_display(), content="Max(10)")
  inspect(Constraint::Min(10).to_display(), content="Min(10)")
  inspect(Constraint::Fill(1).to_display(), content="Fill(1)")
}

///|
/// 上游 from_lengths：长度序列转约束喵。
test "Constraint::from_lengths" {
  @debug.assert_eq(Constraint::from_lengths([1, 2, 3]), [
    Constraint::Length(1),
    Constraint::Length(2),
    Constraint::Length(3),
  ])
}

///|
/// 上游 from_ratios：比率序列转约束喵。
test "Constraint::from_ratios" {
  @debug.assert_eq(Constraint::from_ratios([(1, 4), (1, 2), (1, 4)]), [
    Constraint::Ratio(1, 4),
    Constraint::Ratio(1, 2),
    Constraint::Ratio(1, 4),
  ])
}

///|
/// 上游 from_percentages：百分比序列转约束喵。
test "Constraint::from_percentages" {
  @debug.assert_eq(Constraint::from_percentages([25, 50, 25]), [
    Constraint::Percentage(25),
    Constraint::Percentage(50),
    Constraint::Percentage(25),
  ])
}

///|
/// 上游 from_maxes / from_mins / from_fills喵。
test "Constraint 其余构造器" {
  @debug.assert_eq(Constraint::from_maxes([1, 2]), [
    Constraint::Max(1),
    Constraint::Max(2),
  ])
  @debug.assert_eq(Constraint::from_mins([1, 2]), [
    Constraint::Min(1),
    Constraint::Min(2),
  ])
  @debug.assert_eq(Constraint::from_fills([1, 2]), [
    Constraint::Fill(1),
    Constraint::Fill(2),
  ])
}

///|
/// 上游 apply：约束施加到长度（f32 语义逐条对齐）喵。
test "Constraint::apply" {
  inspect(Constraint::Percentage(0).apply(100), content="0")
  inspect(Constraint::Percentage(50).apply(100), content="50")
  inspect(Constraint::Percentage(100).apply(100), content="100")
  inspect(Constraint::Percentage(200).apply(100), content="100")
  inspect(Constraint::Percentage(MAX_COORD).apply(100), content="100")
  // 0/0 有意规避除零，返回 0 喵
  inspect(Constraint::Ratio(0, 0).apply(100), content="0")
  // x/0 有意返回全长喵
  inspect(Constraint::Ratio(1, 0).apply(100), content="100")
  inspect(Constraint::Ratio(0, 1).apply(100), content="0")
  inspect(Constraint::Ratio(1, 2).apply(100), content="50")
  inspect(Constraint::Ratio(2, 2).apply(100), content="100")
  inspect(Constraint::Ratio(3, 2).apply(100), content="100")
  inspect(Constraint::Ratio(2147483647, 2).apply(100), content="100")
  inspect(Constraint::Length(0).apply(100), content="0")
  inspect(Constraint::Length(50).apply(100), content="50")
  inspect(Constraint::Length(100).apply(100), content="100")
  inspect(Constraint::Length(200).apply(100), content="100")
  inspect(Constraint::Length(MAX_COORD).apply(100), content="100")
  inspect(Constraint::Max(0).apply(100), content="0")
  inspect(Constraint::Max(50).apply(100), content="50")
  inspect(Constraint::Max(100).apply(100), content="100")
  inspect(Constraint::Max(200).apply(100), content="100")
  inspect(Constraint::Max(MAX_COORD).apply(100), content="100")
  inspect(Constraint::Min(0).apply(100), content="100")
  inspect(Constraint::Min(50).apply(100), content="100")
  inspect(Constraint::Min(100).apply(100), content="100")
  inspect(Constraint::Min(200).apply(100), content="200")
  inspect(Constraint::Min(MAX_COORD).apply(100), content="65535")
}
