///|
/// BarChart 单元测试：复刻 ratatui-v0.30.2 `barchart.rs` /
/// `barchart/bar.rs` / `barchart/bar_group.rs` 内联测试清单喵。
///
/// 样式速记（`.red()` 等）按本库惯例经 `style(...)` 构造等价承载；
/// 上游 `Into` 构造糖按 String/显式构造展开喵。

///|
/// 渲染辅助：空缓冲渲染并返回喵。
fn barchart_render_in(chart : BarChart, area : @core.Rect) -> @core.Buffer {
  let buffer = @core.Buffer::empty(area)
  chart.render(area, buffer)
  buffer
}

///|
/// 单元格样式辅助：染前景/修饰位喵。
fn barchart_style_cell(
  buffer : @core.Buffer,
  x : Int,
  y : Int,
  style : @core.Style,
) -> Unit {
  match buffer.mut_cell(x, y) {
    Some(cell) => cell.set_style(style)
    None => ()
  }
}

///|
/// 上游 default：空图渲染为全空白喵。
test "BarChart 缺省为空白" {
  let buffer = barchart_render_in(
    BarChart::default(),
    @core.Rect::new(0, 0, 10, 3),
  )
  assert_eq(
    buffer,
    @core.Buffer::with_lines(["          ", "          ", "          "]),
  )
}

///|
/// 上游 horizontal_empty_barchart_does_not_panic 喵。
test "BarChart 横向空数据不 panic" {
  let buffer = barchart_render_in(
    BarChart::horizontal([]),
    @core.Rect::new(0, 0, 10, 3),
  )
  inspect(buffer.cells.length(), content="30")
}

///|
/// 上游 constructors_ignore_empty_groups：空柱组被过滤喵。
test "BarChart 构造器过滤空组" {
  inspect(BarChart::of_bars([]).data.is_empty(), content="true")
  inspect(BarChart::horizontal([]).data.is_empty(), content="true")
  let chart = BarChart::grouped([
    BarGroup::new([]),
    BarGroup::new([Bar::new(1UL)]),
  ])
  assert_eq(chart.data, [BarGroup::new([Bar::new(1UL)])])
}

///|
/// 上游 data：值序列渲染柱与值、标签喵。
test "BarChart 数据渲染" {
  let buffer = barchart_render_in(
    BarChart::default().data_pairs([("foo", 1UL), ("bar", 2UL)]),
    @core.Rect::new(0, 0, 10, 3),
  )
  assert_eq(
    buffer,
    @core.Buffer::with_lines(["  █       ", "1 2       ", "f b       "]),
  )
}

///|
/// 上游 block：双线边框块内渲染喵。
test "BarChart 块内渲染" {
  let buffer = barchart_render_in(
    BarChart::default()
    .data_pairs([("foo", 1UL), ("bar", 2UL)])
    .block(Block::bordered().border_type(BorderType::Double).title_str("Block")),
    @core.Rect::new(0, 0, 10, 5),
  )
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "╔Block═══╗", "║  █     ║", "║1 2     ║", "║f b     ║",
      "╚════════╝",
    ]),
  )
}

///|
/// 上游 max：缺省取数据集最大值；显式 max 缩放喵。
test "BarChart 高度上限" {
  let without_max = barchart_render_in(
    BarChart::default().data_pairs([("foo", 1UL), ("bar", 2UL), ("baz", 100UL)]),
    @core.Rect::new(0, 0, 10, 3),
  )
  assert_eq(
    without_max,
    @core.Buffer::with_lines(["    █     ", "    █     ", "f b b     "]),
  )
  let with_max = barchart_render_in(
    BarChart::default()
    .data_pairs([("foo", 1UL), ("bar", 2UL), ("baz", 100UL)])
    .max(2UL),
    @core.Rect::new(0, 0, 10, 3),
  )
  assert_eq(
    with_max,
    @core.Buffer::with_lines(["  █ █     ", "1 2 █     ", "f b b     "]),
  )
}

