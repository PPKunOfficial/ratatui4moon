// 上游 `canvas/line.rs` 内联测试逐条复刻：rstest 参数矩阵以数组
// 循环承载（Line 17 组 + FilledLine 20 组）喵。

///|
/// 用例承载：线段 + 期望 10x10 网格喵。
struct LineCase {
  line : CanvasLine
  expected : Array[String]
}

///|
/// 用例承载：填充线段 + 期望 10x10 网格喵。
struct FilledLineCase {
  line : FilledCanvasLine
  expected : Array[String]
}

///|
/// 渲染并对点断言：'•' 染红（上游 tests/tests 的样式回填）喵。
fn assert_line_case(line : CanvasLine, expected : Array[String]) -> Unit raise {
  let area = @core.Rect::new(0, 0, 10, 10)
  let buffer = @core.Buffer::empty(area)
  Canvas::default()
  .marker(@core.Dot)
  .x_bounds((0.0, 10.0))
  .y_bounds((0.0, 10.0))
  .paint(ctx => ctx.draw(line))
  .render(area, buffer)
  let expected_buf = @core.Buffer::with_lines(expected)
  for i in 0..<expected_buf.cells.length() {
    if expected_buf.cells[i].symbol() == "•" {
      expected_buf.cells[i].set_style(@core.Style::new().fg(@core.Red))
    }
  }
  assert_eq(buffer, expected_buf)
}

///|
/// 渲染并对点断言（填充版）喵。
fn assert_filled_line_case(
  line : FilledCanvasLine,
  expected : Array[String],
) -> Unit raise {
  let area = @core.Rect::new(0, 0, 10, 10)
  let buffer = @core.Buffer::empty(area)
  Canvas::default()
  .marker(@core.Dot)
  .x_bounds((0.0, 10.0))
  .y_bounds((0.0, 10.0))
  .paint(ctx => ctx.draw(line))
  .render(area, buffer)
  let expected_buf = @core.Buffer::with_lines(expected)
  for i in 0..<expected_buf.cells.length() {
    if expected_buf.cells[i].symbol() == "•" {
      expected_buf.cells[i].set_style(@core.Style::new().fg(@core.Red))
    }
  }
  assert_eq(buffer, expected_buf)
}

