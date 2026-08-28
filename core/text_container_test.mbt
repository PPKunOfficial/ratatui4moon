///|
/// Text 单元测试：复刻 ratatui-v0.30.2 `text/text.rs` 测试清单喵。
///
/// 登记"待复刻"：`ToText`/`FromIterator`/`IntoIterator` 等 Rust
/// 语法层糖、Stylize 速记（`.green()` 等）。

///|
/// 上游 styled：styled 等价 raw + 样式字段喵。
test "Text::styled 等价性" {
  let style = Style::new().fg(Yellow).add_modifier(Modifier::italic())
  let styled_text = Text::styled("The first line\nThe second line", style)
  let raw_text = Text::raw("The first line\nThe second line").with_style(style)
  @debug.assert_eq(styled_text, raw_text)
}

///|
/// 上游 width：全行最大宽喵。
test "Text::width" {
  inspect(Text::raw("The first line\nThe second line").width(), content="15")
}

///|
/// 上游 height：行数喵。
test "Text::height" {
  inspect(Text::raw("The first line\nThe second line").height(), content="2")
}

///|
/// 上游 patch_style：文本级样式叠加喵。
test "Text::patch_style" {
  let style = Style::new().fg(Yellow).add_modifier(Modifier::italic())
  let style2 = Style::new().fg(Red).add_modifier(Modifier::underlined())
  let text = Text::styled("The first line\nThe second line", style).patch_style(
    style2,
  )
  let expected_style = Style::new()
    .fg(Red)
    .add_modifier(Modifier::italic().insert(Modifier::underlined()))
  @debug.assert_eq(
    text,
    Text::styled("The first line\nThe second line", expected_style),
  )
}

///|
/// 上游 reset_style：文本级样式复位喵。
test "Text::reset_style" {
  let style = Style::new().fg(Yellow).add_modifier(Modifier::italic())
  let text = Text::styled("The first line\nThe second line", style).reset_style()
  @debug.assert_eq(text.style, Style::reset())
}

///|
/// 上游 from_string：按换行拆行喵。
test "Text::raw 拆行" {
  @debug.assert_eq(Text::raw("The first line\nThe second line").lines, [
    Line::raw("The first line"),
    Line::raw("The second line"),
  ])
  // 空串得到单个空行（上游 raw("") 语义）喵
  @debug.assert_eq(Text::raw("").lines, [Line::raw("")])
  // 尾随换行不产生空尾行（对位 str::lines）喵
  @debug.assert_eq(Text::raw("trailing newline\n").lines, [
    Line::raw("trailing newline"),
  ])
}

///|
/// 上游 from_span：span 建文本不拆行喵。
test "Text::of_span" {
  let style = Style::new().fg(Yellow).add_modifier(Modifier::italic())
  let span = Span::styled("The first line\nThe second line", style)
  @debug.assert_eq(Text::of_span(span).lines, [Line::of_span(span)])
}

///|
/// 上游 from_line / from_vec_line喵。
test "Text::of_line 与 of_lines" {
  @debug.assert_eq(Text::of_line(Line::raw("The first line")).lines, [
    Line::raw("The first line"),
  ])
  @debug.assert_eq(
    Text::of_lines([Line::raw("The first line"), Line::raw("The second line")]).lines,
    [Line::raw("The first line"), Line::raw("The second line")],
  )
}

///|
/// 上游 add_line / add_text：拼接且文本级样式承自左值喵。
test "Text 拼接" {
  let added = Text::raw("Red")
    .with_style(Style::new().fg(Red))
    .add_line(Line::raw("Blue").with_style(Style::new().fg(Blue)))
  @debug.assert_eq(added, {
    alignment: None,
    style: Style::new().fg(Red),
    lines: [
      Line::raw("Red"),
      Line::raw("Blue").with_style(Style::new().fg(Blue)),
    ],
  })
  let added = Text::raw("Red")
    .with_style(Style::new().fg(Red))
    .op_add(Text::raw("Blue").with_style(Style::new().fg(Blue)))
  @debug.assert_eq(added, {
    alignment: None,
    style: Style::new().fg(Red),
    lines: [Line::raw("Red"), Line::raw("Blue")],
  })
}

///|
/// 上游 extend：追加多行喵。
test "Text::push_lines" {
  let text = Text::raw("The first line\nThe second line")
  text.push_lines([Line::raw("The third line"), Line::raw("The fourth line")])
  @debug.assert_eq(text.lines, [
    Line::raw("The first line"),
    Line::raw("The second line"),
    Line::raw("The third line"),
    Line::raw("The fourth line"),
  ])
}

///|
/// 上游 push_line / push_line_empty / push_span / push_span_empty喵。
test "Text::push_line 与 push_span" {
  let text = Text::raw("A")
  text.push_line(Line::raw("B"))
  text.push_line(Line::of_span(Span::raw("C")))
  text.push_line(Line::raw("D"))
  @debug.assert_eq(text.lines, [
    Line::raw("A"),
    Line::raw("B"),
    Line::raw("C"),
    Line::raw("D"),
  ])
  let empty = Text::empty()
  empty.push_line(Line::raw("Hello, world!"))
  @debug.assert_eq(empty.lines, [Line::raw("Hello, world!")])
  let text = Text::raw("A")
  text.push_span(Span::raw("B"))
  text.push_span(Span::raw("C"))
  inspect(text.lines.length(), content="1")
  let spans = text.lines[0].spans
  @debug.assert_eq(spans, [Span::raw("A"), Span::raw("B"), Span::raw("C")])
  let empty = Text::empty()
  empty.push_span(Span::raw("Hello, world!"))
  @debug.assert_eq(empty.lines, [Line::of_span(Span::raw("Hello, world!"))])
}