///|
/// 上游 bar_style：柱缺省样式染柱体与值行喵。
test "BarChart 柱样式" {
  let buffer = barchart_render_in(
    BarChart::default()
    .data_pairs([("foo", 1UL), ("bar", 2UL)])
    .bar_style(@core.Style::new().red()),
    @core.Rect::new(0, 0, 10, 3),
  )
  let expected = @core.Buffer::with_lines([
    "  █       ", "1 2       ", "f b       ",
  ])
  for pair in [(0, 0), (0, 1), (2, 0), (2, 1)] {
    barchart_style_cell(
      expected,
      pair.0,
      pair.1,
      @core.Style::new().fg(@core.Color::Red),
    )
  }
  @debug.assert_eq(buffer, expected)
}

///|
/// 上游 bar_width：柱宽 3，值居中、标签展开喵。
test "BarChart 柱宽" {
  let buffer = barchart_render_in(
    BarChart::default().data_pairs([("foo", 1UL), ("bar", 2UL)]).bar_width(3),
    @core.Rect::new(0, 0, 10, 3),
  )
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "    ███   ", "█1█ █2█   ", "foo bar   ",
    ]),
  )
}

///|
/// 上游 bar_gap：柱距 2 拉开柱与标签喵。
test "BarChart 柱距" {
  let buffer = barchart_render_in(
    BarChart::default().data_pairs([("foo", 1UL), ("bar", 2UL)]).bar_gap(2),
    @core.Rect::new(0, 0, 10, 3),
  )
  assert_eq(
    buffer,
    @core.Buffer::with_lines(["   █      ", "1  2      ", "f  b      "]),
  )
}

///|
/// 上游 bar_set：三级符号集（全/半/空）喵。
test "BarChart 三级符号集" {
  let buffer = barchart_render_in(
    BarChart::default()
    .data_pairs([("foo", 0UL), ("bar", 1UL), ("baz", 3UL)])
    .bar_set(@core.BarSet::three_levels()),
    @core.Rect::new(0, 0, 10, 3),
  )
  assert_eq(
    buffer,
    @core.Buffer::with_lines(["    █     ", "  ▄ 3     ", "f b b     "]),
  )
}

///|
/// 上游 bar_set_nine_levels：九级符号集全档喵。
test "BarChart 九级符号集" {
  let chart = BarChart::default()
    .data_pairs([
      ("a", 0UL),
      ("b", 1UL),
      ("c", 2UL),
      ("d", 3UL),
      ("e", 4UL),
      ("f", 5UL),
      ("g", 6UL),
      ("h", 7UL),
      ("i", 8UL),
    ])
    .bar_set(@core.BarSet::nine_levels())
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 18, 3))
  chart.render(@core.Rect::new(0, 1, 18, 2), buffer)
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "                  ", "  ▁ ▂ ▃ ▄ ▅ ▆ ▇ 8 ", "a b c d e f g h i ",
    ]),
  )
}

///|
/// 上游 value_style：值样式染值字符喵。
test "BarChart 值样式" {
  let buffer = barchart_render_in(
    BarChart::default()
    .data_pairs([("foo", 1UL), ("bar", 2UL)])
    .bar_width(3)
    .value_style(@core.Style::new().red()),
    @core.Rect::new(0, 0, 10, 3),
  )
  let expected = @core.Buffer::with_lines([
    "    ███   ", "█1█ █2█   ", "foo bar   ",
  ])
  barchart_style_cell(expected, 1, 1, @core.Style::new().fg(@core.Color::Red))
  barchart_style_cell(expected, 5, 1, @core.Style::new().fg(@core.Color::Red))
  @debug.assert_eq(buffer, expected)
}

///|
/// 上游 label_style：标签样式染标签行喵。
test "BarChart 标签样式" {
  let buffer = barchart_render_in(
    BarChart::default()
    .data_pairs([("foo", 1UL), ("bar", 2UL)])
    .label_style(@core.Style::new().red()),
    @core.Rect::new(0, 0, 10, 3),
  )
  let expected = @core.Buffer::with_lines([
    "  █       ", "1 2       ", "f b       ",
  ])
  barchart_style_cell(expected, 0, 2, @core.Style::new().fg(@core.Color::Red))
  barchart_style_cell(expected, 2, 2, @core.Style::new().fg(@core.Color::Red))
  @debug.assert_eq(buffer, expected)
}

