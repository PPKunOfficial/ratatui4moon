///|
/// Tabs 单元测试：复刻 ratatui-v0.30.2 `widgets/tabs.rs` 测试清单喵。

///|
/// 上游 test_case：以给定区域新建缓冲渲染比对喵。
fn tabs_test_case(
  tabs : Tabs,
  area : @core.Rect,
  expected : @core.Buffer,
) -> Unit raise {
  let buffer = @core.Buffer::empty(area)
  tabs.render(area, buffer)
  @debug.assert_eq(buffer, expected)
}

///|
/// 上游 render_new：缺省分隔符/内边距/首标签选中喵。
test "Tabs::new 渲染" {
  let tabs = Tabs::of_strs(["Tab1", "Tab2", "Tab3", "Tab4"])
  let expected = @core.Buffer::with_lines([
    " Tab1 │ Tab2 │ Tab3 │ Tab4    ",
  ])
  expected.set_style(
    @core.Rect::new(1, 0, 4, 1),
    tabs_default_highlight_style(),
  )
  tabs_test_case(tabs, @core.Rect::new(0, 0, 30, 1), expected)
}

///|
/// 上游 render_no_padding：无内边距喵。
test "Tabs 无内边距" {
  let tabs = Tabs::of_strs(["Tab1", "Tab2", "Tab3", "Tab4"]).padding_str("", "")
  let expected = @core.Buffer::with_lines([
    "Tab1│Tab2│Tab3│Tab4           ",
  ])
  expected.set_style(
    @core.Rect::new(0, 0, 4, 1),
    tabs_default_highlight_style(),
  )
  tabs_test_case(tabs, @core.Rect::new(0, 0, 30, 1), expected)
}

///|
/// 上游 render_left_padding：左内边距喵。
test "Tabs 左内边距" {
  let tabs = Tabs::of_strs(["Tab1", "Tab2", "Tab3", "Tab4"]).padding_left_str(
    "---",
  )
  let expected = @core.Buffer::with_lines([
    "---Tab1 │---Tab2 │---Tab3 │---Tab4      ",
  ])
  expected.set_style(
    @core.Rect::new(3, 0, 4, 1),
    tabs_default_highlight_style(),
  )
  tabs_test_case(tabs, @core.Rect::new(0, 0, 40, 1), expected)
}

///|
/// 上游 render_right_padding：右内边距喵。
test "Tabs 右内边距" {
  let tabs = Tabs::of_strs(["Tab1", "Tab2", "Tab3", "Tab4"]).padding_right_str(
    "++",
  )
  let expected = @core.Buffer::with_lines([
    " Tab1++│ Tab2++│ Tab3++│ Tab4++         ",
  ])
  expected.set_style(
    @core.Rect::new(1, 0, 4, 1),
    tabs_default_highlight_style(),
  )
  tabs_test_case(tabs, @core.Rect::new(0, 0, 40, 1), expected)
}

///|
/// 上游 render_more_padding：两侧内边距 + 区域截断喵。
test "Tabs 两侧内边距" {
  let tabs = Tabs::of_strs(["Tab1", "Tab2", "Tab3", "Tab4"]).padding_str(
    "---", "++",
  )
  let expected = @core.Buffer::with_lines([
    "---Tab1++│---Tab2++│---Tab3++│",
  ])
  expected.set_style(
    @core.Rect::new(3, 0, 4, 1),
    tabs_default_highlight_style(),
  )
  tabs_test_case(tabs, @core.Rect::new(0, 0, 30, 1), expected)
}

///|
/// 上游 render_with_block：边框内渲染喵。
test "Tabs 带边框块" {
  let tabs = Tabs::of_strs(["Tab1", "Tab2", "Tab3", "Tab4"]).block(
    Block::bordered().title_str("Tabs"),
  )
  let expected = @core.Buffer::with_lines([
    "┌Tabs────────────────────────┐",
    "│ Tab1 │ Tab2 │ Tab3 │ Tab4  │", "└────────────────────────────┘",
  ])
  expected.set_style(
    @core.Rect::new(2, 1, 4, 1),
    tabs_default_highlight_style(),
  )
  tabs_test_case(tabs, @core.Rect::new(0, 0, 30, 3), expected)
}

///|
/// 上游 render_style：基础样式铺满喵。
test "Tabs 基础样式" {
  let tabs = Tabs::of_strs(["Tab1", "Tab2", "Tab3", "Tab4"]).style(
    @core.Style::new().fg(@core.Color::Red),
  )
  let expected = @core.Buffer::with_lines([
    " Tab1 │ Tab2 │ Tab3 │ Tab4    ",
  ])
  expected.set_style(
    @core.Rect::new(0, 0, 30, 1),
    @core.Style::new().fg(@core.Color::Red),
  )
  expected.set_style(
    @core.Rect::new(1, 0, 4, 1),
    tabs_default_highlight_style().fg(@core.Color::Red),
  )
  tabs_test_case(tabs, @core.Rect::new(0, 0, 30, 1), expected)
}

