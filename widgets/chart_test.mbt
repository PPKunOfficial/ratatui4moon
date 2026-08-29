// 上游 `chart.rs` 内联测试逐条复刻：rstest 参数矩阵以数组循环承载；
// stylize 速记按本库惯例经 Style 糖 + set_style 承载喵。
//
// 不可移植登记：上游 `it_should_hide_the_legend` /
// `datasets_without_name_dont_contribute_to_legend_height` /
// `no_legend_if_no_named_datasets` 对包私有 `Chart::layout` 直断；
// 本库包私有项不可从测试文件直测（仓库惯例），以渲染等价承载：
// 图例框落位/尺寸由边框字符与邻格空白精确锚定，语义无损喵。

///|
/// 渲染辅助：空缓冲渲染图表并返回喵。
fn chart_render_in(chart : Chart, area : @core.Rect) -> @core.Buffer {
  let buffer = @core.Buffer::empty(area)
  chart.render(area, buffer)
  buffer
}

///|
/// 单元格符号读取辅助喵。
fn chart_cell_symbol(buffer : @core.Buffer, x : Int, y : Int) -> String {
  match buffer.cell(x, y) {
    Some(cell) => cell.symbol()
    None => "<oob>"
  }
}

///|
/// 上游 `it_should_hide_the_legend`（渲染等价承载）：约束满足时
/// 图例恰好落在 (88,0,12,12)，不满足时整体隐藏喵。
test "Chart 图例显隐随约束" {
  let data = [(0.0, 5.0), (1.0, 6.0), (3.0, 7.0)]
  let datasets : Array[ChartDataset] = []
  for i in 0..<10 {
    datasets.push(ChartDataset::default().name_str("Dataset #\{i}").data(data))
  }
  // Ratio(1,4)/(1,4)：图例显示于 (88,0,12,12) 喵。
  let shown = chart_render_in(
    Chart::new(datasets)
    .x_axis(ChartAxis::default().title_str("X axis"))
    .y_axis(ChartAxis::default().title_str("Y axis"))
    .hidden_legend_constraints((@core.Ratio(1, 4), @core.Ratio(1, 4))),
    @core.Rect::new(0, 0, 100, 100),
  )
  inspect(chart_cell_symbol(shown, 88, 0), content="┌")
  inspect(chart_cell_symbol(shown, 99, 0), content="┐")
  inspect(chart_cell_symbol(shown, 88, 11), content="└")
  inspect(chart_cell_symbol(shown, 99, 11), content="┘")
  // 框外邻格必须空白，钉死尺寸恰为 12x12 喵。
  inspect(chart_cell_symbol(shown, 87, 0), content=" ")
  inspect(chart_cell_symbol(shown, 88, 12), content=" ")
  // Ratio(1,10) 宽度约束：图例隐藏喵。
  let hidden = chart_render_in(
    Chart::new(datasets)
    .x_axis(ChartAxis::default().title_str("X axis"))
    .y_axis(ChartAxis::default().title_str("Y axis"))
    .hidden_legend_constraints((@core.Ratio(1, 10), @core.Ratio(1, 4))),
    @core.Rect::new(0, 0, 100, 100),
  )
  inspect(chart_cell_symbol(hidden, 88, 0), content=" ")
}

///|
/// 上游 `axis_can_be_stylized`：Styled 速记链逐位等价喵。
test "ChartAxis 可样式化" {
  @debug.assert_eq(
    ChartAxis::default()
    .set_style(@core.Style::new().black().on_white().bold().not_dim())
    .get_style(),
    @core.Style::new()
    .fg(@core.Black)
    .bg(@core.White)
    .add_modifier(@core.Modifier::bold())
    .remove_modifier(@core.Modifier::dim()),
  )
}

///|
/// 上游 `dataset_can_be_stylized` 喵。
test "ChartDataset 可样式化" {
  @debug.assert_eq(
    ChartDataset::default()
    .set_style(@core.Style::new().black().on_white().bold().not_dim())
    .get_style(),
    @core.Style::new()
    .fg(@core.Black)
    .bg(@core.White)
    .add_modifier(@core.Modifier::bold())
    .remove_modifier(@core.Modifier::dim()),
  )
}

///|
/// 上游 `chart_can_be_stylized` 喵。
test "Chart 可样式化" {
  @debug.assert_eq(
    Chart::new([])
    .set_style(@core.Style::new().black().on_white().bold().not_dim())
    .get_style(),
    @core.Style::new()
    .fg(@core.Black)
    .bg(@core.White)
    .add_modifier(@core.Modifier::bold())
    .remove_modifier(@core.Modifier::dim()),
  )
}

