// Chart 集成黄金用例：复刻 ratatui-v0.30.2 `ratatui/tests/widgets_chart.rs`
// 全部 8 条测试喵。
//
// 上游经 Terminal/TestBackend/assert_buffer 驱动；terminal 会话层
// 未复刻前以等价的"直渲染 + Buffer 全量比对"承载（被测行为一致），
// `assert_buffer_lines` 等价为本文件的 `assert_rows`。

///|
/// 上游 axis_test_case：渲染后整缓冲全量比对（等价
/// `assert_buffer(&Buffer::with_lines(expected))`）喵。
fn chart_axis_test_case(
  width : Int,
  height : Int,
  x_axis : ChartAxis,
  y_axis : ChartAxis,
  expected : Array[String],
) -> Unit raise {
  let buf = @core.Buffer::empty(@core.Rect::new(0, 0, width, height))
  let chart = Chart::new([]).x_axis(x_axis).y_axis(y_axis)
  chart.render(buf.area, buf)
  assert_eq(buf, @core.Buffer::with_lines(expected))
}

///|
/// 上游 `widgets_chart_can_render_on_small_areas`：2x2 至 1x1 极小
/// 区域 + 边框块 + 零长边界不 panic 喵。
test "Chart 极小区域渲染不 panic" {
  for case in [[0, 0], [0, 1], [1, 0], [1, 1], [2, 2]] {
    let (w, h) = (case[0], case[1])
    let buf = @core.Buffer::empty(@core.Rect::new(0, 0, w, h))
    let datasets = [
      ChartDataset::default()
      .marker(@core.Braille)
      .style(@core.Style::new().fg(@core.Magenta))
      .data([(0.0, 0.0)]),
    ]
    let chart = Chart::new(datasets)
      .block(Block::bordered().title_str("Plot"))
      .x_axis(
        ChartAxis::default().bounds((0.0, 0.0)).labels_of_str(["0.0", "1.0"]),
      )
      .y_axis(
        ChartAxis::default().bounds((0.0, 0.0)).labels_of_str(["0.0", "1.0"]),
      )
    chart.render(buf.area, buf)
  }
}

///|
/// 上游 `widgets_chart_handles_long_labels`：超长轴标签的对齐矩阵
/// 七组喵。
test "Chart 超长轴标签对齐矩阵" {
  let cases : Array[
    ((String, String)?, (String, String)?, @core.Alignment, Array[String]),
  ] = [
    (
      Some(("AAAA", "B")),
      None,
      @core.Left,
      [
        "          ", "          ", "          ", "   ───────", "AAA      B",
      ],
    ),
    (
      Some(("A", "BBBB")),
      None,
      @core.Left,
      [
        "          ", "          ", "          ", " ─────────",
        "A     BBBB",
      ],
    ),
    (
      Some(("AAAAAAAAAAA", "B")),
      None,
      @core.Left,
      [
        "          ", "          ", "          ", "   ───────", "AAA      B",
      ],
    ),
    (
      Some(("A", "B")),
      Some(("CCCCCCC", "D")),
      @core.Left,
      [
        "D  │      ", "   │      ", "CCC│      ", "   └──────",
        "   A     B",
      ],
    ),
    (
      Some(("AAAAAAAAAA", "B")),
      Some(("C", "D")),
      @core.Center,
      [
        "D  │      ", "   │      ", "C  │      ", "   └──────",
        "AAAAAAA  B",
      ],
    ),
    (
      Some(("AAAAAAA", "B")),
      Some(("C", "D")),
      @core.Right,
      [
        "D│        ", " │        ", "C│        ", " └────────",
        " AAAAA   B",
      ],
    ),
    (
      Some(("AAAAAAA", "BBBBBBB")),
      Some(("C", "D")),
      @core.Right,
      [
        "D│        ", " │        ", "C│        ", " └────────",
        " AAAAABBBB",
      ],
    ),
  ]
  for case in cases {
    let (x_labels, y_labels, x_alignment, expected) = case
    let mut x_axis = ChartAxis::default().bounds((0.0, 1.0))
    match x_labels {
      Some((left_label, right_label)) =>
        x_axis = x_axis
          .labels_of_str([left_label, right_label])
          .labels_alignment(x_alignment)
      None => ()
    }
    let mut y_axis = ChartAxis::default().bounds((0.0, 1.0))
    match y_labels {
      Some((left_label, right_label)) =>
        y_axis = y_axis.labels_of_str([left_label, right_label])
      None => ()
    }
    chart_axis_test_case(10, 5, x_axis, y_axis, expected)
  }
}

///|
/// 上游 `widgets_chart_handles_x_axis_labels_alignments`：X 轴首标签
/// 三种对齐喵。
test "Chart X 轴标签对齐矩阵" {
  let cases : Array[(@core.Alignment, Array[String])] = [
    (
      @core.Left,
      [
        "          ", "          ", "          ", "   ───────", "AAA   B  C",
      ],
    ),
    (
      @core.Center,
      [
        "          ", "          ", "          ", "  ────────", "AAAA B   C",
      ],
    ),
    (
      @core.Right,
      [
        "          ", "          ", "          ", "──────────",
        "AAA B    C",
      ],
    ),
  ]
  for case in cases {
    let (y_alignment, expected) = case
    let x_axis = ChartAxis::default()
      .labels_of_str(["AAAA", "B", "C"])
      .labels_alignment(y_alignment)
    chart_axis_test_case(10, 5, x_axis, ChartAxis::default(), expected)
  }
}