///|
/// 上游 `tests`（Line 参数矩阵）：离网/水平/垂直/四象限斜线全量喵。
test "CanvasLine 裁剪与 Bresenham 参数矩阵" {
  let blank = "          "
  let cases : Array[LineCase] = [
    // off_grid1..4：完全离网喵。
    {
      line: CanvasLine::new(-1.0, 0.0, -1.0, 10.0, @core.Red),
      expected: Array::make(10, blank),
    },
    {
      line: CanvasLine::new(0.0, -1.0, 10.0, -1.0, @core.Red),
      expected: Array::make(10, blank),
    },
    {
      line: CanvasLine::new(-10.0, 5.0, -1.0, 5.0, @core.Red),
      expected: Array::make(10, blank),
    },
    {
      line: CanvasLine::new(5.0, 11.0, 5.0, 20.0, @core.Red),
      expected: Array::make(10, blank),
    },
    // off_grid5：半截入网喵。
    {
      line: CanvasLine::new(-10.0, 0.0, 5.0, 0.0, @core.Red),
      expected: [
        "          ", "          ", "          ", "          ", "          ", "          ",
        "          ", "          ", "          ", "••••••    ",
      ],
    },
    // off_grid6..8：端点越界的对角线喵。
    {
      line: CanvasLine::new(-1.0, -1.0, 10.0, 10.0, @core.Red),
      expected: [
        "         •", "        • ", "       •  ", "      •   ", "     •    ",
        "    •     ", "   •      ", "  •       ", " •        ", "•         ",
      ],
    },
    {
      line: CanvasLine::new(0.0, 0.0, 11.0, 11.0, @core.Red),
      expected: [
        "         •", "        • ", "       •  ", "      •   ", "     •    ",
        "    •     ", "   •      ", "  •       ", " •        ", "•         ",
      ],
    },
    {
      line: CanvasLine::new(-1.0, -1.0, 11.0, 11.0, @core.Red),
      expected: [
        "         •", "        • ", "       •  ", "      •   ", "     •    ",
        "    •     ", "   •      ", "  •       ", " •        ", "•         ",
      ],
    },
    // horizontal1/2 喵。
    {
      line: CanvasLine::new(0.0, 0.0, 10.0, 0.0, @core.Red),
      expected: [
        "          ", "          ", "          ", "          ", "          ", "          ",
        "          ", "          ", "          ", "••••••••••",
      ],
    },
    {
      line: CanvasLine::new(10.0, 10.0, 0.0, 10.0, @core.Red),
      expected: [
        "••••••••••", "          ", "          ", "          ",
        "          ", "          ", "          ", "          ", "          ", "          ",
      ],
    },
    // vertical1/2 喵。
    {
      line: CanvasLine::new(0.0, 0.0, 0.0, 10.0, @core.Red),
      expected: Array::make(10, "•         "),
    },
    {
      line: CanvasLine::new(10.0, 10.0, 10.0, 0.0, @core.Red),
      expected: Array::make(10, "         •"),
    },
    // diagonal1：dy < dx, x1 < x2 喵。
    {
      line: CanvasLine::new(0.0, 0.0, 10.0, 5.0, @core.Red),
      expected: [
        "          ", "          ", "          ", "          ", "          ", "        ••",
        "      ••  ", "    ••    ", "  ••      ", "••        ",
      ],
    },
    // diagonal2：dy < dx, x1 > x2 喵。
    {
      line: CanvasLine::new(10.0, 0.0, 0.0, 5.0, @core.Red),
      expected: [
        "          ", "          ", "          ", "          ", "          ", "••        ",
        "  ••      ", "    ••    ", "      ••  ", "        ••",
      ],
    },
    // diagonal3：dy > dx, y1 < y2 喵。
    {
      line: CanvasLine::new(0.0, 0.0, 5.0, 10.0, @core.Red),
      expected: [
        "     •    ", "    •     ", "    •     ", "   •      ", "   •      ",
        "  •       ", "  •       ", " •        ", " •        ", "•         ",
      ],
    },
    // diagonal4：dy > dx, y1 > y2 喵。
    {
      line: CanvasLine::new(0.0, 10.0, 5.0, 0.0, @core.Red),
      expected: [
        "•         ", " •        ", " •        ", "  •       ", "  •       ",
        "   •      ", "   •      ", "    •     ", "    •     ", "     •    ",
      ],
    },
  ]
  for case in cases {
    assert_line_case(case.line, case.expected)
  }
}