///|
/// 上游 `graph_type_to_string` 喵。
test "GraphType Display" {
  inspect(GraphType::Scatter.name(), content="Scatter")
  inspect(GraphType::Line.name(), content="Line")
  inspect(GraphType::Bar.name(), content="Bar")
  inspect(GraphType::Area.name(), content="Area")
}

///|
/// 上游 `graph_type_from_str` 喵。
test "GraphType EnumString" {
  @debug.assert_eq(GraphType::from_str("Scatter"), Some(GraphType::Scatter))
  @debug.assert_eq(GraphType::from_str("Line"), Some(GraphType::Line))
  @debug.assert_eq(GraphType::from_str("Bar"), Some(GraphType::Bar))
  @debug.assert_eq(GraphType::from_str(""), None)
}

///|
/// 上游 `it_does_not_panic_if_title_is_wider_than_buffer`：标题超宽
/// 不 panic 且整体空白喵。
test "Chart 超宽标题不 panic" {
  let widget = Chart::new([])
    .y_axis(ChartAxis::default().title_str("xxxxxxxxxxxxxxxx"))
    .x_axis(ChartAxis::default().title_str("xxxxxxxxxxxxxxxx"))
  let buffer = chart_render_in(widget, @core.Rect::new(0, 0, 8, 4))
  assert_eq(
    buffer,
    @core.Buffer::with_lines(["        ", "        ", "        ", "        "]),
  )
}

///|
/// 上游 `it_does_not_panic_if_y_axis_has_one_label`：单标签不 panic 喵。
test "Chart Y 轴单标签不 panic" {
  let widget = Chart::new([]).y_axis(
    ChartAxis::default().bounds((0.0, 1.0)).labels_of_str(["only"]),
  )
  let _buffer = chart_render_in(widget, @core.Rect::new(0, 0, 20, 5))
}

///|
/// 上游 `datasets_without_name_dont_contribute_to_legend_height`
/// （渲染等价承载）：匿名数据集不占图例行，图例高恰为 4 喵。
test "Chart 匿名数据集不占图例行" {
  let data_named_1 = ChartDataset::default().name_str("data1")
  let data_named_2 = ChartDataset::default().name_str("")
  let data_unnamed = ChartDataset::default()
  let widget = Chart::new([data_named_1, data_unnamed, data_named_2])
  let buffer = chart_render_in(widget, @core.Rect::new(0, 0, 50, 25))
  // 图例宽 = "data1" 宽 + 2 = 7，TopRight 落位于 (43,0,7,4) 喵。
  inspect(chart_cell_symbol(buffer, 43, 0), content="┌")
  inspect(chart_cell_symbol(buffer, 49, 0), content="┐")
  inspect(chart_cell_symbol(buffer, 43, 3), content="└")
  inspect(chart_cell_symbol(buffer, 49, 3), content="┘")
  // 第 5 行必须是框外空白（若匿名数据集占行则此格为 └）喵。
  inspect(chart_cell_symbol(buffer, 43, 4), content=" ")
}

///|
/// 上游 `no_legend_if_no_named_datasets`（渲染等价承载）：全匿名
/// 不出图例喵。
test "Chart 全匿名无图例" {
  let widget = Chart::new([
    ChartDataset::default(),
    ChartDataset::default(),
    ChartDataset::default(),
  ])
  let buffer = chart_render_in(widget, @core.Rect::new(0, 0, 50, 25))
  for i, cell in buffer.cells {
    if cell.symbol() == "┌" {
      // 图例框不存在才算通过喵。
      inspect(i, content="no legend box")
    }
  }
}

///|
/// 上游 `dataset_legend_style_is_patched`：图例行样式被数据集样式
/// 补丁，命名行内对齐保持喵。
test "Chart 图例样式补丁" {
  let long_dataset_name = ChartDataset::default().name_str("Very long name")
  let short_dataset = ChartDataset::default().name(
    @core.Line::raw("Short name").right_aligned(),
  )
  let widget = Chart::new([long_dataset_name, short_dataset]).hidden_legend_constraints(
    (@core.Percentage(100), @core.Percentage(100)),
  )
  let buffer = chart_render_in(widget, @core.Rect::new(0, 0, 20, 5))
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "    ┌──────────────┐", "    │Very long name│",
      "    │    Short name│", "    └──────────────┘",
      "                    ",
    ]),
  )
}

///|
/// 上游 `test_chart_have_a_topleft_legend` 喵。
test "Chart 左上图例" {
  let chart = Chart::new([ChartDataset::default().name_str("Ds1")]).legend_position(
    Some(LegendPosition::TopLeft),
  )
  let buffer = chart_render_in(chart, @core.Rect::new(0, 0, 30, 20))
  let blank = "                              "
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "┌───┐                         ", "│Ds1│                         ",
      "└───┘                         ", blank, blank, blank, blank, blank,
      blank, blank, blank, blank, blank, blank, blank, blank, blank, blank, blank,
      blank,
    ]),
  )
}