///|
/// 上游 `widgets_chart_handles_y_axis_labels_alignments`：Y 轴标签
/// 三种对齐喵。
test "Chart Y 轴标签对齐矩阵" {
  let cases : Array[(@core.Alignment, Array[String])] = [
    (
      @core.Left,
      [
        "D   │               ", "    │               ", "C   │               ",
        "    └───────────────", "AAAAA              B",
      ],
    ),
    (
      @core.Center,
      [
        " D  │               ", "    │               ", " C  │               ",
        "    └───────────────", "AAAAA              B",
      ],
    ),
    (
      @core.Right,
      [
        "   D│               ", "    │               ", "   C│               ",
        "    └───────────────", "AAAAA              B",
      ],
    ),
  ]
  for case in cases {
    let (y_alignment, expected) = case
    let x_axis = ChartAxis::default().labels_of_str(["AAAAA", "B"])
    let y_axis = ChartAxis::default()
      .labels_of_str(["C", "D"])
      .labels_alignment(y_alignment)
    chart_axis_test_case(20, 5, x_axis, y_axis, expected)
  }
}

///|
/// 上游 `widgets_chart_can_have_axis_with_zero_length_bounds`：零长
/// 边界 + 块标题不 panic 喵。
test "Chart 零长边界轴" {
  let buf = @core.Buffer::empty(@core.Rect::new(0, 0, 100, 100))
  let datasets = [
    ChartDataset::default()
    .marker(@core.Braille)
    .style(@core.Style::new().fg(@core.Magenta))
    .data([(0.0, 0.0)]),
  ]
  let chart = Chart::new(datasets)
    .block(Block::bordered().title_str("Plot"))
    .x_axis(
      ChartAxis::default().bounds((0.0, 0.0)).labels_of_str(["0.0", "1.0"]),
    )
    .y_axis(
      ChartAxis::default().bounds((0.0, 0.0)).labels_of_str(["0.0", "1.0"]),
    )
  chart.render(@core.Rect::new(0, 0, 100, 100), buf)
}

///|
/// 上游 `widgets_chart_handles_overflows`：大数值域 + 时间戳标签
/// 不 panic 不溢出喵。
test "Chart 大数值域溢出防护" {
  let buf = @core.Buffer::empty(@core.Rect::new(0, 0, 80, 30))
  let datasets = [
    ChartDataset::default()
    .marker(@core.Braille)
    .style(@core.Style::new().fg(@core.Magenta))
    .data([(1588298471.0, 1.0), (1588298473.0, 0.0), (1588298496.0, 1.0)]),
  ]
  let chart = Chart::new(datasets)
    .block(Block::bordered().title_str("Plot"))
    .x_axis(
      ChartAxis::default()
      .bounds((1588298471.0, 1588992600.0))
      .labels_of_str(["1588298471.0", "1588992600.0"]),
    )
    .y_axis(
      ChartAxis::default().bounds((0.0, 1.0)).labels_of_str(["0.0", "1.0"]),
    )
  chart.render(@core.Rect::new(0, 0, 80, 30), buf)
}

///|
/// 上游 `widgets_chart_can_have_empty_datasets`：空数据 + Line 图型
/// 不 panic 喵。
test "Chart 空数据集" {
  let buf = @core.Buffer::empty(@core.Rect::new(0, 0, 100, 100))
  let datasets = [ChartDataset::default().data([]).graph_type(GraphType::Line)]
  let chart = Chart::new(datasets)
    .block(Block::bordered().title_str("Empty Dataset With Line"))
    .x_axis(
      ChartAxis::default().bounds((0.0, 0.0)).labels_of_str(["0.0", "1.0"]),
    )
    .y_axis(
      ChartAxis::default().bounds((0.0, 1.0)).labels_of_str(["0.0", "1.0"]),
    )
  chart.render(@core.Rect::new(0, 0, 100, 100), buf)
}

///|
/// 上游 `widgets_chart_top_line_styling_is_correct`：顶部行标题与
/// 数据前景样式精确归属喵。
test "Chart 顶行样式归属" {
  let title_style = @core.Style::new().fg(@core.Red).bg(@core.LightRed)
  let data_style = @core.Style::new().fg(@core.Blue)
  let data = [(0.0, 1.0), (1.0, 1.0)]
  let widget = Chart::new([
      ChartDataset::default()
      .data(data)
      .graph_type(GraphType::Line)
      .style(data_style),
    ])
    .y_axis(
      ChartAxis::default()
      .title(@core.Line::of_span(@core.Span::styled("abc", title_style)))
      .bounds((0.0, 1.0))
      .labels_of_str(["a", "b"]),
    )
    .x_axis(ChartAxis::default().bounds((0.0, 1.0)))
  let buf = @core.Buffer::empty(@core.Rect::new(0, 0, 9, 5))
  widget.render(buf.area, buf)
  let expected = @core.Buffer::with_lines([
    "b│abc••••", " │       ", " │       ", " │       ", "a│       ",
  ])
  expected.set_style(@core.Rect::new(2, 0, 3, 1), title_style)
  expected.set_style(@core.Rect::new(5, 0, 4, 1), data_style)
  assert_eq(buf, expected)
}
