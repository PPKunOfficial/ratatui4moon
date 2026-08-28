///|
/// List 单元测试：复刻 ratatui-v0.30.2 `widgets/list.rs`、
/// `list/item.rs`、`list/state.rs` 测试清单喵。
///
/// 登记"待复刻"：上游 `tests/list/` 集成测试目录（渲染黄金用例
/// 体量较大，随 Table/Scrollbar 轮一并补齐）、Stylize 链糖、
/// `FromIterator` 糖。

///|
/// 上游 selected：选中/取消选中喵。
test "ListState::selected" {
  let state = ListState::new()
  inspect(state.selected() is None, content="true")
  state.select(Some(1))
  @debug.assert_eq(state.selected(), Some(1))
  state.select(None)
  inspect(state.selected() is None, content="true")
}

///|
/// 上游 select / state_navigation：选中收敛与导航语义喵。
test "ListState::select 与导航" {
  let state = ListState::new()
  inspect(state.offset, content="0")
  state.select(Some(2))
  @debug.assert_eq(state.selected(), Some(2))
  inspect(state.offset, content="0")
  state.select(None)
  inspect(state.offset, content="0")
  // select(None) 归零偏移后重新选中喵
  state.select(Some(2))
  inspect(state.offset, content="0")
}

///|
/// 上游 state_navigation：first/previous/next/last 与滚动步进喵。
test "ListState 导航" {
  let state = ListState::new()
  state.select_first()
  @debug.assert_eq(state.selected(), Some(0))
  state.select_previous()
  @debug.assert_eq(state.selected(), Some(0))
  state.select_next()
  @debug.assert_eq(state.selected(), Some(1))
  state.select_previous()
  @debug.assert_eq(state.selected(), Some(0))
  state.select_last()
  @debug.assert_eq(state.selected(), Some(2147483647))
  state.select_next()
  @debug.assert_eq(state.selected(), Some(2147483647))
  state.select_previous()
  @debug.assert_eq(state.selected(), Some(2147483646))
  state.select_next()
  @debug.assert_eq(state.selected(), Some(2147483647))
  let state = ListState::new()
  state.select_next()
  @debug.assert_eq(state.selected(), Some(0))
  let state = ListState::new()
  state.select_previous()
  @debug.assert_eq(state.selected(), Some(2147483647))
  let state = ListState::new()
  state.select(Some(2))
  state.scroll_down_by(4)
  @debug.assert_eq(state.selected(), Some(6))
  let state = ListState::new()
  state.scroll_up_by(3)
  @debug.assert_eq(state.selected(), Some(0))
  state.select(Some(6))
  state.scroll_up_by(4)
  @debug.assert_eq(state.selected(), Some(2))
  state.scroll_up_by(4)
  @debug.assert_eq(state.selected(), Some(0))
}

///|
/// 上游 new_from_str：字符串构造喵。
test "ListItem::of_str" {
  let item = ListItem::of_str("Test item")
  @debug.assert_eq(item.content, @core.Text::raw("Test item"))
  inspect(item.style.is_default(), content="true")
}

///|
/// 上游 new_from_span：span 构造不拆行喵。
test "ListItem::of_span" {
  let span = @core.Span::styled("Test item", @core.Style::new().fg(Blue))
  let item = ListItem::of_span(span)
  @debug.assert_eq(item.content, @core.Text::of_span(span))
  inspect(item.style.is_default(), content="true")
}

///|
/// 上游 height / width 喵。
test "ListItem 高度与宽度" {
  let item = ListItem::of(@core.Text::raw("Hello\nWorld"))
  inspect(item.height(), content="2")
  inspect(item.width(), content="5")
}

///|
/// 上游 no_style：高亮符号间距预留但未选中为空白喵。
test "List 未选中渲染" {
  let list = List::new([ListItem::of_str("Item 1")])
    .highlight_symbol_str(">>")
    .highlight_spacing(HighlightSpacing::Always)
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 10, 1))
  List::render_stateful(list, buffer.area, buffer, ListState::new())
  @debug.assert_eq(buffer, @core.Buffer::with_lines(["  Item 1  "]))
}