///|
/// 上游 `test_chart_have_a_long_y_axis_title_overlapping_legend`：
/// Y 轴标题把图例挤下一行喵。
test "Chart 长 Y 轴标题避让图例" {
  let chart = Chart::new([ChartDataset::default().name_str("Ds1")]).y_axis(
    ChartAxis::default().title_str("The title overlap a legend."),
  )
  let buffer = chart_render_in(chart, @core.Rect::new(0, 0, 30, 20))
  let blank = "                              "
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "The title overlap a legend.   ", "                         ┌───┐",
      "                         │Ds1│", "                         └───┘",
      blank, blank, blank, blank, blank, blank, blank, blank, blank, blank, blank,
      blank, blank, blank, blank, blank,
    ]),
  )
}

///|
/// 上游 `test_chart_have_overflowed_y_axis`：极小区域整体裁剪喵。
test "Chart Y 轴溢出裁剪" {
  let chart = Chart::new([ChartDataset::default().name_str("Ds1")]).y_axis(
    ChartAxis::default().title_str("The title overlap a legend."),
  )
  let buffer = chart_render_in(chart, @core.Rect::new(0, 0, 10, 10))
  assert_eq(buffer, @core.Buffer::with_lines(Array::make(10, "          ")))
}

///|
/// 上游 `test_legend_area_can_fit_same_chart_area`：图例与整图同大时
/// 八方位渲染一致喵。
test "Chart 图例占满图区八方位于一体" {
  let chart = Chart::new([ChartDataset::default().name_str("Data")]).hidden_legend_constraints(
    (@core.Percentage(100), @core.Percentage(100)),
  )
  let expected = @core.Buffer::with_lines([
    "┌────┐", "│Data│", "└────┘",
  ])
  for
    position in [
      LegendPosition::TopLeft,
      LegendPosition::Top,
      LegendPosition::TopRight,
      LegendPosition::Left,
      LegendPosition::Right,
      LegendPosition::Bottom,
      LegendPosition::BottomLeft,
      LegendPosition::BottomRight,
    ] {
    let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 6, 3))
    chart.legend_position(Some(position)).render(buffer.area, buffer)
    assert_eq(buffer, expected)
  }
}

///|
/// 上游 `test_legend_of_chart_have_odd_margin_size`：奇数余量下八方
/// 位的图例落位矩阵喵。
test "Chart 奇数余量图例落位矩阵" {
  let name = "Data"
  let area = @core.Rect::new(0, 0, name.length() + 2 + 3, 3 + 3)
  let chart = Chart::new([ChartDataset::default().name_str(name)]).hidden_legend_constraints(
    (@core.Percentage(100), @core.Percentage(100)),
  )
  let blank = "         "
  let cases : Array[(LegendPosition?, Array[String])] = [
    (
      Some(LegendPosition::TopLeft),
      [
        "┌────┐   ", "│Data│   ", "└────┘   ", blank,
        blank, blank,
      ],
    ),
    (
      Some(LegendPosition::Top),
      [
        " ┌────┐  ", " │Data│  ", " └────┘  ", blank,
        blank, blank,
      ],
    ),
    (
      Some(LegendPosition::TopRight),
      [
        "   ┌────┐", "   │Data│", "   └────┘", blank,
        blank, blank,
      ],
    ),
    (
      Some(LegendPosition::Left),
      [
        blank, "┌────┐   ", "│Data│   ", "└────┘   ",
        blank, blank,
      ],
    ),
    (
      Some(LegendPosition::Right),
      [
        blank, "   ┌────┐", "   │Data│", "   └────┘",
        blank, blank,
      ],
    ),
    (
      Some(LegendPosition::BottomLeft),
      [
        blank, blank, blank, "┌────┐   ", "│Data│   ", "└────┘   ",
      ],
    ),
    (
      Some(LegendPosition::Bottom),
      [
        blank, blank, blank, " ┌────┐  ", " │Data│  ", " └────┘  ",
      ],
    ),
    (
      Some(LegendPosition::BottomRight),
      [
        blank, blank, blank, "   ┌────┐", "   │Data│", "   └────┘",
      ],
    ),
    (None, Array::make(6, blank)),
  ]
  for case in cases {
    let (position, expected) = case
    let rendered = chart_render_in(chart.legend_position(position), area)
    assert_eq(rendered, @core.Buffer::with_lines(expected))
  }
}