///|
/// 上游 style：整图样式染一切未显式样式元素喵。
test "BarChart 整图样式" {
  let buffer = barchart_render_in(
    BarChart::default()
    .data_pairs([("foo", 1UL), ("bar", 2UL)])
    .style(@core.Style::new().red()),
    @core.Rect::new(0, 0, 10, 3),
  )
  let expected = @core.Buffer::with_lines([
    "  █       ", "1 2       ", "f b       ",
  ])
  for y in 0..<3 {
    for x in 0..<10 {
      barchart_style_cell(
        expected,
        x,
        y,
        @core.Style::new().fg(@core.Color::Red),
      )
    }
  }
  @debug.assert_eq(buffer, expected)
}

///|
/// 上游 can_be_stylized：样式构造与显式构造等价喵。
test "BarChart 可被样式化" {
  assert_eq(
    BarChart::default().style(@core.Style::new().black().on_white().bold()).style,
    @core.Style::new()
    .fg(@core.Color::Black)
    .bg(@core.Color::White)
    .add_modifier(@core.Modifier::bold()),
  )
}

///|
/// 上游 test_empty_group：空组不占位、组标签照常喵。
test "BarChart 空组过滤" {
  let chart = BarChart::default()
    .data(BarGroup::default().label_str("invisible"))
    .data(
      BarGroup::default()
      .label_str("G")
      .bars([Bar::default().value(1UL), Bar::default().value(2UL)]),
    )
  let buffer = barchart_render_in(chart, @core.Rect::new(0, 0, 3, 3))
  assert_eq(buffer, @core.Buffer::with_lines(["  █", "1 2", "G  "]))
}

///|
/// 上游 build_test_barchart fixture：双组横向柱喵。
fn build_test_barchart() -> BarChart {
  BarChart::default()
  .data(
    BarGroup::default()
    .label_str("G1")
    .bars([
      Bar::default().value(2UL),
      Bar::default().value(3UL),
      Bar::default().value(4UL),
    ]),
  )
  .data(
    BarGroup::default()
    .label_str("G2")
    .bars([
      Bar::default().value(3UL),
      Bar::default().value(4UL),
      Bar::default().value(5UL),
    ]),
  )
  .group_gap(1)
  .direction(@core.Horizontal)
  .bar_gap(0)
}

///|
/// 上游 test_horizontal_bars：横向双组完整渲染喵。
test "BarChart 横向双组" {
  let buffer = barchart_render_in(
    build_test_barchart(),
    @core.Rect::new(0, 0, 5, 8),
  )
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "2█   ", "3██  ", "4███ ", "G1   ", "3██  ", "4███ ",
      "5████", "G2   ",
    ]),
  )
}

///|
/// 上游 test_horizontal_bars_no_space_for_group_label：高度不足时
/// 第二组组标签不渲染喵。
test "BarChart 横向无组标签空间" {
  let buffer = barchart_render_in(
    build_test_barchart(),
    @core.Rect::new(0, 0, 5, 7),
  )
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "2█   ", "3██  ", "4███ ", "G1   ", "3██  ", "4███ ",
      "5████",
    ]),
  )
}

///|
/// 上游 test_horizontal_bars_no_space_for_all_bars：空间不足时第二组
/// 只渲染前几根柱喵。
test "BarChart 横向柱数截断" {
  let buffer = barchart_render_in(
    build_test_barchart(),
    @core.Rect::new(0, 0, 5, 5),
  )
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "2█   ", "3██  ", "4███ ", "G1   ", "3██  ",
    ]),
  )
}

