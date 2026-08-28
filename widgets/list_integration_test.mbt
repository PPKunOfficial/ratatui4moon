///|
/// List 集成黄金用例：复刻 ratatui-v0.30.2 `ratatui/tests/widgets_list.rs`
/// 全部 8 条测试喵。
///
/// 上游经 Terminal/TestBackend/assert_buffer 驱动；terminal 会话层
/// 未复刻前以等价的"直渲染 + Buffer 全量比对"承载（被测行为一致）。
/// 上游 `assert_buffer_lines` 等价为本文件的 `assert_rows`。

///|
/// 渲染列表进指定尺寸的新缓冲喵。
fn render_list(
  list : List,
  state : ListState,
  width : Int,
  height : Int,
) -> @core.Buffer {
  let buf = @core.Buffer::empty(@core.Rect::new(0, 0, width, height))
  List::render_stateful(list, buf.area, buf, state)
  buf
}

///|
/// 渲染列表进既有缓冲的子区域喵。
fn render_list_in(
  list : List,
  state : ListState,
  buf : @core.Buffer,
  area : @core.Rect,
) -> Unit {
  List::render_stateful(list, area, buf, state)
}

///|
/// 上游 assert_buffer_lines：逐行符号串比对喵。
fn assert_rows(buf : @core.Buffer, expected : Array[String]) -> Unit raise {
  for y, row in expected {
    let out = StringBuilder()
    for x in 0..<buf.area.width {
      out.write_string(buf.get(x, y).symbol())
    }
    assert_eq(out.to_string().trim_end().to_owned(), row)
  }
}

///|
/// 上游 list_should_shows_the_length：len/is_empty 喵。
test "List 长度与判空" {
  let list = List::new([
    ListItem::of_str("Item 1"),
    ListItem::of_str("Item 2"),
    ListItem::of_str("Item 3"),
  ])
  inspect(list.len(), content="3")
  inspect(list.is_empty(), content="false")
  let empty_list = List::new([])
  inspect(empty_list.len(), content="0")
  inspect(empty_list.is_empty(), content="true")
}

///|
/// 上游 widgets_list_should_highlight_the_selected_item：
/// 选中项高亮背景铺满整行喵。
test "List 选中项高亮" {
  let items = [
    ListItem::of_str("Item 1"),
    ListItem::of_str("Item 2"),
    ListItem::of_str("Item 3"),
  ]
  let state = ListState::new().with_selected(Some(1))
  let list = List::new(items)
    .highlight_style(@core.Style::new().bg(@core.Color::Yellow))
    .highlight_symbol_str(">> ")
  let buf = render_list(list, state, 10, 3)
  let expected = @core.Buffer::with_lines([
    "   Item 1 ", ">> Item 2 ", "   Item 3 ",
  ])
  for x in 0..<10 {
    match expected.mut_cell(x, 1) {
      Some(cell) => cell.set_bg(@core.Color::Yellow)
      None => ()
    }
  }
  @debug.assert_eq(buf, expected)
}

///|
/// 上游 widgets_list_should_highlight_the_selected_item_wide_symbol：
/// 宽符号列宽按显示宽度计（▶ 为 Ambiguous 宽 1）喵。
test "List 宽高亮符号" {
  let items = [
    ListItem::of_str("Item 1"),
    ListItem::of_str("Item 2"),
    ListItem::of_str("Item 3"),
  ]
  let list = List::new(items)
    .highlight_style(@core.Style::new().bg(@core.Color::Yellow))
    .highlight_symbol_str("▶  ")
  let state = ListState::new().with_selected(Some(1))
  let buf = render_list(list, state, 10, 3)
  let expected = @core.Buffer::with_lines([
    "   Item 1 ", "▶  Item 2 ", "   Item 3 ",
  ])
  for x in 0..<10 {
    match expected.mut_cell(x, 1) {
      Some(cell) => cell.set_bg(@core.Color::Yellow)
      None => ()
    }
  }
  @debug.assert_eq(buf, expected)
}