///|
/// 上游 `bar_chart`：柱形图型的整幅快照喵。
test "Chart 柱形图型" {
  let data = [
    (0.0, 0.0),
    (2.0, 1.0),
    (4.0, 4.0),
    (6.0, 8.0),
    (8.0, 9.0),
    (10.0, 10.0),
  ]
  let chart = Chart::new([
      ChartDataset::default().data(data).marker(@core.Dot).graph_type(Bar),
    ])
    .x_axis(ChartAxis::default().bounds((0.0, 10.0)))
    .y_axis(ChartAxis::default().bounds((0.0, 10.0)))
  let buffer = chart_render_in(chart, @core.Rect::new(0, 0, 11, 11))
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "          •", "        • •", "      • • •", "      • • •",
      "      • • •", "      • • •", "    • • • •", "    • • • •",
      "    • • • •", "  • • • • •", "• • • • • •",
    ]),
  )
}

///|
/// 上游 `overlapping_lines`：Block 层与点线层叠加时的前景/背景
/// 归属矩阵（Dot/Braille 两组）喵。
test "Chart 叠加线条分层归属" {
  let cases : Array[(@core.Marker, String)] = [
    (@core.Dot, "•"),
    (@core.Braille, "⢣"),
  ]
  for case in cases {
    let (marker, symbol) = case
    let data_diagonal_up = [(0.0, 0.0), (5.0, 5.0)]
    let data_diagonal_down = [(0.0, 5.0), (5.0, 0.0)]
    let chart = Chart::new([
        ChartDataset::default()
        .data(data_diagonal_up)
        .marker(@core.Block)
        .graph_type(Line)
        .style(@core.Style::new().blue()),
        ChartDataset::default()
        .data(data_diagonal_down)
        .marker(marker)
        .graph_type(Line)
        .style(@core.Style::new().red()),
      ])
      .x_axis(ChartAxis::default().bounds((0.0, 5.0)))
      .y_axis(ChartAxis::default().bounds((0.0, 5.0)))
    let buffer = chart_render_in(chart, @core.Rect::new(0, 0, 5, 5))
    let expected = @core.Buffer::with_lines([
      "\{symbol}   █",
      " \{symbol} █ ",
      "  \{symbol}  ",
      " █ \{symbol} ",
      "█   \{symbol}",
    ])
    for i in 0..<5 {
      // Dot/Braille 瓦片前景为红喵。
      expected.set_style(
        @core.Rect::new(i, i, 1, 1),
        @core.Style::new().fg(@core.Red),
      )
      // Block 瓦片前后景皆为蓝喵。
      expected.set_style(
        @core.Rect::new(i, 4 - i, 1, 1),
        @core.Style::new().fg(@core.Blue).bg(@core.Blue),
      )
    }
    // 交叠格：前景红来自点线层，背景蓝来自 Block 层喵。
    expected.set_style(
      @core.Rect::new(2, 2, 1, 1),
      @core.Style::new().fg(@core.Red).bg(@core.Blue),
    )
    assert_eq(buffer, expected)
  }
}

///|
/// 上游 `filled_line`：面积图型的整幅快照喵。
test "Chart 面积图型" {
  let data = [(0.0, 0.0), (5.0, 5.0), (10.0, 5.0)]
  let chart = Chart::new([
      ChartDataset::default()
      .data(data)
      .marker(@core.Dot)
      .fill_to_y(0.0)
      .graph_type(Area),
    ])
    .x_axis(ChartAxis::default().bounds((0.0, 10.0)))
    .y_axis(ChartAxis::default().bounds((0.0, 10.0)))
  let buffer = chart_render_in(chart, @core.Rect::new(0, 0, 11, 11))
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "           ", "           ", "           ", "           ", "           ",
      "     ••••••", "    •••••••", "   ••••••••",
      "  •••••••••", " ••••••••••", "•••••••••••",
    ]),
  )
}

///|
/// 上游 `render_in_minimal_buffer`：1x1 缓冲不 panic 且画出缺省点喵。
test "Chart 极小缓冲渲染" {
  let chart = Chart::new([
      ChartDataset::default().data([(0.0, 0.0), (1.0, 1.0)]),
    ])
    .x_axis(ChartAxis::default().bounds((0.0, 1.0)))
    .y_axis(ChartAxis::default().bounds((0.0, 1.0)))
  let buffer = chart_render_in(chart, @core.Rect::new(0, 0, 1, 1))
  assert_eq(buffer, @core.Buffer::with_lines(["•"]))
}

///|
/// 上游 `render_in_zero_size_buffer`：零尺寸缓冲不 panic 喵。
test "Chart 零尺寸缓冲渲染" {
  let chart = Chart::new([
      ChartDataset::default().data([(0.0, 0.0), (1.0, 1.0)]),
    ])
    .x_axis(ChartAxis::default().bounds((0.0, 1.0)))
    .y_axis(ChartAxis::default().bounds((0.0, 1.0)))
  let _ = chart_render_in(chart, @core.Rect::new(0, 0, 0, 0))
}
