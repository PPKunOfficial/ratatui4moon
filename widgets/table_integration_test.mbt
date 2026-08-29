///|
/// Table 集成黄金用例：复刻 ratatui-v0.30.2 `ratatui/tests/widgets_table.rs`
/// 全部 11 组测试（29 个 rstest case + 4 条独立用例）喵。
///
/// 上游经 Terminal/TestBackend/assert_buffer_lines 驱动；terminal 会话层
/// 未复刻前以等价的"直渲染 + 全宽逐行比对"承载喵。

///|
/// 上游 assert_buffer_lines：全宽逐行符号串比对喵。
fn table_assert_rows(
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
/// 夹具 A：30×10，4 行 × 3 列 + 表头（下边距 1）+ 边框块喵。
fn table_fixture_a(spacing : Int, widths : Array[@core.Constraint]) -> Table {
  Table::make(
    [
      TableRow::of_strs(["Row11", "Row12", "Row13"]),
      TableRow::of_strs(["Row21", "Row22", "Row23"]),
      TableRow::of_strs(["Row31", "Row32", "Row33"]),
      TableRow::of_strs(["Row41", "Row42", "Row43"]),
    ],
    widths,
  )
  .header(TableRow::of_strs(["Head1", "Head2", "Head3"]).bottom_margin(1))
  .block(Block::bordered())
  .column_spacing(spacing)
}

///|
/// 夹具 B：30×8，行高交替 1/2 + 高亮符号 ">> " 喵。
fn table_fixture_b() -> Table {
  Table::make(
    [
      TableRow::of_strs(["Row11", "Row12", "Row13"]),
      TableRow::of_strs(["Row21", "Row22", "Row23"]).height(2),
      TableRow::of_strs(["Row31", "Row32", "Row33"]),
      TableRow::of_strs(["Row41", "Row42", "Row43"]).height(2),
    ],
    [@core.Length(5), @core.Length(5), @core.Length(5)],
  )
  .header(TableRow::of_strs(["Head1", "Head2", "Head3"]).bottom_margin(1))
  .block(Block::bordered())
  .highlight_symbol_str(">> ")
  .column_spacing(1)
}

///|
/// 渲染夹具 A 并返回缓冲喵。
fn table_render_a(table : Table) -> @core.Buffer {
  let area = @core.Rect::new(0, 0, 30, 10)
  let buffer = @core.Buffer::empty(area)
  table.render(area, buffer)
  buffer
}

///|
/// 上游 widgets_table_column_spacing_can_be_changed（4 case）喵。
test "Table 集成：列间距可调" {
  let cases : Array[(Int, Array[String])] = [
    (
      0,
      [
        "┌────────────────────────────┐",
        "│Head1Head2Head3             │", "│                            │",
        "│Row11Row12Row13             │", "│Row21Row22Row23             │",
        "│Row31Row32Row33             │", "│Row41Row42Row43             │",
        "│                            │", "│                            │",
        "└────────────────────────────┘",
      ],
    ),
    (
      1,
      [
        "┌────────────────────────────┐",
        "│Head1 Head2 Head3           │", "│                            │",
        "│Row11 Row12 Row13           │", "│Row21 Row22 Row23           │",
        "│Row31 Row32 Row33           │", "│Row41 Row42 Row43           │",
        "│                            │", "│                            │",
        "└────────────────────────────┘",
      ],
    ),
    (
      6,
      [
        "┌────────────────────────────┐",
        "│Head1      Head2      Head3 │", "│                            │",
        "│Row11      Row12      Row13 │", "│Row21      Row22      Row23 │",
        "│Row31      Row32      Row33 │", "│Row41      Row42      Row43 │",
        "│                            │", "│                            │",
        "└────────────────────────────┘",
      ],
    ),
    (
      7,
      [
        "┌────────────────────────────┐",
        "│Head1       Head       Head3│", "│                            │",
        "│Row11       Row1       Row13│", "│Row21       Row2       Row23│",
        "│Row31       Row3       Row33│", "│Row41       Row4       Row43│",
        "│                            │", "│                            │",
        "└────────────────────────────┘",
      ],
    ),
  ]
  for case in cases {
    let buf = table_render_a(
      table_fixture_a(case.0, [
        @core.Length(5),
        @core.Length(5),
        @core.Length(5),
      ]),
    )
    table_assert_rows(buf, case.1)
  }
}

///|
/// 上游 widgets_table_columns_widths_can_use_fixed_length_constraints（3 case）喵。
test "Table 集成：固定长度列宽" {
  let cases : Array[(Array[@core.Constraint], Array[String])] = [
    (
      [@core.Length(0), @core.Length(0), @core.Length(0)],
      [
        "┌────────────────────────────┐",
        "│                            │", "│                            │",
        "│                            │", "│                            │",
        "│                            │", "│                            │",
        "│                            │", "│                            │",
        "└────────────────────────────┘",
      ],
    ),
    (
      [@core.Length(1), @core.Length(1), @core.Length(1)],
      [
        "┌────────────────────────────┐",
        "│H H H                       │", "│                            │",
        "│R R R                       │", "│R R R                       │",
        "│R R R                       │", "│R R R                       │",
        "│                            │", "│                            │",
        "└────────────────────────────┘",
      ],
    ),
    (
      [@core.Length(8), @core.Length(8), @core.Length(8)],
      [
        "┌────────────────────────────┐",
        "│Head1    Head2    Head3     │", "│                            │",
        "│Row11    Row12    Row13     │", "│Row21    Row22    Row23     │",
        "│Row31    Row32    Row33     │", "│Row41    Row42    Row43     │",
        "│                            │", "│                            │",
        "└────────────────────────────┘",
      ],
    ),
  ]
  for case in cases {
    let buf = table_render_a(table_fixture_a(1, case.0))
    table_assert_rows(buf, case.1)
  }
}

///|
/// 上游 widgets_table_columns_widths_can_use_percentage_constraints（4 case）喵。
test "Table 集成：百分比列宽" {
  let cases : Array[(Array[@core.Constraint], Array[String])] = [
    (
      [@core.Percentage(0), @core.Percentage(0), @core.Percentage(0)],
      [
        "┌────────────────────────────┐",
        "│                            │", "│                            │",
        "│                            │", "│                            │",
        "│                            │", "│                            │",
        "│                            │", "│                            │",
        "└────────────────────────────┘",
      ],
    ),
    (
      [@core.Percentage(11), @core.Percentage(11), @core.Percentage(11)],
      [
        "┌────────────────────────────┐",
        "│HeaHeaHea                   │", "│                            │",
        "│RowRowRow                   │", "│RowRowRow                   │",
        "│RowRowRow                   │", "│RowRowRow                   │",
        "│                            │", "│                            │",
        "└────────────────────────────┘",
      ],
    ),
    (
      [@core.Percentage(33), @core.Percentage(33), @core.Percentage(33)],
      [
        "┌────────────────────────────┐",
        "│Head1    Head2    Head3     │", "│                            │",
        "│Row11    Row12    Row13     │", "│Row21    Row22    Row23     │",
        "│Row31    Row32    Row33     │", "│Row41    Row42    Row43     │",
        "│                            │", "│                            │",
        "└────────────────────────────┘",
      ],
    ),
    (
      [@core.Percentage(50), @core.Percentage(50)],
      [
        "┌────────────────────────────┐",
        "│Head1         Head2         │", "│                            │",
        "│Row11         Row12         │", "│Row21         Row22         │",
        "│Row31         Row32         │", "│Row41         Row42         │",
        "│                            │", "│                            │",
        "└────────────────────────────┘",
      ],
    ),
  ]
  for case in cases {
    let buf = table_render_a(table_fixture_a(0, case.0))
    table_assert_rows(buf, case.1)
  }
}

///|
/// 上游 widgets_table_columns_widths_can_use_mixed_constraints（4 case）喵。
test "Table 集成：混合约束列宽" {
  let cases : Array[(Array[@core.Constraint], Array[String])] = [
    (
      [@core.Percentage(0), @core.Length(0), @core.Percentage(0)],
      [
        "┌────────────────────────────┐",
        "│                            │", "│                            │",
        "│                            │", "│                            │",
        "│                            │", "│                            │",
        "│                            │", "│                            │",
        "└────────────────────────────┘",
      ],
    ),
    (
      [@core.Percentage(11), @core.Length(20), @core.Percentage(11)],
      [
        "┌────────────────────────────┐",
        "│Hea Head2                Hea│", "│                            │",
        "│Row Row12                Row│", "│Row Row22                Row│",
        "│Row Row32                Row│", "│Row Row42                Row│",
        "│                            │", "│                            │",
        "└────────────────────────────┘",
      ],
    ),
    (
      [@core.Percentage(33), @core.Length(10), @core.Percentage(33)],
      [
        "┌────────────────────────────┐",
        "│Head1     Head2      Head3  │", "│                            │",
        "│Row11     Row12      Row13  │", "│Row21     Row22      Row23  │",
        "│Row31     Row32      Row33  │", "│Row41     Row42      Row43  │",
        "│                            │", "│                            │",
        "└────────────────────────────┘",
      ],
    ),
    (
      [@core.Percentage(60), @core.Length(10), @core.Percentage(60)],
      [
        "┌────────────────────────────┐",
        "│Head1      Head2      Head3 │", "│                            │",
        "│Row11      Row12      Row13 │", "│Row21      Row22      Row23 │",
        "│Row31      Row32      Row33 │", "│Row41      Row42      Row43 │",
        "│                            │", "│                            │",
        "└────────────────────────────┘",
      ],
    ),
  ]
  for case in cases {
    let buf = table_render_a(table_fixture_a(1, case.0))
    table_assert_rows(buf, case.1)
  }
}

///|
/// 上游 widgets_table_columns_widths_can_use_ratio_constraints（4 case）喵。
test "Table 集成：比例列宽" {
  let cases : Array[(Array[@core.Constraint], Array[String])] = [
    (
      [@core.Ratio(0, 1), @core.Ratio(0, 1), @core.Ratio(0, 1)],
      [
        "┌────────────────────────────┐",
        "│                            │", "│                            │",
        "│                            │", "│                            │",
        "│                            │", "│                            │",
        "│                            │", "│                            │",
        "└────────────────────────────┘",
      ],
    ),
    (
      [@core.Ratio(1, 9), @core.Ratio(1, 9), @core.Ratio(1, 9)],
      [
        "┌────────────────────────────┐",
        "│HeaHeaHea                   │", "│                            │",
        "│RowRowRow                   │", "│RowRowRow                   │",
        "│RowRowRow                   │", "│RowRowRow                   │",
        "│                            │", "│                            │",
        "└────────────────────────────┘",
      ],
    ),
    (
      [@core.Ratio(1, 3), @core.Ratio(1, 3), @core.Ratio(1, 3)],
      [
        "┌────────────────────────────┐",
        "│Head1    Head2     Head3    │", "│                            │",
        "│Row11    Row12     Row13    │", "│Row21    Row22     Row23    │",
        "│Row31    Row32     Row33    │", "│Row41    Row42     Row43    │",
        "│                            │", "│                            │",
        "└────────────────────────────┘",
      ],
    ),
    (
      [@core.Ratio(1, 2), @core.Ratio(1, 2)],
      [
        "┌────────────────────────────┐",
        "│Head1         Head2         │", "│                            │",
        "│Row11         Row12         │", "│Row21         Row22         │",
        "│Row31         Row32         │", "│Row41         Row42         │",
        "│                            │", "│                            │",
        "└────────────────────────────┘",
      ],
    ),
  ]
  for case in cases {
    let buf = table_render_a(table_fixture_a(0, case.0))
    table_assert_rows(buf, case.1)
  }
}

///|
/// 上游 widgets_table_can_have_rows_with_multi_lines（4 case）喵。
test "Table 集成：多行内容与选中滚动" {
  let cases : Array[(Int?, Array[String])] = [
    (
      None,
      [
        "┌────────────────────────────┐",
        "│Head1 Head2 Head3           │", "│                            │",
        "│Row11 Row12 Row13           │", "│Row21 Row22 Row23           │",
        "│                            │", "│Row31 Row32 Row33           │",
        "└────────────────────────────┘",
      ],
    ),
    (
      Some(0),
      [
        "┌────────────────────────────┐",
        "│   Head1 Head2 Head3        │", "│                            │",
        "│>> Row11 Row12 Row13        │", "│   Row21 Row22 Row23        │",
        "│                            │", "│   Row31 Row32 Row33        │",
        "└────────────────────────────┘",
      ],
    ),
    (
      Some(1),
      [
        "┌────────────────────────────┐",
        "│   Head1 Head2 Head3        │", "│                            │",
        "│   Row11 Row12 Row13        │", "│>> Row21 Row22 Row23        │",
        "│                            │", "│   Row31 Row32 Row33        │",
        "└────────────────────────────┘",
      ],
    ),
    (
      Some(3),
      [
        "┌────────────────────────────┐",
        "│   Head1 Head2 Head3        │", "│                            │",
        "│   Row31 Row32 Row33        │", "│>> Row41 Row42 Row43        │",
        "│                            │", "│                            │",
        "└────────────────────────────┘",
      ],
    ),
  ]
  for case in cases {
    let area = @core.Rect::new(0, 0, 30, 8)
    let buffer = @core.Buffer::empty(area)
    table_fixture_b().render_stateful(
      area,
      buffer,
      TableState::new().with_selected(case.0),
    )
    table_assert_rows(buffer, case.1)
  }
}

///|
/// 上游 widgets_table_enable_always_highlight_spacing（6 case）喵。
test "Table 集成：高亮列占位策略" {
  let cases : Array[(Int?, HighlightSpacing, Array[String])] = [
    (
      None,
      HighlightSpacing::WhenSelected,
      [
        "┌────────────────────────────┐",
        "│Head1 Head2 Head3           │", "│                            │",
        "│Row11 Row12 Row13           │", "│Row21 Row22 Row23           │",
        "│                            │", "│Row31 Row32 Row33           │",
        "└────────────────────────────┘",
      ],
    ),
    (
      None,
      HighlightSpacing::Always,
      [
        "┌────────────────────────────┐",
        "│   Head1 Head2 Head3        │", "│                            │",
        "│   Row11 Row12 Row13        │", "│   Row21 Row22 Row23        │",
        "│                            │", "│   Row31 Row32 Row33        │",
        "└────────────────────────────┘",
      ],
    ),
    (
      None,
      HighlightSpacing::Never,
      [
        "┌────────────────────────────┐",
        "│Head1 Head2 Head3           │", "│                            │",
        "│Row11 Row12 Row13           │", "│Row21 Row22 Row23           │",
        "│                            │", "│Row31 Row32 Row33           │",
        "└────────────────────────────┘",
      ],
    ),
    (
      Some(0),
      HighlightSpacing::WhenSelected,
      [
        "┌────────────────────────────┐",
        "│   Head1 Head2 Head3        │", "│                            │",
        "│>> Row11 Row12 Row13        │", "│   Row21 Row22 Row23        │",
        "│                            │", "│   Row31 Row32 Row33        │",
        "└────────────────────────────┘",
      ],
    ),
    (
      Some(0),
      HighlightSpacing::Always,
      [
        "┌────────────────────────────┐",
        "│   Head1 Head2 Head3        │", "│                            │",
        "│>> Row11 Row12 Row13        │", "│   Row21 Row22 Row23        │",
        "│                            │", "│   Row31 Row32 Row33        │",
        "└────────────────────────────┘",
      ],
    ),
    (
      Some(0),
      HighlightSpacing::Never,
      [
        "┌────────────────────────────┐",
        "│Head1 Head2 Head3           │", "│                            │",
        "│Row11 Row12 Row13           │", "│Row21 Row22 Row23           │",
        "│                            │", "│Row31 Row32 Row33           │",
        "└────────────────────────────┘",
      ],
    ),
  ]
  for case in cases {
    let area = @core.Rect::new(0, 0, 30, 8)
    let buffer = @core.Buffer::empty(area)
    table_fixture_b()
    .highlight_spacing(case.1)
    .render_stateful(area, buffer, TableState::new().with_selected(case.0))
    table_assert_rows(buffer, case.2)
  }
}

///|
/// 上游 widgets_table_can_have_elements_styled_individually：行/单元格/
/// 文本三层样式与行/列/单元格高亮的叠加矩阵喵。
test "Table 集成：逐元素样式叠加" {
  let area = @core.Rect::new(0, 0, 30, 4)
  let buffer = @core.Buffer::empty(area)
  Table::make(
    [
      TableRow::new([
        TableCell::of_str("Row11"),
        TableCell::of_str("Row12"),
        TableCell::of_str("Row13"),
      ]).style(@core.Style::new().fg(@core.Color::Green)),
      TableRow::new([
        TableCell::of_str("Row21"),
        TableCell::of_str("Row22").style(
          @core.Style::new().fg(@core.Color::Yellow),
        ),
        TableCell::new(
          @core.Text::of_line(
            @core.Line::of_spans([
              @core.Span::raw("Row"),
              @core.Span::styled("23", @core.Style::new().fg(@core.Color::Blue)),
            ]),
          ),
        ).style(@core.Style::new().fg(@core.Color::Red)),
      ]).style(@core.Style::new().fg(@core.Color::LightGreen)),
    ],
    [@core.Length(6), @core.Length(6), @core.Length(6)],
  )
  .header(TableRow::of_strs(["Head1", "Head2", "Head3"]).bottom_margin(1))
  .block(Block::new().borders(Borders::left().union(Borders::right())))
  .highlight_symbol_str(">> ")
  .row_highlight_style(@core.Style::new().add_modifier(@core.Modifier::bold()))
  .column_highlight_style(
    @core.Style::new().add_modifier(@core.Modifier::italic()),
  )
  .cell_highlight_style(@core.Style::new().add_modifier(@core.Modifier::dim()))
  .column_spacing(1)
  .render_stateful(
    area,
    buffer,
    TableState::new().with_selected(Some(0)).with_selected_column(Some(1)),
  )
  let expected = @core.Buffer::with_lines([
    "│   Head1  Head2  Head3      │", "│                            │", "│>> Row11  Row12  Row13      │",
    "│   Row21  Row22  Row23      │",
  ])
  // 首行：行色 + 行高亮（bold）喵。
  for col in 1..<29 {
    match expected.mut_cell(col, 2) {
      Some(cell) =>
        cell.set_style(
          @core.Style::new()
          .fg(@core.Color::Green)
          .add_modifier(@core.Modifier::bold()),
        )
      None => ()
    }
  }
  // 第二列高亮（italic）喵。
  for row in 2..<4 {
    for col in 11..<17 {
      match expected.mut_cell(col, row) {
        Some(cell) =>
          cell.set_style(
            @core.Style::new().add_modifier(@core.Modifier::italic()),
          )
        None => ()
      }
    }
  }
  // 首行第二列（单元格高亮 dim）喵。
  for col in 11..<17 {
    match expected.mut_cell(col, 2) {
      Some(cell) =>
        cell.set_style(@core.Style::new().add_modifier(@core.Modifier::dim()))
      None => ()
    }
  }
  // 第二行：行色 → 单元格色 → 文本色喵。
  for col in 1..<29 {
    match expected.mut_cell(col, 3) {
      Some(cell) =>
        cell.set_style(@core.Style::new().fg(@core.Color::LightGreen))
      None => ()
    }
  }
  for col in 11..<17 {
    match expected.mut_cell(col, 3) {
      Some(cell) => cell.set_style(@core.Style::new().fg(@core.Color::Yellow))
      None => ()
    }
  }
  for col in 18..<24 {
    match expected.mut_cell(col, 3) {
      Some(cell) => cell.set_style(@core.Style::new().fg(@core.Color::Red))
      None => ()
    }
  }
  for col in 21..<23 {
    match expected.mut_cell(col, 3) {
      Some(cell) => cell.set_style(@core.Style::new().fg(@core.Color::Blue))
      None => ()
    }
  }
  @debug.assert_eq(buffer, expected)
}

///|
/// 上游 widgets_table_should_render_even_if_empty：空表仅渲染表头喵。
test "Table 集成：空表渲染" {
  let area = @core.Rect::new(0, 0, 30, 4)
  let buffer = @core.Buffer::empty(area)
  Table::make([], [@core.Length(6), @core.Length(6), @core.Length(6)])
  .header(TableRow::of_strs(["Head1", "Head2", "Head3"]))
  .block(Block::new().borders(Borders::left().union(Borders::right())))
  .column_spacing(1)
  .render(area, buffer)
  table_assert_rows(buffer, [
    "│Head1  Head2  Head3         │", "│                            │", "│                            │",
    "│                            │",
  ])
}

///|
/// 上游 widgets_table_columns_dont_panic（tui-rs #470 回归）喵。
test "Table 集成：宽表列不 panic" {
  let area = @core.Rect::new(0, 0, 98, 8)
  let buffer = @core.Buffer::empty(area)
  Table::make([TableRow::of_strs(["r1", "r2", "r3", "r4"])], [
    @core.Percentage(15),
    @core.Percentage(15),
    @core.Percentage(25),
    @core.Percentage(45),
  ])
  .header(TableRow::of_strs(["h1", "h2", "h3", "h4"]))
  .block(Block::bordered())
  .highlight_symbol_str(">> ")
  .column_spacing(1)
  .render_stateful(area, buffer, TableState::new().with_selected(Some(0)))
}

///|
/// 上游 widgets_table_should_clamp_offset_if_rows_are_removed：行数减少
/// 后偏移收敛喵。
test "Table 集成：偏移收敛" {
  let area = @core.Rect::new(0, 0, 30, 8)
  let state = TableState::new()
  state.select(Some(5))
  let buffer = @core.Buffer::empty(area)
  Table::make(
    [
      TableRow::of_strs(["Row01", "Row02", "Row03"]),
      TableRow::of_strs(["Row11", "Row12", "Row13"]),
      TableRow::of_strs(["Row21", "Row22", "Row23"]),
      TableRow::of_strs(["Row31", "Row32", "Row33"]),
      TableRow::of_strs(["Row41", "Row42", "Row43"]),
      TableRow::of_strs(["Row51", "Row52", "Row53"]),
    ],
    [@core.Length(5), @core.Length(5), @core.Length(5)],
  )
  .header(TableRow::of_strs(["Head1", "Head2", "Head3"]).bottom_margin(1))
  .block(Block::bordered())
  .column_spacing(1)
  .render_stateful(area, buffer, state)
  table_assert_rows(buffer, [
    "┌────────────────────────────┐",
    "│Head1 Head2 Head3           │", "│                            │", "│Row21 Row22 Row23           │",
    "│Row31 Row32 Row33           │", "│Row41 Row42 Row43           │", "│Row51 Row52 Row53           │",
    "└────────────────────────────┘",
  ])
  let buffer = @core.Buffer::empty(area)
  Table::make([TableRow::of_strs(["Row31", "Row32", "Row33"])], [
    @core.Length(5),
    @core.Length(5),
    @core.Length(5),
  ])
  .header(TableRow::of_strs(["Head1", "Head2", "Head3"]).bottom_margin(1))
  .block(Block::bordered())
  .column_spacing(1)
  .render_stateful(area, buffer, state)
  table_assert_rows(buffer, [
    "┌────────────────────────────┐",
    "│Head1 Head2 Head3           │", "│                            │", "│Row31 Row32 Row33           │",
    "│                            │", "│                            │", "│                            │",
    "└────────────────────────────┘",
  ])
}
