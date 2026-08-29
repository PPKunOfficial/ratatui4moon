///|
/// Gauge 集成黄金用例：复刻 ratatui-v0.30.2 `ratatui/tests/widgets_gauge.rs`
/// 全部 5 条测试喵。
///
/// 上游经 Terminal/TestBackend/assert_buffer 驱动；terminal 会话层
/// 未复刻前以等价的"直渲染 + Buffer 全量比对"承载（被测行为一致）。
/// 上游 `assert_buffer` 等价为 `@debug.assert_eq(buffer, expected)`；
/// `assert_buffer_lines` 等价为 `assert_rows_exact`（全宽逐行比对，
/// 不裁尾空格）。上游 `Layout`（margin 2 + Vertical 50/50 on 40×10）
/// 求解器未落位，分区结果按 ADR-3 线性等分预计算：
/// chunks[0]=(2,2,36,3)、chunks[1]=(2,5,36,3) 喵。

///|
/// 上游 assert_buffer_lines：全宽逐行符号串比对（不裁尾空格）喵。
fn assert_rows_exact(
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
/// 上游 widgets_gauge_renders：unicode 半格精度 + 块内居中标签 +
/// 填充/标签互换样式矩阵喵。
test "Gauge unicode 渲染矩阵" {
  let buf = @core.Buffer::empty(@core.Rect::new(0, 0, 40, 10))
  let gauge_style = @core.Style::new()
    .bg(@core.Color::Blue)
    .fg(@core.Color::Red)
  Gauge::default()
  .block(Block::bordered().title_str("Percentage"))
  .gauge_style(gauge_style)
  .use_unicode(true)
  .percent(43)
  .render(@core.Rect::new(2, 2, 36, 3), buf)
  Gauge::default()
  .block(Block::bordered().title_str("Ratio"))
  .gauge_style(gauge_style)
  .use_unicode(true)
  .ratio(0.5113139343131)
  .render(@core.Rect::new(2, 5, 36, 3), buf)
  let expected = @core.Buffer::with_lines([
    "                                        ", "                                        ",
    "  ┌Percentage────────────────────────┐  ",
    "  │██████████████▋43%                │  ",
    "  └──────────────────────────────────┘  ",
    "  ┌Ratio─────────────────────────────┐  ",
    "  │███████████████51%                │  ",
    "  └──────────────────────────────────┘  ",
    "                                        ", "                                        ",
  ])
  expected.set_style(
    @core.Rect::new(3, 3, 34, 1),
    @core.Style::new().red().on_blue(),
  )
  expected.set_style(
    @core.Rect::new(3, 6, 15, 1),
    @core.Style::new().red().on_blue(),
  )
  // 标签遮挡的填充段：前/背景互换（5、1 两格，% 不在填充段）喵。
  expected.set_style(
    @core.Rect::new(18, 6, 2, 1),
    @core.Style::new().blue().on_red(),
  )
  expected.set_style(
    @core.Rect::new(20, 6, 17, 1),
    @core.Style::new().red().on_blue(),
  )
  @debug.assert_eq(buf, expected)
}

///|
/// 上游 widgets_gauge_renders_no_unicode：非 unicode 走 round 取整，
/// 填充止于 end 列，标签右侧保持空白喵。
test "Gauge 非 unicode 渲染矩阵" {
  let buf = @core.Buffer::empty(@core.Rect::new(0, 0, 40, 10))
  Gauge::default()
  .block(Block::bordered().title_str("Percentage"))
  .percent(43)
  .use_unicode(false)
  .render(@core.Rect::new(2, 2, 36, 3), buf)
  Gauge::default()
  .block(Block::bordered().title_str("Ratio"))
  .ratio(0.2113139343131)
  .use_unicode(false)
  .render(@core.Rect::new(2, 5, 36, 3), buf)
  assert_rows_exact(buf, [
    "                                        ", "                                        ",
    "  ┌Percentage────────────────────────┐  ",
    "  │███████████████43%                │  ",
    "  └──────────────────────────────────┘  ",
    "  ┌Ratio─────────────────────────────┐  ",
    "  │███████        21%                │  ", "  └──────────────────────────────────┘  ",
    "                                        ", "                                        ",
  ])
}

///|
/// 上游 widgets_gauge_applies_styles：块标题样式 / gauge_style /
/// 自定义标签样式三层叠加，标签前景取标签样式、背景取所在格喵。
test "Gauge 样式叠加矩阵" {
  let buf = @core.Buffer::empty(@core.Rect::new(0, 0, 12, 5))
  Gauge::default()
  .block(
    Block::bordered().title(
      @core.Line::styled("Test", @core.Style::new().fg(@core.Color::Red)),
    ),
  )
  .gauge_style(@core.Style::new().fg(@core.Color::Blue).bg(@core.Color::Red))
  .percent(43)
  .label(
    @core.Span::styled(
      "43%",
      @core.Style::new()
      .fg(@core.Color::Green)
      .add_modifier(@core.Modifier::bold()),
    ),
  )
  .render(buf.area, buf)
  let expected = @core.Buffer::with_lines([
    "┌Test──────┐", "│████      │", "│███43%    │",
    "│████      │", "└──────────┘",
  ])
  // 标题喵。
  expected.set_style(
    @core.Rect::new(1, 0, 4, 1),
    @core.Style::new().fg(@core.Color::Red),
  )
  // gauge 区域（含标签行互换格）喵。
  expected.set_style(
    @core.Rect::new(1, 1, 10, 3),
    @core.Style::new().fg(@core.Color::Blue).bg(@core.Color::Red),
  )
  // 填充段喵。
  expected.set_style(
    @core.Rect::new(1, 1, 4, 3),
    @core.Style::new().fg(@core.Color::Blue).bg(@core.Color::Red),
  )
  // 标签 "4"：在填充段内，背景取 gauge_style 前景喵。
  expected.set_style(
    @core.Rect::new(4, 2, 1, 1),
    @core.Style::new()
    .fg(@core.Color::Green)
    .bg(@core.Color::Blue)
    .add_modifier(@core.Modifier::bold()),
  )
  // 标签 "3%"：不在填充段内，背景取 gauge_style 背景喵。
  expected.set_style(
    @core.Rect::new(5, 2, 2, 1),
    @core.Style::new()
    .fg(@core.Color::Green)
    .bg(@core.Color::Red)
    .add_modifier(@core.Modifier::bold()),
  )
  @debug.assert_eq(buf, expected)
}

///|
/// 上游 widgets_gauge_supports_large_labels：超宽标签截断占满整行喵。
test "Gauge 超宽标签" {
  let buf = @core.Buffer::empty(@core.Rect::new(0, 0, 10, 1))
  Gauge::default()
  .percent(43)
  .label_str("43333333333333333333333333333%")
  .render(buf.area, buf)
  assert_rows_exact(buf, ["4333333333"])
}

///|
/// 上游 widgets_line_gauge_renders：单行进度条四连渲染，覆盖缺省
/// 标签、块内布局、自定义填充/空置符号喵。
test "LineGauge 渲染矩阵" {
  let buf = @core.Buffer::empty(@core.Rect::new(0, 0, 20, 6))
  LineGauge::default()
  .filled_style(@core.Style::new().fg(@core.Color::Green))
  .unfilled_style(@core.Style::new().fg(@core.Color::White))
  .ratio(0.43)
  .render(@core.Rect::new(0, 0, 20, 1), buf)
  // 填充/空置同用粗横线符号喵。
  LineGauge::default()
  .block(Block::bordered().title_str("Gauge 2"))
  .filled_style(@core.Style::new().fg(@core.Color::Green))
  .filled_symbol(@core.LINE_THICK_HORIZONTAL)
  .unfilled_symbol(@core.LINE_THICK_HORIZONTAL)
  .ratio(0.2113139343131)
  .render(@core.Rect::new(0, 1, 20, 3), buf)
  // 填充缺省符号，空置为空格喵。
  LineGauge::default()
  .unfilled_symbol(" ")
  .ratio(0.5)
  .render(@core.Rect::new(0, 4, 20, 1), buf)
  // 填充/空置各用自定义符号（█/░）喵。
  LineGauge::default()
  .filled_symbol("█")
  .unfilled_symbol("░")
  .ratio(0.8)
  .render(@core.Rect::new(0, 5, 20, 1), buf)
  let expected = @core.Buffer::with_lines([
    " 43% ───────────────", "┌Gauge 2───────────┐",
    "│ 21% ━━━━━━━━━━━━━│", "└──────────────────┘",
    " 50% ───────        ", " 80% ████████████░░░",
  ])
  for col in 5..<11 {
    match expected.mut_cell(col, 0) {
      Some(cell) => cell.set_fg(@core.Color::Green)
      None => ()
    }
  }
  for col in 11..<20 {
    match expected.mut_cell(col, 0) {
      Some(cell) => cell.set_fg(@core.Color::White)
      None => ()
    }
  }
  for col in 6..<8 {
    match expected.mut_cell(col, 2) {
      Some(cell) => cell.set_fg(@core.Color::Green)
      None => ()
    }
  }
  @debug.assert_eq(buf, expected)
}