///|
/// 上游 styled_text / styled_list_item：文本与项样式叠加喵。
test "List 样式叠加" {
  let text = @core.Text::raw("Item 1").patch_style(
    @core.Style::new().add_modifier(@core.Modifier::bold()),
  )
  let item = ListItem::of(text).style(
    @core.Style::new().add_modifier(@core.Modifier::italic()),
  )
  let list = List::new([item])
    .highlight_symbol_str(">>")
    .highlight_spacing(HighlightSpacing::Always)
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 10, 1))
  List::render_stateful(list, buffer.area, buffer, ListState::new())
  // 项级样式作用于整行（含高亮符号列），文本级样式只作用于文本喵
  let expected = @core.Buffer::with_lines(["  Item 1  "])
  expected.set_style(
    @core.Rect::new(0, 0, 10, 1),
    @core.Style::new().add_modifier(@core.Modifier::italic()),
  )
  expected.set_style(
    @core.Rect::new(2, 0, 8, 1),
    @core.Style::new().add_modifier(@core.Modifier::bold()),
  )
  @debug.assert_eq(buffer, expected)
}

///|
/// 上游 styled_highlight：选中项叠加高亮样式与符号喵。
test "List 选中高亮" {
  let text = @core.Text::raw("Item 1").patch_style(
    @core.Style::new().add_modifier(@core.Modifier::bold()),
  )
  let item = ListItem::of(text).style(
    @core.Style::new().add_modifier(@core.Modifier::italic()),
  )
  let state = ListState::new().with_selected(Some(0))
  let list = List::new([item])
    .highlight_symbol_str(">>")
    .highlight_style(@core.Style::new().fg(@core.Color::Red))
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 10, 1))
  List::render_stateful(list, buffer.area, buffer, state)
  let expected = @core.Buffer::with_lines([">>Item 1  "])
  expected.set_style(
    @core.Rect::new(0, 0, 10, 1),
    @core.Style::new()
    .fg(@core.Color::Red)
    .add_modifier(@core.Modifier::italic()),
  )
  expected.set_style(
    @core.Rect::new(2, 0, 8, 1),
    @core.Style::new()
    .fg(@core.Color::Red)
    .add_modifier(@core.Modifier::bold())
    .add_modifier(@core.Modifier::italic()),
  )
  @debug.assert_eq(buffer, expected)
}

///|
/// 上游 render_in_minimal_buffer：1×1 缓冲渲染不炸喵。
test "List 极小缓冲" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 1, 1))
  let state = ListState::new()
  let items = [
    ListItem::of_str("Item 1"),
    ListItem::of_str("Item 2"),
    ListItem::of_str("Item 3"),
  ]
  let list = List::new(items)
  List::render_stateful(list, buffer.area, buffer, state)
  @debug.assert_eq(buffer, @core.Buffer::with_lines(["I"]))
}

///|
/// 上游 render_in_zero_size_buffer：零尺寸缓冲不炸喵。
test "List 零尺寸缓冲" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 0, 0))
  let state = ListState::new()
  let items = [
    ListItem::of_str("Item 1"),
    ListItem::of_str("Item 2"),
    ListItem::of_str("Item 3"),
  ]
  let list = List::new(items)
  List::render_stateful(list, buffer.area, buffer, state)
  inspect(buffer.cells.length(), content="0")
}

///|
/// 空列表渲染取消选中（上游渲染语义：items.is_empty → select(None)）喵。
test "List 空列表取消选中" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 10, 3))
  let state = ListState::new().with_selected(Some(2))
  let list = List::new([])
  List::render_stateful(list, buffer.area, buffer, state)
  inspect(state.selected() is None, content="true")
}

///|
/// 选中项越界收敛到最后一项，偏移回写可视窗口首项喵。
test "List 选中越界收敛与偏移回写" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 10, 2))
  let state = ListState::new().with_selected(Some(9))
  let list = List::new([
    ListItem::of_str("Item 1"),
    ListItem::of_str("Item 2"),
    ListItem::of_str("Item 3"),
    ListItem::of_str("Item 4"),
  ])
  List::render_stateful(list, buffer.area, buffer, state)
  @debug.assert_eq(state.selected(), Some(3))
  @debug.assert_eq(state.offset, 2)
  @debug.assert_eq(
    buffer,
    @core.Buffer::with_lines(["Item 3    ", "Item 4    "]),
  )
}
