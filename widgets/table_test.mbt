///|
/// TableCell/TableRow 单元测试：复刻 ratatui-v0.30.2
/// `table/cell.rs` + `table/row.rs` 内联测试清单喵。
///
/// 上游 `From`/`FromIterator`/Stylize 速记按本库惯例经显式构造与
/// `style(...)` 等价承载；`collect` 用例与 `new` 同形合并喵。

///|
/// 上游 cell.rs new + content 喵。
test "TableCell 构造与内容" {
  let cell = TableCell::of_str("")
  assert_eq(cell.content, @core.Text::raw(""))
  let cell = TableCell::default().content_str("")
  assert_eq(cell.content, @core.Text::raw(""))
  inspect(cell.column_span, content="1")
}

///|
/// 上游 cell.rs style + stylize 喵。
test "TableCell 样式" {
  let style = @core.Style::new().red().italic()
  let cell = TableCell::default().style(style)
  assert_eq(cell.style, style)
  assert_eq(
    TableCell::of_str("").style(
      @core.Style::new().black().on_white().bold().not_dim(),
    ).style,
    @core.Style::new()
    .fg(@core.Color::Black)
    .bg(@core.Color::White)
    .add_modifier(@core.Modifier::bold())
    .remove_modifier(@core.Modifier::dim()),
  )
}

///|
/// 上游 cell.rs column_span doc 示例语义：跨度设值喵。
test "TableCell 列跨度" {
  inspect(TableCell::of_str("12345").column_span(2).column_span, content="2")
}

///|
/// 上游 row.rs new + collect + cells 喵。
test "TableRow 构造" {
  let cells = [TableCell::of_str("")]
  let row = TableRow::new(cells)
  assert_eq(row.cells, cells)
  let row = TableRow::default().cells(cells)
  assert_eq(row.cells, cells)
  inspect(row.height, content="1")
}

///|
/// 上游 row.rs height/top_margin/bottom_margin/style/stylize 喵。
test "TableRow 高度边距与样式" {
  inspect(TableRow::default().height(2).height, content="2")
  inspect(TableRow::default().top_margin(1).top_margin, content="1")
  inspect(TableRow::default().bottom_margin(1).bottom_margin, content="1")
  let style = @core.Style::new().red().italic()
  assert_eq(TableRow::default().style(style).style, style)
  assert_eq(
    TableRow::new([TableCell::of_str("")]).style(
      @core.Style::new().black().on_white().bold().not_italic(),
    ).style,
    @core.Style::new()
    .fg(@core.Color::Black)
    .bg(@core.Color::White)
    .add_modifier(@core.Modifier::bold())
    .remove_modifier(@core.Modifier::italic()),
  )
}

///|
/// Table 配置与状态测试：复刻 ratatui-v0.30.2 `table.rs` 内联测试
/// （new/default/widths/rows/… + state 模块）喵。
///
/// 登记不可移植：
/// - `highlight_style`：上游 0.27 起弃用的构造器不复刻；
/// - `table_invalid_percentages`：上游 assert! panic，按无 panic 铁律
///   改为饱和（110 → 100）验证；
/// - `widths_conversions`/`collect`：Rust Into 形态在 MoonBit 统一为
///   Array，合并承载。

///|
/// 上游 new + default 喵。
test "Table 缺省字段" {
  let rows = [TableRow::new([TableCell::of_str("")])]
  let widths = [@core.Percentage(100)]
  let table = Table::make(rows, widths)
  assert_eq(table.rows, rows)
  assert_eq(table.header, None)
  assert_eq(table.footer, None)
  assert_eq(table.widths, widths)
  inspect(table.column_spacing, content="1")
  assert_eq(table.block, None)
  assert_eq(table.style, @core.Style::new())
  assert_eq(table.row_highlight_style, @core.Style::new())
  assert_eq(table.highlight_symbol, @core.Text::empty())
  assert_eq(table.highlight_spacing, HighlightSpacing::WhenSelected)
  assert_eq(table.flex, @core.Start)
  let empty = Table::default()
  inspect(empty.rows.length(), content="0")
  inspect(empty.column_spacing, content="1")
}