///|
/// 上游 `tests_filled`（FilledLine 参数矩阵）：填充分界/满填/离网
/// 全量喵。
test "FilledCanvasLine 填充参数矩阵" {
  let blank = "          "
  let cases : Array[FilledLineCase] = [
    // filled_off_grid1..4：完全离网喵。
    {
      line: FilledCanvasLine::new(-1.0, 0.0, -1.0, 10.0, 0.0, @core.Red),
      expected: Array::make(10, blank),
    },
    {
      line: FilledCanvasLine::new(0.0, -1.0, 10.0, -1.0, 0.0, @core.Red),
      expected: Array::make(10, blank),
    },
    {
      line: FilledCanvasLine::new(-10.0, 5.0, -1.0, 5.0, 0.0, @core.Red),
      expected: Array::make(10, blank),
    },
    {
      line: FilledCanvasLine::new(5.0, 11.0, 5.0, 20.0, 0.0, @core.Red),
      expected: Array::make(10, blank),
    },
    // filled_off_grid5：半截入网喵。
    {
      line: FilledCanvasLine::new(-10.0, 0.0, 5.0, 0.0, -10.0, @core.Red),
      expected: [
        "          ", "          ", "          ", "          ", "          ", "          ",
        "          ", "          ", "          ", "••••••    ",
      ],
    },
    // filled_off_grid6..8：对角线向下填充到 y=0 喵。
    {
      line: FilledCanvasLine::new(0.0, 0.0, 10.0, 10.0, 0.0, @core.Red),
      expected: [
        "         •", "        ••", "       •••", "      ••••",
        "     •••••", "    ••••••", "   •••••••",
        "  ••••••••", " •••••••••", "••••••••••",
      ],
    },
    {
      line: FilledCanvasLine::new(0.0, 0.0, 11.0, 11.0, 0.0, @core.Red),
      expected: [
        "         •", "        ••", "       •••", "      ••••",
        "     •••••", "    ••••••", "   •••••••",
        "  ••••••••", " •••••••••", "••••••••••",
      ],
    },
    {
      line: FilledCanvasLine::new(-1.0, -1.0, 11.0, 11.0, 0.0, @core.Red),
      expected: [
        "         •", "        ••", "       •••", "      ••••",
        "     •••••", "    ••••••", "   •••••••",
        "  ••••••••", " •••••••••", "••••••••••",
      ],
    },
    // filled_horizontal1..4 喵。
    {
      line: FilledCanvasLine::new(0.0, 0.0, 10.0, 0.0, 0.0, @core.Red),
      expected: [
        "          ", "          ", "          ", "          ", "          ", "          ",
        "          ", "          ", "          ", "••••••••••",
      ],
    },
    {
      line: FilledCanvasLine::new(0.0, 0.0, 10.0, 0.0, 10.0, @core.Red),
      expected: Array::make(10, "••••••••••"),
    },
    {
      line: FilledCanvasLine::new(10.0, 10.0, 0.0, 10.0, 10.0, @core.Red),
      expected: [
        "••••••••••", "          ", "          ", "          ",
        "          ", "          ", "          ", "          ", "          ", "          ",
      ],
    },
    {
      line: FilledCanvasLine::new(10.0, 10.0, 0.0, 10.0, 0.0, @core.Red),
      expected: Array::make(10, "••••••••••"),
    },
    // filled_vertical1/2 喵。
    {
      line: FilledCanvasLine::new(0.0, 0.0, 0.0, 10.0, 0.0, @core.Red),
      expected: Array::make(10, "•         "),
    },
    {
      line: FilledCanvasLine::new(10.0, 10.0, 10.0, 0.0, 0.0, @core.Red),
      expected: Array::make(10, "         •"),
    },
    // filled_diagonal1：dy < dx, x1 < x2 喵。
    {
      line: FilledCanvasLine::new(0.0, 0.0, 10.0, 5.0, 0.0, @core.Red),
      expected: [
        "          ", "          ", "          ", "          ", "          ", "        ••",
        "      ••••", "    ••••••", "  ••••••••",
        "••••••••••",
      ],
    },
    // filled_diagonal2：dy < dx, x1 > x2 喵。
    {
      line: FilledCanvasLine::new(10.0, 0.0, 0.0, 5.0, 0.0, @core.Red),
      expected: [
        "          ", "          ", "          ", "          ", "          ", "••        ",
        "••••      ", "••••••    ", "••••••••  ",
        "••••••••••",
      ],
    },
    // filled_diagonal3：dy > dx, y1 < y2 喵。
    {
      line: FilledCanvasLine::new(0.0, 0.0, 5.0, 10.0, 0.0, @core.Red),
      expected: [
        "     •    ", "    ••    ", "    ••    ", "   •••    ", "   •••    ",
        "  ••••    ", "  ••••    ", " •••••    ", " •••••    ",
        "••••••    ",
      ],
    },
    // filled_diagonal4：dy > dx, y1 > y2 喵。
    {
      line: FilledCanvasLine::new(0.0, 10.0, 5.0, 0.0, 0.0, @core.Red),
      expected: [
        "•         ", "••        ", "••        ", "•••       ", "•••       ",
        "••••      ", "••••      ", "•••••     ", "•••••     ",
        "••••••    ",
      ],
    },
    // filled_split1/2：线两侧分区填充喵。
    {
      line: FilledCanvasLine::new(0.0, 0.0, 10.0, 10.0, 5.0, @core.Red),
      expected: [
        "         •", "        ••", "       •••", "      ••••",
        "     •••••", "••••••••••", "••••      ",
        "•••       ", "••        ", "•         ",
      ],
    },
    {
      line: FilledCanvasLine::new(0.0, 0.0, 10.0, 10.0, 7.0, @core.Red),
      expected: [
        "         •", "        ••", "       •••", "••••••••••",
        "••••••    ", "•••••     ", "••••      ", "•••       ",
        "••        ", "•         ",
      ],
    },
  ]
  for case in cases {
    assert_filled_line_case(case.line, case.expected)
  }
}