///|
/// 上游 widgets_list_should_truncate_items：右边框内截断，
/// 选中与否决定符号列是否预留喵。
test "List 截断与右边框" {
  let cases = [
    (Some(0), [">> A ve│", "   A ve│"]),
    (None, ["A very │", "A very │"]),
  ]
  for case in cases {
    let (selected, rows) = case
    let state = ListState::new().with_selected(selected)
    let list = List::new([
        ListItem::of_str("A very long line"),
        ListItem::of_str("A very long line"),
      ])
      .block(Block::new().borders(Borders::right()))
      .highlight_symbol_str(">> ")
    let buf = @core.Buffer::empty(@core.Rect::new(0, 0, 10, 2))
    render_list_in(list, state, buf, @core.Rect::new(0, 0, 8, 2))
    assert_rows(buf, rows)
  }
}

///|
/// 上游 widgets_list_should_clamp_offset_if_items_are_removed：
/// 条目减少后偏移钳制喵。
test "List 偏移钳制" {
  let state = ListState::new()
  // 6 条目选中最后一条：偏移收敛到 2 喵
  state.select(Some(5))
  let items = [
    ListItem::of_str("Item 0"),
    ListItem::of_str("Item 1"),
    ListItem::of_str("Item 2"),
    ListItem::of_str("Item 3"),
    ListItem::of_str("Item 4"),
    ListItem::of_str("Item 5"),
  ]
  let buf = render_list(
    List::new(items).highlight_symbol_str(">> "),
    state,
    10,
    4,
  )
  assert_rows(buf, ["   Item 2", "   Item 3", "   Item 4", ">> Item 5"])
  // 只剩 1 条目：偏移钳制，选中项可见；上游双缓冲下第二帧起始于净缓冲喵
  state.select(Some(1))
  let buf = render_list(
    List::new([ListItem::of_str("Item 3")]).highlight_symbol_str(">> "),
    state,
    10,
    4,
  )
  assert_rows(buf, [">> Item 3", "", "", ""])
}

///|
/// 上游 widgets_list_should_display_multiline_items：多行条目与
/// 高亮背景铺满条目全部行喵。
test "List 多行条目高亮" {
  let items = [
    ListItem::of(
      @core.Text::of_lines([
        @core.Line::raw("Item 1"),
        @core.Line::raw("Item 1a"),
      ]),
    ),
    ListItem::of(
      @core.Text::of_lines([
        @core.Line::raw("Item 2"),
        @core.Line::raw("Item 2b"),
      ]),
    ),
    ListItem::of(
      @core.Text::of_lines([
        @core.Line::raw("Item 3"),
        @core.Line::raw("Item 3c"),
      ]),
    ),
  ]
  let state = ListState::new().with_selected(Some(1))
  let list = List::new(items)
    .highlight_style(@core.Style::new().bg(@core.Color::Yellow))
    .highlight_symbol_str(">> ")
  let buf = render_list(list, state, 10, 6)
  let expected = @core.Buffer::with_lines([
    "   Item 1 ", "   Item 1a", ">> Item 2 ", "   Item 2b", "   Item 3 ", "   Item 3c",
  ])
  for x in 0..<10 {
    for y in [2, 3] {
      match expected.mut_cell(x, y) {
        Some(cell) => cell.set_bg(@core.Color::Yellow)
        None => ()
      }
    }
  }
  @debug.assert_eq(buf, expected)
}

///|
/// 上游 widgets_list_should_repeat_highlight_symbol：多行条目的
/// 每一行都重复高亮符号喵。
test "List 重复高亮符号" {
  let items = [
    ListItem::of(
      @core.Text::of_lines([
        @core.Line::raw("Item 1"),
        @core.Line::raw("Item 1a"),
      ]),
    ),
    ListItem::of(
      @core.Text::of_lines([
        @core.Line::raw("Item 2"),
        @core.Line::raw("Item 2b"),
      ]),
    ),
    ListItem::of(
      @core.Text::of_lines([
        @core.Line::raw("Item 3"),
        @core.Line::raw("Item 3c"),
      ]),
    ),
  ]
  let state = ListState::new().with_selected(Some(1))
  let list = List::new(items)
    .highlight_style(@core.Style::new().bg(@core.Color::Yellow))
    .highlight_symbol_str(">> ")
    .repeat_highlight_symbol(true)
  let buf = render_list(list, state, 10, 6)
  let expected = @core.Buffer::with_lines([
    "   Item 1 ", "   Item 1a", ">> Item 2 ", ">> Item 2b", "   Item 3 ", "   Item 3c",
  ])
  for x in 0..<10 {
    for y in [2, 3] {
      match expected.mut_cell(x, y) {
        Some(cell) => cell.set_bg(@core.Color::Yellow)
        None => ()
      }
    }
  }
  @debug.assert_eq(buf, expected)
}