///|
/// 上游 widths + table_invalid_percentages（饱和承载）+ widths_conversions 喵。
test "Table 列宽约束" {
  let table = Table::default().widths([@core.Length(100)])
  assert_eq(table.widths, [@core.Length(100)])
  // 越界百分比饱和（上游 panic 的无 panic 等价）喵。
  let table = Table::default().widths([@core.Percentage(110)])
  assert_eq(table.widths, [@core.Percentage(100)])
}

///|
/// 上游 rows/column_spacing/block/header/footer/highlight_* 喵。
test "Table 构造器" {
  let rows = [TableRow::new([TableCell::of_str("")])]
  inspect(Table::default().rows(rows).rows.length(), content="1")
  inspect(Table::default().column_spacing(2).column_spacing, content="2")
  let block = Block::bordered().title_str("Table")
  assert_eq(Table::default().block(block).block, Some(block))
  let header = TableRow::new([TableCell::of_str("")])
  assert_eq(Table::default().header(header).header, Some(header))
  let footer = TableRow::new([TableCell::of_str("")])
  assert_eq(Table::default().footer(footer).footer, Some(footer))
  let style = @core.Style::new().red().italic()
  assert_eq(
    Table::default().row_highlight_style(style).row_highlight_style,
    style,
  )
  assert_eq(
    Table::default().column_highlight_style(style).column_highlight_style,
    style,
  )
  assert_eq(
    Table::default().cell_highlight_style(style).cell_highlight_style,
    style,
  )
  assert_eq(
    Table::default().highlight_symbol_str(">>").highlight_symbol,
    @core.Text::raw(">>"),
  )
  assert_eq(
    Table::default().highlight_spacing(HighlightSpacing::Always).highlight_spacing,
    HighlightSpacing::Always,
  )
}

///|
/// 上游 state 模块：空表与单行表的状态收敛喵。
test "Table 状态收敛" {
  let area = @core.Rect::new(0, 0, 10, 10)
  let widths = [@core.Percentage(100)]
  // 空表：选中清空喵。
  let empty_table = Table::make([], widths)
  let state = TableState::new()
  state.select_first()
  empty_table.render_stateful(area, @core.Buffer::empty(area), state)
  assert_eq(state.selected, None)
  assert_eq(state.selected_column, None)
  // 单行表：last/previous/next 收敛到 0 喵。
  let table = Table::make([TableRow::of_strs(["Item 1"])], widths)
  let state = TableState::new()
  state.select_first()
  table.render_stateful(area, @core.Buffer::empty(area), state)
  assert_eq(state.selected, Some(0))
  state.select_last()
  table.render_stateful(area, @core.Buffer::empty(area), state)
  assert_eq(state.selected, Some(0))
  state.select_previous()
  table.render_stateful(area, @core.Buffer::empty(area), state)
  assert_eq(state.selected, Some(0))
  state.select_next()
  table.render_stateful(area, @core.Buffer::empty(area), state)
  assert_eq(state.selected, Some(0))
  // 列选中收敛喵。
  let state = TableState::new()
  state.select_first_column()
  table.render_stateful(area, @core.Buffer::empty(area), state)
  assert_eq(state.selected_column, Some(0))
  assert_eq(state.selected, None)
  state.select_last_column()
  table.render_stateful(area, @core.Buffer::empty(area), state)
  assert_eq(state.selected_column, Some(0))
  state.select_previous_column()
  table.render_stateful(area, @core.Buffer::empty(area), state)
  assert_eq(state.selected_column, Some(0))
  state.select_next_column()
  table.render_stateful(area, @core.Buffer::empty(area), state)
  assert_eq(state.selected_column, Some(0))
}

///|
/// Table 渲染测试：复刻 ratatui-v0.30.2 `table.rs` render/column_widths
/// 模块可公开承载的用例喵。
///
/// 登记不可移植：column_widths 模块对包私有 `get_column_widths` 直测，
/// 本库以渲染路径等价承载（列宽行为由 render/集成用例覆盖）喵。

