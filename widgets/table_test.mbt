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