///|
/// 上游 widget_list_should_not_ignore_empty_string_items：空条目占行喵。
test "List 空条目" {
  let items = [
    ListItem::of_str("Item 1"),
    ListItem::of_str(""),
    ListItem::of_str(""),
    ListItem::of_str("Item 4"),
  ]
  let list = List::new(items)
    .style(@core.Style::new())
    .highlight_style(@core.Style::new())
  let buf = render_list(list, ListState::new(), 6, 4)
  assert_rows(buf, ["Item 1", "", "", "Item 4"])
}

///|
/// 上游 widgets_list_enable_always_highlight_spacing（7 组参数化）：
/// 选中状态 × 间距策略决定符号列喵。
test "List 高亮间距策略矩阵" {
  let cases = [
    (
      None,
      HighlightSpacing::WhenSelected,
      [
        "┌─────────────┐", "│Item 1       │", "│Item 1a      │",
        "│Item 2       │", "│Item 2b      │", "│Item 3       │", "│Item 3c      │",
        "└─────────────┘",
      ],
    ),
    (
      None,
      HighlightSpacing::Always,
      [
        "┌─────────────┐", "│   Item 1    │", "│   Item 1a   │",
        "│   Item 2    │", "│   Item 2b   │", "│   Item 3    │", "│   Item 3c   │",
        "└─────────────┘",
      ],
    ),
    (
      None,
      HighlightSpacing::Never,
      [
        "┌─────────────┐", "│Item 1       │", "│Item 1a      │",
        "│Item 2       │", "│Item 2b      │", "│Item 3       │", "│Item 3c      │",
        "└─────────────┘",
      ],
    ),
    (
      Some(0),
      HighlightSpacing::WhenSelected,
      [
        "┌─────────────┐", "│>> Item 1    │", "│   Item 1a   │",
        "│   Item 2    │", "│   Item 2b   │", "│   Item 3    │", "│   Item 3c   │",
        "└─────────────┘",
      ],
    ),
    (
      Some(0),
      HighlightSpacing::Always,
      [
        "┌─────────────┐", "│>> Item 1    │", "│   Item 1a   │",
        "│   Item 2    │", "│   Item 2b   │", "│   Item 3    │", "│   Item 3c   │",
        "└─────────────┘",
      ],
    ),
    (
      Some(0),
      HighlightSpacing::Never,
      [
        "┌─────────────┐", "│Item 1       │", "│Item 1a      │",
        "│Item 2       │", "│Item 2b      │", "│Item 3       │", "│Item 3c      │",
        "└─────────────┘",
      ],
    ),
  ]
  for case in cases {
    let (selected, spacing, rows) = case
    let state = ListState::new().with_selected(selected)
    let list = List::new([
        ListItem::of(
          @core.Text::of_lines([
            @core.Line::raw("Item 1"),
            @core.Line::raw("Item 1a"),
          ]),
        ),
        ListItem::of(
          @core.Text::of_lines([
            @core.Line::raw("Item 2"),
            @core.Line::raw("Item 2b"),
          ]),
        ),
        ListItem::of(
          @core.Text::of_lines([
            @core.Line::raw("Item 3"),
            @core.Line::raw("Item 3c"),
          ]),
        ),
      ])
      .block(Block::bordered())
      .highlight_symbol_str(">> ")
      .highlight_spacing(spacing)
    let buf = render_list(list, state, 15, 8)
    assert_rows(buf, rows)
  }
}