///|
/// 渲染辅助：空缓冲渲染表格喵。
fn table_render(
  table : Table,
  area : @core.Rect,
  state : TableState?,
) -> @core.Buffer {
  let buffer = @core.Buffer::empty(area)
  match state {
    Some(s) => table.render_stateful(area, buffer, s)
    None => table.render(area, buffer)
  }
  buffer
}

///|
/// 上游 render_empty_area + render_default 喵。
test "Table 空区域与缺省渲染" {
  let buf = table_render(
    Table::make([TableRow::of_strs(["Cell1", "Cell2"])], [
      @core.Length(5),
      @core.Length(5),
    ]),
    @core.Rect::new(0, 0, 0, 0),
    None,
  )
  assert_eq(buf, @core.Buffer::empty(@core.Rect::new(0, 0, 0, 0)))
  let buf = table_render(Table::default(), @core.Rect::new(0, 0, 15, 3), None)
  assert_eq(buf, @core.Buffer::empty(@core.Rect::new(0, 0, 15, 3)))
}

///|
/// 上游 render_with_block 喵。
test "Table 块内渲染" {
  let buf = table_render(
    Table::make(
      [
        TableRow::of_strs(["Cell1", "Cell2"]),
        TableRow::of_strs(["Cell3", "Cell4"]),
      ],
      [@core.Length(5), @core.Length(5)],
    ).block(Block::bordered().title_str("Block")),
    @core.Rect::new(0, 0, 15, 3),
    None,
  )
  assert_eq(
    buf,
    @core.Buffer::with_lines([
      "┌Block────────┐", "│Cell1 Cell2  │", "└─────────────┘",
    ]),
  )
}

///|
/// 上游 test_colspans_2_cols：跨度 0/1/2 的列占用喵。
test "Table 双列跨度" {
  let render = fn(rows : Array[TableRow], width : Int) {
    table_render(
      Table::make(rows, [@core.Length(5), @core.Length(5)]),
      @core.Rect::new(0, 0, width, 2),
      None,
    )
  }
  let normal = render(
    [
      TableRow::of_strs(["Cell1", "Cell2"]),
      TableRow::of_strs(["Cell3", "Cell4"]),
    ],
    15,
  )
  assert_eq(
    normal,
    @core.Buffer::with_lines(["Cell1 Cell2    ", "Cell3 Cell4    "]),
  )
  // 跨度 0：首格不占用喵。
  let zero_span = render(
    [
      TableRow::new([
        TableCell::of_str("Cell1").column_span(0),
        TableCell::of_str("Cell2"),
      ]),
      TableRow::of_strs(["Cell3", "Cell4"]),
    ],
    15,
  )
  assert_eq(
    zero_span,
    @core.Buffer::with_lines(["Cell2          ", "Cell3 Cell4    "]),
  )
  // 跨度 2：合并两列喵。
  let double_span = render(
    [
      TableRow::new([
        TableCell::of_str("Cell1").column_span(2),
        TableCell::of_str("Cell2"),
      ]),
      TableRow::of_strs(["Cell3", "Cell4"]),
    ],
    15,
  )
  assert_eq(
    double_span,
    @core.Buffer::with_lines(["Cell1          ", "Cell3 Cell4    "]),
  )
}