///|
/// 上游 display_raw_text / display_styled_text / display_text_from_vec /
/// display_extended_text：Display 按行以换行连接喵。
test "Text::to_display" {
  inspect(Text::raw("The first line").to_display(), content="The first line")
  inspect(
    Text::raw("The first line\nThe second line").to_display(),
    content="The first line\nThe second line",
  )
  inspect(
    Text::styled(
      "The first line\nThe second line",
      Style::new().fg(Yellow).add_modifier(Modifier::italic()),
    ).to_display(),
    content="The first line\nThe second line",
  )
  let text = Text::raw("The first line\nThe second line")
  text.push_lines([Line::raw("The third line"), Line::raw("The fourth line")])
  inspect(
    text.to_display(),
    content="The first line\nThe second line\nThe third line\nThe fourth line",
  )
}

///|
/// 上游 left/centered/right_aligned喵。
test "Text 对齐" {
  @debug.assert_eq(
    Text::raw("Hello, world!").left_aligned().alignment,
    Some(Left),
  )
  @debug.assert_eq(
    Text::raw("Hello, world!").centered().alignment,
    Some(Center),
  )
  @debug.assert_eq(
    Text::raw("Hello, world!").right_aligned().alignment,
    Some(Right),
  )
}

///|
/// 上游 render：单行落位喵。
test "Text::render 基础" {
  let text = Text::raw("foo")
  let area = Rect::new(0, 0, 5, 1)
  let buf = Buffer::empty(area)
  text.render(area, buf)
  @debug.assert_eq(buf, Buffer::with_lines(["foo  "]))
}

///|
/// 上游 render_out_of_bounds：完全出界零写入喵。
test "Text::render 越界" {
  let buf = Buffer::empty(Rect::new(0, 0, 10, 1))
  Text::raw("Hello, world!").render(Rect::new(20, 20, 10, 1), buf)
  @debug.assert_eq(buf, Buffer::empty(buf.area))
}

///|
/// 上游 render_right_aligned喵。
test "Text::render 右对齐" {
  let text = Text::raw("foo").right_aligned()
  let area = Rect::new(0, 0, 5, 1)
  let buf = Buffer::empty(area)
  text.render(area, buf)
  @debug.assert_eq(buf, Buffer::with_lines(["  foo"]))
}

///|
/// 上游 render_centered_odd / render_centered_even：奇偶宽度居中喵。
test "Text::render 居中" {
  let text = Text::raw("foo").centered()
  let buf = Buffer::empty(Rect::new(0, 0, 5, 1))
  text.render(Rect::new(0, 0, 5, 1), buf)
  @debug.assert_eq(buf, Buffer::with_lines([" foo "]))
  let text = Text::raw("foo").centered()
  let buf = Buffer::empty(Rect::new(0, 0, 6, 1))
  text.render(Rect::new(0, 0, 6, 1), buf)
  @debug.assert_eq(buf, Buffer::with_lines([" foo  "]))
}

///|
/// 上游 render_right_aligned_with_truncation /
/// render_centered_odd_with_truncation / render_centered_even_with_truncation：
/// 超宽时按对齐裁左喵。
test "Text::render 对齐截断" {
  let text = Text::raw("123456789").right_aligned()
  let buf = Buffer::empty(Rect::new(0, 0, 5, 1))
  text.render(Rect::new(0, 0, 5, 1), buf)
  @debug.assert_eq(buf, Buffer::with_lines(["56789"]))
  let text = Text::raw("123456789").centered()
  let buf = Buffer::empty(Rect::new(0, 0, 5, 1))
  text.render(Rect::new(0, 0, 5, 1), buf)
  @debug.assert_eq(buf, Buffer::with_lines(["34567"]))
  let text = Text::raw("123456789").centered()
  let buf = Buffer::empty(Rect::new(0, 0, 6, 1))
  text.render(Rect::new(0, 0, 6, 1), buf)
  @debug.assert_eq(buf, Buffer::with_lines(["234567"]))
}

///|
/// 上游 render_one_line_right：文本级对齐下发，行级对齐优先喵。
test "Text::render 行级对齐优先" {
  let text = Text::of_lines([Line::raw("foo"), Line::raw("bar").centered()]).right_aligned()
  let area = Rect::new(0, 0, 5, 2)
  let buf = Buffer::empty(area)
  text.render(area, buf)
  @debug.assert_eq(buf, Buffer::with_lines(["  foo", " bar "]))
}

///|
/// 上游 render_only_styles_line_area：span 样式只染内容区喵。
test "Text::render 样式范围" {
  let area = Rect::new(0, 0, 5, 1)
  let buf = Buffer::empty(area)
  Text::of_span(Span::styled("foo", Style::new().bg(Blue))).render(area, buf)
  let expected = Buffer::with_lines(["foo  "])
  expected.set_style(Rect::new(0, 0, 3, 1), Style::new().bg(Blue))
  @debug.assert_eq(buf, expected)
}

///|
/// 上游 render_truncates：区域小于文本时截断喵。
test "Text::render 截断" {
  let buf = Buffer::empty(Rect::new(0, 0, 6, 1))
  Text::of_span(Span::styled("foobar", Style::new().bg(Blue))).render(
    Rect::new(0, 0, 3, 1),
    buf,
  )
  let expected = Buffer::with_lines(["foo   "])
  expected.set_style(Rect::new(0, 0, 3, 1), Style::new().bg(Blue))
  @debug.assert_eq(buf, expected)
}
