///|
/// BarChart 集成黄金用例：复刻 ratatui-v0.30.2
/// `ratatui/tests/widgets_barchart.rs` 全部 2 条测试喵。
///
/// 上游经 Terminal/TestBackend 驱动；terminal 会话层未复刻前以等价的
/// "直渲染 + Buffer 比对"承载。`assert_buffer_lines` 等价为
/// `barchart_assert_rows`（全宽逐行符号比对）；`assert_buffer` 等价为
/// `@debug.assert_eq(buffer, expected)` 喵。

///|
/// 上游 assert_buffer_lines：全宽逐行符号串比对（不裁尾空格）喵。
fn barchart_assert_rows(
  buf : @core.Buffer,
  expected : Array[String],
) -> Unit raise {
  for y, row in expected {
    let out = StringBuilder()
    for x in 0..<buf.area.width {
      out.write_string(buf.get(x, y).symbol())
    }
    assert_eq(out.to_string(), row)
  }
}

///|
/// 上游 widgets_barchart_not_full_below_max_value：柱体按 max(100)
/// 比例填充、值行与标签行喵。
test "BarChart 集成：未达上限按比例填充" {
  let area = @core.Rect::new(0, 0, 30, 10)
  let buffer = @core.Buffer::empty(area)
  BarChart::default()
  .block(Block::bordered())
  .data_pairs([
    ("empty", 0UL),
    ("half", 50UL),
    ("almost", 99UL),
    ("full", 100UL),
  ])
  .max(100UL)
  .bar_width(7)
  .bar_gap(0)
  .render(area, buffer)
  barchart_assert_rows(buffer, [
    "┌────────────────────────────┐",
    "│              ▇▇▇▇▇▇▇███████│", "│              ██████████████│",
    "│              ██████████████│", "│       ▄▄▄▄▄▄▄██████████████│",
    "│       █████████████████████│",
    "│       █████████████████████│",
    "│       ██50█████99█████100██│", "│ empty  half  almost  full  │",
    "└────────────────────────────┘",
  ])
}

///|
/// 上游 widgets_barchart_group：分组柱状图 + 逐柱样式/值样式/
/// 自定义值文本 + 组标签喵。
test "BarChart 集成：分组渲染" {
  let terminal_height = 11
  let area = @core.Rect::new(0, 0, 35, terminal_height)
  let buffer = @core.Buffer::empty(area)
  BarChart::default()
  .block(Block::bordered())
  .data(
    BarGroup::default()
    .label_str("Mar")
    .bars([
      Bar::default()
      .value(10UL)
      .label_str("C1")
      .style(@core.Style::new().fg(@core.Color::Red))
      .value_style(@core.Style::new().fg(@core.Color::Blue)),
      Bar::default()
      .value(20UL)
      .style(@core.Style::new().fg(@core.Color::Green))
      .text_value("20M"),
    ]),
  )
  .data_pairs([("C1", 50UL), ("C2", 40UL)])
  .data_pairs([("C1", 60UL), ("C2", 90UL)])
  .data_pairs([("xx", 10UL), ("xx", 10UL)])
  .group_gap(2)
  .bar_width(4)
  .bar_gap(1)
  .render(area, buffer)
  let expected = @core.Buffer::with_lines([
    "┌─────────────────────────────────┐",
    "│                             ████│", "│                             ████│",
    "│                        ▅▅▅▅ ████│", "│            ▇▇▇▇        ████ ████│",
    "│            ████ ████   ████ ████│", "│     ▄▄▄▄   ████ ████   ████ ████│",
    "│▆10▆ 20M█   █50█ █40█   █60█ █90█│", "│ C1          C1   C2     C1   C2 │",
    "│Mar                              │", "└─────────────────────────────────┘",
  ])
  let bar_rows = terminal_height - 3
  for y in 1..<bar_rows {
    for x in 1..<5 {
      match expected.mut_cell(x, y) {
        Some(cell) => cell.set_fg(@core.Color::Red)
        None => ()
      }
      match expected.mut_cell(x + 5, y) {
        Some(cell) => cell.set_fg(@core.Color::Green)
        None => ()
      }
    }
  }
  match expected.mut_cell(2, 7) {
    Some(cell) => cell.set_fg(@core.Color::Blue)
    None => ()
  }
  match expected.mut_cell(3, 7) {
    Some(cell) => cell.set_fg(@core.Color::Blue)
    None => ()
  }
  @debug.assert_eq(buffer, expected)
}