///|
/// 上游 test_colspans_3_cols：三列下的跨列矩阵喵。
test "Table 三列跨度" {
  let render = fn(rows : Array[TableRow], width : Int) {
    table_render(
      Table::make(rows, [@core.Length(5), @core.Length(5), @core.Length(5)]),
      @core.Rect::new(0, 0, width, 2),
      None,
    )
  }
  let a = render(
    [
      TableRow::new([
        TableCell::of_str("Cell1").column_span(2),
        TableCell::of_str("Cell2"),
      ]),
      TableRow::of_strs(["Cell3", "Cell4", "Cell5"]),
    ],
    17,
  )
  assert_eq(
    a,
    @core.Buffer::with_lines(["Cell1       Cell2", "Cell3 Cell4 Cell5"]),
  )
  let b = render(
    [
      TableRow::new([
        TableCell::of_str("Cell1"),
        TableCell::of_str("Cell2").column_span(2),
        TableCell::of_str("Cell3"),
      ]),
      TableRow::of_strs(["Cell4", "Cell5", "Cell6"]),
    ],
    17,
  )
  assert_eq(
    b,
    @core.Buffer::with_lines(["Cell1 Cell2      ", "Cell4 Cell5 Cell6"]),
  )
  let c = render(
    [
      TableRow::new([
        TableCell::of_str("11111111111111111111").column_span(2),
        TableCell::of_str("22222222222222222222"),
      ]),
      TableRow::new([
        TableCell::of_str("33333333333333333333"),
        TableCell::of_str("44444444444444444444").column_span(2),
        TableCell::of_str("55555555555555555555"),
      ]),
    ],
    15,
  )
  assert_eq(c, @core.Buffer::with_lines(["1111111111 2222", "3333 4444444444"]))
}

///|
/// 上游 render_with_header/footer/header_and_footer 喵。
test "Table 表头表尾" {
  let rows = [TableRow::of_strs(["Cell1", "Cell2"])]
  let header = TableRow::of_strs(["Head1", "Head2"])
  let footer = TableRow::of_strs(["Foot1", "Foot2"])
  let buf = table_render(
    Table::make(rows, [@core.Length(5), @core.Length(5)]).header(header),
    @core.Rect::new(0, 0, 15, 3),
    None,
  )
  assert_eq(
    buf,
    @core.Buffer::with_lines([
      "Head1 Head2    ", "Cell1 Cell2    ", "               ",
    ]),
  )
  let buf = table_render(
    Table::make(rows, [@core.Length(5), @core.Length(5)]).footer(footer),
    @core.Rect::new(0, 0, 15, 3),
    None,
  )
  assert_eq(
    buf,
    @core.Buffer::with_lines([
      "Cell1 Cell2    ", "               ", "Foot1 Foot2    ",
    ]),
  )
  let buf = table_render(
    Table::make(rows, [@core.Length(5), @core.Length(5)])
    .header(header)
    .footer(footer),
    @core.Rect::new(0, 0, 15, 3),
    None,
  )
  assert_eq(
    buf,
    @core.Buffer::with_lines([
      "Head1 Head2    ", "Cell1 Cell2    ", "Foot1 Foot2    ",
    ]),
  )
}

///|
/// 上游 render_with_header_margin/footer_margin/row_margin 喵。
test "Table 外边距" {
  let rows = [TableRow::of_strs(["Cell1", "Cell2"])]
  let two_rows = [
    TableRow::of_strs(["Cell1", "Cell2"]).bottom_margin(1),
    TableRow::of_strs(["Cell3", "Cell4"]),
  ]
  let header = TableRow::of_strs(["Head1", "Head2"]).bottom_margin(1)
  let footer = TableRow::of_strs(["Foot1", "Foot2"]).top_margin(1)
  let widths = [@core.Length(5), @core.Length(5)]
  let buf = table_render(
    Table::make(
      [
        TableRow::of_strs(["Cell1", "Cell2"]),
        TableRow::of_strs(["Cell3", "Cell4"]),
      ],
      widths,
    ).header(header),
    @core.Rect::new(0, 0, 15, 3),
    None,
  )
  assert_eq(
    buf,
    @core.Buffer::with_lines([
      "Head1 Head2    ", "               ", "Cell1 Cell2    ",
    ]),
  )
  let buf = table_render(
    Table::make(rows, widths).footer(footer),
    @core.Rect::new(0, 0, 15, 3),
    None,
  )
  assert_eq(
    buf,
    @core.Buffer::with_lines([
      "Cell1 Cell2    ", "               ", "Foot1 Foot2    ",
    ]),
  )
  let buf = table_render(
    Table::make(two_rows, widths),
    @core.Rect::new(0, 0, 15, 3),
    None,
  )
  assert_eq(
    buf,
    @core.Buffer::with_lines([
      "Cell1 Cell2    ", "               ", "Cell3 Cell4    ",
    ]),
  )
}