///|
/// 上游 test_horizontal_bars_label_width_greater_than_bar：值文本长于
/// 柱体时柱内段用值样式、溢出段用柱样式（含可选柱样式覆盖）喵。
fn horizontal_label_width_case(bar_color : @core.Color?) -> Unit raise {
  let mut bar = Bar::default()
    .value(2UL)
    .text_value("label")
    .value_style(@core.Style::new().fg(@core.Color::Red))
  match bar_color {
    Some(color) => bar = bar.style(@core.Style::new().fg(color))
    None => ()
  }
  let chart = BarChart::default()
    .data(BarGroup::default().bars([bar, Bar::default().value(5UL)]))
    .direction(@core.Horizontal)
    .bar_style(@core.Style::new().yellow())
    .value_style(@core.Style::new().italic())
    .bar_gap(0)
  let buffer = barchart_render_in(chart, @core.Rect::new(0, 0, 5, 2))
  let expected = @core.Buffer::with_lines(["label", "5████"])
  // 值行：柱体黄色；首格 "5" 带斜体（值样式）喵。
  match expected.mut_cell(0, 1) {
    Some(cell) => cell.modifier = cell.modifier.insert(@core.Modifier::italic())
    None => ()
  }
  for x in 0..<5 {
    match expected.mut_cell(x, 1) {
      Some(cell) => cell.set_fg(@core.Color::Yellow)
      None => ()
    }
  }
  // "label" 行：前 2 字符斜体红（值样式），其余取柱样式喵。
  let expected_color = match bar_color {
    Some(color) => color
    None => @core.Color::Yellow
  }
  match expected.mut_cell(0, 0) {
    Some(cell) => {
      cell.set_fg(@core.Color::Red)
      cell.modifier = cell.modifier.insert(@core.Modifier::italic())
    }
    None => ()
  }
  match expected.mut_cell(1, 0) {
    Some(cell) => {
      cell.set_fg(@core.Color::Red)
      cell.modifier = cell.modifier.insert(@core.Modifier::italic())
    }
    None => ()
  }
  for x in 2..<5 {
    match expected.mut_cell(x, 0) {
      Some(cell) => cell.set_fg(expected_color)
      None => ()
    }
  }
  @debug.assert_eq(buffer, expected)
}

///|
/// 上游 test_horizontal_bars_label_width_greater_than_bar_without_style 喵。
test "BarChart 值文本溢出（无柱样式）" {
  horizontal_label_width_case(None)
}

///|
/// 上游 test_horizontal_bars_label_width_greater_than_bar_with_style 喵。
test "BarChart 值文本溢出（白柱样式）" {
  horizontal_label_width_case(Some(@core.Color::White))
}

///|
/// 上游 test_horizontal_label：横向柱标签在柱内喵。
test "BarChart 横向标签" {
  let chart = BarChart::default()
    .direction(@core.Horizontal)
    .bar_gap(0)
    .data_pairs([("Jan", 10UL), ("Feb", 20UL), ("Mar", 5UL)])
  let buffer = barchart_render_in(chart, @core.Rect::new(0, 0, 10, 3))
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "Jan 10█   ", "Feb 20████", "Mar 5     ",
    ]),
  )
}

///|
/// 上游 test_group_label_style：组标签样式 = 标签行样式 patch 行自带
/// 样式（bold 黄打底 + 红前景）喵。
test "BarChart 组标签样式" {
  let chart = BarChart::default()
    .data(
      BarGroup::default()
      .label(@core.Line::styled("G1", @core.Style::new().red()))
      .bars([Bar::default().value(2UL)]),
    )
    .group_gap(1)
    .direction(@core.Horizontal)
    .label_style(@core.Style::new().bold().yellow())
  let buffer = barchart_render_in(chart, @core.Rect::new(0, 0, 5, 2))
  let expected = @core.Buffer::with_lines(["2████", "G1   "])
  match expected.mut_cell(0, 1) {
    Some(cell) => {
      cell.set_fg(@core.Color::Red)
      cell.modifier = cell.modifier.insert(@core.Modifier::bold())
    }
    None => ()
  }
  match expected.mut_cell(1, 1) {
    Some(cell) => {
      cell.set_fg(@core.Color::Red)
      cell.modifier = cell.modifier.insert(@core.Modifier::bold())
    }
    None => ()
  }
  @debug.assert_eq(buffer, expected)
}

///|
/// 上游 test_group_label_center：居中组标签（含第二组被截断）喵。
test "BarChart 组标签居中" {
  let group = BarGroup::of_pairs([
    ("a", 1UL),
    ("b", 2UL),
    ("c", 3UL),
    ("c", 4UL),
  ])
  let chart = BarChart::default()
    .data(group.label(@core.Line::raw("G1").centered()))
    .data(
      BarGroup::of_pairs([("a", 1UL), ("b", 2UL), ("c", 3UL), ("c", 4UL)]).label(
        @core.Line::raw("G2").centered(),
      ),
    )
  let buffer = barchart_render_in(chart, @core.Rect::new(0, 0, 13, 5))
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "    ▂ █     ▂", "  ▄ █ █   ▄ █", "▆ 2 3 4 ▆ 2 3", "a b c c a b c",
      "  G1     G2  ",
    ]),
  )
}

