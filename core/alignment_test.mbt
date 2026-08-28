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