///|
/// 上游 render_with_tall_row：多行内容 + 固定高度 3 喵。
test "Table 高行" {
  let rows = [
    TableRow::of_strs(["Cell1", "Cell2"]),
    TableRow::new([
      TableCell::of_str("Cell3-Line1\nCell3-Line2\nCell3-Line3"),
      TableCell::of_str("Cell4-Line1\nCell4-Line2\nCell4-Line3"),
    ]).height(3),
  ]
  let buf = table_render(
    Table::make(rows, [@core.Length(11), @core.Length(11)]),
    @core.Rect::new(0, 0, 23, 3),
    None,
  )
  assert_eq(
    buf,
    @core.Buffer::with_lines([
      "Cell1       Cell2      ", "Cell3-Line1 Cell4-Line1", "Cell3-Line2 Cell4-Line2",
    ]),
  )
}

///|
/// 上游 render_with_alignment：单元格内容对齐喵。
test "Table 对齐" {
  let rows = [
    TableRow::new([TableCell::new(@core.Text::raw("Left").left_aligned())]),
    TableRow::new([TableCell::new(@core.Text::raw("Center").centered())]),
    TableRow::new([TableCell::new(@core.Text::raw("Right").right_aligned())]),
  ]
  let buf = table_render(
    Table::make(rows, [@core.Percentage(100)]),
    @core.Rect::new(0, 0, 10, 3),
    None,
  )
  assert_eq(
    buf,
    @core.Buffer::with_lines(["Left      ", "  Center  ", "     Right"]),
  )
}

///|
/// 上游 render_with_overflow / incorrect_width_count：越界不 panic 喵。
test "Table 越界不 panic" {
  let table = Table::make([], [@core.Min(20)])
    .header(
      TableRow::new([TableCell::new(@core.Text::raw("").right_aligned())]),
    )
    .footer(
      TableRow::new([TableCell::new(@core.Text::raw("").right_aligned())]),
    )
  ignore(table_render(table, @core.Rect::new(0, 0, 20, 3), None))
  let table = Table::make([TableRow::of_strs(["Row1", "Row2", "Row3"])], [
    @core.Length(10),
  ])
  ignore(
    table_render(
      table,
      @core.Rect::new(0, 0, 20, 3),
      Some(TableState::new().with_selected_column(Some(2))),
    ),
  )
}

///|
/// 上游 render_with_selected：行高亮铺满整行（含选择列）喵。
test "Table 选中行高亮" {
  let buf = table_render(
    Table::make(
      [
        TableRow::of_strs(["Cell1", "Cell2"]),
        TableRow::of_strs(["Cell3", "Cell4"]),
      ],
      [@core.Length(5), @core.Length(5)],
    )
    .row_highlight_style(@core.Style::new().red())
    .highlight_symbol_str(">>"),
    @core.Rect::new(0, 0, 15, 3),
    Some(TableState::new().with_selected(Some(0))),
  )
  let expected = @core.Buffer::with_lines([
    ">>Cell1 Cell2  ", "  Cell3 Cell4  ", "               ",
  ])
  for x in 0..<15 {
    match expected.mut_cell(x, 0) {
      Some(cell) => cell.set_fg(@core.Color::Red)
      None => ()
    }
  }
  @debug.assert_eq(buf, expected)
}

///|
/// 上游 render_with_selected_column：列高亮喵。
test "Table 选中列高亮" {
  let buf = table_render(
    Table::make(
      [
        TableRow::of_strs(["Cell1", "Cell2"]),
        TableRow::of_strs(["Cell3", "Cell4"]),
      ],
      [@core.Length(5), @core.Length(5)],
    )
    .column_highlight_style(@core.Style::new().blue())
    .highlight_symbol_str(">>"),
    @core.Rect::new(0, 0, 15, 3),
    Some(TableState::new().with_selected_column(Some(1))),
  )
  let expected = @core.Buffer::with_lines([
    "Cell1 Cell2    ", "Cell3 Cell4    ", "               ",
  ])
  for y in 0..<3 {
    for x in 6..<11 {
      match expected.mut_cell(x, y) {
        Some(cell) => cell.set_fg(@core.Color::Blue)
        None => ()
      }
    }
  }
  @debug.assert_eq(buf, expected)
}