///|
/// 上游 test_group_label_right：右对齐组标签喵。
test "BarChart 组标签右对齐" {
  let chart = BarChart::default().data(
    BarGroup::default()
    .label(@core.Line::raw("G").right_aligned())
    .bars([Bar::default().value(2UL), Bar::default().value(5UL)]),
  )
  let buffer = barchart_render_in(chart, @core.Rect::new(0, 0, 3, 3))
  assert_eq(buffer, @core.Buffer::with_lines(["  █", "▆ 5", "  G"]))
}

///|
/// 上游 test_unicode_as_value：CJK 值文本在柱内渲染（宽度 2）喵。
test "BarChart CJK 值文本" {
  let group = BarGroup::default().bars([
    Bar::default().value(123UL).label_str("B1").text_value("写"),
    Bar::default().value(321UL).label_str("B2").text_value("写"),
    Bar::default().value(333UL).label_str("B2").text_value("写"),
  ])
  let chart = BarChart::default().data(group).bar_width(3).bar_gap(1)
  let buffer = barchart_render_in(chart, @core.Rect::new(0, 0, 11, 5))
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "    ▆▆▆ ███", "    ███ ███", "▃▃▃ ███ ███",
      "写█ 写█ 写█", "B1  B2  B2 ",
    ]),
  )
}

///|
/// 上游 handles_zero_width：零柱宽/零柱距不 panic 喵。
test "BarChart 零柱宽不 panic" {
  let chart = BarChart::default()
    .data_pairs([("A", 1UL)])
    .bar_width(0)
    .bar_gap(0)
  let buffer = barchart_render_in(chart, @core.Rect::new(0, 0, 0, 10))
  assert_eq(buffer, @core.Buffer::empty(@core.Rect::new(0, 0, 0, 10)))
}

///|
/// 上游 single_line：单行高度只剩值行喵。
test "BarChart 单行" {
  let group = BarGroup::of_pairs([
    ("a", 0UL),
    ("b", 1UL),
    ("c", 2UL),
    ("d", 3UL),
    ("e", 4UL),
    ("f", 5UL),
    ("g", 6UL),
    ("h", 7UL),
    ("i", 8UL),
  ]).label_str("Group")
  let chart = BarChart::default()
    .data(group)
    .bar_set(@core.BarSet::nine_levels())
  let buffer = barchart_render_in(chart, @core.Rect::new(0, 0, 17, 1))
  assert_eq(
    buffer,
    @core.Buffer::with_lines(["  ▁ ▂ ▃ ▄ ▅ ▆ ▇ 8"]),
  )
}

///|
/// 上游 two_lines：两行 = 值行 + 标签行喵。
test "BarChart 两行" {
  let group = BarGroup::of_pairs([
    ("a", 0UL),
    ("b", 1UL),
    ("c", 2UL),
    ("d", 3UL),
    ("e", 4UL),
    ("f", 5UL),
    ("g", 6UL),
    ("h", 7UL),
    ("i", 8UL),
  ]).label_str("Group")
  let chart = BarChart::default()
    .data(group)
    .bar_set(@core.BarSet::nine_levels())
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 17, 3))
  chart.render(@core.Rect::new(0, 1, 17, 2), buffer)
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "                 ", "  ▁ ▂ ▃ ▄ ▅ ▆ ▇ 8", "a b c d e f g h i",
    ]),
  )
}

///|
/// 上游 three_lines：三行 = 值行 + 标签行 + 组标签行（居中）喵。
test "BarChart 三行" {
  let group = BarGroup::of_pairs([
    ("a", 0UL),
    ("b", 1UL),
    ("c", 2UL),
    ("d", 3UL),
    ("e", 4UL),
    ("f", 5UL),
    ("g", 6UL),
    ("h", 7UL),
    ("i", 8UL),
  ]).label(@core.Line::raw("Group").centered())
  let chart = BarChart::default()
    .data(group)
    .bar_set(@core.BarSet::nine_levels())
  let buffer = barchart_render_in(chart, @core.Rect::new(0, 0, 17, 3))
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "  ▁ ▂ ▃ ▄ ▅ ▆ ▇ 8", "a b c d e f g h i", "      Group      ",
    ]),
  )
}