///|
/// 上游 render_select：选中切换/越界/取消喵。
test "Tabs::select 渲染" {
  let tabs = Tabs::of_strs(["Tab1", "Tab2", "Tab3", "Tab4"])
  // 第一个标签选中喵
  let expected = @core.Buffer::with_lines([
    " Tab1 │ Tab2 │ Tab3 │ Tab4    ",
  ])
  expected.set_style(
    @core.Rect::new(1, 0, 4, 1),
    tabs_default_highlight_style(),
  )
  tabs_test_case(tabs.select(Some(0)), @core.Rect::new(0, 0, 30, 1), expected)
  // 第二个标签选中喵
  let expected = @core.Buffer::with_lines([
    " Tab1 │ Tab2 │ Tab3 │ Tab4    ",
  ])
  expected.set_style(
    @core.Rect::new(8, 0, 4, 1),
    tabs_default_highlight_style(),
  )
  tabs_test_case(tabs.select(Some(1)), @core.Rect::new(0, 0, 30, 1), expected)
  // 最后一个标签选中喵
  let expected = @core.Buffer::with_lines([
    " Tab1 │ Tab2 │ Tab3 │ Tab4    ",
  ])
  expected.set_style(
    @core.Rect::new(22, 0, 4, 1),
    tabs_default_highlight_style(),
  )
  tabs_test_case(tabs.select(Some(3)), @core.Rect::new(0, 0, 30, 1), expected)
  // 越界：无选中喵
  let expected = @core.Buffer::with_lines([
    " Tab1 │ Tab2 │ Tab3 │ Tab4    ",
  ])
  tabs_test_case(tabs.select(Some(4)), @core.Rect::new(0, 0, 30, 1), expected)
  // 取消选中喵
  let expected = @core.Buffer::with_lines([
    " Tab1 │ Tab2 │ Tab3 │ Tab4    ",
  ])
  tabs_test_case(tabs.select(None), @core.Rect::new(0, 0, 30, 1), expected)
}

///|
/// 上游 render_style_and_selected：基础样式 + 高亮样式叠加喵。
test "Tabs 样式与选中叠加" {
  let tabs = Tabs::of_strs(["Tab1", "Tab2", "Tab3", "Tab4"])
    .style(@core.Style::new().fg(@core.Color::Red))
    .highlight_style(@core.Style::new().underlined())
    .select(Some(0))
  let expected = @core.Buffer::with_lines([
    " Tab1 │ Tab2 │ Tab3 │ Tab4    ",
  ])
  expected.set_style(
    @core.Rect::new(0, 0, 30, 1),
    @core.Style::new().fg(@core.Color::Red),
  )
  expected.set_style(
    @core.Rect::new(1, 0, 4, 1),
    @core.Style::new().fg(@core.Color::Red).underlined(),
  )
  tabs_test_case(tabs, @core.Rect::new(0, 0, 30, 1), expected)
}

///|
/// 上游 render_divider：自定义分隔符喵。
test "Tabs::divider" {
  let tabs = Tabs::of_strs(["Tab1", "Tab2", "Tab3", "Tab4"]).divider_str("--")
  let expected = @core.Buffer::with_lines([" Tab1 -- Tab2 -- Tab3 -- Tab4 "])
  expected.set_style(
    @core.Rect::new(1, 0, 4, 1),
    tabs_default_highlight_style(),
  )
  tabs_test_case(tabs, @core.Rect::new(0, 0, 30, 1), expected)
}

///|
/// 上游 render_in_minimal_buffer：1×1 缓冲渲染不炸喵。
test "Tabs 极小缓冲" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 1, 1))
  let tabs = Tabs::of_strs(["Tab1", "Tab2", "Tab3", "Tab4"])
    .select(Some(1))
    .divider_str("|")
  tabs.render(buffer.area, buffer)
  @debug.assert_eq(buffer, @core.Buffer::with_lines([" "]))
}

///|
/// 上游 render_in_zero_size_buffer：零尺寸缓冲不炸喵。
test "Tabs 零尺寸缓冲" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 0, 0))
  let tabs = Tabs::of_strs(["Tab1", "Tab2", "Tab3", "Tab4"])
  tabs.render(buffer.area, buffer)
  inspect(buffer.cells.length(), content="0")
}

///|
/// titles 替换时选中索引收敛进界内（上游 `Tabs::titles` 语义）喵。
test "Tabs::titles 选中收敛" {
  let tabs = Tabs::of_strs(["Tab1", "Tab2", "Tab3"]).select(Some(2))
  let tabs = tabs.titles([@core.Line::raw("Only")])
  @debug.assert_eq(tabs.selected, Some(0))
  let tabs = Tabs::of_strs(["Tab1", "Tab2"]).titles([])
  inspect(tabs.selected is None, content="true")
}