///|
/// 上游 render_with_selected_cell / row_and_column / row_and_column_and_cell：
/// 行/列/单元格三层高亮叠加喵。
test "Table 选中单元格高亮矩阵" {
  let rows = [
    TableRow::of_strs(["Cell1", "Cell2", "Cell3"]),
    TableRow::of_strs(["Cell4", "Cell5", "Cell6"]),
    TableRow::of_strs(["Cell7", "Cell8", "Cell9"]),
  ]
  let widths = [@core.Length(5), @core.Length(5), @core.Length(5)]
  let red = @core.Style::new().red()
  let blue = @core.Style::new().blue()
  let green = @core.Style::new().green()
  // 仅单元格高亮：cell (1,2) 绿喵。
  let buf = table_render(
    Table::make(rows, widths)
    .highlight_symbol_str(">>")
    .cell_highlight_style(green),
    @core.Rect::new(0, 0, 20, 4),
    Some(TableState::new().with_selected_cell(Some((1, 2)))),
  )
  let expected = @core.Buffer::with_lines([
    "  Cell1 Cell2 Cell3 ", ">>Cell4 Cell5 Cell6 ", "  Cell7 Cell8 Cell9 ", "                    ",
  ])
  for x in 14..<19 {
    match expected.mut_cell(x, 1) {
      Some(cell) => cell.set_fg(@core.Color::Green)
      None => ()
    }
  }
  @debug.assert_eq(buf, expected)
  // 行 + 列（无单元格）：交集处列样式覆盖行样式喵。
  let buf = table_render(
    Table::make(rows, widths)
    .highlight_symbol_str(">>")
    .row_highlight_style(red)
    .column_highlight_style(blue),
    @core.Rect::new(0, 0, 20, 4),
    Some(TableState::new().with_selected(Some(1)).with_selected_column(Some(2))),
  )
  let expected = @core.Buffer::with_lines([
    "  Cell1 Cell2 Cell3 ", ">>Cell4 Cell5 Cell6 ", "  Cell7 Cell8 Cell9 ", "                    ",
  ])
  // 行 1 全红喵。
  for x in 0..<20 {
    match expected.mut_cell(x, 1) {
      Some(cell) => cell.set_fg(@core.Color::Red)
      None => ()
    }
  }
  // 列 2 全蓝（含表尾空行），交叠单元格蓝覆盖红喵。
  for y in 0..<4 {
    for x in 14..<19 {
      match expected.mut_cell(x, y) {
        Some(cell) => cell.set_fg(@core.Color::Blue)
        None => ()
      }
    }
  }
  @debug.assert_eq(buf, expected)
  // 行 + 列 + 单元格：交集处单元格绿覆盖喵。
  let buf = table_render(
    Table::make(rows, widths)
    .highlight_symbol_str(">>")
    .row_highlight_style(red)
    .column_highlight_style(blue)
    .cell_highlight_style(green),
    @core.Rect::new(0, 0, 20, 4),
    Some(TableState::new().with_selected(Some(1)).with_selected_column(Some(2))),
  )
  let expected = @core.Buffer::with_lines([
    "  Cell1 Cell2 Cell3 ", ">>Cell4 Cell5 Cell6 ", "  Cell7 Cell8 Cell9 ", "                    ",
  ])
  for x in 0..<20 {
    match expected.mut_cell(x, 1) {
      Some(cell) => cell.set_fg(@core.Color::Red)
      None => ()
    }
  }
  for y in 0..<4 {
    for x in 14..<19 {
      match expected.mut_cell(x, y) {
        Some(cell) => cell.set_fg(@core.Color::Blue)
        None => ()
      }
    }
  }
  for x in 14..<19 {
    match expected.mut_cell(x, 1) {
      Some(cell) => cell.set_fg(@core.Color::Green)
      None => ()
    }
  }
  @debug.assert_eq(buf, expected)
}