///|
/// 上游 three_lines_double_width：柱宽 2 的值居中（字节长度语义）喵。
test "BarChart 三行双倍柱宽" {
  let group = BarGroup::of_pairs([
    ("a", 0UL),
    ("b", 1UL),
    ("c", 2UL),
    ("d", 3UL),
    ("e", 4UL),
    ("f", 5UL),
    ("g", 6UL),
    ("h", 7UL),
    ("i", 8UL),
  ]).label(@core.Line::raw("Group").centered())
  let chart = BarChart::default()
    .data(group)
    .bar_width(2)
    .bar_set(@core.BarSet::nine_levels())
  let buffer = barchart_render_in(chart, @core.Rect::new(0, 0, 26, 3))
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "   1▁ 2▂ 3▃ 4▄ 5▅ 6▆ 7▇ 8█", "a  b  c  d  e  f  g  h  i ",
      "          Group           ",
    ]),
  )
}

///|
/// 上游 four_lines：四行时高柱分两段显示喵。
test "BarChart 四行" {
  let group = BarGroup::of_pairs([
    ("a", 0UL),
    ("b", 1UL),
    ("c", 2UL),
    ("d", 3UL),
    ("e", 4UL),
    ("f", 5UL),
    ("g", 6UL),
    ("h", 7UL),
    ("i", 8UL),
  ]).label(@core.Line::raw("Group").centered())
  let chart = BarChart::default()
    .data(group)
    .bar_set(@core.BarSet::nine_levels())
  let buffer = barchart_render_in(chart, @core.Rect::new(0, 0, 17, 4))
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "          ▂ ▄ ▆ █", "  ▂ ▄ ▆ 4 5 6 7 8", "a b c d e f g h i",
      "      Group      ",
    ]),
  )
}

///|
/// 上游 two_lines_without_bar_labels：无柱标签时组标签占一行喵。
test "BarChart 两行无柱标签" {
  let bars : Array[Bar] = []
  for i in 0..<9 {
    bars.push(Bar::default().value(i.to_uint64()))
  }
  let group = BarGroup::default()
    .label(@core.Line::raw("Group").centered())
    .bars(bars)
  let chart = BarChart::default().data(group)
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 17, 3))
  chart.render(@core.Rect::new(0, 1, 17, 2), buffer)
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "                 ", "  ▁ ▂ ▃ ▄ ▅ ▆ ▇ 8", "      Group      ",
    ]),
  )
}

///|
/// 上游 one_lines_with_more_bars：30 根柱挤进单行喵。
test "BarChart 单行 30 柱" {
  let bars : Array[Bar] = []
  for i in 0..<30 {
    bars.push(Bar::default().value(i.to_uint64()))
  }
  let chart = BarChart::default().data(BarGroup::default().bars(bars))
  let buffer = barchart_render_in(chart, @core.Rect::new(0, 0, 59, 1))
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "        ▁ ▁ ▁ ▁ ▂ ▂ ▂ ▃ ▃ ▃ ▃ ▄ ▄ ▄ ▄ ▅ ▅ ▅ ▆ ▆ ▆ ▆ ▇ ▇ ▇ █",
    ]),
  )
}

///|
/// 上游 first_bar_of_the_group_is_half_outside_view：首组被挤出视口喵。
test "BarChart 首组半出界" {
  let chart = BarChart::default()
    .data_pairs([("a", 1UL), ("b", 2UL)])
    .data_pairs([("a", 1UL), ("b", 2UL)])
    .bar_width(2)
  let buffer = barchart_render_in(chart, @core.Rect::new(0, 0, 7, 6))
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "   ██  ", "   ██  ", "▄▄ ██  ", "██ ██  ", "1█ 2█  ",
      "a  b   ",
    ]),
  )
}

///|
/// 上游 render_handles_u64_max_value：u64::MAX 满量程不溢出喵。
test "BarChart u64 上限值" {
  let chart = BarChart::of_bars([Bar::new(18446744073709551615UL)]).max(
    18446744073709551615UL,
  )
  let buffer = barchart_render_in(chart, @core.Rect::new(0, 0, 5, 5))
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "█    ", "█    ", "█    ", "█    ", "█    ",
    ]),
  )
}

///|
/// 上游 render_keeps_integer_precision_for_large_values：整数精度喵。
test "BarChart 大数值整数精度" {
  let chart = BarChart::of_bars([Bar::new(18446744073709551614UL)]).max(
    18446744073709551615UL,
  )
  let buffer = barchart_render_in(chart, @core.Rect::new(0, 0, 1, 1))
  assert_eq(buffer, @core.Buffer::with_lines(["▇"]))
}

///|
/// 上游 test_barchart_new + data 追加语义喵。
test "BarChart 构造与追加" {
  let bars = [
    Bar::with_label_str("Red", 1UL),
    Bar::with_label_str("Green", 2UL),
  ]
  let chart = BarChart::of_bars(bars)
  inspect(chart.data.length(), content="1")
  assert_eq(chart.data[0].bars, bars)
  let updated = chart.data_pairs([("Blue", 3UL)])
  inspect(updated.data.length(), content="2")
  assert_eq(updated.data[1].bars, [Bar::with_label_str("Blue", 3UL)])
}

///|
/// 上游 regression_1928：多字节值文本渲染不 panic（窄不换行空格）喵。
test "BarChart issue 1928 回归" {
  let text_value = "\u{202f}"
  let bars : Array[Bar] = []
  for i in 0..<5 {
    bars.push(Bar::default().text_value(text_value).value(i.to_uint64()))
  }
  let chart = BarChart::default()
    .data(BarGroup::default().bars(bars))
    .bar_gap(0)
    .direction(@core.Horizontal)
  let buffer = barchart_render_in(chart, @core.Rect::new(0, 0, 4, 5))
  let nbsp = "\u{202f}"
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "\{nbsp}   ",
      "\{nbsp}   ",
      "\{nbsp}█  ",
      "\{nbsp}██ ",
      "\{nbsp}███",
    ]),
  )
}

///|
/// 上游 render_in_minimal_buffer：1×1 缓冲双方向不 panic 喵。
test "BarChart 极小缓冲渲染" {
  for direction in [@core.Horizontal, @core.Vertical] {
    let chart = BarChart::default()
      .data_pairs([("A", 1UL), ("B", 2UL)])
      .bar_width(3)
      .bar_gap(1)
      .direction(direction)
    let buffer = barchart_render_in(chart, @core.Rect::new(0, 0, 1, 1))
    assert_eq(buffer, @core.Buffer::with_lines([" "]))
  }
}

///|
/// 上游 render_in_zero_size_buffer：零尺寸缓冲双方向不 panic 喵。
test "BarChart 零尺寸缓冲渲染" {
  for direction in [@core.Horizontal, @core.Vertical] {
    let chart = BarChart::default()
      .data_pairs([("A", 1UL), ("B", 2UL)])
      .bar_width(3)
      .bar_gap(1)
      .direction(direction)
    let buffer = barchart_render_in(chart, @core.Rect::new(0, 0, 0, 0))
    inspect(buffer.cells.length(), content="0")
  }
}

///|
/// 上游 bar.rs test_bar_new / test_bar_with_label / test_bar_stylized 喵。
test "Bar 构造与样式" {
  let bar = Bar::new(42UL).label(@core.Line::raw("Label"))
  assert_eq(bar.label, Some(@core.Line::raw("Label")))
  inspect(bar.value.to_string(), content="42")
  let with_label = Bar::with_label_str("Label", 42UL)
  assert_eq(with_label.label, Some(@core.Line::raw("Label")))
  inspect(with_label.value.to_string(), content="42")
  let stylized = Bar::default().style(@core.Style::new().red().bold())
  assert_eq(
    stylized.style,
    @core.Style::new().fg(@core.Color::Red).add_modifier(@core.Modifier::bold()),
  )
}

///|
/// 上游 bar_group.rs test_bargroup_new 喵。
test "BarGroup 构造" {
  let group = BarGroup::new([
    Bar::with_label_str("Label1", 1UL),
    Bar::with_label_str("Label2", 2UL),
  ]).label(@core.Line::raw("Group1"))
  assert_eq(group.label, Some(@core.Line::raw("Group1")))
  inspect(group.bars.length(), content="2")
}