///|
/// 上游 render_with_selection_and_offset：100 行偏移 50 的滚动收敛
/// 矩阵（issue #1179 回归）喵。
test "Table 选中与偏移滚动" {
  let rows : Array[TableRow] = []
  for i in 0..<100 {
    rows.push(TableRow::of_strs([i.to_string()]))
  }
  let cases : Array[(Int?, Int, Array[String])] = [
    (None, 50, ["50", "51", "52", "53", "54"]),
    (Some(20), 20, ["20", "21", "22", "23", "24"]),
    (Some(49), 49, ["49", "50", "51", "52", "53"]),
    (Some(50), 50, ["50", "51", "52", "53", "54"]),
    (Some(54), 50, ["50", "51", "52", "53", "54"]),
    (Some(55), 51, ["51", "52", "53", "54", "55"]),
    (Some(80), 76, ["76", "77", "78", "79", "80"]),
  ]
  for case in cases {
    let table = Table::make(rows, [@core.Length(2)])
    let buf = @core.Buffer::empty(@core.Rect::new(0, 0, 2, 5))
    let state = TableState::new().with_offset(50).with_selected(case.0)
    table.render_stateful(@core.Rect::new(0, 0, 5, 5), buf, state)
    assert_eq(buf, @core.Buffer::with_lines(case.2))
    inspect(state.offset, content="\{case.1}")
  }
}

///|
/// 上游 column_count 参数矩阵（表头/行/表尾最大单元格数）喵。
test "Table 列数取最大" {
  let count_of = fn(
    header : Array[String],
    rows : Array[Array[String]],
    footer : Array[String],
  ) {
    let table = Table::make(rows.map(fn(r) { TableRow::of_strs(r) }), [])
      .header(TableRow::of_strs(header))
      .footer(TableRow::of_strs(footer))
    table.column_count()
  }
  inspect(count_of([], [], []), content="0")
  inspect(count_of(["H1", "H2"], [], []), content="2")
  inspect(count_of([], [["C1", "C2"], ["C1", "C2", "C3"]], []), content="3")
  inspect(count_of([], [], ["F1", "F2", "F3", "F4"]), content="4")
  inspect(
    count_of(["H1", "H2", "H3", "H4"], [["C1", "C2"], ["C1", "C2", "C3"]], [
      "F1", "F2",
    ]),
    content="4",
  )
  inspect(
    count_of(["H1", "H2"], [["C1", "C2"], ["C1", "C2", "C3", "C4"]], [
      "F1", "F2",
    ]),
    content="4",
  )
  inspect(
    count_of(["H1", "H2"], [["C1", "C2"], ["C1", "C2", "C3"]], [
      "F1", "F2", "F3", "F4",
    ]),
    content="4",
  )
}

///|
/// 上游 stylize + render_in_minimal_buffer + render_in_zero_size_buffer 喵。
test "Table 样式速记与极小缓冲" {
  assert_eq(
    Table::make([TableRow::new([TableCell::of_str("")])], [
      @core.Percentage(100),
    ]).style(@core.Style::new().black().on_white().bold().not_crossed_out()).style,
    @core.Style::new()
    .fg(@core.Color::Black)
    .bg(@core.Color::White)
    .add_modifier(@core.Modifier::bold())
    .remove_modifier(@core.Modifier::crossed_out()),
  )
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 1, 1))
  let table = Table::make(
      [
        TableRow::of_strs(["Cell1", "Cell2", "Cell3"]),
        TableRow::of_strs(["Cell4", "Cell5", "Cell6"]),
      ],
      [@core.Length(10), @core.Length(10), @core.Length(10)],
    )
    .header(TableRow::of_strs(["Header1", "Header2", "Header3"]))
    .footer(TableRow::of_strs(["Footer1", "Footer2", "Footer3"]))
  table.render(buffer.area, buffer)
  assert_eq(buffer, @core.Buffer::with_lines([" "]))
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 0, 0))
  table.render(buffer.area, buffer)
  inspect(buffer.cells.length(), content="0")
}
